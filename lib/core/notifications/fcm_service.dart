import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:dio/dio.dart';
import '../../../api/api_config.dart';
import '../../../api/endpoints_notifications.dart';
import '../auth/services/session_storage.dart';

/// Handler para notificaciones cuando la app está en background
/// Debe ser una función top-level o estática
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('📱 Notificación recibida en background: ${message.messageId}');
  print('Título: ${message.notification?.title}');
  print('Cuerpo: ${message.notification?.body}');
  print('Data: ${message.data}');
}

class FCMService {
  static final FCMService _instance = FCMService._internal();
  factory FCMService() => _instance;
  FCMService._internal();

  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();
  final Dio _dio = Dio();
  
  bool _initialized = false;
  Function(Map<String, dynamic>)? _onNotificationTapped;

  /// Inicializar el servicio FCM
  Future<void> initialize() async {
    if (_initialized) {
      print('FCMService ya está inicializado');
      return;
    }

    try {
      // Configurar notificaciones locales para Android
      await _initializeLocalNotifications();

      // Solicitar permisos
      NotificationSettings settings = await _fcm.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        print('✅ Permisos de notificaciones concedidos');

        // Configurar handler para cuando la app está en background
        FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

        // Configurar handler para cuando la app está en foreground
        FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

        // Configurar handler para cuando se toca una notificación (app abierta)
        FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);

        // Verificar si la app se abrió desde una notificación (app cerrada)
        RemoteMessage? initialMessage = await _fcm.getInitialMessage();
        if (initialMessage != null) {
          _handleNotificationTap(initialMessage);
        }

        // Escuchar cuando el token se renueva
        _fcm.onTokenRefresh.listen(_registerTokenInBackend);

        _initialized = true;
        print('✅ FCMService inicializado correctamente');
      } else {
        print('❌ Permisos de notificaciones denegados');
      }
    } catch (e) {
      print('❌ Error inicializando FCMService: $e');
    }
  }

  /// Inicializar notificaciones locales para Android
  Future<void> _initializeLocalNotifications() async {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: DarwinInitializationSettings(),
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        if (response.payload != null) {
          // Manejar tap en notificación local
          print('Notificación local tocada: ${response.payload}');
        }
      },
    );

    // Crear canal de notificación para Android
    if (Platform.isAndroid) {
      const AndroidNotificationChannel channel = AndroidNotificationChannel(
        'high_importance_channel',
        'Notificaciones Importantes',
        description: 'Este canal se usa para notificaciones importantes',
        importance: Importance.high,
      );

      await _localNotifications
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(channel);
    }
  }

  /// Obtener token FCM y registrarlo en el backend
  Future<void> registerToken() async {
    try {
      final session = await SessionStorage.getSession();
      if (session == null) {
        print('⚠️ No hay sesión activa, no se puede registrar token');
        return;
      }

      // Obtener token FCM
      String? fcmToken = await _fcm.getToken();
      if (fcmToken == null) {
        print('⚠️ No se pudo obtener token FCM');
        return;
      }

      print('📱 Token FCM obtenido: ${fcmToken.substring(0, 20)}...');

      // Obtener token JWT de la sesión
      final token = session['token'] ??
          session['access_token'] ??
          session['accessToken'];

      if (token == null) {
        print('⚠️ No hay token JWT en la sesión');
        return;
      }

      // Detectar plataforma
      String plataforma = Platform.isIOS ? 'ios' : 'android';

      // Registrar token en el backend
      await _registerTokenInBackend(fcmToken, token, plataforma);
    } catch (e) {
      print('❌ Error registrando token FCM: $e');
    }
  }

  /// Registrar token en el backend
  Future<void> _registerTokenInBackend(String fcmToken, [String? jwtToken, String? plataforma]) async {
    try {
      // Si no se proporcionan parámetros, obtenerlos de la sesión
      if (jwtToken == null || plataforma == null) {
        final session = await SessionStorage.getSession();
        if (session == null) return;

        jwtToken = session['token'] ??
            session['access_token'] ??
            session['accessToken'];
        
        if (jwtToken == null) return;
        
        plataforma = Platform.isIOS ? 'ios' : 'android';
      }

      final response = await _dio.post(
        '${ApiConfig.baseUrl}${ApiConfig.apiVersion}${EndpointsNotifications.registerToken}',
        data: {
          'device_token': fcmToken,
          'plataforma': plataforma,
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer $jwtToken',
            'Content-Type': 'application/json',
          },
        ),
      );

      print('✅ Token FCM registrado en backend: ${response.data}');
    } catch (e) {
      print('❌ Error registrando token FCM en backend: $e');
      if (e is DioException) {
        print('Status: ${e.response?.statusCode}');
        print('Error: ${e.response?.data}');
      }
    }
  }

  /// Desregistrar tokens (útil para logout)
  Future<void> unregisterToken() async {
    try {
      final session = await SessionStorage.getSession();
      if (session == null) {
        print('⚠️ No hay sesión activa');
        return;
      }

      final token = session['token'] ??
          session['access_token'] ??
          session['accessToken'];

      if (token == null) {
        print('⚠️ No hay token JWT en la sesión');
        return;
      }

      await _dio.post(
        '${ApiConfig.baseUrl}${ApiConfig.apiVersion}${EndpointsNotifications.unregisterToken}',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      print('✅ Tokens FCM desregistrados del backend');
    } catch (e) {
      print('❌ Error desregistrando tokens FCM: $e');
    }
  }

  /// Manejar notificación cuando la app está en foreground
  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    print('📱 Notificación recibida en foreground: ${message.notification?.title}');
    print('Cuerpo: ${message.notification?.body}');
    print('Data: ${message.data}');

    // Mostrar notificación local
    if (message.notification != null) {
      await _showLocalNotification(message);
    }
  }

  /// Mostrar notificación local
  Future<void> _showLocalNotification(RemoteMessage message) async {
    final notification = message.notification;
    if (notification == null) return;

    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'high_importance_channel',
      'Notificaciones Importantes',
      channelDescription: 'Este canal se usa para notificaciones importantes',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      message.hashCode,
      notification.title,
      notification.body,
      details,
      payload: message.data.toString(),
    );
  }

  /// Manejar cuando se toca una notificación
  void _handleNotificationTap(RemoteMessage message) {
    print('👆 Notificación tocada: ${message.data}');
    
    // Llamar al callback si está configurado
    if (_onNotificationTapped != null) {
      _onNotificationTapped!(message.data);
    } else {
      // Si no hay callback configurado, intentar navegar automáticamente
      _navigateFromNotification(message.data);
    }
  }

  /// Navegar automáticamente basado en el tipo de notificación
  void _navigateFromNotification(Map<String, dynamic> data) {
    final tipo = data['tipo'] as String?;
    
    if (tipo == null) {
      print('⚠️ Tipo de notificación no especificado');
      return;
    }

    switch (tipo) {
      case 'limpieza_asignada':
      case 'limpieza_completada':
        final limpiezaId = data['limpieza_id'] as String?;
        if (limpiezaId != null) {
          print('📱 Navegando a limpieza_detail con ID: $limpiezaId (tipo: $tipo)');
          // La navegación real se manejará desde el callback configurado
          // o desde el widget que escuche el callback
        }
        break;
      case 'transporte_asignado':
      case 'transporte_iniciado':
      case 'transporte_terminado':
        final servicioId = data['servicio_id'] as String?;
        if (servicioId != null) {
          if (tipo == 'transporte_asignado') {
            print('📱 Navegando a transportista_detail con ID: $servicioId (tipo: $tipo)');
          } else {
            print('📱 Navegando a transporte_detail con ID: $servicioId (tipo: $tipo)');
          }
          // La navegación real se manejará desde el callback configurado
          // o desde el widget que escuche el callback
        }
        break;
      case 'mantenimiento_asignado':
        final mantenimientoId = data['mantenimiento_id'] as String?;
        if (mantenimientoId != null) {
          print('📱 Navegando a mantenimiento_detail con ID: $mantenimientoId (tipo: $tipo)');
          // La navegación real se manejará desde el callback configurado
          // o desde el widget que escuche el callback
        }
        break;
      default:
        print('⚠️ Tipo de notificación desconocido: $tipo');
    }
  }

  /// Configurar callback para cuando se toca una notificación
  /// El callback recibirá un Map con los datos de la notificación
  /// Ejemplo: {'tipo': 'limpieza_asignada', 'limpieza_id': '123', ...}
  void setOnNotificationTapped(Function(Map<String, dynamic>) callback) {
    _onNotificationTapped = callback;
  }

  /// Obtener token FCM actual (sin registrarlo)
  Future<String?> getToken() async {
    try {
      return await _fcm.getToken();
    } catch (e) {
      print('❌ Error obteniendo token FCM: $e');
      return null;
    }
  }
}


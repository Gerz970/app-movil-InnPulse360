import 'package:app_movil_innpulse/features/pisos/controllers/piso_controller.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'features/login/login_screen.dart';
import 'core/auth/controllers/auth_controller.dart';
import 'core/sidebar/sidebar_controller.dart';
import 'core/notifications/fcm_service.dart';
import 'features/hoteles/controllers/hotel_controller.dart';
import 'features/clientes/controllers/cliente_controller.dart';
import 'features/incidencias/controllers/incidencia_controller.dart';
import 'features/perfil/controllers/perfil_controller.dart';
import 'features/limpieza/controllers/limpieza_controller.dart';
import 'features/limpieza/limpieza_detail_screen.dart';
import 'features/reservas/controllers/reservas_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inicializar Firebase
  try {
    await Firebase.initializeApp();
    print('✅ Firebase inicializado correctamente');
    
    // Inicializar FCMService (solo configuración, no registra token aún)
    final fcmService = FCMService();
    await fcmService.initialize();
    
    // Configurar callback para navegación desde notificaciones
    fcmService.setOnNotificationTapped((data) {
      print('📱 Callback de notificación ejecutado: $data');
      _handleNotificationNavigation(data);
    });
    
    print('✅ FCMService inicializado');
  } catch (e) {
    print('⚠️ Error inicializando Firebase: $e');
    // Continuar aunque falle Firebase (para desarrollo sin Firebase configurado)
  }
  
  runApp(const MyApp());
}

// Global key para navegación desde notificaciones
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

/// Maneja la navegación cuando se toca una notificación
void _handleNotificationNavigation(Map<String, dynamic> data) {
  final tipo = data['tipo'] as String?;
  
  if (tipo == null) {
    print('⚠️ Tipo de notificación no especificado');
    return;
  }

  final navigator = navigatorKey.currentState;
  if (navigator == null) {
    print('⚠️ Navigator no disponible aún');
    return;
  }

  switch (tipo) {
    case 'limpieza_asignada':
    case 'limpieza_completada':
      final limpiezaIdStr = data['limpieza_id'] as String?;
      if (limpiezaIdStr != null) {
        final limpiezaId = int.tryParse(limpiezaIdStr);
        if (limpiezaId != null) {
          print('📱 Navegando a limpieza_detail con ID: $limpiezaId');
          _navigateToLimpiezaDetail(navigator, limpiezaId);
        } else {
          print('⚠️ limpieza_id no es un número válido: $limpiezaIdStr');
        }
      } else {
        print('⚠️ limpieza_id no encontrado en datos de notificación');
      }
      break;
    default:
      print('⚠️ Tipo de notificación desconocido: $tipo');
  }
}

/// Navega a la pantalla de detalle de limpieza cargando primero los datos
void _navigateToLimpiezaDetail(NavigatorState navigator, int limpiezaId) async {
  try {
    // Obtener el contexto del navigator
    final context = navigator.context;
    
    // Obtener el LimpiezaController del Provider
    final limpiezaController = Provider.of<LimpiezaController>(context, listen: false);
    
    // Mostrar indicador de carga
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );
    
    // Cargar detalle de la limpieza
    await limpiezaController.loadLimpiezaDetail(limpiezaId);
    
    // Cerrar indicador de carga
    if (navigator.canPop()) {
      navigator.pop();
    }
    
    // Verificar que se cargó correctamente
    final limpieza = limpiezaController.limpiezaDetail;
    if (limpieza != null) {
      // Navegar a la pantalla de detalle
      navigator.push(
        MaterialPageRoute(
          builder: (context) => LimpiezaDetailScreen(limpieza: limpieza),
        ),
      );
    } else {
      // Mostrar error si no se pudo cargar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(limpiezaController.detailErrorMessage ?? 'Error al cargar la limpieza'),
          backgroundColor: Colors.red,
        ),
      );
    }
  } catch (e) {
    print('❌ Error navegando a detalle de limpieza: $e');
    // Cerrar indicador de carga si está abierto
    if (navigator.canPop()) {
      navigator.pop();
    }
    // Mostrar error
    final context = navigator.context;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Error al cargar la limpieza: $e'),
        backgroundColor: Colors.red,
      ),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthController()),
        ChangeNotifierProvider(create: (_) => SidebarController()),
        ChangeNotifierProvider(create: (_) => HotelController()),
        ChangeNotifierProvider(create: (_) => ClienteController()),
        ChangeNotifierProvider(create: (_) => IncidenciaController()),
        ChangeNotifierProvider(create: (_) => PisoController()),
        ChangeNotifierProvider(create: (_) => PerfilController()),
        ChangeNotifierProvider(create: (_) => LimpiezaController()),
        ChangeNotifierProvider(create: (_) => ReservacionController()),
      ],
      child: MaterialApp(
        navigatorKey: navigatorKey,
        title: 'InnPulseMovile',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF667eea)),
          useMaterial3: true,
        ),
        home: const LoginScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
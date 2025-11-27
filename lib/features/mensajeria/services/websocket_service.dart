import 'dart:async';
import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../../../api/api_config.dart';
import '../../../core/auth/services/session_storage.dart';
import '../models/mensaje_model.dart';

class WebSocketService {
  WebSocketChannel? _channel;
  StreamController<MensajeModel>? _messageController;
  StreamController<bool>? _connectionController;
  Timer? _reconnectTimer;
  Timer? _pingTimer;
  bool _isConnecting = false;
  bool _shouldReconnect = true;
  int? _usuarioId;
  String? _token;

  Stream<MensajeModel> get messageStream =>
      _messageController?.stream ?? const Stream.empty();

  Stream<bool> get connectionStream =>
      _connectionController?.stream ?? const Stream.empty();

  bool get isConnected => _channel != null;

  /// Conectar al WebSocket
  Future<void> connect(int usuarioId, String token) async {
    if (_isConnecting || isConnected) {
      return;
    }

    _usuarioId = usuarioId;
    _token = token;
    _shouldReconnect = true;
    await _connect();
  }

  Future<void> _connect() async {
    if (_isConnecting) return;
    _isConnecting = true;

    try {
      // Construir URL del WebSocket
      String wsUrl = ApiConfig.baseUrl
          .replaceAll('http://', 'ws://')
          .replaceAll('https://', 'wss://');
      
      // Manejar localhost para dispositivos móviles
      if (wsUrl.contains('localhost') || wsUrl.contains('127.0.0.1')) {
        // En Android emulador: usar 10.0.2.2
        // En iOS simulator: usar localhost (funciona)
        // En dispositivo físico: usar la IP local de la máquina
        wsUrl = wsUrl.replaceAll('localhost', '10.0.2.2');
        wsUrl = wsUrl.replaceAll('127.0.0.1', '10.0.2.2');
      }
      
      final url = '${wsUrl}ws/$_usuarioId?token=$_token';

      _channel = WebSocketChannel.connect(Uri.parse(url));

      _messageController ??= StreamController<MensajeModel>.broadcast();
      _connectionController ??= StreamController<bool>.broadcast();

      _connectionController!.add(true);

      // Escuchar mensajes
      _channel!.stream.listen(
        (data) {
          try {
            final json = jsonDecode(data as String);
            final type = json['type'] as String?;

            if (type == 'nuevo_mensaje' || type == 'mensaje_enviado') {
              final mensajeData = json['mensaje'] as Map<String, dynamic>;
              final mensaje = MensajeModel.fromJson(mensajeData);
              _messageController!.add(mensaje);
            } else if (type == 'pong') {
              // Respuesta a ping, conexión activa
            } else if (type == 'error') {
              print('Error del WebSocket: ${json['message']}');
            }
          } catch (e) {
            print('Error procesando mensaje WebSocket: $e');
          }
        },
        onError: (error) {
          print('Error en WebSocket: $error');
          _handleDisconnection();
        },
        onDone: () {
          print('WebSocket desconectado');
          _handleDisconnection();
        },
        cancelOnError: false,
      );

      // Iniciar ping periódico
      _startPingTimer();

      _isConnecting = false;
    } catch (e) {
      print('Error conectando WebSocket: $e');
      _isConnecting = false;
      _handleDisconnection();
    }
  }

  /// Enviar mensaje por WebSocket
  Future<void> sendMessage({
    required int conversacionId,
    required String contenido,
  }) async {
    if (!isConnected || _channel == null) {
      throw Exception('WebSocket no conectado');
    }

    try {
      final message = {
        'type': 'enviar_mensaje',
        'conversacion_id': conversacionId,
        'contenido': contenido,
      };

      _channel!.sink.add(jsonEncode(message));
    } catch (e) {
      print('Error enviando mensaje por WebSocket: $e');
      rethrow;
    }
  }

  /// Enviar ping para mantener conexión activa
  void _startPingTimer() {
    _pingTimer?.cancel();
    _pingTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      if (isConnected && _channel != null) {
        try {
          _channel!.sink.add(jsonEncode({'type': 'ping'}));
        } catch (e) {
          print('Error enviando ping: $e');
        }
      }
    });
  }

  /// Manejar desconexión y reconexión automática
  void _handleDisconnection() {
    _connectionController?.add(false);
    _pingTimer?.cancel();

    if (_shouldReconnect && _usuarioId != null && _token != null) {
      _reconnectTimer?.cancel();
      _reconnectTimer = Timer(const Duration(seconds: 5), () {
        if (_shouldReconnect && !isConnected && !_isConnecting) {
          print('Intentando reconectar WebSocket...');
          _connect();
        }
      });
    }
  }

  /// Desconectar WebSocket
  Future<void> disconnect() async {
    _shouldReconnect = false;
    _reconnectTimer?.cancel();
    _pingTimer?.cancel();

    try {
      await _channel?.sink.close();
    } catch (e) {
      print('Error cerrando WebSocket: $e');
    }

    _channel = null;
    _connectionController?.add(false);
  }

  /// Cerrar recursos
  void dispose() {
    disconnect();
    _messageController?.close();
    _connectionController?.close();
    _messageController = null;
    _connectionController = null;
  }
}


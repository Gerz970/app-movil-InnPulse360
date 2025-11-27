import 'package:flutter/material.dart';
import '../models/conversacion_model.dart';
import '../models/mensaje_model.dart';
import '../models/usuario_chat_model.dart';
import '../services/mensajeria_service.dart';
import '../services/websocket_service.dart';
import '../../../core/auth/services/session_storage.dart';

class MensajeriaController with ChangeNotifier {
  final MensajeriaService _service = MensajeriaService();
  WebSocketService? _websocketService;

  // Estados
  List<ConversacionModel> _conversaciones = [];
  ConversacionModel? _conversacionActual;
  List<MensajeModel> _mensajes = [];
  List<UsuarioChatModel> _usuariosDisponibles = [];
  bool _isLoading = false;
  bool _isLoadingMensajes = false;
  String? _errorMessage;
  int _contadorNoLeidos = 0;
  bool _hasMoreMensajes = true;
  int _usuarioActualId = 0;

  // Getters
  List<ConversacionModel> get conversaciones => _conversaciones;
  ConversacionModel? get conversacionActual => _conversacionActual;
  List<MensajeModel> get mensajes => _mensajes;
  List<UsuarioChatModel> get usuariosDisponibles => _usuariosDisponibles;
  bool get isLoading => _isLoading;
  bool get isLoadingMensajes => _isLoadingMensajes;
  String? get errorMessage => _errorMessage;
  int get contadorNoLeidos => _contadorNoLeidos;
  bool get hasMoreMensajes => _hasMoreMensajes;
  bool get isWebSocketConnected => _websocketService?.isConnected ?? false;

  /// Inicializar usuario actual
  Future<void> _initUsuarioActual() async {
    if (_usuarioActualId == 0) {
      final session = await SessionStorage.getSession();
      final usuario = session?['usuario'] as Map<String, dynamic>?;
      _usuarioActualId = usuario?['id_usuario'] as int? ?? 0;
    }
  }

  /// Obtener conversaciones del usuario
  Future<void> fetchConversaciones({bool refresh = false}) async {
    try {
      print('🔵 MensajeriaController: Iniciando fetchConversaciones');
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final conversaciones = await _service.fetchConversaciones();
      print('🔵 MensajeriaController: Conversaciones recibidas: ${conversaciones.length}');

      _conversaciones = conversaciones;

      // Actualizar contador no leídos
      await actualizarContadorNoLeidos();
      print('🔵 MensajeriaController: fetchConversaciones completado exitosamente');
    } catch (e) {
      print('❌ MensajeriaController: Error en fetchConversaciones: $e');
      _errorMessage = "Error al cargar conversaciones: $e";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Obtener detalle de una conversación
  Future<void> fetchConversacion(int conversacionId) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      _conversacionActual = await _service.fetchConversacion(conversacionId);
    } catch (e) {
      _errorMessage = "Error al cargar conversación: $e";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Obtener mensajes de una conversación
  Future<void> fetchMensajes(int conversacionId, {bool loadMore = false}) async {
    try {
      if (!loadMore) {
        _isLoadingMensajes = true;
        _mensajes = [];
        _hasMoreMensajes = true;
      }
      _errorMessage = null;
      notifyListeners();

      final skip = loadMore ? _mensajes.length : 0;
      final mensajes = await _service.fetchMensajes(
        conversacionId: conversacionId,
        skip: skip,
        limit: 50,
      );

      if (loadMore) {
        _mensajes.addAll(mensajes);
      } else {
        _mensajes = mensajes;
      }

      _hasMoreMensajes = mensajes.length == 50;
    } catch (e) {
      _errorMessage = "Error al cargar mensajes: $e";
    } finally {
      _isLoadingMensajes = false;
      notifyListeners();
    }
  }

  /// Enviar mensaje
  Future<void> enviarMensaje(int conversacionId, String contenido) async {
    try {
      // Intentar enviar por WebSocket primero
      if (_websocketService?.isConnected ?? false) {
        await _websocketService!.sendMessage(
          conversacionId: conversacionId,
          contenido: contenido,
        );
      } else {
        // Fallback a HTTP
        final mensaje = await _service.enviarMensaje(
          conversacionId: conversacionId,
          contenido: contenido,
        );
        _mensajes.insert(0, mensaje);
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = "Error al enviar mensaje: $e";
      notifyListeners();
      rethrow;
    }
  }

  /// Buscar usuarios disponibles
  Future<void> buscarUsuarios(String? query) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      _usuariosDisponibles = await _service.buscarUsuarios(query: query);
    } catch (e) {
      _errorMessage = "Error al buscar usuarios: $e";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Crear conversación cliente-admin
  Future<ConversacionModel> crearConversacionClienteAdmin({
    required int clienteId,
    required int adminId,
  }) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final conversacion = await _service.crearConversacionClienteAdmin(
        clienteId: clienteId,
        adminId: adminId,
      );

      // Agregar a la lista si no existe
      if (!_conversaciones.any((c) => c.idConversacion == conversacion.idConversacion)) {
        _conversaciones.insert(0, conversacion);
      }

      return conversacion;
    } catch (e) {
      _errorMessage = "Error al crear conversación: $e";
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Crear conversación empleado-empleado
  Future<ConversacionModel> crearConversacionEmpleadoEmpleado({
    required int empleado1Id,
    required int empleado2Id,
  }) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final conversacion = await _service.crearConversacionEmpleadoEmpleado(
        empleado1Id: empleado1Id,
        empleado2Id: empleado2Id,
      );

      // Agregar a la lista si no existe
      if (!_conversaciones.any((c) => c.idConversacion == conversacion.idConversacion)) {
        _conversaciones.insert(0, conversacion);
      }

      return conversacion;
    } catch (e) {
      _errorMessage = "Error al crear conversación: $e";
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Conectar WebSocket
  Future<void> conectarWebSocket() async {
    try {
      await _initUsuarioActual();
      if (_usuarioActualId == 0) return;

      final session = await SessionStorage.getSession();
      final token = session?['token'] as String?;
      if (token == null) return;

      _websocketService ??= WebSocketService();

      // Escuchar mensajes entrantes
      _websocketService!.messageStream.listen((mensaje) {
        if (mensaje.conversacionId == _conversacionActual?.idConversacion) {
          _mensajes.insert(0, mensaje);
          notifyListeners();
        }
        // Actualizar contador
        actualizarContadorNoLeidos();
      });

      await _websocketService!.connect(_usuarioActualId, token);
    } catch (e) {
      print('Error conectando WebSocket: $e');
    }
  }

  /// Desconectar WebSocket
  Future<void> desconectarWebSocket() async {
    await _websocketService?.disconnect();
  }

  /// Actualizar contador de no leídos
  Future<void> actualizarContadorNoLeidos() async {
    try {
      _contadorNoLeidos = await _service.obtenerContadorNoLeidos();
      notifyListeners();
    } catch (e) {
      print('Error actualizando contador: $e');
    }
  }

  /// Agregar mensaje recibido (desde WebSocket o notificación)
  void agregarMensajeRecibido(MensajeModel mensaje) {
    if (mensaje.conversacionId == _conversacionActual?.idConversacion) {
      _mensajes.insert(0, mensaje);
      notifyListeners();
    }
    // Actualizar última conversación en la lista
    final index = _conversaciones.indexWhere(
      (c) => c.idConversacion == mensaje.conversacionId,
    );
    if (index != -1) {
      final conv = _conversaciones[index];
      _conversaciones[index] = ConversacionModel(
        idConversacion: conv.idConversacion,
        tipoConversacion: conv.tipoConversacion,
        usuario1Id: conv.usuario1Id,
        usuario2Id: conv.usuario2Id,
        clienteId: conv.clienteId,
        empleado1Id: conv.empleado1Id,
        empleado2Id: conv.empleado2Id,
        fechaCreacion: conv.fechaCreacion,
        fechaUltimoMensaje: DateTime.now(),
        idEstatus: conv.idEstatus,
        ultimoMensaje: mensaje,
        contadorNoLeidos: conv.contadorNoLeidos + 1,
        otroUsuarioId: conv.otroUsuarioId,
        otroUsuarioNombre: conv.otroUsuarioNombre,
        otroUsuarioFoto: conv.otroUsuarioFoto,
      );
      notifyListeners();
    }
  }

  /// Limpiar estado
  void limpiarEstado() {
    _conversacionActual = null;
    _mensajes = [];
    _errorMessage = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _websocketService?.dispose();
    super.dispose();
  }
}


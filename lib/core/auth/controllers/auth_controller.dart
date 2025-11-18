import 'package:flutter/foundation.dart'; // Para uso de ChangeNotifier
import '../services/auth_service.dart'; // para conexion con servicio
import '../services/session_storage.dart'; // para almacenamiento de sesión
import '../models/request_login_model.dart'; // modelo de body para request
import '../models/verificacion_disponibilidad_model.dart'; // modelo de verificación
import '../models/registro_cliente_response_model.dart'; // modelo de registro
import 'package:dio/dio.dart'; // clase dio para construir objeto de http

  // ChangeNotifier: sirve para notificar 
class AuthController extends ChangeNotifier 
{
  // Instancia de AuthService
  final AuthService _authService = AuthService();

  // Estados privados para login
  bool _isLoading = false;           // Estado de carga
  String? _errorMessage;             // Mensaje de error (puede ser null)
  Map<String, dynamic>? _loginResponse;  // Respuesta del login (temporal)

  // Estados privados para verificación y registro
  bool _isVerifying = false;         // Estado de verificación de disponibilidad
  bool _isRegistering = false;       // Estado de registro de usuario-cliente
  VerificacionDisponibilidadModel? _verificacionResponse; // Respuesta de verificación
  RegistroClienteResponseModel? _registroResponse; // Respuesta de registro
  String? _verificacionErrorMessage; // Mensaje de error en verificación
  String? _registroErrorMessage;     // Mensaje de error en registro

  // Constructor que carga la sesión al inicializar
  AuthController() {
    loadSession();
  }

  // Getters para login
  bool get isLoading {
    return _isLoading;
  }
  String? get errorMessage {
    return _errorMessage;
  }
  Map<String, dynamic>? get loginResponse {
    return _loginResponse;
  }

  // Getters para verificación y registro
  bool get isVerifying => _isVerifying;
  bool get isRegistering => _isRegistering;
  VerificacionDisponibilidadModel? get verificacionResponse => _verificacionResponse;
  RegistroClienteResponseModel? get registroResponse => _registroResponse;
  String? get verificacionErrorMessage => _verificacionErrorMessage;
  String? get registroErrorMessage => _registroErrorMessage;

  Future<bool> login(String username, String password) async {
    // 1.- Preparar petición
    _isLoading = true; //activar loading
    _errorMessage = null; // limpiar error anterior (En caso que existiera)
    notifyListeners(); // Notificar cambio de estado

    try {
      // 2.- crear modelo de request
      final requestModel = RequestLoginModel(login: username, password: password);
      // 3.- hacer peticion al API
      final response = await _authService.login(requestModel);
      // 4.- Guardar respuesta temporalmente
      _loginResponse = response.data;
      
      // 5.- Guardar sesión en caché
      if (response.data != null) {
        await SessionStorage.saveSession(response.data);
        print("Sesión guardada en caché");
      }
      
      // 6.- desactivar loading y notificar estado
      _isLoading = false;
      notifyListeners();
      //7.- imprimir en consola la respuesta
      print("Login correctamente ejecutado");
      print('Status code: ${response.statusCode}');
      print(response.data);
      return true;

    } catch (e) {
      // 7. Desactivar loading
      _isLoading = false;
      
      // 8. Manejar errores de forma profesional y sutil
      if (e is DioException) {
        // Verificar si hay respuesta del servidor
        if (e.response != null) {
          final statusCode = e.response?.statusCode;
          final errorData = e.response?.data;
          
          // Manejar errores 401 (credenciales incorrectas) de forma sutil
          if (statusCode == 401) {
            // Intentar extraer mensaje del JSON si está disponible
            if (errorData is Map<String, dynamic>) {
              final detail = errorData['detail'];
              if (detail is String && detail.isNotEmpty) {
                // Si el mensaje contiene "credenciales" o "incorrectas", usar mensaje genérico
                if (detail.toLowerCase().contains('credenciales') || 
                    detail.toLowerCase().contains('incorrectas') ||
                    detail.toLowerCase().contains('invalid')) {
                  _errorMessage = 'Usuario o contraseña incorrectos';
                } else {
                  _errorMessage = detail;
                }
              } else {
                _errorMessage = 'Usuario o contraseña incorrectos';
              }
            } else {
              _errorMessage = 'Usuario o contraseña incorrectos';
            }
          } else {
            // Otros errores del servidor - intentar extraer mensaje amigable
            if (errorData is Map<String, dynamic>) {
              final detail = errorData['detail'];
              if (detail is String && detail.isNotEmpty) {
                _errorMessage = detail;
              } else {
                _errorMessage = 'Error al iniciar sesión. Por favor, intenta nuevamente';
              }
            } else if (errorData is String && errorData.isNotEmpty) {
              _errorMessage = errorData;
            } else {
              _errorMessage = 'Error al iniciar sesión. Por favor, intenta nuevamente';
            }
          }
          
          print('Error del servidor (${statusCode}): ${errorData}');
        } else {
          // Error de conexión (sin respuesta del servidor)
          _errorMessage = 'Error de conexión. Verifica tu internet e intenta nuevamente';
          print('Error de conexión: ${e.message}');
        }
      } else {
        // Otro tipo de error (no es DioException)
        _errorMessage = 'Error inesperado. Por favor, intenta nuevamente';
        print('Error general: $e');
      }
      
      // Notificar cambio de estado
      notifyListeners();
      
      // Retornar false porque el login falló
      return false;
    }
  }

  /// Cargar la sesión guardada del almacenamiento
  /// Se llama automáticamente al inicializar el controlador
  /// Crea una copia profunda nueva del objeto para que Flutter detecte los cambios
  Future<void> loadSession() async {
    try {
      final session = await SessionStorage.getSession();
      if (session != null) {
        // Crear una copia profunda nueva del objeto session
        // Esto asegura que Flutter detecte el cambio cuando se llama notifyListeners()
        final sessionCopy = Map<String, dynamic>.from(session);
        
        // Crear una copia nueva del objeto usuario si existe
        if (session['usuario'] is Map<String, dynamic>) {
          sessionCopy['usuario'] = Map<String, dynamic>.from(session['usuario'] as Map<String, dynamic>);
        }
        
        // Asignar la nueva referencia para que Flutter detecte el cambio
        _loginResponse = sessionCopy;
        
        print("DEBUG AuthController: Sesión cargada desde caché (nueva referencia creada)");
        // Debug: imprimir la foto de perfil si existe
        if (_loginResponse?['usuario'] is Map<String, dynamic>) {
          final fotoUrl = _loginResponse!['usuario']['url_foto_perfil'];
          final timestamp = _loginResponse!['usuario']['foto_perfil_timestamp'];
          print("DEBUG AuthController: Foto de perfil en sesión cargada: $fotoUrl");
          print("DEBUG AuthController: Timestamp de foto: $timestamp");
        }
        
        // Notificar cambios después de imprimir logs
        notifyListeners();
        print("DEBUG AuthController: notifyListeners() ejecutado");
      }
    } catch (e) {
      print('ERROR al cargar sesión: $e');
    }
  }

  /// Cerrar sesión y limpiar datos
  /// Limpia la sesión guardada y los datos del controlador
  Future<void> logout() async {
    try {
      await SessionStorage.clearSession();
      _loginResponse = null;
      _errorMessage = null;
      notifyListeners();
      print("Sesión cerrada y limpiada");
    } catch (e) {
      print('Error al cerrar sesión: $e');
    }
  }

  /// Verificar disponibilidad de login y correo para registro
  /// No requiere autenticación
  /// Parámetros: login y correo electrónico
  Future<bool> verificarDisponibilidad(String login, String correo) async {
    // 1. Preparar petición
    _isVerifying = true;
    _verificacionErrorMessage = null;
    _verificacionResponse = null;
    notifyListeners();

    try {
      // 2. Hacer petición al API
      final response = await _authService.verificarDisponibilidad(login, correo);

      // 3. Parsear respuesta
      if (response.data != null) {
        _verificacionResponse = VerificacionDisponibilidadModel.fromJson(
          response.data as Map<String, dynamic>,
        );
      }

      // 4. Desactivar loading y notificar estado
      _isVerifying = false;
      notifyListeners();

      print("Verificación ejecutada correctamente");
      print('Status code: ${response.statusCode}');
      return true;
    } catch (e) {
      // 5. Desactivar loading
      _isVerifying = false;

      // 6. Manejar errores
      if (e is DioException) {
        if (e.response != null) {
          // El servidor respondió con un código de error
          final errorData = e.response?.data;
          if (errorData is Map && errorData['detail'] != null) {
            _verificacionErrorMessage = errorData['detail'] as String;
          } else {
            _verificacionErrorMessage = 'Error ${e.response?.statusCode}: ${e.response?.data}';
          }
          print('Error del servidor: ${e.response?.data}');
        } else {
          // Error de conexión
          _verificacionErrorMessage = 'Error de conexión: ${e.message ?? e.toString()}';
          print('Error de conexión: ${e.message}');
        }
      } else {
        // Otro tipo de error
        _verificacionErrorMessage = 'Error: ${e.toString()}';
        print('Error general: $e');
      }

      // Notificar cambio de estado
      notifyListeners();

      // Retornar false porque la verificación falló
      return false;
    }
  }

  /// Registrar usuario-cliente
  /// No requiere autenticación
  /// Parámetros: login, correo electrónico, clienteId y password opcional
  Future<bool> registrarCliente(
    String login,
    String correo,
    int clienteId, {
    String? password,
  }) async {
    // 1. Preparar petición
    _isRegistering = true;
    _registroErrorMessage = null;
    _registroResponse = null;
    notifyListeners();

    try {
      // 2. Hacer petición al API
      final response = await _authService.registrarCliente(
        login,
        correo,
        clienteId,
        password: password,
      );

      // 3. Parsear respuesta
      if (response.data != null) {
        _registroResponse = RegistroClienteResponseModel.fromJson(
          response.data as Map<String, dynamic>,
        );
      }

      // 4. Desactivar loading y notificar estado
      _isRegistering = false;
      notifyListeners();

      print("Registro ejecutado correctamente");
      print('Status code: ${response.statusCode}');
      return true;
    } catch (e) {
      // 5. Desactivar loading
      _isRegistering = false;

      // 6. Manejar errores
      if (e is DioException) {
        if (e.response != null) {
          // El servidor respondió con un código de error
          final errorData = e.response?.data;
          print('Error del servidor (${e.response?.statusCode}): ${e.response?.data}');
          
          if (errorData is Map) {
            // Manejar errores de validación 422 de FastAPI
            if (e.response?.statusCode == 422 && errorData['detail'] != null) {
              final detail = errorData['detail'];
              if (detail is List) {
                // FastAPI devuelve un array de errores de validación
                final errores = detail.map((e) {
                  if (e is Map) {
                    final campo = e['loc']?.last?.toString() ?? 'campo';
                    final mensaje = e['msg']?.toString() ?? 'Error de validación';
                    return '$campo: $mensaje';
                  }
                  return e.toString();
                }).join(', ');
                _registroErrorMessage = 'Error de validación: $errores';
              } else if (detail is String) {
                _registroErrorMessage = detail;
              } else {
                _registroErrorMessage = 'Error de validación: ${detail.toString()}';
              }
            } else if (errorData['detail'] != null) {
              _registroErrorMessage = errorData['detail'] is String 
                  ? errorData['detail'] as String
                  : errorData['detail'].toString();
            } else {
              _registroErrorMessage = 'Error ${e.response?.statusCode}: ${errorData.toString()}';
            }
          } else {
            _registroErrorMessage = 'Error ${e.response?.statusCode}: ${e.response?.data}';
          }
        } else {
          // Error de conexión
          _registroErrorMessage = 'Error de conexión: ${e.message ?? e.toString()}';
        }
      } else {
        // Otro tipo de error
        _registroErrorMessage = 'Error: ${e.toString()}';
      }

      // Notificar cambio de estado
      notifyListeners();

      // Retornar false porque el registro falló
      return false;
    }
  }

  /// Limpiar estados de verificación y registro
  /// Útil para resetear el estado después de completar el flujo
  void clearVerificacionYRegistro() {
    _isVerifying = false;
    _isRegistering = false;
    _verificacionResponse = null;
    _registroResponse = null;
    _verificacionErrorMessage = null;
    _registroErrorMessage = null;
    notifyListeners();
  }
}
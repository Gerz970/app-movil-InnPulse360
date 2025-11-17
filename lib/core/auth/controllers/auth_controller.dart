import 'package:flutter/foundation.dart'; // Para uso de ChangeNotifier
import '../services/auth_service.dart'; // para conexion con servicio
import '../services/session_storage.dart'; // para almacenamiento de sesión
import '../models/request_login_model.dart'; // modelo de body para request
import 'package:dio/dio.dart'; // clase dio para construir objeto de http
import 'package:provider/provider.dart';
import 'package:flutter/widgets.dart';
import '../../../features/hoteles/controllers/hotel_controller.dart';
  // ChangeNotifier: sirve para notificar 
class AuthController extends ChangeNotifier 
{
  // Instancia de AuthService
  final AuthService _authService = AuthService();

  // Estados privados
  bool _isLoading = false;           // Estado de carga
  String? _errorMessage;             // Mensaje de error (puede ser null)
  Map<String, dynamic>? _loginResponse;  // Respuesta del login (temporal)

  // Constructor que carga la sesión al inicializar
  AuthController() {
    loadSession();
  }

  // Getters
  bool get isLoading {
    return _isLoading;
  }
  String? get errorMessage {
    return _errorMessage;
  }
  Map<String, dynamic>? get loginResponse {
    return _loginResponse;
  }

  Future<bool> login(String username, String password, BuildContext context) async {
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
      
      // 6.- CARGAR LOS HOTELES DESPUÉS DEL LOGIN
      try {
        final hotelController = Provider.of<HotelController>(context, listen: false);
        await hotelController.fetchHotels();
        print("Hoteles cargados después del login");
      } catch (e) {
        print("Error cargando hoteles tras login: $e");
      }

    // 7.- desactivar loading y notificar estado
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
      
      // 8. Manejar errores (sin verificar response, porque no existe aquí)
      if (e is DioException) {
        // Verificar si hay respuesta del servidor
        if (e.response != null) {
          // El servidor respondió con un código de error (401, 404, 500, etc.)
          _errorMessage = 'Error ${e.response?.statusCode}: ${e.response?.data}';
          print('Error del servidor: ${e.response?.data}');
        } else {
          // Error de conexión (sin respuesta del servidor)
          _errorMessage = 'Error de conexión: ${e.message ?? e.toString()}';
          print('Error de conexión: ${e.message}');
        }
      } else {
        // Otro tipo de error (no es DioException)
        _errorMessage = 'Error: ${e.toString()}';
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
  Future<void> loadSession() async {
    try {
      final session = await SessionStorage.getSession();
      if (session != null) {
        _loginResponse = session;
        notifyListeners();
        print("Sesión cargada desde caché");
      }
    } catch (e) {
      print('Error al cargar sesión: $e');
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
}
import 'package:dio/dio.dart'; // se importa libreria para hacer peticiones HTTP al backend
import '../models/request_login_model.dart'; // se importa el modelo de la estructura request
import '../../../api/api_config.dart'; // importar configuracion del api
import '../../../api/endpoints_auth.dart'; // importar endpoints de autenticacion 

class AuthService {
  //se instancia la clase de DIO para las peticiones de HTTP
  final Dio _dio;

  //URL base de la API
  final String baseUrl = ApiConfig.baseUrl + ApiConfig.apiVersion;

  // Constructor de la clase, se inicializa validando si se proporciona una instancia del mismo objeto
  // en caso de que no se proporcione, este creara una nueva
  AuthService ({ Dio? dio, }) : _dio = dio ?? Dio() {
      // intercepteros para la petición
  _dio.options.connectTimeout = Duration(seconds: ApiConfig.connectTimeoutSeconds);
  _dio.options.receiveTimeout = Duration(seconds: ApiConfig.receiveTimeoutSeconds);
  _dio.options.headers = { // son valores de configuracion del endpoint
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

  }

  // Metodo de Login
  // Requiere de parametro el modelo de request login y devuelve un modelo de respuesta
  Future<Response> login(RequestLoginModel request) async {
    // Hacemos construcción de la ruta final del endpoint
    final url = baseUrl + EndpointsAuth.login;

    // convertimos el modelo a Json con su funcion interna del modelo
    final data = request.toJson();

    // hacemos la peticion post
    try {
      final response = await _dio.post(
        url,  // Url final ya debe estar construida completamente
        data: data // body esperado del endpoint
      );

      return response; // Respuesta del API
    } catch (e) {
      // Manejo de errores
      rethrow;
    }
  }

  /// Método para verificar disponibilidad de login y correo
  /// No requiere autenticación
  /// Parámetros: login y correo electrónico
  Future<Response> verificarDisponibilidad(String login, String correo) async {
    // Construir la URL del endpoint
    final url = baseUrl + EndpointsAuth.verificarDisponibilidad;

    // Construir el body de la petición
    final data = {
      'login': login.trim(),
      'correo_electronico': correo.trim(),
    };

    // Hacer la petición POST sin autenticación
    try {
      final response = await _dio.post(
        url,
        data: data,
      );

      return response; // Respuesta del API
    } catch (e) {
      // Manejo de errores
      rethrow;
    }
  }

  /// Método para registrar un usuario-cliente
  /// No requiere autenticación
  /// Parámetros: login, correo electrónico, clienteId y password opcional
  Future<Response> registrarCliente(
    String login,
    String correo,
    int clienteId, {
    String? password,
  }) async {
    // Construir la URL del endpoint
    final url = baseUrl + EndpointsAuth.registroCliente;

    // Construir el body de la petición
    final data = <String, dynamic>{
      'login': login.trim(),
      'correo_electronico': correo.trim(),
      'cliente_id': clienteId,
    };

    // Agregar password solo si se proporciona
    if (password != null && password.isNotEmpty) {
      data['password'] = password;
    }

    // Log para debugging
    print('Enviando petición de registro a: $url');
    print('Datos enviados: $data');

    // Hacer la petición POST sin autenticación
    try {
      final response = await _dio.post(
        url,
        data: data,
      );

      return response; // Respuesta del API
    } catch (e) {
      // Manejo de errores
      rethrow;
    }
  }

  /// Método para recuperar contraseña
  /// No requiere autenticación
  /// Parámetro: correo electrónico
  Future<Response> recuperarPassword(String correoElectronico) async {
    // Construir la URL del endpoint
    final url = baseUrl + EndpointsAuth.recuperarPassword;

    // Construir el body de la petición
    final data = {
      'correo_electronico': correoElectronico.trim(),
    };

    // Hacer la petición POST sin autenticación
    try {
      final response = await _dio.post(
        url,
        data: data,
      );

      return response; // Respuesta del API
    } catch (e) {
      // Manejo de errores
      rethrow;
    }
  }
}

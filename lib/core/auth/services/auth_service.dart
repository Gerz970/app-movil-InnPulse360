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

}

import 'package:dio/dio.dart'; // se importa libreria para hacer peticiones HTTP al backend
import '../../../api/api_config.dart'; // importar configuracion del api
import '../../../api/endpoints_reservacion.dart'; // importar endpoints de reservaciones
import '../../../core/auth/services/session_storage.dart'; // para obtener token de sesión
import '../../../api/endpoints_habitacion_area.dart'; // importar endpoints de reservaciones
import '../../../api/endpoints_tipo_habitacion.dart'; // importar endpoints de tipos de habitación

class ReservaService {
  final Dio _dio;

  final String baseUrl = ApiConfig.baseUrl + ApiConfig.apiVersion;

  // Constructor de la clase, se inicializa validando si se proporciona una instancia del mismo objeto
  // en caso de que no se proporcione, este creara una nueva
  ReservaService({Dio? dio}) : _dio = dio ?? Dio() {
    // configuración para la petición
    _dio.options.connectTimeout = Duration(
      seconds: ApiConfig.connectTimeoutSeconds,
    );
    _dio.options.receiveTimeout = Duration(
      seconds: ApiConfig.receiveTimeoutSeconds,
    );
    _dio.options.headers = {
      // son valores de configuracion del endpoint
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
  }

  /// Obtener el token de la sesión guardada
  Future<String?> _getToken() async {
    try {
      final session = await SessionStorage.getSession();
      if (session == null) return null;

      final token =
          session['token'] ??
          session['access_token'] ??
          session['accessToken'] || session['token_access'];

      return token is String ? token : null;
    } catch (e) {
      print('Error al obtener token: $e');
      return null;
    }
  }

  Future<Response> fetchReservaciones(int idCliente) async {
    final token = await _getToken();

    if (token == null) {
      throw DioException(
        requestOptions: RequestOptions(path: ''),
        error: 'No hay token de autenticación disponible',
        type: DioExceptionType.unknown,
      );
    }

    // Construir la URL
    final url = baseUrl + EndpointsReservacion.reservasCliente(idCliente);

    // Configurar headers con el token de autenticación
    final headers = {'Authorization': 'Bearer $token'};

    // Hacer la petición GET
    try {
      final response = await _dio.get(url, options: Options(headers: headers));

      return response; // Respuesta del API
    } catch (e) {
      // Manejo de errores
      rethrow;
    }
  }

  Future<Response> fetchDisponibles(String inicio, String fin) async {
    final token = await _getToken();

    if (token == null) {
      throw DioException(
        requestOptions: RequestOptions(path: ''),
        error: 'No hay token de autenticación disponible',
        type: DioExceptionType.unknown,
      );
    }

    // Construir la URL
    final url =
        baseUrl + EndpointsReservacion.habitacionesDisponibles(inicio, fin, 10);

    // Configurar headers con el token de autenticación
    final headers = {'Authorization': 'Bearer $token'};

    // Hacer la petición GET
    try {
      final response = await _dio.get(url, options: Options(headers: headers));

      return response; // Respuesta del API
    } catch (e) {
      // Manejo de errores
      rethrow;
    }
  }

  Future<Response> createReserva(Map<String, dynamic> reservaData) async {
    // Obtener token de la sesión
    final token = await _getToken();

    if (token == null) {
      throw DioException(
        requestOptions: RequestOptions(path: ''),
        error: 'No hay token de autenticación disponible',
        type: DioExceptionType.unknown,
      );
    }

    // Construir la URL
    final url = baseUrl + EndpointsReservacion.list;

    // Configurar headers con el token de autenticación
    final headers = {'Authorization': 'Bearer $token'};

    // Hacer la petición POST
    try {
      final response = await _dio.post(
        url,
        data: reservaData,
        options: Options(headers: headers),
      );

      return response; // Respuesta del API
    } catch (e) {
      // Manejo de errores
      rethrow;
    }
  }

  Future<Response> cancelarReserva(int reservaId) async {
    // Obtener token de la sesión
    final token = await _getToken();

    if (token == null) {
      throw DioException(
        requestOptions: RequestOptions(path: ''),
        error: 'No hay token de autenticación disponible',
        type: DioExceptionType.unknown,
      );
    }

    // Construir la URL
    final url = baseUrl + EndpointsReservacion.detail(reservaId);

    // Configurar headers con el token de autenticación
    final headers = {
      'Authorization': 'Bearer $token',
      'Accept': 'application/json',
    };

    // Hacer la petición DELETE
    try {
      final response = await _dio.delete(
        url,
        options: Options(headers: headers),
      );

      return response; // Respuesta del API
    } catch (e) {
      // Manejo de errores
      rethrow;
    }
  }

  Future<String> obtenerImagenHabitacion(int habitacionId) async {
    // Obtener token de la sesión
    final token = await _getToken();

    if (token == null) {
      throw DioException(
        requestOptions: RequestOptions(path: ''),
        error: 'No hay token de autenticación disponible',
        type: DioExceptionType.unknown,
      );
    }

    // Construir la URL
    final url = baseUrl + EndpointsHabitacionArea.obtenerImagen(habitacionId);

    // Configurar headers con el token de autenticación
    final headers = {
      'Authorization': 'Bearer $token',
      'Accept': 'application/json',
    };

    try {
      final response = await _dio.get(url, options: Options(headers: headers));

      if (response.data is Map &&
      response.data['imagenes'] != null &&
      response.data['imagenes'] is List &&
      response.data['imagenes'].isNotEmpty &&
      response.data['imagenes'][0]['url_publica'] != null) {

        return response.data['imagenes'][0]['url_publica'];
      }

      return "";
    } catch (e) {
      // Manejo de errores
      rethrow;
    }
  }

  Future<Response> fetchGaleriaHabitacion(int habitacionId) async {
    // Obtener token de la sesión
    final token = await _getToken();

    if (token == null) {
      throw DioException(
        requestOptions: RequestOptions(path: ''),
        error: 'No hay token de autenticación disponible',
        type: DioExceptionType.unknown,
      );
    }

    // Construir la URL usando el mismo endpoint que obtenerImagenHabitacion
    final url = baseUrl + EndpointsHabitacionArea.obtenerImagen(habitacionId);

    // Configurar headers con el token de autenticación
    final headers = {
      'Authorization': 'Bearer $token',
      'Accept': 'application/json',
    };

    // Hacer la petición GET
    try {
      final response = await _dio.get(url, options: Options(headers: headers));
      return response; // Retornar Response completa con todas las imágenes
    } catch (e) {
      // Manejo de errores
      rethrow;
    }
  }

  /// Obtener detalle de un tipo de habitación por su ID
  Future<Response> fetchTipoHabitacionDetail(int tipoHabitacionId) async {
    final token = await _getToken();

    if (token == null) {
      throw DioException(
        requestOptions: RequestOptions(path: ''),
        error: 'No hay token de autenticación disponible',
        type: DioExceptionType.unknown,
      );
    }

    final url = baseUrl + EndpointsTipoHabitacion.detail(tipoHabitacionId);
    final headers = {'Authorization': 'Bearer $token'};

    try {
      final response = await _dio.get(url, options: Options(headers: headers));
      return response;
    } catch (e) {
      rethrow;
    }
  }

  /// Obtener galería de imágenes de un tipo de habitación
  Future<Response> fetchGaleriaTipoHabitacion(int tipoHabitacionId) async {
    final token = await _getToken();

    if (token == null) {
      throw DioException(
        requestOptions: RequestOptions(path: ''),
        error: 'No hay token de autenticación disponible',
        type: DioExceptionType.unknown,
      );
    }

    final url = baseUrl + EndpointsTipoHabitacion.galeria(tipoHabitacionId);
    final headers = {
      'Authorization': 'Bearer $token',
      'Accept': 'application/json',
    };

    try {
      final response = await _dio.get(url, options: Options(headers: headers));
      return response;
    } catch (e) {
      rethrow;
    }
  }

  /// Obtener lista de todos los tipos de habitación
  Future<Response> fetchTiposHabitacion({int skip = 0, int limit = 100}) async {
    final token = await _getToken();

    if (token == null) {
      throw DioException(
        requestOptions: RequestOptions(path: ''),
        error: 'No hay token de autenticación disponible',
        type: DioExceptionType.unknown,
      );
    }

    final url = baseUrl + EndpointsTipoHabitacion.list + '?skip=$skip&limit=$limit';
    final headers = {'Authorization': 'Bearer $token'};

    try {
      final response = await _dio.get(url, options: Options(headers: headers));
      return response;
    } catch (e) {
      rethrow;
    }
  }

  /// Obtener tipos de habitación disponibles agrupados por tipo
  Future<Response> fetchTiposHabitacionDisponibles(String inicio, String fin, {int? idHotel}) async {
    final token = await _getToken();

    if (token == null) {
      throw DioException(
        requestOptions: RequestOptions(path: ''),
        error: 'No hay token de autenticación disponible',
        type: DioExceptionType.unknown,
      );
    }

    final url = baseUrl + EndpointsReservacion.tiposDisponibles(inicio, fin, idHotel: idHotel);
    final headers = {'Authorization': 'Bearer $token'};

    try {
      final response = await _dio.get(url, options: Options(headers: headers));
      return response;
    } catch (e) {
      rethrow;
    }
  }
}

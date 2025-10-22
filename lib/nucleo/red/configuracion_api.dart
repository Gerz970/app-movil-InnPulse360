/// Configuración central de la API
/// Contiene la URL base y configuraciones generales para todas las peticiones HTTP
class ConfiguracionApi {
  /// URL base de la API de producción
  /// Fuente: https://app-interface-innpulse360-production.up.railway.app/docs
  static const String urlBase = 'https://app-interface-innpulse360-production.up.railway.app';
  
  /// Versión de la API
  static const String version = '/api/v1';
  
  /// URL completa concatenada
  static String get urlCompleta => '$urlBase$version';
  
  /// Timeout para establecer la conexión (30 segundos)
  static const Duration tiempoConexion = Duration(seconds: 30);
  
  /// Timeout para recibir datos (30 segundos)
  static const Duration tiempoRecepcion = Duration(seconds: 30);
  
  /// Headers comunes para todas las peticiones
  /// Content-Type y Accept en formato JSON
  static Map<String, String> get headersBase => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };
}


/* Esta clase tiene como objetivo configurar el api de Innpulse
almacenar la url base del api, configuracion general del API como timeouts, versiones y 
variables de confgiguracion
*/

class ApiConfig {
  //Url base del api
  //static const String baseUrl = "https://app-interface-innpulse360-production.up.railway.app/";
  static const String baseUrl = "http://localhost:8000/";
  //static const String baseUrl = "https://www.innpulse360.cloud/";
  // Timeout para las peticiones
  static const int connectTimeoutSeconds = 60; //Propósito: tiempo máximo para establecer conexión (en segundos)
  static const int receiveTimeoutSeconds = 120; //Propósito: tiempo máximo para recibir respuesta (en segundos)

  static const String apiVersion = "api/v1/"; // Proposito: versión del Api que va utilizar
}
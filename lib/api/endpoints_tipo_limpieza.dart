// Endpoints para tipos de limpieza
class EndpointsTipoLimpieza {
  // [GET]: listado de tipos de limpieza
  static const String list = "tipos-limpieza/";
  
  // Método helper para construir endpoint de tipo de limpieza por ID
  static String detail(int idTipoLimpieza) => "tipos-limpieza/$idTipoLimpieza";
}


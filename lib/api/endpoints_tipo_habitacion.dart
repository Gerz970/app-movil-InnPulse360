class EndpointsTipoHabitacion {
  // Endpoints de tipos de habitación

  // [GET]: listado de tipos de habitación
  static const String list = "tipos-habitacion/";

  // Método helper para construir endpoint de detalle de tipo de habitación
  static String detail(int idTipoHabitacion) => "tipos-habitacion/$idTipoHabitacion";

  // Método helper para construir endpoint de tipo de habitación por clave
  static String byClave(String clave) => "tipos-habitacion/clave/$clave";

  // Método helper para construir endpoint de tipo de habitación por nombre
  static String byNombre(String nombre) => "tipos-habitacion/nombre/$nombre";

  // Método helper para construir endpoint de galería de tipo de habitación
  static String galeria(int idTipoHabitacion) => "tipo-habitacion/$idTipoHabitacion/galeria";
}


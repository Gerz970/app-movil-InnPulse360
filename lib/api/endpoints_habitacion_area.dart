class EndpointsHabitacionArea {
  static const String base = "habitacion-area/";
  static String disponiblesPorPiso(int pisoId) => "habitacion-area/disponibles-por-piso/$pisoId";
  static String obtenerPorPiso(int pisoId) => "habitacion-area/obtener-por-piso/$pisoId";
  static String obtenerImagen(int habitacion_area_id) => "habitaciones/$habitacion_area_id/galeria";

}


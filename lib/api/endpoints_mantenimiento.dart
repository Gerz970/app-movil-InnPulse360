
class EndpointsMantenimiento {
  // Endpoints de incidencias

  static const String list = "mantenimientos/";
  
  static String detail(int mantenimientoId) => "mantenimientos/$mantenimientoId";
  
  static String obtener_por_empleado_estatus(int empleadoId, int estatus) => "mantenimientos/empleado-estatus/$empleadoId/$estatus";

}

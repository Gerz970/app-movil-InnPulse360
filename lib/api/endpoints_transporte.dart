class EndpointsTransporte {
  static const String list = "servicios-transporte/";
  
  static String detail(int idServicio) => "servicios-transporte/$idServicio";
  
  static String porEmpleado(int empleadoId) => "servicios-transporte/empleado/$empleadoId";
}


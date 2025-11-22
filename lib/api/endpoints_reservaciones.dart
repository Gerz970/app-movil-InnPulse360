class EndpointsReservaciones {

// END POINT PARA LISTAR Y CREAR
  static const String reservaciones = "reservaciones/";
  
  //[GET],[PUT],[DELETE]
  static String detail(int idReservacion) => "reservaciones/$idReservacion";
  
  // [GET]
  static String obtenerPorCliente(int idCliente) => "reservaciones/$idCliente";
  
  //[GET]
  static String obtenerHabitacionesPorCliente(int idCliente) => "reservaciones/$idCliente/habitaciones";

  //[GET]
  static String obtenerPorHabitacion(int idHabitacionArea) => "reservaciones/habitacion/$idHabitacionArea";

  static String obtenerPorFechas = "reservaciones/fechas/";
  
}


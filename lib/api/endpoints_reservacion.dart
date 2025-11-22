// aqui se definen las rutas para hacer peticiones a los endpoints especificos de reservaciones, se requiere utilizar
// rutas relativas es decir sin "/" al inicio por ejemplo "/reservaciones/" esto seria incorrecto
// lo correcto es "reservaciones/"

class EndpointsReservacion {
  // Endpoints de reservaciones

  //[GET]: listado de reservaciones
  static const String list = "reservaciones/";

  // Método helper para construir endpoint de detalle de reservacion
  static String detail(int reservacionId) => "reservaciones/$reservacionId";

  // Método helper para construir endpoint de habitaciones reservadas por cliente
  static String habitacionesReservadasCliente(int clienteId) => "reservaciones/cliente/$clienteId/habitaciones";

   // Método helper para construir endpoint de habitaciones reservadas por usuario
  static String reservasCliente(int clienteId) => "reservaciones/cliente/$clienteId";

}

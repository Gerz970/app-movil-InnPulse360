// aqui se definen las rutas para hacer peticiones a los endpoints especificos de empleados, se requiere utilizar
// rutas relativas es decir sin "/" al inicio por ejemplo "/empleado/" esto seria incorrecto
// lo correcto es "empleado/"

class EndpointsEmpleado {
  // Endpoints de empleados

  // Método helper para construir endpoint de empleados por hotel
  static String empleadoHotel(int hotelId) => "empleado/empleado-hotel/$hotelId";
  
  // Método helper para construir endpoint de hoteles por empleado
  static String hotelesPorEmpleado(int empleadoId) => "empleado/hoteles-por-empleado/$empleadoId";
}

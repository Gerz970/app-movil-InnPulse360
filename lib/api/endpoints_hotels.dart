// aqui se definen las rutas para hacer peticiones a los endpoints especificos de hoteles, se requiere utilizar
// rutas relativas es decir sin "/" al inicio por ejemplo "/hotel/" esto seria incorrecto
// lo correcto es "hotel/"

class EndpointsHotels {
  // Endpoints de hoteles

  //[GET]: listado de hoteles
  static const String list = "hotel/";
  
  //[GET]: catálogo de países
  static const String paises = "paises/";
  
  //[GET]: catálogo de estados
  static const String estados = "estados/";
  
  // Método helper para construir endpoint de detalle de hotel
  static String detail(int hotelId) => "hotel/$hotelId";
  
  // Método helper para construir endpoint de país por ID
  static String paisById(int idPais) => "paises/$idPais";
  
  // Método helper para construir endpoint de estado por ID
  static String estadoById(int idEstado) => "estados/$idEstado";
  
  // Método helper para construir endpoint de actualizar foto de hotel
  static String actualizarFotoHotel(int idHotel) => "hotel/$idHotel/foto-perfil";
  
  // Método helper para construir endpoint de eliminar foto de hotel
  static String eliminarFotoHotel(int idHotel) => "hotel/$idHotel/foto-perfil";
}


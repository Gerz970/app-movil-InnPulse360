// aqui se definen las rutas para hacer peticiones a los endpoints especificos de incidencias, se requiere utilizar
// rutas relativas es decir sin "/" al inicio por ejemplo "/incidencias/" esto seria incorrecto
// lo correcto es "incidencias/"

class EndpointsIncidencias {
  // Endpoints de incidencias

  //[GET]: listado de incidencias
  static const String list = "incidencias/";
  
  // Método helper para construir endpoint de detalle de incidencia
  static String detail(int incidenciaId) => "incidencias/$incidenciaId";
  
  // Método helper para construir endpoint de galería de incidencia
  static String galeria(int incidenciaId) => "incidencias/$incidenciaId/galeria";
  
  // Método helper para construir endpoint de eliminar imagen específica de galería
  static String galeriaImagen(int incidenciaId, String nombreArchivo) => 
      "incidencias/$incidenciaId/galeria/$nombreArchivo";
}


// aqui se definen las rutas para hacer peticiones a los endpoints especificos de limpieza, se requiere utilizar
// rutas relativas es decir sin "/" al inicio por ejemplo "/limpiezas/" esto seria incorrecto
// lo correcto es "limpiezas/"

class EndpointsLimpieza {
  // Endpoints de limpiezas

  //[GET]: listado de limpiezas
  static const String list = "limpiezas/";

  // Método helper para construir endpoint de limpiezas por estatus
  static String estatus(int estatusLimpiezaId) => "limpiezas/estatus/$estatusLimpiezaId";

  // Método helper para construir endpoint de limpiezas por empleado
  static String porEmpleado(int empleadoId) => "limpiezas/empleado/$empleadoId";

  // Método helper para construir endpoint de detalle de limpieza
  static String detail(int limpiezaId) => "limpiezas/$limpiezaId";

  // Método helper para construir endpoint de galería de limpieza
  static String galeria(int limpiezaId, String tipo) => "limpiezas/$limpiezaId/galeria?tipo=$tipo";

  // Método helper para construir endpoint de eliminar foto de galería
  static String deleteFoto(int limpiezaId, String nombreArchivo, String tipo) => "limpiezas/$limpiezaId/galeria/$nombreArchivo?tipo=$tipo";
}

// aqui se definen las rutas para hacer peticiones a los endpoints especificos de limpieza, se requiere utilizar
// rutas relativas es decir sin "/" al inicio por ejemplo "/limpiezas/" esto seria incorrecto
// lo correcto es "limpiezas/"

class EndpointsLimpieza {
  // Endpoints de limpiezas

  //[GET]: listado de limpiezas
  static const String list = "limpiezas/";

  // Método helper para construir endpoint de limpiezas por estatus
  static String estatus(int estatusLimpiezaId) => "limpiezas/estatus/$estatusLimpiezaId";

  // Método helper para construir endpoint de detalle de limpieza
  static String detail(int limpiezaId) => "limpiezas/$limpiezaId";
}

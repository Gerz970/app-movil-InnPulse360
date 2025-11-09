// aqui se definen las rutas para hacer peticiones a los endpoints especificos de clientes, se requiere utilizar
// rutas relativas es decir sin "/" al inicio por ejemplo "/clientes/" esto seria incorrecto
// lo correcto es "clientes/"

class EndpointsClientes {
  // Endpoints de clientes

  //[GET]: listado de clientes
  static const String list = "clientes/";
  
  // Método helper para construir endpoint de detalle de cliente
  static String detail(int clienteId) => "clientes/$clienteId";
}


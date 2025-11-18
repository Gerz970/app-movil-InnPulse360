// aqui se definen las rutas para hacer peticiones a los endpoints especificos de perfil, se requiere utilizar
// rutas relativas es decir sin "/" al inicio por ejemplo "/usuarios/me/profile" esto seria incorrecto
// lo correcto es "usuarios/me/profile"

class EndpointsPerfil {
  // Endpoints de perfil de usuario

  //[GET]: obtener perfil actual del usuario autenticado
  static const String obtenerPerfil = "usuarios/me/profile";
  
  //[PUT]: actualizar perfil actual del usuario autenticado
  static const String actualizarPerfil = "usuarios/me/profile";
  
  //[PUT]: actualizar foto de perfil de usuario
  // Método helper para construir endpoint de foto de perfil
  static String actualizarFotoPerfil(int idUsuario) => "imagenes/foto/perfil/$idUsuario";
  
  //[DELETE]: eliminar/restaurar foto de perfil por defecto
  // Método helper para construir endpoint de eliminar foto de perfil
  static String eliminarFotoPerfil(int idUsuario) => "imagenes/foto/perfil/$idUsuario";
  
  //[POST]: cambiar contraseña temporal
  static const String cambiarPasswordTemporal = "usuarios/cambiar-password-temporal";
}


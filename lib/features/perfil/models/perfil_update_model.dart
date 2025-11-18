/*
  Modelo para actualizar el perfil de usuario
  Todos los campos son opcionales para permitir actualizaciones parciales
*/

class PerfilUpdate {
  final String? login;
  final String? correoElectronico;

  PerfilUpdate({
    this.login,
    this.correoElectronico,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = {};
    
    if (login != null && login!.isNotEmpty) {
      json['login'] = login;
    }
    
    if (correoElectronico != null && correoElectronico!.isNotEmpty) {
      json['correo_electronico'] = correoElectronico;
    }
    
    return json;
  }

  // Verificar si hay datos para actualizar
  bool get tieneDatos => (login != null && login!.isNotEmpty) || 
                         (correoElectronico != null && correoElectronico!.isNotEmpty);
}


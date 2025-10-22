/// Entidad de Usuario del dominio
/// Representa un usuario en el sistema (lógica de negocio pura)
/// No depende de ninguna librería externa
class Usuario {
  final int id;
  final String login;
  final String correoElectronico;
  
  const Usuario({
    required this.id,
    required this.login,
    required this.correoElectronico,
  });
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    
    return other is Usuario &&
        other.id == id &&
        other.login == login &&
        other.correoElectronico == correoElectronico;
  }
  
  @override
  int get hashCode => id.hashCode ^ login.hashCode ^ correoElectronico.hashCode;
  
  @override
  String toString() {
    return 'Usuario(id: $id, login: $login, correo: $correoElectronico)';
  }
}


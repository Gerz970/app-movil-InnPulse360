import '../../dominio/entidades/usuario.dart';

/// Modelo de Usuario para la capa de datos
/// Extiende la entidad de dominio y agrega funcionalidad de serialización JSON
/// Este modelo se usa para convertir datos JSON de la API a objetos Dart
class UsuarioModelo extends Usuario {
  const UsuarioModelo({
    required super.id,
    required super.login,
    required super.correoElectronico,
  });
  
  /// Crear UsuarioModelo desde JSON
  /// Convierte la respuesta de la API al modelo
  /// JSON esperado: { "id_usuario": 1, "login": "juan.perez", "correo_electronico": "juan@gmail.com" }
  factory UsuarioModelo.desdeJson(Map<String, dynamic> json) {
    return UsuarioModelo(
      id: json['id_usuario'] as int,
      login: json['login'] as String,
      correoElectronico: json['correo_electronico'] as String,
    );
  }
  
  /// Convertir UsuarioModelo a JSON
  /// Para enviar datos a la API
  Map<String, dynamic> aJson() {
    return {
      'id_usuario': id,
      'login': login,
      'correo_electronico': correoElectronico,
    };
  }
  
  /// Convertir a entidad de dominio
  /// Para usar en la capa de dominio
  Usuario aEntidad() {
    return Usuario(
      id: id,
      login: login,
      correoElectronico: correoElectronico,
    );
  }
}


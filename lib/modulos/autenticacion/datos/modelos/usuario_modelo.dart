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
    // Buscar el ID con diferentes nombres posibles
    int? id;
    if (json['id_usuario'] != null) {
      id = json['id_usuario'] as int;
    } else if (json['id'] != null) {
      id = json['id'] as int;
    } else if (json['user_id'] != null) {
      id = json['user_id'] as int;
    } else {
      throw ArgumentError('No se encontró el campo de ID. Campos disponibles: ${json.keys.join(', ')}');
    }
    
    // Buscar el login con diferentes nombres posibles
    String? login;
    if (json['login'] != null) {
      login = json['login'] as String;
    } else if (json['username'] != null) {
      login = json['username'] as String;
    } else if (json['user_name'] != null) {
      login = json['user_name'] as String;
    } else {
      throw ArgumentError('No se encontró el campo de login. Campos disponibles: ${json.keys.join(', ')}');
    }
    
    // Buscar el correo con diferentes nombres posibles
    String? correo;
    if (json['correo_electronico'] != null) {
      correo = json['correo_electronico'] as String;
    } else if (json['email'] != null) {
      correo = json['email'] as String;
    } else if (json['correo'] != null) {
      correo = json['correo'] as String;
    } else {
      throw ArgumentError('No se encontró el campo de correo. Campos disponibles: ${json.keys.join(', ')}');
    }
    
    return UsuarioModelo(
      id: id,
      login: login,
      correoElectronico: correo,
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


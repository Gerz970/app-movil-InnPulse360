class UsuarioChatModel {
  final int idUsuario;
  final String login;
  final String nombre;
  final String? urlFotoPerfil;
  final String tipoUsuario; // 'Administrador', 'Empleado', etc.
  final int? empleadoId; // Solo si es empleado

  UsuarioChatModel({
    required this.idUsuario,
    required this.login,
    required this.nombre,
    this.urlFotoPerfil,
    required this.tipoUsuario,
    this.empleadoId,
  });

  factory UsuarioChatModel.fromJson(Map<String, dynamic> json) {
    return UsuarioChatModel(
      idUsuario: json['id_usuario'] as int,
      login: json['login'] as String,
      nombre: json['nombre'] as String,
      urlFotoPerfil: json['url_foto_perfil'] as String?,
      tipoUsuario: json['tipo_usuario'] as String,
      empleadoId: json['empleado_id'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_usuario': idUsuario,
      'login': login,
      'nombre': nombre,
      'url_foto_perfil': urlFotoPerfil,
      'tipo_usuario': tipoUsuario,
      'empleado_id': empleadoId,
    };
  }
}


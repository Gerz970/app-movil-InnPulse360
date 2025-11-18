/*
  Modelo para la respuesta del perfil de usuario obtenido del API
  Incluye información básica del usuario y sus roles
*/

import 'rol_simple_model.dart';

class UsuarioPerfil {
  final int idUsuario;
  final String login;
  final String correoElectronico;
  final int estatusId;
  final List<RolSimple> roles;
  final String? urlFotoPerfil;

  UsuarioPerfil({
    required this.idUsuario,
    required this.login,
    required this.correoElectronico,
    required this.estatusId,
    required this.roles,
    this.urlFotoPerfil,
  });

  factory UsuarioPerfil.fromJson(Map<String, dynamic> json) {
    // Parsear roles si existen
    List<RolSimple> rolesList = [];
    if (json['roles'] != null && json['roles'] is List) {
      rolesList = (json['roles'] as List)
          .map((rol) => RolSimple.fromJson(rol as Map<String, dynamic>))
          .toList();
    }

    return UsuarioPerfil(
      idUsuario: json['id_usuario'] as int? ?? 0,
      login: json['login'] as String? ?? '',
      correoElectronico: json['correo_electronico'] as String? ?? '',
      estatusId: json['estatus_id'] as int? ?? 1,
      roles: rolesList,
      urlFotoPerfil: json['url_foto_perfil'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_usuario': idUsuario,
      'login': login,
      'correo_electronico': correoElectronico,
      'estatus_id': estatusId,
      'roles': roles.map((rol) => rol.toJson()).toList(),
      'url_foto_perfil': urlFotoPerfil,
    };
  }

  // Helper para obtener nombres de roles como string
  String get nombresRoles {
    if (roles.isEmpty) return 'Sin roles';
    return roles.map((rol) => rol.rol).join(', ');
  }

  // Helper para verificar si está activo
  bool get estaActivo => estatusId == 1;
}


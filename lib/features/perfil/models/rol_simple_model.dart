/*
  Modelo para representar un rol simple del usuario
*/

class RolSimple {
  final int idRol;
  final String rol;

  RolSimple({
    required this.idRol,
    required this.rol,
  });

  factory RolSimple.fromJson(Map<String, dynamic> json) {
    return RolSimple(
      idRol: json['id_rol'] as int? ?? 0,
      rol: json['rol'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_rol': idRol,
      'rol': rol,
    };
  }
}


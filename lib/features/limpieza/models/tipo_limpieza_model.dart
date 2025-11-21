/*
  Modelo independiente para Tipo de Limpieza
  Usado para el selector de tipos de limpieza en la creación
*/

/// Modelo para Tipo de Limpieza (independiente)
class TipoLimpieza {
  final int idTipoLimpieza;
  final String nombreTipo;
  final String descripcion;
  final int idEstatus;

  TipoLimpieza({
    required this.idTipoLimpieza,
    required this.nombreTipo,
    required this.descripcion,
    required this.idEstatus,
  });

  factory TipoLimpieza.fromJson(Map<String, dynamic> json) {
    return TipoLimpieza(
      idTipoLimpieza: json['id_tipo_limpieza'] as int? ?? 0,
      nombreTipo: json['nombre_tipo'] as String? ?? '',
      descripcion: json['descripcion'] as String? ?? '',
      idEstatus: json['id_estatus'] as int? ?? 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_tipo_limpieza': idTipoLimpieza,
      'nombre_tipo': nombreTipo,
      'descripcion': descripcion,
      'id_estatus': idEstatus,
    };
  }
}


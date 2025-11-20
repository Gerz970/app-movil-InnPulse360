class HabitacionArea {
  final int idHabitacionArea;
  final int pisoId;
  final int tipoHabitacionId;
  final String nombreClave;
  final String descripcion;
  final int estatusId;

  HabitacionArea({
    required this.idHabitacionArea,
    required this.pisoId,
    required this.tipoHabitacionId,
    required this.nombreClave,
    required this.descripcion,
    required this.estatusId,
  });

  factory HabitacionArea.fromJson(Map<String, dynamic> json) {
    return HabitacionArea(
      idHabitacionArea: json['id_habitacion_area'] as int? ?? 0,
      pisoId: json['piso_id'] as int? ?? 0,
      tipoHabitacionId: json['tipo_habitacion_id'] as int? ?? 0,
      nombreClave: json['nombre_clave'] as String? ?? '',
      descripcion: json['descripcion'] as String? ?? '',
      estatusId: json['estatus_id'] as int? ?? 1,
    );
  }
}


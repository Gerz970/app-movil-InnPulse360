/*
  Este modelo es para definir la estructura de una Habitación/Área obtenida del API
  Usado como modelo anidado en las incidencias
*/

class HabitacionArea {
  // Atributos del modelo
  final int idHabitacionArea;
  final String nombreClave;
  final String? descripcion;
  final int? pisoId;
  final int? tipoHabitacionId;
  final int? estatusId;

  // Constructor con valores por defecto para null-safety
  HabitacionArea({
    required this.idHabitacionArea,
    required this.nombreClave,
    this.descripcion,
    this.pisoId,
    this.tipoHabitacionId,
    this.estatusId,
  });

  // Método para deserializar desde JSON
  factory HabitacionArea.fromJson(Map<String, dynamic> json) {
    return HabitacionArea(
      idHabitacionArea: json['id_habitacion_area'] as int? ?? 0,
      nombreClave: json['nombre_clave'] as String? ?? '',
      descripcion: json['descripcion'] as String?,
      pisoId: json['piso_id'] as int?,
      tipoHabitacionId: json['tipo_habitacion_id'] as int?,
      estatusId: json['estatus_id'] as int?,
    );
  }
}


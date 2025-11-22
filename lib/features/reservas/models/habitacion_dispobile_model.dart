class HabitacionDisponible {
  final int idHabitacionArea;
  final String nombreClave;
  final String descripcion;

  HabitacionDisponible({
    required this.idHabitacionArea,
    required this.nombreClave,
    required this.descripcion,
  });

  factory HabitacionDisponible.fromJson(Map<String, dynamic> json) {
    return HabitacionDisponible(
      idHabitacionArea: json['id_habitacion_area'],
      nombreClave: json['nombre_clave'],
      descripcion: json['descripcion'],
    );
  }
}

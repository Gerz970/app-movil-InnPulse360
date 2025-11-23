class HabitacionDisponible {
  final int idHabitacionArea;
  final String nombreClave;
  final String descripcion;
  String imagenUrl;

  HabitacionDisponible({
    required this.idHabitacionArea,
    required this.nombreClave,
    required this.descripcion,
    required this.imagenUrl,
  });

  factory HabitacionDisponible.fromJson(Map<String, dynamic> json) {
    return HabitacionDisponible(
      idHabitacionArea: json['id_habitacion_area'],
      nombreClave: json['nombre_clave'],
      descripcion: json['descripcion'],
      imagenUrl: json['imagen_url'] ?? "", 
    );
  }
}

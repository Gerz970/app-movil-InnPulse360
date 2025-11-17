class Piso {
  final int idPiso;
  final int idHotel;
  final int numeroPisos;
  final String nombre;
  final String descripcion;
  final int estatusId;

  Piso({
    required this.idPiso,
    required this.idHotel,
    required this.numeroPisos,
    required this.nombre,
    required this.descripcion,
    required this.estatusId,
  });

  factory Piso.fromJson(Map<String, dynamic> json) {
    return Piso(
      idPiso: json['id_piso'] as int ?? 0,
      idHotel: json['id_hotel'] as int ?? 0,
      numeroPisos: json['numero_pisos'] as int ?? 0,
      nombre: json['nombre'] as String? ?? '',
      descripcion: json['descripcion'] as String? ?? '',
      estatusId: json['estatus_id'] as int ?? 0,
    );
  }
}

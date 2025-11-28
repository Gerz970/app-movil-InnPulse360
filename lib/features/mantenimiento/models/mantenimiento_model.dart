class Mantenimiento {
  final int idMantenimiento;
  final String descripcion;
  final DateTime fecha;
  final DateTime? fechaTermino;
  final int empleadoId;
  final int estatus;

  Mantenimiento({
    required this.idMantenimiento,
    required this.descripcion,
    required this.fecha,
    this.fechaTermino,
    required this.empleadoId,
    required this.estatus,
  });

  factory Mantenimiento.fromJson(Map<String, dynamic> json) {
    return Mantenimiento(
      idMantenimiento: json["id_mantenimiento"],
      descripcion: json["descripcion"],
      fecha: DateTime.parse(json["fecha"]),
      fechaTermino:
          json["fecha_termino"] != null ? DateTime.parse(json["fecha_termino"]) : null,
      empleadoId: json["empleado_id"],
      estatus: json["estatus"],
    );
  }

  String get fechaFormateada =>
      "${fecha.day}/${fecha.month}/${fecha.year} ${fecha.hour}:${fecha.minute.toString().padLeft(2, '0')}";
}

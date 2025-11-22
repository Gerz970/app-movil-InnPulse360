class Reservacion {
  final int idReservacion;
  final int clienteId;
  final int habitacionAreaId;
  final String fechaReserva;
  final String fechaSalida;
  final int duracion;
  final int idEstatus;

  final Habitacion habitacion;
  final Cliente cliente;

  Reservacion({
    required this.idReservacion,
    required this.clienteId,
    required this.habitacionAreaId,
    required this.fechaReserva,
    required this.fechaSalida,
    required this.duracion,
    required this.idEstatus,
    required this.habitacion,
    required this.cliente,
  });

  factory Reservacion.fromJson(Map<String, dynamic> json) {
    return Reservacion(
      idReservacion: json['id_reservacion'],
      clienteId: json['cliente_id'],
      habitacionAreaId: json['habitacion_area_id'],
      fechaReserva: json['fecha_reserva'],
      fechaSalida: json['fecha_salida'],
      duracion: json['duracion'],
      idEstatus: json['id_estatus'],
      habitacion: Habitacion.fromJson(json['habitacion']),
      cliente: Cliente.fromJson(json['cliente']),
    );
  }
}

class Habitacion {
  final String nombreClave;
  final String descripcion;

  Habitacion({
    required this.nombreClave,
    required this.descripcion,
  });

  factory Habitacion.fromJson(Map<String, dynamic> json) {
    return Habitacion(
      nombreClave: json['nombre_clave'],
      descripcion: json['descripcion'],
    );
  }
}

class Cliente {
  final String nombre;
  final String apellidoPaterno;
  final String apellidoMaterno;

  Cliente({
    required this.nombre,
    required this.apellidoPaterno,
    required this.apellidoMaterno,
  });

  factory Cliente.fromJson(Map<String, dynamic> json) {
    return Cliente(
      nombre: json['nombre_razon_social'],
      apellidoPaterno: json['apellido_paterno'],
      apellidoMaterno: json['apellido_materno'],
    );
  }
}

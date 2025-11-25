class ServicioTransporteModel {
  final int? idServicioTransporte;
  final String destino;
  final DateTime fechaServicio;
  final String horaServicio;
  final int? idEstatus;
  final int? empleadoId;
  final String? observacionesCliente;
  final String? observacionesEmpleado;
  final int? calificacionViaje;
  final double costoViaje;
  
  // Nuevos campos de geolocalización
  final double? latitudOrigen;
  final double? longitudOrigen;
  final double? latitudDestino;
  final double? longitudDestino;
  final String? direccionOrigen;
  final String? direccionDestino;
  final double? distanciaKm;

  ServicioTransporteModel({
    this.idServicioTransporte,
    required this.destino,
    required this.fechaServicio,
    required this.horaServicio,
    this.idEstatus,
    this.empleadoId,
    this.observacionesCliente,
    this.observacionesEmpleado,
    this.calificacionViaje,
    required this.costoViaje,
    this.latitudOrigen,
    this.longitudOrigen,
    this.latitudDestino,
    this.longitudDestino,
    this.direccionOrigen,
    this.direccionDestino,
    this.distanciaKm,
  });

  Map<String, dynamic> toJson() => {
    if (idServicioTransporte != null) 'id_servicio_transporte': idServicioTransporte,
    'destino': destino,
    'fecha_servicio': fechaServicio.toIso8601String().split('T')[0],
    'hora_servicio': horaServicio,
    if (idEstatus != null) 'id_estatus': idEstatus,
    if (empleadoId != null) 'empleado_id': empleadoId,
    if (observacionesCliente != null) 'observaciones_cliente': observacionesCliente,
    if (observacionesEmpleado != null) 'observaciones_empleado': observacionesEmpleado,
    if (calificacionViaje != null) 'calificacion_viaje': calificacionViaje,
    'costo_viaje': costoViaje,
    if (latitudOrigen != null) 'latitud_origen': latitudOrigen,
    if (longitudOrigen != null) 'longitud_origen': longitudOrigen,
    if (latitudDestino != null) 'latitud_destino': latitudDestino,
    if (longitudDestino != null) 'longitud_destino': longitudDestino,
    if (direccionOrigen != null) 'direccion_origen': direccionOrigen,
    if (direccionDestino != null) 'direccion_destino': direccionDestino,
    if (distanciaKm != null) 'distancia_km': distanciaKm,
  };

  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  factory ServicioTransporteModel.fromJson(Map<String, dynamic> json) => ServicioTransporteModel(
    idServicioTransporte: json['id_servicio_transporte'],
    destino: json['destino'],
    fechaServicio: DateTime.parse(json['fecha_servicio']),
    horaServicio: json['hora_servicio'],
    idEstatus: json['id_estatus'],
    empleadoId: json['empleado_id'],
    observacionesCliente: json['observaciones_cliente'],
    observacionesEmpleado: json['observaciones_empleado'],
    calificacionViaje: json['calificacion_viaje'],
    costoViaje: _parseDouble(json['costo_viaje']) ?? 0.0,
    latitudOrigen: _parseDouble(json['latitud_origen']),
    longitudOrigen: _parseDouble(json['longitud_origen']),
    latitudDestino: _parseDouble(json['latitud_destino']),
    longitudDestino: _parseDouble(json['longitud_destino']),
    direccionOrigen: json['direccion_origen'],
    direccionDestino: json['direccion_destino'],
    distanciaKm: _parseDouble(json['distancia_km']),
  );
}

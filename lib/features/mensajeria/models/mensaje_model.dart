class MensajeModel {
  final int idMensaje;
  final int conversacionId;
  final int remitenteId;
  final String contenido;
  final DateTime fechaEnvio;
  final DateTime? fechaLeido;
  final int idEstatus;
  final List<dynamic> adjuntos; // Por ahora vacío, se puede expandir después

  MensajeModel({
    required this.idMensaje,
    required this.conversacionId,
    required this.remitenteId,
    required this.contenido,
    required this.fechaEnvio,
    this.fechaLeido,
    required this.idEstatus,
    this.adjuntos = const [],
  });

  factory MensajeModel.fromJson(Map<String, dynamic> json) {
    return MensajeModel(
      idMensaje: json['id_mensaje'] as int,
      conversacionId: json['conversacion_id'] as int,
      remitenteId: json['remitente_id'] as int,
      contenido: json['contenido'] as String,
      fechaEnvio: DateTime.parse(json['fecha_envio'] as String),
      fechaLeido: json['fecha_leido'] != null
          ? DateTime.parse(json['fecha_leido'] as String)
          : null,
      idEstatus: json['id_estatus'] as int,
      adjuntos: json['adjuntos'] as List<dynamic>? ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_mensaje': idMensaje,
      'conversacion_id': conversacionId,
      'remitente_id': remitenteId,
      'contenido': contenido,
      'fecha_envio': fechaEnvio.toIso8601String(),
      'fecha_leido': fechaLeido?.toIso8601String(),
      'id_estatus': idEstatus,
      'adjuntos': adjuntos,
    };
  }

  // Getter para verificar si el mensaje es del usuario actual
  bool esMio(int usuarioActualId) {
    return remitenteId == usuarioActualId;
  }

  // Getter para verificar si el mensaje está leído
  bool get estaLeido => fechaLeido != null;
}


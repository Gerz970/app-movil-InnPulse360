import 'mensaje_model.dart';

class ConversacionModel {
  final int idConversacion;
  final String tipoConversacion;
  final int usuario1Id;
  final int usuario2Id;
  final int? clienteId;
  final int? empleado1Id;
  final int? empleado2Id;
  final DateTime fechaCreacion;
  final DateTime? fechaUltimoMensaje;
  final int idEstatus;
  
  // Campos adicionales para UI
  final MensajeModel? ultimoMensaje;
  final int contadorNoLeidos;
  final int? otroUsuarioId;
  final String? otroUsuarioNombre;
  final String? otroUsuarioFoto;

  ConversacionModel({
    required this.idConversacion,
    required this.tipoConversacion,
    required this.usuario1Id,
    required this.usuario2Id,
    this.clienteId,
    this.empleado1Id,
    this.empleado2Id,
    required this.fechaCreacion,
    this.fechaUltimoMensaje,
    required this.idEstatus,
    this.ultimoMensaje,
    this.contadorNoLeidos = 0,
    this.otroUsuarioId,
    this.otroUsuarioNombre,
    this.otroUsuarioFoto,
  });

  factory ConversacionModel.fromJson(Map<String, dynamic> json) {
    return ConversacionModel(
      idConversacion: json['id_conversacion'] as int,
      tipoConversacion: json['tipo_conversacion'] as String,
      usuario1Id: json['usuario1_id'] as int,
      usuario2Id: json['usuario2_id'] as int,
      clienteId: json['cliente_id'] as int?,
      empleado1Id: json['empleado1_id'] as int?,
      empleado2Id: json['empleado2_id'] as int?,
      fechaCreacion: DateTime.parse(json['fecha_creacion'] as String),
      fechaUltimoMensaje: json['fecha_ultimo_mensaje'] != null
          ? DateTime.parse(json['fecha_ultimo_mensaje'] as String)
          : null,
      idEstatus: json['id_estatus'] as int,
      ultimoMensaje: json['ultimo_mensaje'] != null
          ? MensajeModel.fromJson(json['ultimo_mensaje'] as Map<String, dynamic>)
          : null,
      contadorNoLeidos: json['contador_no_leidos'] as int? ?? 0,
      otroUsuarioId: json['otro_usuario_id'] as int?,
      otroUsuarioNombre: json['otro_usuario_nombre'] as String?,
      otroUsuarioFoto: json['otro_usuario_foto'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_conversacion': idConversacion,
      'tipo_conversacion': tipoConversacion,
      'usuario1_id': usuario1Id,
      'usuario2_id': usuario2Id,
      'cliente_id': clienteId,
      'empleado1_id': empleado1Id,
      'empleado2_id': empleado2Id,
      'fecha_creacion': fechaCreacion.toIso8601String(),
      'fecha_ultimo_mensaje': fechaUltimoMensaje?.toIso8601String(),
      'id_estatus': idEstatus,
      'ultimo_mensaje': ultimoMensaje?.toJson(),
      'contador_no_leidos': contadorNoLeidos,
      'otro_usuario_id': otroUsuarioId,
      'otro_usuario_nombre': otroUsuarioNombre,
      'otro_usuario_foto': otroUsuarioFoto,
    };
  }
}


/*
  Modelo para la respuesta del registro de usuario-cliente
  Usado en el flujo de registro de usuarios
*/

/// Modelo para la información del cliente asociado en la respuesta
class ClienteAsociadoInfo {
  final int idCliente;
  final String nombreRazonSocial;
  final String? rfc;
  final int tipoPersona;
  final String correoElectronico;

  ClienteAsociadoInfo({
    required this.idCliente,
    required this.nombreRazonSocial,
    this.rfc,
    required this.tipoPersona,
    required this.correoElectronico,
  });

  factory ClienteAsociadoInfo.fromJson(Map<String, dynamic> json) {
    return ClienteAsociadoInfo(
      idCliente: json['id_cliente'] as int? ?? 0,
      nombreRazonSocial: json['nombre_razon_social'] as String? ?? '',
      rfc: json['rfc'] as String?,
      tipoPersona: json['tipo_persona'] as int? ?? 1,
      correoElectronico: json['correo_electronico'] as String? ?? '',
    );
  }
}

/// Modelo para la respuesta del registro de usuario-cliente
class RegistroClienteResponseModel {
  /// Indica si el usuario fue creado exitosamente
  final bool usuarioCreado;
  
  /// ID del usuario creado
  final int idUsuario;
  
  /// Login del usuario creado
  final String login;
  
  /// Correo electrónico del usuario
  final String correoElectronico;
  
  /// Información del cliente asociado
  final ClienteAsociadoInfo clienteAsociado;
  
  /// Rol asignado al usuario
  final String rolAsignado;
  
  /// Indica si se generó una contraseña temporal
  final bool passwordTemporalGenerada;
  
  /// Indica si se envió el email con las credenciales
  final bool emailEnviado;
  
  /// Mensaje descriptivo del resultado
  final String mensaje;

  /// Constructor
  RegistroClienteResponseModel({
    required this.usuarioCreado,
    required this.idUsuario,
    required this.login,
    required this.correoElectronico,
    required this.clienteAsociado,
    required this.rolAsignado,
    required this.passwordTemporalGenerada,
    required this.emailEnviado,
    required this.mensaje,
  });

  /// Método para deserializar desde JSON
  factory RegistroClienteResponseModel.fromJson(Map<String, dynamic> json) {
    return RegistroClienteResponseModel(
      usuarioCreado: json['usuario_creado'] as bool? ?? false,
      idUsuario: json['id_usuario'] as int? ?? 0,
      login: json['login'] as String? ?? '',
      correoElectronico: json['correo_electronico'] as String? ?? '',
      clienteAsociado: ClienteAsociadoInfo.fromJson(
        json['cliente_asociado'] as Map<String, dynamic>,
      ),
      rolAsignado: json['rol_asignado'] as String? ?? 'Cliente',
      passwordTemporalGenerada: json['password_temporal_generada'] as bool? ?? false,
      emailEnviado: json['email_enviado'] as bool? ?? false,
      mensaje: json['mensaje'] as String? ?? '',
    );
  }
}


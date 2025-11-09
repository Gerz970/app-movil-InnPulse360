/*
  Este modelo es para definir la estructura de un Cliente obtenido del API
  Incluye todos los campos necesarios para Persona Física y Persona Moral
*/

class Cliente {
  // Atributos del modelo
  final int idCliente;
  final String nombreRazonSocial;
  final String? apellidoPaterno; // Solo para Persona Física
  final String? apellidoMaterno; // Solo para Persona Física
  final String rfc;
  final String? curp; // Solo para Persona Física
  final String? correoElectronico;
  final String? telefono;
  final String? direccion;
  final int? documentoIdentificacion;
  final int? paisId;
  final int? estadoId;
  final int idEstatus; // 1 = Activo, 0 = Inactivo
  final int tipoPersona; // 1 = Física, 2 = Moral
  final String? representante; // Solo para Persona Moral

  // Constructor con valores por defecto para null-safety
  Cliente({
    required this.idCliente,
    required this.nombreRazonSocial,
    this.apellidoPaterno,
    this.apellidoMaterno,
    required this.rfc,
    this.curp,
    this.correoElectronico,
    this.telefono,
    this.direccion,
    this.documentoIdentificacion,
    this.paisId,
    this.estadoId,
    required this.idEstatus,
    required this.tipoPersona,
    this.representante,
  });

  // Método para deserializar desde JSON
  factory Cliente.fromJson(Map<String, dynamic> json) {
    return Cliente(
      idCliente: json['id_cliente'] as int? ?? 0,
      nombreRazonSocial: json['nombre_razon_social'] as String? ?? '',
      apellidoPaterno: json['apellido_paterno'] as String?,
      apellidoMaterno: json['apellido_materno'] as String?,
      rfc: json['rfc'] as String? ?? '',
      curp: json['curp'] as String?,
      correoElectronico: json['correo_electronico'] as String?,
      telefono: json['telefono'] as String?,
      direccion: json['direccion'] as String?,
      documentoIdentificacion: json['documento_identificacion'] as int?,
      paisId: json['pais_id'] as int?,
      estadoId: json['estado_id'] as int?,
      idEstatus: json['id_estatus'] as int? ?? 1,
      tipoPersona: json['tipo_persona'] as int? ?? 1,
      representante: json['representante'] as String?,
    );
  }

  // Método helper para obtener el nombre completo (solo para Persona Física)
  String get nombreCompleto {
    if (tipoPersona == 1 && apellidoPaterno != null) {
      final apellidos = [apellidoPaterno, apellidoMaterno]
          .where((a) => a != null && a.isNotEmpty)
          .join(' ');
      return apellidos.isNotEmpty ? '$nombreRazonSocial $apellidos' : nombreRazonSocial;
    }
    return nombreRazonSocial;
  }

  // Método helper para obtener el texto del tipo de persona
  String get tipoPersonaTexto {
    return tipoPersona == 1 ? 'Física' : 'Moral';
  }
}


/*
  Modelo para la respuesta de verificación de disponibilidad de login y correo
  Usado en el flujo de registro de usuarios
*/

import '../../../features/clientes/models/cliente_model.dart';

/// Modelo para la respuesta de verificación de disponibilidad
class VerificacionDisponibilidadModel {
  /// Indica si el login está disponible
  final bool loginDisponible;
  
  /// Indica si el correo existe en la tabla de clientes
  final bool correoEnClientes;
  
  /// Datos del cliente encontrado (si existe)
  final Cliente? cliente;
  
  /// Indica si puede continuar con el registro
  final bool puedeRegistrar;
  
  /// Indica si el cliente ya tiene un usuario asociado con ese correo
  final bool usuarioYaExiste;
  
  /// Mensaje descriptivo de la verificación
  final String mensaje;

  /// Constructor
  VerificacionDisponibilidadModel({
    required this.loginDisponible,
    required this.correoEnClientes,
    this.cliente,
    required this.puedeRegistrar,
    required this.usuarioYaExiste,
    required this.mensaje,
  });

  /// Método para deserializar desde JSON
  factory VerificacionDisponibilidadModel.fromJson(Map<String, dynamic> json) {
    Cliente? clienteData;
    
    // Si existe cliente en la respuesta, parsearlo
    if (json['cliente'] != null) {
      final clienteJson = json['cliente'] as Map<String, dynamic>;
      // Log para debugging
      print('Parseando cliente desde verificación:');
      print('  JSON del cliente: $clienteJson');
      print('  id_cliente en JSON: ${clienteJson['id_cliente']}');
      
      clienteData = Cliente.fromJson(clienteJson);
      
      // Log del cliente parseado
      print('  Cliente parseado - idCliente: ${clienteData.idCliente}');
    }
    
    return VerificacionDisponibilidadModel(
      loginDisponible: json['login_disponible'] as bool? ?? false,
      correoEnClientes: json['correo_en_clientes'] as bool? ?? false,
      cliente: clienteData,
      puedeRegistrar: json['puede_registrar'] as bool? ?? false,
      usuarioYaExiste: json['usuario_ya_existe'] as bool? ?? false,
      mensaje: json['mensaje'] as String? ?? '',
    );
  }
}


/// Importar la entidad del dominio
import '../../dominio/entidades/respuesta_autenticacion.dart';

/// Modelo de información de contraseña temporal para la capa de datos
/// Representa la información sobre contraseñas temporales que van a expirar
class PasswordTemporalInfoModelo {
  final bool requiereCambio;
  final String passwordExpira;
  final int diasRestantes;
  final String mensaje;
  
  const PasswordTemporalInfoModelo({
    required this.requiereCambio,
    required this.passwordExpira,
    required this.diasRestantes,
    required this.mensaje,
  });
  
  /// Crear PasswordTemporalInfoModelo desde JSON
  /// JSON esperado:
  /// {
  ///   "requiere_cambio": true,
  ///   "password_expira": "2025-10-27T14:30:00",
  ///   "dias_restantes": 5,
  ///   "mensaje": "Debe cambiar su contraseña temporal. Expira en 5 días."
  /// }
  factory PasswordTemporalInfoModelo.desdeJson(Map<String, dynamic> json) {
    // Validar campos requeridos
    if (json['requiere_cambio'] == null) {
      throw ArgumentError('requiere_cambio no puede ser null');
    }
    if (json['password_expira'] == null) {
      throw ArgumentError('password_expira no puede ser null');
    }
    if (json['dias_restantes'] == null) {
      throw ArgumentError('dias_restantes no puede ser null');
    }
    if (json['mensaje'] == null) {
      throw ArgumentError('mensaje no puede ser null');
    }
    
    return PasswordTemporalInfoModelo(
      requiereCambio: json['requiere_cambio'] as bool,
      passwordExpira: json['password_expira'] as String,
      diasRestantes: json['dias_restantes'] as int,
      mensaje: json['mensaje'] as String,
    );
  }
  
  /// Convertir PasswordTemporalInfoModelo a JSON
  Map<String, dynamic> aJson() {
    return {
      'requiere_cambio': requiereCambio,
      'password_expira': passwordExpira,
      'dias_restantes': diasRestantes,
      'mensaje': mensaje,
    };
  }
  
  /// Convertir a entidad de dominio
  PasswordTemporalInfo aEntidad() {
    return PasswordTemporalInfo(
      requiereCambio: requiereCambio,
      passwordExpira: passwordExpira,
      diasRestantes: diasRestantes,
      mensaje: mensaje,
    );
  }
}

import '../../dominio/entidades/respuesta_autenticacion.dart';
import 'usuario_modelo.dart';

/// Modelo de Respuesta de Login para la capa de datos
/// Representa la respuesta del endpoint /api/v1/usuarios/login
/// Estructura JSON esperada de la API
class RespuestaLoginModelo {
  final String tokenAcceso;
  final String tipoToken;
  final int expiraEn;
  final UsuarioModelo informacionUsuario;
  
  const RespuestaLoginModelo({
    required this.tokenAcceso,
    required this.tipoToken,
    required this.expiraEn,
    required this.informacionUsuario,
  });
  
  /// Crear RespuestaLoginModelo desde JSON
  /// Convierte la respuesta de la API al modelo
  /// JSON esperado:
  /// {
  ///   "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  ///   "token_type": "bearer",
  ///   "expires_in": 3600,
  ///   "user_info": {
  ///     "id_usuario": 1,
  ///     "login": "juan.perez",
  ///     "correo_electronico": "juan.perez@gmail.com"
  ///   }
  /// }
  factory RespuestaLoginModelo.desdeJson(Map<String, dynamic> json) {
    return RespuestaLoginModelo(
      tokenAcceso: json['access_token'] as String,
      tipoToken: json['token_type'] as String,
      expiraEn: json['expires_in'] as int,
      informacionUsuario: UsuarioModelo.desdeJson(
        json['user_info'] as Map<String, dynamic>,
      ),
    );
  }
  
  /// Convertir RespuestaLoginModelo a JSON
  /// Para serializar datos si es necesario
  Map<String, dynamic> aJson() {
    return {
      'access_token': tokenAcceso,
      'token_type': tipoToken,
      'expires_in': expiraEn,
      'user_info': informacionUsuario.aJson(),
    };
  }
  
  /// Convertir a entidad de dominio
  /// Para usar en la capa de dominio y presentación
  RespuestaAutenticacion aEntidad() {
    return RespuestaAutenticacion(
      tokenAcceso: tokenAcceso,
      tipoToken: tipoToken,
      expiraEn: expiraEn,
      usuario: informacionUsuario.aEntidad(),
    );
  }
}


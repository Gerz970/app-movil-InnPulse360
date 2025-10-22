import '../../dominio/entidades/respuesta_autenticacion.dart';
import 'usuario_modelo.dart';
import 'modulo_modelo.dart';
import 'password_temporal_info_modelo.dart';

/// Modelo de Respuesta de Login para la capa de datos
/// Representa la respuesta del endpoint /api/v1/usuarios/login
/// Estructura JSON esperada de la API
class RespuestaLoginModelo {
  final String tokenAcceso;
  final String tipoToken;
  final int expiraEn;
  final UsuarioModelo informacionUsuario;
  final List<ModuloModelo> modulos;
  final PasswordTemporalInfoModelo? passwordTemporalInfo;
  
  const RespuestaLoginModelo({
    required this.tokenAcceso,
    required this.tipoToken,
    required this.expiraEn,
    required this.informacionUsuario,
    required this.modulos,
    this.passwordTemporalInfo,
  });
  
  /// Crear RespuestaLoginModelo desde JSON
  /// Convierte la respuesta de la API al modelo
  /// JSON esperado:
  /// {
  ///   "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  ///   "token_type": "bearer",
  ///   "expires_in": 1800,
  ///   "usuario": {
  ///     "id_usuario": 1,
  ///     "login": "juan.perez",
  ///     "correo_electronico": "juan.perez@gmail.com"
  ///   },
  ///   "modulos": [...],
  ///   "password_temporal_info": {...}
  /// }
  factory RespuestaLoginModelo.desdeJson(Map<String, dynamic> json) {
    // Validar campos requeridos
    if (json['access_token'] == null) {
      throw ArgumentError('access_token no puede ser null');
    }
    if (json['token_type'] == null) {
      throw ArgumentError('token_type no puede ser null');
    }
    if (json['expires_in'] == null) {
      throw ArgumentError('expires_in no puede ser null');
    }
    
    // Buscar el campo de usuario con diferentes nombres posibles
    Map<String, dynamic>? usuarioJson;
    if (json['usuario'] != null) {
      usuarioJson = json['usuario'] as Map<String, dynamic>;
    } else if (json['user'] != null) {
      usuarioJson = json['user'] as Map<String, dynamic>;
    } else if (json['user_info'] != null) {
      usuarioJson = json['user_info'] as Map<String, dynamic>;
    } else {
      throw ArgumentError('No se encontró el campo de usuario. Campos disponibles: ${json.keys.join(', ')}');
    }
    
    final modulosJson = json['modulos'] as List<dynamic>? ?? [];
    final passwordTemporalInfoJson = json['password_temporal_info'] as Map<String, dynamic>?;
    
    return RespuestaLoginModelo(
      tokenAcceso: json['access_token'] as String,
      tipoToken: json['token_type'] as String,
      expiraEn: json['expires_in'] as int,
      informacionUsuario: UsuarioModelo.desdeJson(usuarioJson),
      modulos: modulosJson
          .where((moduloJson) => moduloJson != null)
          .map((moduloJson) => ModuloModelo.desdeJson(moduloJson as Map<String, dynamic>))
          .toList(),
      passwordTemporalInfo: passwordTemporalInfoJson != null
          ? PasswordTemporalInfoModelo.desdeJson(passwordTemporalInfoJson)
          : null,
    );
  }
  
  /// Convertir RespuestaLoginModelo a JSON
  /// Para serializar datos si es necesario
  Map<String, dynamic> aJson() {
    return {
      'access_token': tokenAcceso,
      'token_type': tipoToken,
      'expires_in': expiraEn,
      'usuario': informacionUsuario.aJson(),
      'modulos': modulos.map((modulo) => modulo.aJson()).toList(),
      'password_temporal_info': passwordTemporalInfo?.aJson(),
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
      modulos: modulos.map((modulo) => modulo.aEntidad()).toList(),
      passwordTemporalInfo: passwordTemporalInfo?.aEntidad(),
    );
  }
}


import 'usuario.dart';

/// Entidad que representa la respuesta de autenticación
/// Contiene el token de acceso y la información del usuario
class RespuestaAutenticacion {
  final String tokenAcceso;
  final String tipoToken;
  final int expiraEn;
  final Usuario usuario;
  
  const RespuestaAutenticacion({
    required this.tokenAcceso,
    required this.tipoToken,
    required this.expiraEn,
    required this.usuario,
  });
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    
    return other is RespuestaAutenticacion &&
        other.tokenAcceso == tokenAcceso &&
        other.tipoToken == tipoToken &&
        other.expiraEn == expiraEn &&
        other.usuario == usuario;
  }
  
  @override
  int get hashCode {
    return tokenAcceso.hashCode ^
        tipoToken.hashCode ^
        expiraEn.hashCode ^
        usuario.hashCode;
  }
  
  @override
  String toString() {
    return 'RespuestaAutenticacion(tipo: $tipoToken, expira: ${expiraEn}s, usuario: ${usuario.login})';
  }
}


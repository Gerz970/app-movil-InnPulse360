import 'usuario.dart';

/// Entidad que representa la información de contraseña temporal
class PasswordTemporalInfo {
  final bool requiereCambio;
  final String passwordExpira;
  final int diasRestantes;
  final String mensaje;
  
  const PasswordTemporalInfo({
    required this.requiereCambio,
    required this.passwordExpira,
    required this.diasRestantes,
    required this.mensaje,
  });
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    
    return other is PasswordTemporalInfo &&
        other.requiereCambio == requiereCambio &&
        other.passwordExpira == passwordExpira &&
        other.diasRestantes == diasRestantes &&
        other.mensaje == mensaje;
  }
  
  @override
  int get hashCode {
    return requiereCambio.hashCode ^
        passwordExpira.hashCode ^
        diasRestantes.hashCode ^
        mensaje.hashCode;
  }
}

/// Entidad que representa un módulo del sistema
class Modulo {
  final int idModulo;
  final String nombre;
  final String descripcion;
  final String icono;
  final String ruta;
  
  const Modulo({
    required this.idModulo,
    required this.nombre,
    required this.descripcion,
    required this.icono,
    required this.ruta,
  });
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    
    return other is Modulo &&
        other.idModulo == idModulo &&
        other.nombre == nombre &&
        other.descripcion == descripcion &&
        other.icono == icono &&
        other.ruta == ruta;
  }
  
  @override
  int get hashCode {
    return idModulo.hashCode ^
        nombre.hashCode ^
        descripcion.hashCode ^
        icono.hashCode ^
        ruta.hashCode;
  }
}

/// Entidad que representa la respuesta de autenticación
/// Contiene el token de acceso, información del usuario, módulos y estado de contraseña temporal
class RespuestaAutenticacion {
  final String tokenAcceso;
  final String tipoToken;
  final int expiraEn;
  final Usuario usuario;
  final List<Modulo> modulos;
  final PasswordTemporalInfo? passwordTemporalInfo;
  
  const RespuestaAutenticacion({
    required this.tokenAcceso,
    required this.tipoToken,
    required this.expiraEn,
    required this.usuario,
    required this.modulos,
    this.passwordTemporalInfo,
  });
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    
    return other is RespuestaAutenticacion &&
        other.tokenAcceso == tokenAcceso &&
        other.tipoToken == tipoToken &&
        other.expiraEn == expiraEn &&
        other.usuario == usuario &&
        other.modulos == modulos &&
        other.passwordTemporalInfo == passwordTemporalInfo;
  }
  
  @override
  int get hashCode {
    return tokenAcceso.hashCode ^
        tipoToken.hashCode ^
        expiraEn.hashCode ^
        usuario.hashCode ^
        modulos.hashCode ^
        passwordTemporalInfo.hashCode;
  }
  
  @override
  String toString() {
    return 'RespuestaAutenticacion(tipo: $tipoToken, expira: ${expiraEn}s, usuario: ${usuario.login}, modulos: ${modulos.length}, passwordTemporal: ${passwordTemporalInfo != null})';
  }
}


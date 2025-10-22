import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../aplicacion/inyeccion_dependencias/localizador_servicios.dart';
import '../../dominio/casos_uso/iniciar_sesion_caso_uso.dart';
import 'login_estado.dart';

/// Notificador para manejar el estado del login
/// Extiende Notifier de Riverpod para gestionar el estado de forma reactiva
class LoginNotificador extends Notifier<LoginEstado> {
  @override
  LoginEstado build() {
    /// Estado inicial
    return const LoginInicial();
  }
  
  /// Ejecutar el proceso de login
  /// Parámetros:
  ///   - login: nombre de usuario o email
  ///   - password: contraseña del usuario
  Future<void> iniciarSesion({
    required String login,
    required String password,
  }) async {
    /// Obtener el caso de uso desde el ref
    final iniciarSesionCasoUso = ref.read(iniciarSesionCasoUsoProvider);
    
    /// Cambiar estado a cargando
    state = const LoginCargando();
    
    /// Crear parámetros para el caso de uso
    final parametros = ParametrosIniciarSesion(
      login: login,
      password: password,
    );
    
    /// Ejecutar caso de uso
    final resultado = await iniciarSesionCasoUso.ejecutar(parametros);
    
    /// Procesar resultado
    resultado.when(
      exito: (respuesta) {
        /// Login exitoso
        state = LoginExitoso(respuesta);
      },
      error: (falla) {
        /// Login fallido
        state = LoginError(falla.mensaje);
      },
    );
  }
  
  /// Resetear el estado a inicial
  /// Útil para limpiar errores o mensajes
  void resetear() {
    state = const LoginInicial();
  }
}

/// Provider del caso de uso de iniciar sesión
/// Obtiene la instancia del service locator (GetIt)
final iniciarSesionCasoUsoProvider = Provider<IniciarSesionCasoUso>((ref) {
  return sl<IniciarSesionCasoUso>();
});


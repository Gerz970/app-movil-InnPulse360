import 'package:get_it/get_it.dart';
import '../../nucleo/red/cliente_api_base.dart';
import '../../nucleo/almacenamiento/almacenamiento_local.dart';
import '../../modulos/autenticacion/datos/fuentes_datos/autenticacion_fuente_remota.dart';
import '../../modulos/autenticacion/datos/repositorios/repositorio_autenticacion_impl.dart';
import '../../modulos/autenticacion/dominio/repositorios/repositorio_autenticacion.dart';
import '../../modulos/autenticacion/dominio/casos_uso/iniciar_sesion_caso_uso.dart';

/// Localizador de servicios global
/// Maneja la inyección de dependencias usando GetIt
final sl = GetIt.instance;

/// Inicializar todas las dependencias
/// Debe ser llamado al inicio de la aplicación (en main.dart)
Future<void> inicializarDependencias() async {
  // ============================================================
  // NÚCLEO - Servicios base compartidos
  // ============================================================
  
  /// Almacenamiento local (Singleton)
  /// Una sola instancia para toda la app
  sl.registerLazySingleton<AlmacenamientoLocal>(
    () => AlmacenamientoLocal(),
  );
  
  /// Cliente HTTP base (Singleton)
  /// Una sola instancia configurada para todas las peticiones
  sl.registerLazySingleton<ClienteApiBase>(
    () => ClienteApiBase(sl()),
  );
  
  // ============================================================
  // AUTENTICACIÓN - Módulo de login
  // ============================================================
  
  /// Fuente de datos remota de autenticación (Singleton)
  /// Maneja las peticiones HTTP relacionadas con auth
  sl.registerLazySingleton<AutenticacionFuenteRemota>(
    () => AutenticacionFuenteRemotaImpl(sl()),
  );
  
  /// Repositorio de autenticación (Singleton)
  /// Implementación del contrato de dominio
  sl.registerLazySingleton<RepositorioAutenticacion>(
    () => RepositorioAutenticacionImpl(
      fuenteRemota: sl(),
      almacenamiento: sl(),
    ),
  );
  
  /// Caso de uso: Iniciar sesión (Factory)
  /// Nueva instancia cada vez que se solicita
  sl.registerFactory<IniciarSesionCasoUso>(
    () => IniciarSesionCasoUso(sl()),
  );
  
  // Aquí se agregarán más casos de uso conforme se desarrollen
}


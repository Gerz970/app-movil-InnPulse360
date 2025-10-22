# Módulo de Autenticación

Este módulo implementa el proceso de inicio de sesión (login) siguiendo arquitectura limpia.

## Estructura del Módulo

```
autenticacion/
├── datos/                                    # Capa de Datos
│   ├── fuentes_datos/
│   │   └── autenticacion_fuente_remota.dart # Peticiones HTTP
│   ├── modelos/
│   │   ├── usuario_modelo.dart              # DTO de Usuario
│   │   └── respuesta_login_modelo.dart      # DTO de Respuesta Login
│   └── repositorios/
│       └── repositorio_autenticacion_impl.dart  # Implementación
│
├── dominio/                                 # Capa de Dominio
│   ├── entidades/
│   │   ├── usuario.dart                     # Entidad de Usuario
│   │   └── respuesta_autenticacion.dart     # Entidad de Respuesta
│   ├── repositorios/
│   │   └── repositorio_autenticacion.dart   # Contrato
│   └── casos_uso/
│       └── iniciar_sesion_caso_uso.dart     # Lógica de Login
│
└── presentacion/                            # Capa de Presentación
    ├── estado/
    │   ├── login_estado.dart                # Estados del Login
    │   ├── login_notificador.dart           # Notificador Riverpod
    │   └── login_provider.dart              # Providers
    └── paginas/
        └── login_page.dart                  # UI del Login
```

## API Endpoint

### Login
- **URL**: `https://app-interface-innpulse360-production.up.railway.app/api/v1/usuarios/login`
- **Método**: POST
- **Headers**: 
  - Content-Type: application/json
  - Accept: application/json

### Request Body
```json
{
  "login": "juan.perez",
  "password": "123456"
}
```

### Response Exitosa (200)
```json
{
  "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "token_type": "bearer",
  "expires_in": 3600,
  "user_info": {
    "correo_electronico": "juan.perez@gmail.com",
    "id_usuario": 1,
    "login": "juan.perez"
  }
}
```

## Flujo de Datos

1. **Usuario Ingresa Credenciales** → LoginPage (UI)
2. **Presiona Botón de Login** → LoginNotificador
3. **Notificador Ejecuta Caso de Uso** → IniciarSesionCasoUso
4. **Caso de Uso Valida Datos** → Llama a RepositorioAutenticacion
5. **Repositorio Llama DataSource** → AutenticacionFuenteRemota
6. **DataSource Hace Petición HTTP** → API
7. **API Responde** → DataSource convierte JSON a Modelo
8. **Repositorio Guarda Token** → AlmacenamientoLocal
9. **Repositorio Retorna Entidad** → Caso de Uso
10. **Caso de Uso Retorna Resultado** → Notificador
11. **Notificador Actualiza Estado** → UI Reacciona

## Manejo de Estados

### Estados Posibles

```dart
// Estado inicial (pantalla cargada)
LoginInicial()

// Estado de carga (petición en progreso)
LoginCargando()

// Estado de éxito (login exitoso)
LoginExitoso(RespuestaAutenticacion respuesta)

// Estado de error (credenciales incorrectas, error de red, etc.)
LoginError(String mensaje)
```

### Cómo se Usan los Estados

```dart
// En LoginPage
final estadoLogin = ref.watch(loginNotificadorProvider);

// Mostrar loading spinner
if (estadoLogin is LoginCargando) {
  // Mostrar CircularProgressIndicator
}

// Escuchar cambios de estado
ref.listen<LoginEstado>(loginNotificadorProvider, (previous, next) {
  if (next is LoginExitoso) {
    // Mostrar mensaje de éxito
    // Navegar a pantalla principal
  } else if (next is LoginError) {
    // Mostrar mensaje de error
  }
});
```

## Manejo de Errores

### Tipos de Fallas

1. **FallaValidacion**: Datos incorrectos (campos vacíos, contraseña corta)
2. **FallaAutenticacion**: Credenciales incorrectas (401)
3. **FallaRed**: Sin conexión, timeout
4. **FallaServidor**: Error del servidor (500)
5. **FallaDesconocida**: Errores inesperados

### Ejemplo de Conversión de Excepciones

```dart
// En RepositorioAutenticacionImpl
try {
  final respuesta = await fuenteRemota.iniciarSesion(...);
  return Exito(respuesta.aEntidad());
} on ExcepcionAutenticacion catch (e) {
  return Error(FallaAutenticacion(e.mensaje));
} on ExcepcionRed catch (e) {
  return Error(FallaRed(e.mensaje));
}
```

## Almacenamiento de Token

El token se guarda de forma segura usando:
- **FlutterSecureStorage**: Para datos sensibles (token, tipo de token)
- **SharedPreferences**: Para datos no sensibles (expiración, info usuario)

### Datos Guardados

```dart
// Guardado automático después de login exitoso
await almacenamiento.guardarToken(token);
await almacenamiento.guardarTipoToken('bearer');
await almacenamiento.guardarExpiracion(3600);
await almacenamiento.guardarInformacionUsuario(
  idUsuario: 1,
  login: 'juan.perez',
  correoElectronico: 'juan@gmail.com',
);
```

## Uso de la Funcionalidad

### En la UI

```dart
// Obtener valores de los campos
final login = _loginController.text.trim();
final password = _passwordController.text.trim();

// Llamar al notificador para iniciar sesión
ref.read(loginNotificadorProvider.notifier).iniciarSesion(
  login: login,
  password: password,
);
```

### Validaciones Implementadas

1. Login no puede estar vacío
2. Password no puede estar vacío
3. Password debe tener al menos 6 caracteres

## Inyección de Dependencias

### Registro en Service Locator

```dart
// En localizador_servicios.dart

// Cliente HTTP
sl.registerLazySingleton<ClienteApiBase>(() => ClienteApiBase(sl()));

// DataSource
sl.registerLazySingleton<AutenticacionFuenteRemota>(
  () => AutenticacionFuenteRemotaImpl(sl()),
);

// Repositorio
sl.registerLazySingleton<RepositorioAutenticacion>(
  () => RepositorioAutenticacionImpl(
    fuenteRemota: sl(),
    almacenamiento: sl(),
  ),
);

// Caso de Uso
sl.registerFactory<IniciarSesionCasoUso>(
  () => IniciarSesionCasoUso(sl()),
);
```

## Testing

### Ejemplo de Test Unitario

```dart
test('debe retornar RespuestaAutenticacion cuando login es exitoso', () async {
  // Arrange
  final mockRepo = MockRepositorioAutenticacion();
  final casoUso = IniciarSesionCasoUso(mockRepo);
  
  when(mockRepo.iniciarSesion(any, any))
      .thenAnswer((_) async => Exito(respuestaEsperada));
  
  // Act
  final resultado = await casoUso.ejecutar(
    ParametrosIniciarSesion(login: 'test', password: '123456'),
  );
  
  // Assert
  expect(resultado, isA<Exito<RespuestaAutenticacion>>());
});
```

## Funcionalidad Implementada

✅ **Inicio de Sesión (Login)**
- Endpoint: `POST /api/v1/usuarios/login`
- Arquitectura limpia completa (Presentación → Dominio → Datos)
- Manejo robusto de errores
- Almacenamiento seguro de tokens
- Estados de UI (inicial, cargando, exitoso, error)


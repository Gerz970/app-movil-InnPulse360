# Arquitectura del Proyecto App Móvil InnPulse

## Visión General

La aplicación móvil InnPulse es una aplicación Flutter diseñada para la gestión integral de hoteles. Está desarrollada siguiendo principios de arquitectura limpia y separación de responsabilidades, utilizando el patrón **Provider** para la gestión de estado.

## Stack Tecnológico

- **Framework**: Flutter 3.9.2+
- **Lenguaje**: Dart
- **Gestión de Estado**: Provider (ChangeNotifier)
- **HTTP Client**: Dio 5.4.0
- **Navegación**: Material Navigator (preparado para go_router 13.0.0)
- **Almacenamiento Local**: 
  - SharedPreferences 2.2.2 (para sesión)
  - Flutter Secure Storage 9.0.0 (para tokens)
- **Manipulación de Imágenes**: Image Picker 1.0.7, Cached Network Image 3.3.1
- **Permisos**: Permission Handler 11.3.0

## Arquitectura General

El proyecto sigue una arquitectura en capas basada en el patrón **MVVM (Model-View-ViewModel)** con características de **Clean Architecture**:

```
┌─────────────────────────────────────────────┐
│           CAPA DE PRESENTACIÓN              │
│  (Features: Screens, Widgets)              │
└─────────────────────────────────────────────┘
                    ↕
┌─────────────────────────────────────────────┐
│          CAPA DE CONTROLADORES              │
│  (Controllers: State Management)            │
└─────────────────────────────────────────────┘
                    ↕
┌─────────────────────────────────────────────┐
│            CAPA DE SERVICIOS                │
│  (Services: API Communication)              │
└─────────────────────────────────────────────┘
                    ↕
┌─────────────────────────────────────────────┐
│            CAPA DE MODELOS                  │
│  (Models: Data Structures)                  │
└─────────────────────────────────────────────┘
```

## Estructura de Directorios

```
lib/
├── main.dart                          # Punto de entrada de la aplicación
├── api/                               # Configuración de API y Endpoints
│   ├── api_config.dart                # Configuración base del API
│   ├── endpoints_auth.dart            # Endpoints de autenticación
│   ├── endpoints_clientes.dart        # Endpoints de clientes
│   ├── endpoints_hotels.dart          # Endpoints de hoteles
│   └── endpoints_incidencias.dart     # Endpoints de incidencias
├── app/                               # Configuración de la aplicación
│   └── go_routes.dart                 # Configuración de rutas (preparado)
├── core/                              # Componentes centrales compartidos
│   ├── auth/                          # Módulo de autenticación
│   │   ├── controllers/
│   │   │   └── auth_controller.dart   # Controlador de autenticación
│   │   ├── models/
│   │   │   └── request_login_model.dart
│   │   └── services/
│   │       ├── auth_service.dart      # Servicio de autenticación
│   │       └── session_storage.dart   # Almacenamiento de sesión
│   └── sidebar/
│       └── sidebar_controller.dart    # Controlador del sidebar
├── features/                          # Módulos de funcionalidades
│   ├── login/                         # Módulo de login
│   │   ├── login_screen.dart
│   │   └── register_screen.dart
│   ├── home/                          # Módulo de inicio
│   │   └── home_screen.dart
│   ├── clientes/                      # Módulo de clientes
│   │   ├── controllers/
│   │   │   └── cliente_controller.dart
│   │   ├── models/
│   │   │   └── cliente_model.dart
│   │   ├── services/
│   │   │   └── cliente_service.dart
│   │   ├── clientes_list_screen.dart
│   │   ├── cliente_create_screen.dart
│   │   └── cliente_detail_screen.dart
│   ├── hoteles/                       # Módulo de hoteles
│   │   ├── controllers/
│   │   │   └── hotel_controller.dart
│   │   ├── models/
│   │   │   ├── hotel_model.dart
│   │   │   ├── pais_model.dart
│   │   │   └── estado_model.dart
│   │   ├── services/
│   │   │   └── hotel_service.dart
│   │   ├── hotels_list_screen.dart
│   │   ├── hotel_create_screen.dart
│   │   └── hotel_detail_screen.dart
│   ├── incidencias/                   # Módulo de incidencias
│   │   ├── controllers/
│   │   │   └── incidencia_controller.dart
│   │   ├── models/
│   │   │   ├── incidencia_model.dart
│   │   │   ├── habitacion_area_model.dart
│   │   │   └── galeria_imagen_model.dart
│   │   ├── services/
│   │   │   └── incidencia_service.dart
│   │   ├── incidencias_list_screen.dart
│   │   ├── incidencia_create_screen.dart
│   │   ├── incidencia_detail_screen.dart
│   │   ├── incidencia_edit_screen.dart
│   │   ├── incidencia_galeria_screen.dart
│   │   └── incidencia_success_screen.dart
│   └── common/                        # Componentes comunes
│       └── under_construction_screen.dart
└── widgets/                           # Widgets reutilizables
    ├── app_header.dart                # Header global de la aplicación
    └── app_sidebar.dart               # Sidebar de navegación
```

## Capas de la Arquitectura

### 1. Capa de Presentación (UI)

**Responsabilidades**:
- Renderizar la interfaz de usuario
- Capturar interacciones del usuario
- Consumir estados de los controladores mediante `Consumer` o `Provider.of`

**Componentes principales**:
- **Screens**: Pantallas principales de cada módulo
- **Widgets**: Componentes reutilizables compartidos entre módulos

**Ejemplo de flujo**:
```dart
Consumer<AuthController>(
  builder: (context, authController, child) {
    // UI que reacciona a cambios en AuthController
    return Widget();
  },
)
```

### 2. Capa de Controladores (State Management)

**Responsabilidades**:
- Gestionar el estado de cada módulo
- Coordinar las operaciones entre la UI y los servicios
- Notificar cambios a los listeners mediante `ChangeNotifier`

**Patrón utilizado**: `ChangeNotifier` + `Provider`

**Componentes**:
- Controladores por módulo (AuthController, ClienteController, etc.)
- Estados privados para diferentes operaciones (loading, error, data)
- Métodos públicos para operaciones CRUD

**Estructura típica de un controlador**:
```dart
class ClienteController extends ChangeNotifier {
  // Estados privados
  bool _isLoading = false;
  List<Cliente> _clientes = [];
  String? _errorMessage;
  
  // Getters públicos
  bool get isLoading => _isLoading;
  List<Cliente> get clientes => _clientes;
  
  // Métodos públicos
  Future<void> fetchClientes() async { ... }
  
  // Notificar cambios
  notifyListeners();
}
```

### 3. Capa de Servicios (API Layer)

**Responsabilidades**:
- Realizar peticiones HTTP al backend
- Configurar headers, autenticación y timeouts
- Manejar errores de red y del servidor
- Obtener tokens de autenticación desde SessionStorage

**Componentes**:
- Servicios por módulo (AuthService, ClienteService, etc.)
- Instancia de Dio configurada
- Métodos específicos para cada endpoint

**Configuración típica**:
```dart
class ClienteService {
  final Dio _dio;
  final String baseUrl = ApiConfig.baseUrl + ApiConfig.apiVersion;
  
  ClienteService({Dio? dio}) : _dio = dio ?? Dio() {
    _dio.options.connectTimeout = Duration(seconds: 30);
    _dio.options.receiveTimeout = Duration(seconds: 30);
    _dio.options.headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
  }
  
  Future<String?> _getToken() async { ... }
  
  Future<Response> fetchClientes() async { ... }
}
```

### 4. Capa de Modelos (Data Layer)

**Responsabilidades**:
- Definir estructuras de datos
- Serialización/deserialización JSON
- Validación básica de datos

**Componentes**:
- Modelos por entidad (Cliente, Hotel, Incidencia, etc.)
- Métodos `fromJson()` para deserialización
- Métodos `toJson()` para serialización (cuando sea necesario)

**Ejemplo**:
```dart
class Cliente {
  final int idCliente;
  final String nombreRazonSocial;
  // ... más campos
  
  factory Cliente.fromJson(Map<String, dynamic> json) {
    return Cliente(
      idCliente: json['id_cliente'] as int? ?? 0,
      nombreRazonSocial: json['nombre_razon_social'] as String? ?? '',
      // ...
    );
  }
}
```

## Flujo de Datos

### Flujo Típico: Cargar Lista de Entidades

```
1. Usuario abre pantalla de listado
   ↓
2. Screen llama a controller.fetchEntidades()
   ↓
3. Controller actualiza estado (_isLoading = true) y notifica
   ↓
4. Controller llama a service.fetchEntidades()
   ↓
5. Service obtiene token de SessionStorage
   ↓
6. Service hace petición HTTP al API con Dio
   ↓
7. Service retorna Response
   ↓
8. Controller parsea Response a List<Model>
   ↓
9. Controller actualiza estado (_entidades = parsed, _isLoading = false)
   ↓
10. Controller notifica cambios
   ↓
11. Screen (Consumer) se reconstruye con nuevos datos
```

### Flujo de Autenticación

```
1. Usuario ingresa credenciales en LoginScreen
   ↓
2. LoginScreen valida campos y llama a authController.login()
   ↓
3. AuthController actualiza estado y llama a authService.login()
   ↓
4. AuthService hace POST al endpoint de login
   ↓
5. Si exitoso, AuthController guarda respuesta en SessionStorage
   ↓
6. AuthController actualiza _loginResponse y notifica
   ↓
7. LoginScreen navega a HomeScreen
   ↓
8. En futuras peticiones, servicios obtienen token de SessionStorage
```

## Gestión de Estado

### Provider Pattern

La aplicación utiliza **Provider** como solución principal de gestión de estado:

**Configuración en main.dart**:
```dart
MultiProvider(
  providers: [
    ChangeNotifierProvider(create: (_) => AuthController()),
    ChangeNotifierProvider(create: (_) => SidebarController()),
    ChangeNotifierProvider(create: (_) => HotelController()),
    ChangeNotifierProvider(create: (_) => ClienteController()),
    ChangeNotifierProvider(create: (_) => IncidenciaController()),
  ],
  child: MaterialApp(...),
)
```

**Consumo en widgets**:
```dart
// Opción 1: Consumer (recomendado para partes específicas)
Consumer<AuthController>(
  builder: (context, authController, child) {
    return Text(authController.loginResponse?['login'] ?? 'Usuario');
  },
)

// Opción 2: Provider.of (para acciones)
final controller = Provider.of<AuthController>(context, listen: false);
await controller.login(username, password);
```

### Estados por Módulo

Cada controlador gestiona múltiples estados:

**Estados típicos**:
- `_isLoading`: Carga de lista
- `_isLoadingDetail`: Carga de detalle
- `_isCreating`: Creación de entidad
- `_isUpdating`: Actualización de entidad
- `_isDeleting`: Eliminación de entidad
- `_errorMessage`: Mensajes de error generales
- `_createErrorMessage`: Errores específicos de creación
- `_isNotAuthenticated`: Estado de autenticación

## Configuración de API

### ApiConfig

Ubicación: `lib/api/api_config.dart`

```dart
class ApiConfig {
  static const String baseUrl = "https://app-interface-innpulse360-production.up.railway.app/";
  static const int connectTimeoutSeconds = 30;
  static const int receiveTimeoutSeconds = 30;
  static const String apiVersion = "api/v1/";
}
```

### Endpoints

Cada módulo tiene su archivo de endpoints:
- `endpoints_auth.dart`: Autenticación
- `endpoints_clientes.dart`: Clientes
- `endpoints_hotels.dart`: Hoteles y catálogos (países, estados)
- `endpoints_incidencias.dart`: Incidencias y galería

**Estructura de endpoints**:
```dart
class EndpointsClientes {
  static const String list = "clientes/";
  static String detail(int clienteId) => "clientes/$clienteId";
}
```

## Autenticación y Seguridad

### Token Bearer

Todas las peticiones autenticadas utilizan **Bearer Token** en el header:
```dart
headers: {
  'Authorization': 'Bearer $token',
}
```

### Almacenamiento de Sesión

**SessionStorage** (`lib/core/auth/services/session_storage.dart`):
- Utiliza `SharedPreferences` para almacenar la sesión
- Convierte el Map de sesión a JSON string
- Métodos disponibles:
  - `saveSession()`: Guardar sesión
  - `getSession()`: Obtener sesión
  - `clearSession()`: Limpiar sesión
  - `isSessionActive()`: Verificar si hay sesión activa

### Obtención de Token

Cada servicio implementa un método privado `_getToken()`:
```dart
Future<String?> _getToken() async {
  final session = await SessionStorage.getSession();
  if (session == null) return null;
  
  final token = session['token'] ?? 
               session['access_token'] ?? 
               session['accessToken'] ??
               session['token_access'];
  
  return token is String ? token : null;
}
```

## Manejo de Errores

### Tipos de Errores Gestionados

1. **Errores de Autenticación (401)**:
   - Token inválido o expirado
   - Usuario no autenticado
   - Se actualiza `_isNotAuthenticated = true`

2. **Errores de Validación (400, 422)**:
   - Datos inválidos
   - RFC duplicado (clientes)
   - Mensajes específicos por operación

3. **Errores de Conexión**:
   - Sin respuesta del servidor
   - Timeout
   - Mensajes amigables para el usuario

4. **Errores del Servidor (500+)**:
   - Errores internos del backend
   - Se muestra código de estado y mensaje

### Patrón de Manejo

```dart
try {
  final response = await _service.fetchData();
  // Procesar éxito
} catch (e) {
  if (e is DioException) {
    if (e.response != null) {
      // Error con respuesta del servidor
      if (e.response?.statusCode == 401) {
        _isNotAuthenticated = true;
        _errorMessage = 'No estás autenticado...';
      }
    } else {
      // Error de conexión
      _errorMessage = 'Error de conexión...';
    }
  }
  notifyListeners();
}
```

## Navegación

### Navegación Actual

La aplicación utiliza `Navigator` de Material con rutas explícitas:

```dart
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => const ClientesListScreen(),
  ),
);
```

### Configuración de Rutas (Preparado)

El archivo `lib/app/go_routes.dart` define una estructura de rutas preparada para implementar `go_router` en el futuro, pero actualmente no se utiliza.

**Estructura definida**:
```dart
class RouteItem {
  final String nombre;
  final String ruta;
  final Widget screen;
  final List<String> permisos;
}

final List<RouteItem> routes = [
  RouteItem(nombre: 'LoginScreen', ruta: '/login', ...),
  // ...
];
```

## Componentes Reutilizables

### AppHeader

**Ubicación**: `lib/widgets/app_header.dart`

**Funcionalidades**:
- Muestra información del usuario autenticado
- Botón de menú hamburguesa para abrir sidebar
- Botón de agregar (+)
- Menú de opciones (perfil, configuración, ayuda, cerrar sesión)

**Características**:
- Consume `AuthController` para obtener datos del usuario
- Reutilizable en todas las pantallas principales

### AppSidebar

**Ubicación**: `lib/widgets/app_sidebar.dart`

**Funcionalidades**:
- Navegación entre módulos
- Información del usuario
- Lista de módulos disponibles

**Módulos mostrados**:
1. Incidencias (implementado)
2. Usuarios (en construcción)
3. Clientes (implementado)
4. Hoteles (implementado)
5. Pisos (en construcción)
6. Habitaciones (en construcción)
7. Reservaciones (en construcción)
8. Mantenimiento (en construcción)
9. Limpieza (en construcción)

## Inyección de Dependencias

Actualmente se utiliza **instanciación directa** en los controladores:

```dart
class ClienteController extends ChangeNotifier {
  final ClienteService _clienteService = ClienteService();
  // ...
}
```

Los servicios aceptan una instancia opcional de Dio para testing:
```dart
ClienteService({Dio? dio}) : _dio = dio ?? Dio() { ... }
```

**Nota**: El proyecto está preparado para migrar a un sistema de inyección de dependencias más robusto (como `get_it`) si es necesario.

## Convenciones de Código

### Nomenclatura

- **Archivos**: `snake_case.dart`
- **Clases**: `PascalCase`
- **Métodos y variables**: `camelCase`
- **Constantes**: `UPPER_SNAKE_CASE` o `PascalCase` (según contexto)

### Estructura de Archivos por Módulo

Cada módulo en `features/` sigue esta estructura:
```
modulo/
├── controllers/
│   └── modulo_controller.dart
├── models/
│   └── modulo_model.dart
├── services/
│   └── modulo_service.dart
├── modulo_list_screen.dart
├── modulo_create_screen.dart
└── modulo_detail_screen.dart
```

## Configuración del Proyecto

### pubspec.yaml

**Dependencias principales**:
- `flutter`: SDK de Flutter
- `provider: ^6.1.1`: Gestión de estado
- `dio: ^5.4.0`: Cliente HTTP
- `shared_preferences: ^2.2.2`: Almacenamiento local
- `flutter_secure_storage: ^9.0.0`: Almacenamiento seguro
- `image_picker: ^1.0.7`: Selección de imágenes
- `cached_network_image: ^3.3.1`: Caché de imágenes de red
- `go_router: ^13.0.0`: Router (instalado pero no completamente implementado)

**Assets**:
- Imágenes en `lib/assets/img/`

## Consideraciones de Diseño

### Material Design 3

La aplicación utiliza Material Design 3:
```dart
theme: ThemeData(
  colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF667eea)),
  useMaterial3: true,
)
```

### Color Principal

- **Color primario**: `#667eea` (Azul/Púrpura)
- **Colores de UI**: Paleta basada en Material Design 3

## Arquitectura de Red

### Timeouts

- **Connect Timeout**: 30 segundos
- **Receive Timeout**: 30 segundos

### Headers Estándar

```dart
headers: {
  'Content-Type': 'application/json',
  'Accept': 'application/json',
  'Authorization': 'Bearer $token',  // En peticiones autenticadas
}
```

### Paginación

Los endpoints de listado soportan paginación mediante query parameters:
- `skip`: Offset de registros
- `limit`: Cantidad de registros por página (default: 100)

## Testing

Actualmente el proyecto no tiene pruebas unitarias o de integración implementadas, pero la arquitectura está preparada para:
- Mocking de servicios mediante inyección de Dio
- Testing de controladores de forma aislada
- Testing de modelos con datos de prueba

## Optimizaciones y Mejoras Futuras

### Posibles Mejoras Arquitectónicas

1. **Inyección de Dependencias**:
   - Implementar `get_it` o similar para gestión centralizada de dependencias

2. **Routing**:
   - Completar implementación de `go_router` para navegación declarativa

3. **Caché de Datos**:
   - Implementar caché local para reducir peticiones al API

4. **Offline Support**:
   - Sincronización de datos cuando se recupera la conexión

5. **Testing**:
   - Implementar suite de pruebas unitarias y de integración

6. **Error Handling Global**:
   - Interceptor global de Dio para manejo centralizado de errores

7. **Logging**:
   - Sistema de logging estructurado

## Diagrama de Dependencias

```
main.dart
  ├── MultiProvider
  │     ├── AuthController ──→ AuthService ──→ Dio
  │     ├── SidebarController
  │     ├── HotelController ──→ HotelService ──→ Dio
  │     ├── ClienteController ──→ ClienteService ──→ Dio
  │     └── IncidenciaController ──→ IncidenciaService ──→ Dio
  └── MaterialApp
        └── LoginScreen
              └── HomeScreen
                    ├── AppHeader ──→ AuthController
                    ├── AppSidebar ──→ AuthController
                    └── [Features Screens]
                          └── [Controllers]
                                └── [Services]
                                      └── [Models]
```

## Resumen

La arquitectura del proyecto App Móvil InnPulse está diseñada para:
- **Escalabilidad**: Fácil agregar nuevos módulos siguiendo el mismo patrón
- **Mantenibilidad**: Separación clara de responsabilidades
- **Testabilidad**: Servicios y controladores pueden testearse independientemente
- **Flexibilidad**: Preparada para mejoras futuras (DI, routing avanzado)

La aplicación sigue las mejores prácticas de Flutter y proporciona una base sólida para el crecimiento del proyecto.





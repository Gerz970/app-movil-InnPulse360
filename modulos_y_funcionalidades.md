# Módulos y Funcionalidades - App Móvil InnPulse

## Resumen Ejecutivo

La aplicación móvil InnPulse es una plataforma integral para la gestión de hoteles que permite administrar clientes, hoteles, incidencias y otros aspectos relacionados con la operación hotelera. Actualmente implementa 4 módulos principales completamente funcionales y 6 módulos en estado de construcción.

---

## Módulos Implementados

### 1. Módulo de Autenticación (Login)

**Ubicación**: `lib/core/auth/` y `lib/features/login/`

**Descripción**: Gestiona la autenticación de usuarios y la persistencia de sesión.

#### Componentes

**AuthController** (`lib/core/auth/controllers/auth_controller.dart`):
- Gestiona el estado de autenticación
- Método `login(String username, String password)`: Realiza el inicio de sesión
- Método `logout()`: Cierra la sesión y limpia datos
- Método `loadSession()`: Carga la sesión guardada al inicializar
- Estados gestionados:
  - `_isLoading`: Indica si hay una petición de login en curso
  - `_errorMessage`: Mensajes de error de autenticación
  - `_loginResponse`: Respuesta completa del login (Map con datos del usuario y token)

**AuthService** (`lib/core/auth/services/auth_service.dart`):
- Realiza petición POST a `usuarios/login`
- Configura headers estándar (Content-Type, Accept)
- Maneja timeouts de 30 segundos
- Retorna `Response` de Dio con los datos del login

**SessionStorage** (`lib/core/auth/services/session_storage.dart`):
- Guarda sesión en `SharedPreferences` como JSON string
- Métodos:
  - `saveSession(Map<String, dynamic>)`: Guarda la sesión del usuario
  - `getSession()`: Obtiene la sesión guardada
  - `clearSession()`: Elimina la sesión
  - `isSessionActive()`: Verifica si hay una sesión activa

**LoginScreen** (`lib/features/login/login_screen.dart`):
- Pantalla de inicio de sesión con diseño moderno
- Campos:
  - Campo de texto para usuario/login
  - Campo de contraseña con opción de mostrar/ocultar
  - Botón "¿Olvidaste tu contraseña?" (no implementado, muestra snackbar)
  - Botón de login con indicador de carga
  - Opción para navegar a registro (no implementado, muestra snackbar)
- Validación: Verifica que los campos no estén vacíos
- Navegación: En login exitoso, navega a `HomeScreen`

**RegisterScreen** (`lib/features/login/register_screen.dart`):
- Pantalla de registro (actualmente solo muestra mensaje de "no implementado")

#### Funcionalidades

✅ **Login de Usuario**:
- Validación de campos requeridos
- Envío de credenciales al API
- Manejo de errores (401, conexión, etc.)
- Guardado automático de sesión
- Navegación a pantalla principal en éxito

✅ **Persistencia de Sesión**:
- La sesión se guarda automáticamente al hacer login
- La sesión se carga automáticamente al iniciar la app
- Permite mantener al usuario autenticado entre sesiones

✅ **Cerrar Sesión**:
- Limpia la sesión guardada
- Limpia el estado del controlador
- Regresa a la pantalla de login

#### Endpoints Utilizados

- **POST** `api/v1/usuarios/login`: Autenticación de usuario

---

### 2. Módulo de Clientes

**Ubicación**: `lib/features/clientes/`

**Descripción**: Gestiona el CRUD completo de clientes (Persona Física y Persona Moral).

#### Componentes

**ClienteController** (`lib/features/clientes/controllers/cliente_controller.dart`):
- Estados gestionados:
  - `_isLoading`: Carga de lista
  - `_clientes`: Lista de clientes
  - `_errorMessage`: Errores generales
  - `_isNotAuthenticated`: Estado de autenticación
  - `_isLoadingCatalogs`: Carga de catálogos (países, estados)
  - `_paises`: Lista de países
  - `_estados`: Lista de estados
  - `_isCreating`: Creación de cliente
  - `_createErrorMessage`: Errores de creación
  - `_rfcDuplicadoError`: Flag especial para RFC duplicado
  - `_clienteDetail`: Cliente en detalle
  - `_isLoadingDetail`: Carga de detalle
  - `_isUpdating`: Actualización
  - `_isDeleting`: Eliminación
- Métodos:
  - `fetchClientes({skip, limit})`: Obtiene listado paginado
  - `loadCatalogs()`: Carga todos los países con paginación automática
  - `loadEstadosByPais(int idPais)`: Carga estados por país con paginación
  - `loadPaisById(int idPais)`: Carga un país específico
  - `loadEstadoById(int idEstado)`: Carga un estado específico
  - `createCliente(Map<String, dynamic>)`: Crea nuevo cliente
  - `loadClienteDetail(int clienteId)`: Carga detalle de cliente
  - `updateCliente(int clienteId, Map<String, dynamic>)`: Actualiza cliente
  - `deleteCliente(int clienteId)`: Elimina cliente

**ClienteService** (`lib/features/clientes/services/cliente_service.dart`):
- Métodos HTTP:
  - `fetchClientes({skip, limit})`: GET con paginación
  - `createCliente(Map<String, dynamic>)`: POST
  - `fetchClienteDetail(int clienteId)`: GET por ID
  - `updateCliente(int clienteId, Map<String, dynamic>)`: PUT
  - `deleteCliente(int clienteId)`: DELETE
- Métodos de catálogos (reutilizados de EndpointsHotels):
  - `fetchPaises({skip, limit})`: GET países
  - `fetchEstados({skip, limit, idPais})`: GET estados
  - `fetchPaisById(int idPais)`: GET país por ID
  - `fetchEstadoById(int idEstado)`: GET estado por ID
- Todas las peticiones incluyen token Bearer en headers

**ClienteModel** (`lib/features/clientes/models/cliente_model.dart`):
- Campos:
  - `idCliente`: ID único
  - `nombreRazonSocial`: Nombre o razón social
  - `apellidoPaterno`: Solo para Persona Física
  - `apellidoMaterno`: Solo para Persona Física
  - `rfc`: RFC del cliente (requerido, único)
  - `curp`: Solo para Persona Física
  - `correoElectronico`: Email
  - `telefono`: Teléfono
  - `direccion`: Dirección
  - `documentoIdentificacion`: ID de documento
  - `paisId`: ID del país
  - `estadoId`: ID del estado
  - `idEstatus`: 1=Activo, 0=Inactivo
  - `tipoPersona`: 1=Física, 2=Moral
  - `representante`: Solo para Persona Moral
- Métodos:
  - `fromJson()`: Deserialización
  - `nombreCompleto`: Getter que construye nombre completo (PF)
  - `tipoPersonaTexto`: Getter que retorna "Física" o "Moral"

**Pantallas**:
- **ClientesListScreen**: Lista de clientes con cards
- **ClienteCreateScreen**: Formulario de creación
- **ClienteDetailScreen**: Vista detallada con opción de edición

#### Funcionalidades

✅ **Listar Clientes**:
- Paginación (skip/limit, default: 100)
- Indicador de carga
- Manejo de errores (401, conexión, etc.)
- Mensaje cuando no hay clientes
- Navegación a detalle al hacer tap en card

✅ **Crear Cliente**:
- Formulario dinámico según tipo de persona:
  - **Persona Física (1)**: Apellidos, CURP
  - **Persona Moral (2)**: Representante
- Validaciones:
  - Campos requeridos según tipo de persona
  - Validación especial de RFC duplicado (error 400)
- Catálogos:
  - Carga todos los países con paginación automática
  - Carga estados al seleccionar país
- Estados:
  - Indicador de carga durante creación
  - Mensajes de error específicos
  - Refresca lista después de crear exitosamente

✅ **Ver Detalle de Cliente**:
- Muestra todos los campos del cliente
- Carga país y estado por separado (eficiente)
- Indicador de carga
- Manejo de errores

✅ **Editar Cliente**:
- Solo campos editables:
  - `nombre_razon_social`
  - `telefono`
  - `direccion`
  - `id_estatus`
- **NO editables**: RFC, CURP, apellidos, representante (por restricciones del API)
- Validaciones
- Actualiza vista después de editar

✅ **Eliminar Cliente**:
- Confirmación con diálogo
- Manejo de errores específicos:
  - 404: Cliente ya no existe
  - 409/422: Dependencias activas
  - 401: No autenticado
- Remueve de lista local después de eliminar

#### Endpoints Utilizados

- **GET** `api/v1/clientes/`: Listado con paginación
- **POST** `api/v1/clientes/`: Crear cliente
- **GET** `api/v1/clientes/{id}`: Detalle de cliente
- **PUT** `api/v1/clientes/{id}`: Actualizar cliente
- **DELETE** `api/v1/clientes/{id}`: Eliminar cliente
- **GET** `api/v1/paises/`: Catálogo de países (con paginación)
- **GET** `api/v1/estados/`: Catálogo de estados (con paginación y filtro por país)
- **GET** `api/v1/paises/{id}`: País específico
- **GET** `api/v1/estados/{id}`: Estado específico

---

### 3. Módulo de Hoteles

**Ubicación**: `lib/features/hoteles/`

**Descripción**: Gestiona el CRUD completo de hoteles y catálogos relacionados.

#### Componentes

**HotelController** (`lib/features/hoteles/controllers/hotel_controller.dart`):
- Estados similares a ClienteController
- Métodos:
  - `fetchHotels({skip, limit})`: Listado paginado
  - `loadCatalogs()`: Carga países con paginación
  - `loadEstadosByPais(int idPais)`: Carga estados por país
  - `loadPaisById(int idPais)`: País específico
  - `loadEstadoById(int idEstado)`: Estado específico
  - `createHotel(Map<String, dynamic>)`: Crear hotel
  - `loadHotelDetail(int hotelId)`: Detalle de hotel
  - `updateHotel(int hotelId, Map<String, dynamic>)`: Actualizar hotel
  - `deleteHotel(int hotelId)`: Eliminar hotel

**HotelService** (`lib/features/hoteles/services/hotel_service.dart`):
- Métodos HTTP similares a ClienteService
- Manejo de catálogos (países y estados)
- Logging detallado en métodos de catálogos

**HotelModel** (`lib/features/hoteles/models/hotel_model.dart`):
- Campos:
  - `idHotel`: ID único
  - `nombre`: Nombre del hotel
  - `direccion`: Dirección completa
  - `codigoPostal`: Código postal
  - `telefono`: Teléfono de contacto
  - `emailContacto`: Email de contacto
  - `idPais`: ID del país
  - `idEstado`: ID del estado
  - `numeroEstrellas`: Clasificación por estrellas

**Modelos de Catálogos**:
- **PaisModel**: `idPais`, `nombre`, `idEstatus`
- **EstadoModel**: `idEstado`, `nombre`, `idPais`, `idEstatus`

**Pantallas**:
- **HotelsListScreen**: Lista de hoteles con cards
- **HotelCreateScreen**: Formulario de creación
- **HotelDetailScreen**: Vista detallada con opción de edición

#### Funcionalidades

✅ **Listar Hoteles**:
- Paginación
- Indicadores de carga y error
- Navegación a detalle

✅ **Crear Hotel**:
- Formulario completo con:
  - Nombre, dirección, código postal
  - Teléfono, email
  - Selección de país (catálogo)
  - Selección de estado (dependiente de país)
  - Número de estrellas
- Validaciones
- Refresca lista después de crear

✅ **Ver Detalle de Hotel**:
- Muestra todos los campos
- Carga país y estado relacionados
- Información completa del hotel

✅ **Editar Hotel**:
- Campos editables:
  - `nombre`
  - `numero_estrellas`
  - `telefono`
- Actualización optimista
- Validaciones

✅ **Eliminar Hotel**:
- Confirmación
- Manejo de errores (404, 409, 401)
- Remueve de lista local

✅ **Gestión de Catálogos**:
- Carga automática de países con paginación
- Carga de estados al seleccionar país
- Optimización: Carga país/estado por ID en detalle

#### Endpoints Utilizados

- **GET** `api/v1/hotel/`: Listado con paginación
- **POST** `api/v1/hotel/`: Crear hotel
- **GET** `api/v1/hotel/{id}`: Detalle de hotel
- **PUT** `api/v1/hotel/{id}`: Actualizar hotel
- **DELETE** `api/v1/hotel/{id}`: Eliminar hotel
- **GET** `api/v1/paises/`: Catálogo de países
- **GET** `api/v1/estados/`: Catálogo de estados
- **GET** `api/v1/paises/{id}`: País específico
- **GET** `api/v1/estados/{id}`: Estado específico

---

### 4. Módulo de Incidencias

**Ubicación**: `lib/features/incidencias/`

**Descripción**: Gestiona incidencias reportadas en habitaciones/áreas del hotel, incluyendo galería de imágenes.

#### Componentes

**IncidenciaController** (`lib/features/incidencias/controllers/incidencia_controller.dart`):
- Estados gestionados:
  - Listado: `_isLoading`, `_incidencias`, `_errorMessage`, `_isNotAuthenticated`
  - Catálogos: `_habitacionesAreas`, `_isLoadingCatalogs`
  - Creación: `_isCreating`, `_createErrorMessage`
  - Detalle: `_incidenciaDetail`, `_isLoadingDetail`, `_detailErrorMessage`
  - Actualización: `_isUpdating`, `_updateErrorMessage`
  - Eliminación: `_isDeleting`, `_deleteErrorMessage`
  - Galería: `_galeriaImagenes`, `_isLoadingGaleria`, `_galeriaErrorMessage`
  - Subida de fotos: `_isUploadingPhoto`, `_uploadPhotoError`
  - Eliminación de fotos: `_isDeletingPhoto`
  - `canAddMorePhotos`: Getter que verifica límite de 5 fotos
- Métodos:
  - `fetchIncidencias()`: Listado completo (sin paginación por ahora)
  - `loadCatalogs()`: Cargar habitaciones/áreas (TODO: endpoint pendiente)
  - `createIncidencia(Map<String, dynamic>)`: Crear incidencia
  - `loadIncidenciaDetail(int incidenciaId)`: Detalle de incidencia
  - `updateIncidencia(int incidenciaId, Map<String, dynamic>)`: Actualizar
  - `deleteIncidencia(int incidenciaId)`: Eliminar
  - `fetchGaleria(int incidenciaId)`: Cargar galería de imágenes
  - `uploadPhoto(int incidenciaId, String filePath)`: Subir foto
  - `deletePhoto(int incidenciaId, String nombreArchivo)`: Eliminar foto

**IncidenciaService** (`lib/features/incidencias/services/incidencia_service.dart`):
- Métodos HTTP:
  - `fetchIncidencias()`: GET listado
  - `createIncidencia(Map<String, dynamic>)`: POST
  - `fetchIncidenciaDetail(int incidenciaId)`: GET detalle
  - `updateIncidencia(int incidenciaId, Map<String, dynamic>)`: PUT
  - `deleteIncidencia(int incidenciaId)`: DELETE
  - `fetchGaleria(int incidenciaId)`: GET galería
  - `uploadFotoGaleria(int incidenciaId, String filePath)`: POST multipart/form-data
  - `deleteFotoGaleria(int incidenciaId, String nombreArchivo)`: DELETE con manejo de codificación URL
- Logging detallado en operaciones de galería

**IncidenciaModel** (`lib/features/incidencias/models/incidencia_model.dart`):
- Campos:
  - `idIncidencia`: ID único
  - `habitacionAreaId`: ID de habitación/área
  - `incidencia`: Título/nombre de la incidencia
  - `descripcion`: Descripción detallada
  - `fechaIncidencia`: Fecha (DateTime)
  - `idEstatus`: Estado (1=Activo, 0=Inactivo)
  - `habitacionArea`: Objeto anidado `HabitacionArea` (opcional)
- Métodos:
  - `fromJson()`: Deserialización con parseo de fecha ISO 8601
  - `toJson()`: Serialización para POST/PUT
  - `fechaFormateada`: Getter que formatea fecha en español

**HabitacionAreaModel** (`lib/features/incidencias/models/habitacion_area_model.dart`):
- Campos:
  - `idHabitacionArea`: ID único
  - `nombreClave`: Nombre/clave de la habitación/área
  - `descripcion`: Descripción opcional
  - `pisoId`: ID del piso (opcional)
  - `tipoHabitacionId`: ID del tipo de habitación (opcional)
  - `estatusId`: Estado (opcional)

**GaleriaImagenModel** (`lib/features/incidencias/models/galeria_imagen_model.dart`):
- Campos:
  - `nombre`: Nombre del archivo
  - `ruta`: Ruta en el servidor
  - `tamanio`: Tamaño en bytes
  - `urlPublica`: URL pública para mostrar la imagen
- **GaleriaResponse**: Modelo wrapper que incluye:
  - `imagenes`: Lista de imágenes
  - `success`: Flag de éxito
  - `total`: Total de imágenes

**Pantallas**:
- **IncidenciasListScreen**: Lista de incidencias con cards
- **IncidenciaCreateScreen**: Formulario de creación
- **IncidenciaDetailScreen**: Vista detallada
- **IncidenciaEditScreen**: Formulario de edición
- **IncidenciaGaleriaScreen**: Galería de imágenes con subida/eliminación
- **IncidenciaSuccessScreen**: Pantalla de confirmación después de crear

#### Funcionalidades

✅ **Listar Incidencias**:
- Listado completo de incidencias
- Muestra información básica: título, descripción, fecha, habitación/área
- Indicadores de carga y error
- Manejo mejorado de errores de conexión (mensajes amigables)
- Navegación a detalle

✅ **Crear Incidencia**:
- Formulario con:
  - Selección de habitación/área (catálogo pendiente de endpoint)
  - Campo de título/incidencia
  - Campo de descripción
  - Selección de fecha
  - Selección de estatus
- Validaciones
- Navegación a pantalla de éxito después de crear
- Refresca lista automáticamente

✅ **Ver Detalle de Incidencia**:
- Información completa
- Muestra habitación/área relacionada
- Fecha formateada en español
- Opción de editar
- Opción de ver/editar galería
- Opción de eliminar

✅ **Editar Incidencia**:
- Actualización de campos editables
- Validaciones
- Actualización optimista

✅ **Eliminar Incidencia**:
- Confirmación
- Manejo de errores
- Remueve de lista local

✅ **Galería de Imágenes**:
- **Cargar Galería**: Obtiene todas las imágenes de una incidencia
- **Subir Fotos**: 
  - Usa `image_picker` para seleccionar desde galería o cámara
  - Subida mediante `multipart/form-data`
  - Límite de 5 fotos por incidencia
  - Indicador de carga durante subida
  - Refresca galería automáticamente después de subir
- **Eliminar Fotos**:
  - Eliminación individual de fotos
  - Manejo de codificación URL (intenta con y sin codificar)
  - Refresca galería automáticamente después de eliminar
- **Visualización**:
  - Grid de imágenes con `CachedNetworkImage`
  - Muestra URL pública de cada imagen
  - Indicadores de carga por imagen

#### Endpoints Utilizados

- **GET** `api/v1/incidencias/`: Listado de incidencias
- **POST** `api/v1/incidencias/`: Crear incidencia
- **GET** `api/v1/incidencias/{id}`: Detalle de incidencia
- **PUT** `api/v1/incidencias/{id}`: Actualizar incidencia
- **DELETE** `api/v1/incidencias/{id}`: Eliminar incidencia
- **GET** `api/v1/incidencias/{id}/galeria`: Obtener galería de imágenes
- **POST** `api/v1/incidencias/{id}/galeria`: Subir foto (multipart/form-data)
- **DELETE** `api/v1/incidencias/{id}/galeria/{nombreArchivo}`: Eliminar foto específica

---

## Módulos en Construcción

### 5. Módulo de Usuarios

**Estado**: Preparado en sidebar pero sin implementar

**Pantalla**: Muestra `UnderConstructionScreen` al acceder

---

### 6. Módulo de Pisos

**Estado**: Preparado en sidebar pero sin implementar

**Pantalla**: Muestra `UnderConstructionScreen` al acceder

---

### 7. Módulo de Habitaciones

**Estado**: Preparado en sidebar pero sin implementar

**Nota**: Existe modelo `HabitacionArea` en el módulo de incidencias, lo que sugiere que este módulo estará relacionado.

**Pantalla**: Muestra `UnderConstructionScreen` al acceder

---

### 8. Módulo de Reservaciones

**Estado**: Preparado en sidebar pero sin implementar

**Pantalla**: Muestra `UnderConstructionScreen` al acceder

---

### 9. Módulo de Mantenimiento

**Estado**: Preparado en sidebar pero sin implementar

**Pantalla**: Muestra `UnderConstructionScreen` al acceder

---

### 10. Módulo de Limpieza

**Estado**: Preparado en sidebar pero sin implementar

**Pantalla**: Muestra `UnderConstructionScreen` al acceder

---

## Componentes Globales

### AppHeader

**Ubicación**: `lib/widgets/app_header.dart`

**Funcionalidades**:
- Muestra información del usuario autenticado (login/username)
- Botón de menú hamburguesa (abre sidebar)
- Botón circular "+" (sin funcionalidad por ahora)
- Menú de opciones (PopupMenu):
  - Perfil (no implementado)
  - Configuración (no implementado)
  - Ayuda (no implementado)
  - Cerrar sesión (no implementado, muestra snackbar)
- Consume `AuthController` para obtener datos del usuario
- Diseño moderno con Material Design 3
- Reutilizable en todas las pantallas principales

**Estados y Props**:
- Sin props (usa Consumer interno)
- Reacciona a cambios en `AuthController.loginResponse`

---

### AppSidebar

**Ubicación**: `lib/widgets/app_sidebar.dart`

**Funcionalidades**:
- Header con información del usuario
- Lista de módulos navegables:
  1. **Incidencias** → `IncidenciasListScreen`
  2. **Usuarios** → `UnderConstructionScreen`
  3. **Clientes** → `ClientesListScreen`
  4. **Hoteles** → `HotelsListScreen`
  5. **Pisos** → `UnderConstructionScreen`
  6. **Habitaciones** → `UnderConstructionScreen`
  7. **Reservaciones** → `UnderConstructionScreen`
  8. **Mantenimiento** → `UnderConstructionScreen`
  9. **Limpieza** → `UnderConstructionScreen`
- Cierra automáticamente después de navegar
- Diseño consistente con Material Design 3
- Ancho fijo: 280px

**Navegación**:
- Utiliza `Navigator.push()` con `MaterialPageRoute`
- Cierra el drawer antes de navegar (`Navigator.pop(context)`)

---

### UnderConstructionScreen

**Ubicación**: `lib/features/common/under_construction_screen.dart`

**Propósito**: Pantalla genérica para módulos no implementados

**Funcionalidad**:
- Muestra mensaje de "En construcción"
- Incluye header y sidebar estándar
- Acepta parámetro `title` para personalizar el título

---

### HomeScreen

**Ubicación**: `lib/features/home/home_screen.dart`

**Estado**: Pantalla básica de bienvenida

**Funcionalidades**:
- Muestra mensaje "En proceso..."
- Incluye header y sidebar estándar
- Actúa como pantalla principal después del login
- Preparada para expandir con dashboard/widgets

---

## Sistema de Navegación

### Navegación Actual

La aplicación utiliza **Navigator** de Material con rutas explícitas:

```dart
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => const DestinationScreen(),
  ),
);
```

### Flujo de Navegación Típico

1. **Login** → `LoginScreen`
   - Login exitoso → `HomeScreen`

2. **Desde Sidebar**:
   - Tap en módulo → Pantalla de listado correspondiente

3. **Desde Listado**:
   - Tap en item → Pantalla de detalle
   - Botón "Agregar" → Pantalla de creación

4. **Desde Detalle**:
   - Botón "Editar" → Pantalla de edición
   - Botón "Eliminar" → Confirmación → Elimina y regresa a listado

5. **Desde Creación/Edición**:
   - Guardar exitoso → Regresa a listado o pantalla de éxito
   - Cancelar → Regresa a pantalla anterior

### Rutas Definidas (No Utilizadas)

El archivo `lib/app/go_routes.dart` define una estructura de rutas preparada para `go_router`, pero actualmente no se utiliza:

- `/login` → `LoginScreen`
- `/register` → `RegisterScreen`
- `/home` → `HomeScreen`

**Nota**: El proyecto está preparado para migrar a `go_router` en el futuro.

---

## Funcionalidades del Sistema

### Autenticación y Autorización

✅ **Login de Usuario**:
- Autenticación mediante usuario y contraseña
- Guardado automático de sesión
- Token Bearer para peticiones autenticadas
- Manejo de errores de autenticación (401)

✅ **Persistencia de Sesión**:
- La sesión se mantiene entre cierres de aplicación
- Carga automática al iniciar
- Manejo seguro mediante `SharedPreferences`

✅ **Logout**:
- Limpieza de sesión y datos del controlador
- Regreso a pantalla de login

### Gestión de Datos

✅ **CRUD Completo**:
- **Create**: Creación de entidades con validaciones
- **Read**: Listado y detalle con indicadores de carga
- **Update**: Actualización de campos editables
- **Delete**: Eliminación con confirmación

✅ **Paginación**:
- Soporte para listados paginados (skip/limit)
- Default: 100 registros por página
- Implementado en clientes y hoteles

✅ **Catálogos**:
- Carga de catálogos relacionados (países, estados)
- Carga optimista: solo lo necesario en detalle
- Carga completa con paginación automática en formularios

### Manejo de Errores

✅ **Tipos de Errores Gestionados**:
1. **401 - No Autenticado**: Mensaje específico y estado `_isNotAuthenticated`
2. **400 - Bad Request**: Validación de datos (ej: RFC duplicado)
3. **404 - Not Found**: Recurso no encontrado
4. **409/422 - Conflict/Unprocessable**: Dependencias activas o datos inválidos
5. **500+ - Server Error**: Errores internos del servidor
6. **Conexión**: Errores de red, timeout, sin conexión

✅ **Mensajes al Usuario**:
- Mensajes claros y amigables
- Específicos por tipo de error
- Sin información técnica expuesta al usuario final

### Gestión de Imágenes

✅ **Galería de Incidencias**:
- Subida de imágenes desde galería o cámara
- Límite de 5 fotos por incidencia
- Visualización en grid
- Eliminación individual
- Uso de `CachedNetworkImage` para optimización

✅ **Image Picker**:
- Permisos gestionados automáticamente
- Selección desde galería o cámara
- Compatible con Android e iOS

### Validaciones

✅ **Validaciones de Formularios**:
- Campos requeridos
- Validación de RFC duplicado (clientes)
- Validación de límite de fotos (incidencias)
- Validación de tipos de datos

### Experiencia de Usuario

✅ **Indicadores de Estado**:
- Indicadores de carga durante operaciones
- Mensajes de error claros
- Confirmaciones para acciones destructivas
- Snackbars para retroalimentación

✅ **Navegación Intuitiva**:
- Sidebar para acceso rápido a módulos
- Breadcrumbs implícitos (listado → detalle → edición)
- Regreso natural a pantalla anterior

✅ **Diseño Consistente**:
- Material Design 3
- Colores consistentes (#667eea como primario)
- Componentes reutilizables
- Header y sidebar globales

---

## Limitaciones Actuales

### Funcionalidades No Implementadas

1. **Registro de Usuario**: La pantalla existe pero solo muestra mensaje de "no implementado"

2. **Recuperación de Contraseña**: Botón existe pero sin funcionalidad

3. **Cerrar Sesión desde Header**: Menú existe pero solo muestra snackbar

4. **Perfil de Usuario**: Menú existe pero sin pantalla

5. **Configuración**: Menú existe pero sin pantalla

6. **Ayuda**: Menú existe pero sin contenido

7. **Catálogo de Habitaciones/Áreas**: Endpoint pendiente en incidencias

8. **Filtros y Búsqueda**: No implementados en listados

9. **Ordenamiento**: No implementado en listados

10. **Refresh Manual**: No hay pull-to-refresh en listados

11. **Modo Offline**: Sin sincronización offline

12. **Notificaciones Push**: No implementadas

13. **Módulos en Construcción**: 6 módulos preparados pero sin implementar

### Mejoras Futuras Sugeridas

1. **Implementar Módulos Pendientes**: Usuarios, Pisos, Habitaciones, Reservaciones, Mantenimiento, Limpieza

2. **Filtros y Búsqueda**: Agregar funcionalidad de búsqueda y filtros en listados

3. **Paginación Infinita**: Scroll infinito en lugar de carga paginada

4. **Cache Local**: Implementar caché para reducir peticiones al API

5. **Sincronización Offline**: Permitir trabajo offline con sincronización posterior

6. **Notificaciones**: Implementar notificaciones push para eventos importantes

7. **Analytics**: Agregar tracking de uso y eventos

8. **Testing**: Implementar suite de pruebas unitarias e integración

9. **Internacionalización**: Soporte para múltiples idiomas

10. **Temas**: Soporte para temas claro/oscuro

---

## Resumen de Estadísticas

### Módulos Implementados: 4
- Autenticación ✅
- Clientes ✅
- Hoteles ✅
- Incidencias ✅

### Módulos en Construcción: 6
- Usuarios 🔨
- Pisos 🔨
- Habitaciones 🔨
- Reservaciones 🔨
- Mantenimiento 🔨
- Limpieza 🔨

### Endpoints Utilizados: ~20
- Autenticación: 1
- Clientes: 8
- Hoteles: 8
- Incidencias: 8

### Pantallas Implementadas: ~15
- Login, Register, Home
- Clientes: List, Create, Detail
- Hoteles: List, Create, Detail
- Incidencias: List, Create, Detail, Edit, Galería, Success
- Common: Under Construction

### Modelos de Datos: 9
- Cliente
- Hotel
- País, Estado
- Incidencia
- HabitacionArea
- GaleriaImagen, GaleriaResponse
- RequestLogin

---

## Conclusión

La aplicación móvil InnPulse cuenta con una base sólida implementada con 4 módulos principales completamente funcionales. La arquitectura es escalable y preparada para agregar los módulos restantes siguiendo los mismos patrones establecidos. El sistema proporciona funcionalidades esenciales de gestión hotelera con una experiencia de usuario moderna y consistente.







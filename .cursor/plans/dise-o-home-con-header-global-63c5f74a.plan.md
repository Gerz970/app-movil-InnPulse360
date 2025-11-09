<!-- 63c5f74a-b4d6-45ca-a2ec-b67bd2894a56 e37ce761-78f3-45dc-97ee-f9f77401851a -->
# Plan: Modulo de Clientes Completo

## Objetivo

Implementar el modulo completo de Clientes (listado, creacion, edicion, eliminacion) siguiendo exactamente el patron y arquitectura del modulo de Hoteles existente.

## Estructura del modulo (siguiendo patron de Hoteles)

```
lib/
├── api/
│   └── endpoints_clientes.dart (nuevo)
└── features/
    └── clientes/
        ├── controllers/
        │   └── cliente_controller.dart (nuevo)
        ├── services/
        │   └── cliente_service.dart (nuevo)
        ├── models/
        │   └── cliente_model.dart (nuevo)
        ├── clientes_list_screen.dart (nuevo)
        ├── cliente_create_screen.dart (nuevo)
        └── cliente_detail_screen.dart (nuevo)
```

## Cambios requeridos

### 1. Endpoints (`lib/api/endpoints_clientes.dart`)

- Crear archivo nuevo con:
  - `list = "clientes/"`
  - `detail(int clienteId)` retorna `"clientes/$clienteId"`
- Reutilizar endpoints de paises y estados de `EndpointsHotels`

### 2. Modelo (`lib/features/clientes/models/cliente_model.dart`)

- Crear clase `Cliente` con campos:
  - `idCliente` (id_cliente)
  - `nombreRazonSocial` (nombre_razon_social) - requerido
  - `apellidoPaterno` (apellido_paterno) - nullable, solo Fisica
  - `apellidoMaterno` (apellido_materno) - nullable, solo Fisica
  - `rfc` - requerido, unico
  - `curp` - nullable, solo Fisica
  - `correoElectronico` (correo_electronico) - nullable
  - `telefono` - nullable
  - `direccion` - nullable
  - `documentoIdentificacion` (documento_identificacion) - nullable
  - `paisId` (pais_id) - nullable
  - `estadoId` (estado_id) - nullable
  - `idEstatus` (id_estatus) - requerido (1 activo, 0 inactivo)
  - `tipoPersona` (tipo_persona) - requerido (1 Fisica, 2 Moral)
  - `representante` - nullable, solo Moral
- Factory `fromJson` con mapeo de snake_case a camelCase

### 3. Servicio (`lib/features/clientes/services/cliente_service.dart`)

- Seguir patron de `HotelService`
- Metodos:
  - `Future<Response> fetchClientes({int skip = 0, int limit = 100})` - GET con token
  - `Future<Response> createCliente(Map<String, dynamic> clienteData)` - POST con token
  - `Future<Response> fetchClienteDetail(int clienteId)` - GET con token
  - `Future<Response> updateCliente(int clienteId, Map<String, dynamic> clienteData)` - PUT con token
  - `Future<Response> deleteCliente(int clienteId)` - DELETE con token
  - Metodo privado `_getToken()` igual que HotelService
- Reutilizar metodos fetchPaises, fetchEstados, fetchPaisById, fetchEstadoById de HotelService (importar o duplicar)

### 4. Controlador (`lib/features/clientes/controllers/cliente_controller.dart`)

- Seguir patron de `HotelController` con ChangeNotifier
- Estados privados:
  - `_isLoading`, `_clientes`, `_errorMessage`, `_isNotAuthenticated`
  - `_paises`, `_estados`, `_isLoadingCatalogs`
  - `_isCreating`, `_createErrorMessage`, `_rfcDuplicadoError`
  - `_clienteDetail`, `_isLoadingDetail`, `_detailErrorMessage`
  - `_paisDetail`, `_estadoDetail`
  - `_isUpdating`, `_updateErrorMessage`
  - `_isDeleting`, `_deleteErrorMessage`
- Getters para todos los estados
- Metodos:
  - `fetchClientes({int skip, int limit})` - cargar lista
  - `loadCatalogs()` - cargar paises y estados con paginacion (multiples peticiones)
  - `loadEstadosByPais(int idPais)` - cargar estados filtrados por pais
  - `loadPaisById(int idPais)` - cargar pais especifico para detalle
  - `loadEstadoById(int idEstado)` - cargar estado especifico para detalle
  - `createCliente(Map<String, dynamic> clienteData)` - crear con manejo de error 400 (RFC duplicado)
  - `loadClienteDetail(int clienteId)` - cargar detalle
  - `updateCliente(int clienteId, Map<String, dynamic> clienteData)` - actualizar campos editables
  - `deleteCliente(int clienteId)` - eliminar con manejo de errores

### 5. Pantalla de Listado (`lib/features/clientes/clientes_list_screen.dart`)

- Seguir patron de `HotelsListScreen`
- `StatefulWidget` con `initState` que llama `controller.fetchClientes()`
- Usar `Consumer<ClienteController>`
- Estados: loading, error, empty, lista
- Cards con:
  - Icono segun tipo_persona (Fisica: `Icons.person`, Moral: `Icons.business`)
  - Nombre/Razon social
  - Apellidos (solo si Fisica)
  - RFC
  - Badge con tipo: "Fisica" o "Moral"
  - PopupMenuButton con opcion "Eliminar"
- Tap en card: navegar a `ClienteDetailScreen`
- FAB para navegar a `ClienteCreateScreen`
- Metodos: `_showDeleteConfirmationDialog`, `_handleDelete` (igual que Hoteles pero texto "Eliminar Cliente")

### 6. Pantalla de Creacion (`lib/features/clientes/cliente_create_screen.dart`)

- Seguir patron de `HotelCreateScreen`
- `StatefulWidget` con `initState` que llama `controller.loadCatalogs()`
- Usar `Consumer<ClienteController>`
- Formulario con `GlobalKey<FormState>`
- Dropdown inicial: Tipo de Persona (1 Fisica, 2 Moral)
- Campos dinamicos segun tipo_persona:
  - Comunes: nombre_razon_social, rfc, correo_electronico, telefono, documento_identificacion, direccion, pais_id, estado_id, id_estatus
  - Solo Fisica: apellido_paterno, apellido_materno, curp
  - Solo Moral: representante
- Validaciones:
  - RFC: 12-13 caracteres, requerido
  - CURP: 18 caracteres si es Fisica
  - Email: formato valido
  - Nombres y apellidos: al menos 3 caracteres
- Manejo de error 400 (RFC duplicado): mostrar mensaje especifico bajo campo RFC
- Estados: loadingCatalogs, creating, createError
- Botones: Cancelar, Guardar
- Overlay "Guardando..." durante creacion

### 7. Pantalla de Detalle/Edicion (`lib/features/clientes/cliente_detail_screen.dart`)

- Seguir patron de `HotelDetailScreen`
- Recibe `clienteId` como parametro
- `StatefulWidget` con `initState` que:
  - Llama `controller.loadClienteDetail(clienteId)`
  - Carga pais y estado especificos si existen (usando fetchPaisById, fetchEstadoById)
- Usar `Consumer<ClienteController>`
- Formulario similar a creacion pero:
  - Solo EDITABLES: nombre_razon_social, telefono, direccion, id_estatus
  - READ-ONLY: rfc, tipo_persona, curp, apellidos, pais_id, estado_id, documento_identificacion, correo_electronico, representante
- PopupMenuButton junto al titulo con opcion "Eliminar cliente"
- Metodos: `_preloadClienteData`, `_handleSubmit`, `_showDeleteConfirmationDialog`, `_handleDelete`
- Overlay "Guardando cambios..." durante actualizacion
- Al eliminar o actualizar, refrescar lista y navegar atras

### 8. Registrar en main.dart

- Agregar `ChangeNotifierProvider(create: (_) => ClienteController())` en la lista de providers

### 9. Actualizar sidebar

- Modificar `lib/widgets/app_sidebar.dart`
- Cambiar la opcion "Clientes" para que navegue a `ClientesListScreen` en lugar de `UnderConstructionScreen`

## Detalles tecnicos importantes

### Formulario dinamico por tipo_persona:

```dart
// En _buildForm():
Widget _buildCamposSegunTipo() {
  if (_tipoPersona == 1) {
    // Mostrar: apellido_paterno, apellido_materno, curp
    // Ocultar: representante
  } else if (_tipoPersona == 2) {
    // Mostrar: representante
    // Ocultar: apellido_paterno, apellido_materno, curp
  }
}
```

### Validacion de RFC unico:

En `createCliente()` del controller, capturar error 400 y setear flag especial:

```dart
if (statusCode == 400 && responseData.toString().contains('RFC')) {
  _rfcDuplicadoError = true;
  _createErrorMessage = 'El RFC ya está registrado';
}
```

### Paginacion preparada:

- Parametros `skip` y `limit` en `fetchClientes()`
- Lista acumulativa si se implementa scroll infinito (opcional por ahora)
- Por ahora: cargar primera pagina (skip=0, limit=100)

### Eliminacion:

- Texto de confirmacion: "Eliminar Cliente" (exacto)
- Mismo patron que Hoteles

## Archivos a crear (9 nuevos)

1. `lib/api/endpoints_clientes.dart`
2. `lib/features/clientes/models/cliente_model.dart`
3. `lib/features/clientes/services/cliente_service.dart`
4. `lib/features/clientes/controllers/cliente_controller.dart`
5. `lib/features/clientes/clientes_list_screen.dart`
6. `lib/features/clientes/cliente_create_screen.dart`
7. `lib/features/clientes/cliente_detail_screen.dart`

## Archivos a modificar (2)

1. `lib/main.dart` - agregar ClienteController al provider
2. `lib/widgets/app_sidebar.dart` - actualizar navegacion de Clientes

## Orden de implementacion

1. Endpoints y modelo
2. Servicio con todos los metodos CRUD
3. Controlador con estados y logica de negocio
4. Pantalla de listado con cards y navegacion
5. Pantalla de creacion con formulario dinamico
6. Pantalla de detalle/edicion con campos limitados
7. Registrar en main.dart y actualizar sidebar
8. Verificar funcionamiento completo

### To-dos

- [ ] Crear widget AppHeader en lib/widgets/app_header.dart con diseño moderno y minimalista
- [ ] Integrar Consumer<AuthController> en AppHeader para obtener datos del usuario del loginResponse
- [ ] Implementar foto de perfil circular con icono temporal, nombre del usuario y texto secundario
- [ ] Agregar botones circulares (+ y menú) al header con PopupMenuButton para opciones
- [ ] Crear endpoints_clientes.dart y cliente_model.dart con todos los campos del API
- [ ] Crear cliente_service.dart con metodos fetchClientes, createCliente, fetchClienteDetail, updateCliente, deleteCliente y reutilizar metodos de catalogos
- [ ] Crear cliente_controller.dart con estados para listado, catalogos, creacion, detalle, actualizacion y eliminacion, incluyendo manejo de RFC duplicado
- [ ] Crear clientes_list_screen.dart con cards mostrando icono segun tipo, nombre, apellidos (si aplica), RFC, badge de tipo, menu contextual y navegacion
- [ ] Crear cliente_create_screen.dart con formulario dinamico segun tipo_persona, validaciones, dropdowns de pais/estado, manejo de RFC duplicado y overlay de guardado
- [ ] Crear cliente_detail_screen.dart con formulario de edicion (campos limitados editables), carga de catalogos especificos, menu de eliminacion y overlay de actualizacion
- [ ] Registrar ClienteController en main.dart como ChangeNotifierProvider
- [ ] Modificar app_sidebar.dart para que la opcion Clientes navegue a ClientesListScreen
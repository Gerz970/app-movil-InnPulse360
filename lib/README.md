# Arquitectura del Proyecto - InnPulse360 Movil

Este proyecto sigue una **Arquitectura Limpia (Clean Architecture)** con nomenclatura en **español** para facilitar el entendimiento del equipo.

## 📁 Estructura General

```
lib/
├── aplicacion/              # Configuración global de la aplicación
├── nucleo/                  # Infraestructura compartida (core)
├── modulos/                 # Módulos funcionales (features)
└── main.dart                # Punto de entrada
```

---

## 🏗️ Capas del Proyecto

### 1. **aplicacion/** - Configuración Global

Contiene todo lo que afecta a la app completa, no a un módulo específico.

```
aplicacion/
├── inyeccion_dependencias/  # Dependency Injection (GetIt)
│   └── localizador_servicios.dart
├── enrutador/               # Navegación (GoRouter) - Próximamente
│   ├── enrutador_app.dart
│   └── nombres_rutas.dart
└── tema/                    # Temas y estilos - Próximamente
    ├── tema_app.dart
    └── colores_app.dart
```

**Qué va aquí:**
- Inyección de dependencias
- Configuración de rutas
- Temas y estilos globales
- Configuración de la app

**Qué NO va aquí:**
- Lógica de negocio
- Pantallas o widgets
- Código específico de un módulo

---

### 2. **nucleo/** - Infraestructura Compartida

Utilidades y servicios compartidos entre todos los módulos.

```
nucleo/
├── red/                     # Networking (HTTP/API)
│   ├── cliente_api_base.dart
│   ├── configuracion_api.dart
│   ├── endpoints/
│   │   ├── endpoints_autenticacion.dart
│   │   └── endpoints_negocios.dart
│   └── interceptores/
│       └── interceptor_autenticacion.dart
│
├── almacenamiento/          # Almacenamiento local
│   └── almacenamiento_local.dart
│
├── errores/                 # Manejo de errores
│   ├── fallas.dart
│   └── excepciones.dart
│
└── utilidades/              # Utilidades comunes
    ├── resultado.dart
    └── validadores.dart
```

**Qué va aquí:**
- Cliente HTTP
- Almacenamiento local (SharedPreferences, SecureStorage)
- Manejo de errores
- Validadores y utilidades
- Extensiones de Dart

**Qué NO va aquí:**
- Lógica de UI
- Código específico de un módulo
- Modelos de datos

---

### 3. **modulos/** - Funcionalidades por Módulo

Cada módulo es una funcionalidad independiente de la app.

```
modulos/
├── autenticacion/           # Módulo de login
│   ├── datos/               # Capa de Datos
│   │   ├── modelos/
│   │   ├── fuentes_datos/
│   │   └── repositorios/
│   ├── dominio/             # Capa de Dominio (lógica de negocio)
│   │   ├── entidades/
│   │   ├── repositorios/
│   │   └── casos_uso/
│   └── presentacion/        # Capa de Presentación (UI)
│       ├── paginas/
│       └── estado/
│
└── inicio/                  # Módulo de pantalla principal
    └── presentacion/
        └── paginas/
```

---

## 🎯 Arquitectura por Capas (Clean Architecture)

Cada módulo se divide en 3 capas:

### **DOMINIO** (Lógica de Negocio Pura)

```
modulos/autenticacion/dominio/
├── entidades/               # Modelos puros del negocio
│   ├── usuario.dart
│   └── respuesta_autenticacion.dart
├── repositorios/            # Contratos (interfaces)
│   └── repositorio_autenticacion.dart
└── casos_uso/               # Lógica de negocio
    └── iniciar_sesion_caso_uso.dart
```

**Características:**
- ✅ **Sin dependencias externas** (100% Dart puro)
- ✅ Contiene las **reglas del negocio**
- ✅ Define **contratos** (interfaces)
- ✅ **Independiente** de frameworks

---

### **DATOS** (Implementación y Fuentes de Datos)

```
modulos/autenticacion/datos/
├── modelos/                 # DTOs (Data Transfer Objects)
│   ├── usuario_modelo.dart  # Con fromJson/toJson
│   └── respuesta_login_modelo.dart
├── fuentes_datos/           # Conexiones a APIs/DB
│   └── autenticacion_fuente_remota.dart
└── repositorios/            # Implementación de contratos
    └── repositorio_autenticacion_impl.dart
```

**Características:**
- ✅ Convierte **JSON ↔ Objetos**
- ✅ Hace **peticiones HTTP**
- ✅ Implementa los **contratos del dominio**
- ✅ Maneja **excepciones técnicas**

---

### **PRESENTACIÓN** (UI y Estado)

```
modulos/autenticacion/presentacion/
├── paginas/                 # Pantallas de la app
│   └── pagina_login.dart
└── estado/                  # Manejo de estado (Riverpod)
    ├── login_estado.dart
    ├── login_notificador.dart
    └── login_provider.dart
```

**Características:**
- ✅ Widgets y pantallas
- ✅ Manejo de **estado** (Riverpod)
- ✅ **Reacciona** a cambios de estado
- ✅ **Muestra** datos al usuario

---

## 🔄 Flujo de Datos (Ejemplo: Login)

```
1. PaginaLogin (UI)
   ↓ Usuario presiona "Iniciar Sesión"
   
2. LoginNotificador (Estado)
   ↓ Cambia estado a "Cargando"
   ↓ Ejecuta caso de uso
   
3. IniciarSesionCasoUso (Dominio)
   ↓ Valida datos
   ↓ Llama al repositorio
   
4. RepositorioAutenticacionImpl (Datos)
   ↓ Llama a la fuente de datos
   
5. AutenticacionFuenteRemota (Datos)
   ↓ Hace POST a /api/v1/usuarios/login
   
6. API
   ↓ Responde con token y usuario
   
← El flujo regresa en orden inverso
   
7. PaginaLogin (UI)
   └─ Muestra éxito y navega a Inicio
```

---

## 📋 Reglas de la Arquitectura

### ✅ **Reglas de Dependencia:**

1. **Dominio** NO depende de nadie
2. **Datos** depende de Dominio
3. **Presentación** depende de Dominio (y opcionalmente de Datos)
4. **Núcleo** puede ser usado por todos

### ✅ **Qué va en cada capa:**

| Capa | Qué incluye | Qué NO incluye |
|------|-------------|----------------|
| **Dominio** | Entidades, Casos de Uso, Contratos | JSON, HTTP, UI, Frameworks |
| **Datos** | Modelos, DataSources, Repositorios | Lógica de negocio, UI |
| **Presentación** | Pantallas, Widgets, Estado | Lógica de negocio, HTTP |
| **Núcleo** | HTTP, Storage, Errores, Utils | Lógica de negocio específica |

---

## 🎨 Convenciones de Nombrado

### Archivos y Carpetas:
- ✅ `minusculas_con_guiones_bajos.dart`
- ✅ Carpetas en español: `autenticacion/`, `datos/`, `dominio/`

### Clases:
- ✅ `PascalCase` en español
- ✅ Sufijos descriptivos:
  - Modelos: `UsuarioModelo`
  - Entidades: `Usuario`
  - Casos de Uso: `IniciarSesionCasoUso`
  - Páginas: `PaginaLogin`
  - Notificadores: `LoginNotificador`

### Variables:
- ✅ `camelCase` en español
- ✅ Nombres descriptivos: `estadoLogin`, `tokenAcceso`

---

## 🚀 Cómo Agregar un Nuevo Módulo

### Paso 1: Crear estructura

```
modulos/mi_modulo/
├── datos/
│   ├── modelos/
│   ├── fuentes_datos/
│   └── repositorios/
├── dominio/
│   ├── entidades/
│   ├── repositorios/
│   └── casos_uso/
└── presentacion/
    ├── paginas/
    └── estado/
```

### Paso 2: Implementar de adentro hacia afuera

1. **Dominio** → Entidades y contratos
2. **Datos** → Modelos y fuentes de datos
3. **Dominio** → Casos de uso
4. **Presentación** → Estado y UI
5. **DI** → Registrar dependencias

---

## 📚 Tecnologías Utilizadas

- **Flutter & Dart** - Framework principal
- **Riverpod** - Manejo de estado
- **GetIt** - Inyección de dependencias
- **Dio** - Cliente HTTP
- **SharedPreferences** - Almacenamiento local
- **FlutterSecureStorage** - Almacenamiento seguro

---

## 🔍 Referencias

- [Clean Architecture por Robert C. Martin](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)
- [Flutter Clean Architecture](https://resocoder.com/flutter-clean-architecture-tdd/)
- [Riverpod Documentation](https://riverpod.dev/)

---

## 💡 Ventajas de esta Arquitectura

✅ **Testeable** - Cada capa se puede testear independientemente  
✅ **Escalable** - Fácil agregar nuevos módulos  
✅ **Mantenible** - Cambios no afectan otras capas  
✅ **Independiente** - No depende de frameworks específicos  
✅ **Clara** - Cada cosa tiene su lugar  

---

**Última actualización:** Octubre 2025  
**Versión:** 1.0.0


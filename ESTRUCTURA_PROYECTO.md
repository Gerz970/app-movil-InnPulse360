# 📁 Estructura del Proyecto - InnPulse360 Movil

## ✅ Arquitectura Limpia - TODO EN ESPAÑOL

```
lib/
│
├── 📱 aplicacion/                   # Configuración global de la app
│   └── inyeccion_dependencias/
│       └── localizador_servicios.dart
│
├── 🔧 nucleo/                       # Infraestructura compartida
│   ├── red/                         # Cliente HTTP y APIs
│   │   ├── cliente_api_base.dart
│   │   ├── configuracion_api.dart
│   │   ├── endpoints/
│   │   │   └── endpoints_autenticacion.dart
│   │   └── interceptores/
│   │       └── interceptor_autenticacion.dart
│   │
│   ├── almacenamiento/              # Storage local
│   │   └── almacenamiento_local.dart
│   │
│   ├── errores/                     # Manejo de errores
│   │   ├── fallas.dart
│   │   └── excepciones.dart
│   │
│   └── utilidades/                  # Utilidades comunes
│       └── resultado.dart
│
├── 🎯 modulos/                      # Funcionalidades
│   │
│   ├── autenticacion/               # Módulo de Login/Registro
│   │   ├── datos/                   # Capa de Datos
│   │   │   ├── modelos/
│   │   │   │   ├── usuario_modelo.dart
│   │   │   │   └── respuesta_login_modelo.dart
│   │   │   ├── fuentes_datos/
│   │   │   │   └── autenticacion_fuente_remota.dart
│   │   │   └── repositorios/
│   │   │       └── repositorio_autenticacion_impl.dart
│   │   │
│   │   ├── dominio/                 # Capa de Dominio
│   │   │   ├── entidades/
│   │   │   │   ├── usuario.dart
│   │   │   │   └── respuesta_autenticacion.dart
│   │   │   ├── repositorios/
│   │   │   │   └── repositorio_autenticacion.dart
│   │   │   └── casos_uso/
│   │   │       └── iniciar_sesion_caso_uso.dart
│   │   │
│   │   ├── presentacion/            # Capa de Presentación
│   │   │   ├── paginas/
│   │   │   │   ├── pagina_login.dart
│   │   │   │   └── pagina_registro.dart
│   │   │   └── estado/
│   │   │       ├── login_estado.dart
│   │   │       ├── login_notificador.dart
│   │   │       └── login_provider.dart
│   │   │
│   │   └── README.md
│   │
│   └── inicio/                      # Módulo de Pantalla Principal
│       └── presentacion/
│           └── paginas/
│               └── pagina_inicio.dart
│
├── 📖 README.md                     # Documentación completa
└── 🚀 main.dart                     # Punto de entrada
```

---

## 🎨 Nomenclatura

### Carpetas:
- ✅ `aplicacion/` (antes: app)
- ✅ `nucleo/` (antes: core)
- ✅ `modulos/` (antes: features)
- ✅ `datos/` (antes: data)
- ✅ `dominio/` (antes: domain)
- ✅ `presentacion/` (antes: presentation)
- ✅ `paginas/` (antes: pages)

### Archivos:
- ✅ `pagina_login.dart` (antes: login_page.dart)
- ✅ `pagina_registro.dart` (antes: register_page.dart)
- ✅ `pagina_inicio.dart` (antes: home_page.dart)

### Clases:
- ✅ `PaginaLogin` (antes: LoginPage)
- ✅ `PaginaRegistro` (antes: RegisterPage)
- ✅ `PaginaInicio` (antes: HomePage)

---

## ✨ Estado Actual

### ✅ Completado:
- [x] Módulo de Autenticación completo
- [x] Login funcional con API
- [x] Registro (UI)
- [x] Pantalla de inicio
- [x] Navegación entre pantallas
- [x] Almacenamiento de tokens
- [x] Manejo de errores
- [x] Arquitectura limpia
- [x] Todo en español

### 📋 Pendiente:
- [ ] Implementar funcionalidad de registro
- [ ] Cerrar sesión (limpiar tokens)
- [ ] Recuperar contraseña
- [ ] Más módulos según necesidades

---

## 🚀 Para Ejecutar

```bash
flutter run
```

---

## 📚 Documentación

Lee `lib/README.md` para documentación completa de la arquitectura.

---

**Última actualización:** Octubre 2025  
**Versión:** 1.0.0


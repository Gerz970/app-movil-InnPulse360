# App Móvil InnPulse

Aplicación móvil Flutter para InnPulse con arquitectura limpia.

## 📋 Requisitos Previos

Antes de instalar el proyecto, asegúrate de tener instalado:

- **Flutter SDK** (versión 3.9.2 o superior)
  - [Guía de instalación de Flutter](https://docs.flutter.dev/get-started/install)
- **Dart SDK** (incluido con Flutter)
- **Git**
- **Android Studio** (para desarrollo Android)
  - Android SDK
  - Emulador Android o dispositivo físico
- **Xcode** (solo para macOS, desarrollo iOS)
- **VS Code** o **Android Studio** como IDE

## 🚀 Instalación

### 1. Clonar el Repositorio

```bash
git clone <url-del-repositorio>
cd app_movil_innpulse
```

### 2. Verificar Instalación de Flutter

Verifica que Flutter esté correctamente instalado:

```bash
flutter doctor
```

Asegúrate de que no haya errores críticos. Resuelve cualquier problema antes de continuar.

### 3. Instalar Dependencias

Instala todas las dependencias del proyecto:

```bash
flutter pub get
```

Esto descargará e instalará los siguientes paquetes:
- `dio` - Cliente HTTP para peticiones a la API
- `get_it` - Inyección de dependencias
- `flutter_riverpod` - Gestión de estado
- `shared_preferences` - Almacenamiento local simple
- `flutter_secure_storage` - Almacenamiento seguro para tokens

### 4. Configurar el Entorno

**Importante:** Antes de ejecutar la aplicación, verifica que la configuración de la API sea correcta en:
```
lib/nucleo/red/configuracion_api.dart
```

### 5. Ejecutar la Aplicación

#### En un dispositivo Android:

```bash
# Listar dispositivos disponibles
flutter devices

# Ejecutar en modo debug
flutter run
```

#### En un emulador/simulador:

```bash
# Iniciar emulador Android
flutter emulators
flutter emulators --launch <emulator_id>

# Ejecutar la app
flutter run
```

#### En modo release (optimizado):

```bash
flutter run --release
```

## 🔨 Comandos Útiles

### Análisis de Código

```bash
# Analizar el código
flutter analyze

# Formatear el código
flutter format lib/
```

### Construcción

```bash
# Construir APK (Android)
flutter build apk

# Construir APK dividido por ABI (más ligero)
flutter build apk --split-per-abi

# Construir App Bundle (para Google Play)
flutter build appbundle

# Construir para iOS (solo macOS)
flutter build ios
```

### Limpieza

```bash
# Limpiar archivos de compilación
flutter clean

# Reinstalar dependencias
flutter pub get
```

## 📁 Estructura del Proyecto

```
lib/
├── aplicacion/
│   └── inyeccion_dependencias/    # Configuración de Get_it
├── modulos/
│   ├── autenticacion/              # Módulo de autenticación
│   │   ├── datos/                  # Capa de datos
│   │   ├── dominio/                # Lógica de negocio
│   │   └── presentacion/           # UI y estados
│   └── inicio/                     # Módulo de inicio
├── nucleo/
│   ├── almacenamiento/             # Gestión de almacenamiento
│   ├── errores/                    # Manejo de errores
│   ├── red/                        # Configuración de red y API
│   └── utilidades/                 # Utilidades generales
└── main.dart                       # Punto de entrada
```

## 🏗️ Arquitectura

El proyecto sigue los principios de **Clean Architecture** con las siguientes capas:

- **Presentación**: Widgets, gestores de estado (Riverpod)
- **Dominio**: Entidades, casos de uso, repositorios (interfaces)
- **Datos**: Implementación de repositorios, modelos, fuentes de datos

## 📦 Dependencias Principales

| Paquete | Versión | Propósito |
|---------|---------|-----------|
| `dio` | ^5.9.0 | Cliente HTTP |
| `get_it` | ^8.2.0 | Inyección de dependencias |
| `flutter_riverpod` | ^3.0.3 | Gestión de estado |
| `shared_preferences` | ^2.5.3 | Almacenamiento local |
| `flutter_secure_storage` | ^9.2.4 | Almacenamiento seguro |

## ⚠️ Solución de Problemas

### Error: "Gradle build failed"

```bash
cd android
./gradlew clean
cd ..
flutter clean
flutter pub get
```

### Error: "Flutter SDK not found"

Verifica la ruta de Flutter en tu PATH:
```bash
echo $PATH  # macOS/Linux
echo %PATH% # Windows
```

### Error: "CocoaPods not installed" (iOS)

```bash
sudo gem install cocoapods
cd ios
pod install
cd ..
```

### Error con flutter_secure_storage en Android

Asegúrate de que `minSdkVersion` sea al menos 18 en `android/app/build.gradle.kts`.

## 🤝 Contribución

1. Crea una rama para tu feature: `git checkout -b feature/nueva-funcionalidad`
2. Realiza tus cambios y commits: `git commit -m 'Añade nueva funcionalidad'`
3. Push a la rama: `git push origin feature/nueva-funcionalidad`
4. Abre un Pull Request

## 📄 Licencia

Este proyecto es privado y pertenece a InnPulse.

## 📞 Contacto

Para más información sobre el proyecto, contacta al equipo de desarrollo.

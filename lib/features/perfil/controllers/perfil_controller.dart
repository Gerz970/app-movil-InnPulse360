import 'package:flutter/foundation.dart';
import '../services/perfil_service.dart';
import '../models/usuario_perfil_model.dart';
import '../models/perfil_update_model.dart';
import '../models/cambiar_password_model.dart';
import '../../../core/auth/services/session_storage.dart';
import 'package:dio/dio.dart';

/// Controlador para manejar el estado del módulo de perfil
/// Usa ChangeNotifier para notificar cambios de estado
class PerfilController extends ChangeNotifier {
  // Instancia de PerfilService
  final PerfilService _perfilService = PerfilService();

  // Estados privados para perfil
  bool _isLoading = false;
  UsuarioPerfil? _usuarioPerfil;
  String? _errorMessage;

  // Estados para actualización de perfil
  bool _isUpdatingProfile = false;
  String? _updateProfileError;

  // Estados para foto de perfil
  bool _isUploadingPhoto = false;
  String? _uploadPhotoError;
  bool _isDeletingPhoto = false;

  // Estados para cambio de contraseña
  bool _isChangingPassword = false;
  String? _changePasswordError;

  // Getters para perfil
  bool get isLoading => _isLoading;
  UsuarioPerfil? get usuarioPerfil => _usuarioPerfil;
  String? get errorMessage => _errorMessage;

  // Getters para actualización
  bool get isUpdatingProfile => _isUpdatingProfile;
  String? get updateProfileError => _updateProfileError;

  // Getters para foto
  bool get isUploadingPhoto => _isUploadingPhoto;
  String? get uploadPhotoError => _uploadPhotoError;
  bool get isDeletingPhoto => _isDeletingPhoto;

  // Getters para contraseña
  bool get isChangingPassword => _isChangingPassword;
  String? get changePasswordError => _changePasswordError;

  /// Obtener el ID del usuario desde la sesión guardada
  Future<int?> obtenerIdUsuario() async {
    try {
      final session = await SessionStorage.getSession();
      if (session == null) return null;

      // Intentar obtener el ID desde diferentes campos posibles
      final usuario = session['usuario'];
      if (usuario is Map<String, dynamic>) {
        final idUsuario = usuario['id_usuario'] ?? usuario['idUsuario'];
        if (idUsuario != null) {
          return idUsuario is int ? idUsuario : int.tryParse(idUsuario.toString());
        }
      }

      // Intentar obtener directamente del session
      final idUsuario = session['id_usuario'] ?? session['idUsuario'];
      if (idUsuario != null) {
        return idUsuario is int ? idUsuario : int.tryParse(idUsuario.toString());
      }

      return null;
    } catch (e) {
      print('Error al obtener ID de usuario: $e');
      return null;
    }
  }

  /// Cargar el perfil del usuario actual
  Future<bool> cargarPerfil() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _perfilService.obtenerPerfil();

      if (response.data != null) {
        _usuarioPerfil = UsuarioPerfil.fromJson(response.data as Map<String, dynamic>);
        
        // Actualizar la sesión con los datos del perfil completo (incluyendo foto de perfil)
        // Esto asegura que la sesión siempre tenga los datos más actualizados del backend
        if (_usuarioPerfil != null && _usuarioPerfil!.urlFotoPerfil != null && _usuarioPerfil!.urlFotoPerfil!.isNotEmpty) {
          await _actualizarSesionFotoPerfil(_usuarioPerfil!.urlFotoPerfil!);
        }
      }

      _isLoading = false;
      notifyListeners();

      print("Perfil cargado correctamente");
      print('Status code: ${response.statusCode}');
      return true;
    } catch (e) {
      _isLoading = false;

      if (e is DioException) {
        if (e.response != null) {
          final responseData = e.response?.data;
          if (responseData is Map && responseData['detail'] != null) {
            _errorMessage = responseData['detail'] as String;
          } else {
            _errorMessage = 'Error ${e.response?.statusCode}: ${e.response?.data}';
          }
          print('Error del servidor: ${e.response?.data}');
        } else {
          _errorMessage = 'Error de conexión: ${e.message ?? e.toString()}';
          print('Error de conexión: ${e.message}');
        }
      } else {
        _errorMessage = 'Error: ${e.toString()}';
        print('Error general: $e');
      }

      notifyListeners();
      return false;
    }
  }

  /// Actualizar el perfil del usuario
  Future<bool> actualizarPerfil(PerfilUpdate datos) async {
    if (!datos.tieneDatos) {
      _updateProfileError = 'No hay datos para actualizar';
      notifyListeners();
      return false;
    }

    _isUpdatingProfile = true;
    _updateProfileError = null;
    notifyListeners();

    try {
      final response = await _perfilService.actualizarPerfil(datos.toJson());

      if (response.data != null) {
        _usuarioPerfil = UsuarioPerfil.fromJson(response.data as Map<String, dynamic>);
        
        // Actualizar sesión guardada
        await _actualizarSesion(response.data as Map<String, dynamic>);
      }

      _isUpdatingProfile = false;
      notifyListeners();

      print("Perfil actualizado correctamente");
      print('Status code: ${response.statusCode}');
      return true;
    } catch (e) {
      _isUpdatingProfile = false;

      if (e is DioException) {
        if (e.response != null) {
          final responseData = e.response?.data;
          if (responseData is Map && responseData['detail'] != null) {
            _updateProfileError = responseData['detail'] as String;
          } else {
            _updateProfileError = 'Error ${e.response?.statusCode}: ${e.response?.data}';
          }
          print('Error del servidor: ${e.response?.data}');
        } else {
          _updateProfileError = 'Error de conexión: ${e.message ?? e.toString()}';
          print('Error de conexión: ${e.message}');
        }
      } else {
        _updateProfileError = 'Error: ${e.toString()}';
        print('Error general: $e');
      }

      notifyListeners();
      return false;
    }
  }

  /// Subir foto de perfil
  /// Recibe los bytes del archivo y el nombre del archivo
  Future<bool> subirFotoPerfil(List<int> fileBytes, String fileName) async {
    final idUsuario = await obtenerIdUsuario();
    if (idUsuario == null) {
      _uploadPhotoError = 'No se pudo obtener el ID del usuario';
      notifyListeners();
      return false;
    }

    _isUploadingPhoto = true;
    _uploadPhotoError = null;
    notifyListeners();

    try {
      final response = await _perfilService.subirFotoPerfil(idUsuario, fileBytes, fileName);

      if (response.data != null) {
        final responseData = response.data as Map<String, dynamic>;
        
        // Actualizar la URL de la foto en el perfil
        if (_usuarioPerfil != null && responseData['public_url'] != null) {
          final nuevaUrlFoto = responseData['public_url'] as String;
          _usuarioPerfil = UsuarioPerfil(
            idUsuario: _usuarioPerfil!.idUsuario,
            login: _usuarioPerfil!.login,
            correoElectronico: _usuarioPerfil!.correoElectronico,
            estatusId: _usuarioPerfil!.estatusId,
            roles: _usuarioPerfil!.roles,
            urlFotoPerfil: nuevaUrlFoto,
          );
          
          // Actualizar la sesión guardada con la nueva URL de foto
          // Esperar a que se complete completamente antes de continuar
          final sessionUpdated = await _actualizarSesionFotoPerfil(nuevaUrlFoto);
          if (!sessionUpdated) {
            print('WARNING: La sesión no se actualizó correctamente, pero la foto se subió');
          }
          
          // IMPORTANTE: Recargar el perfil completo desde el backend para obtener datos actualizados
          // Esto asegura que la sesión tenga los datos más recientes del servidor
          try {
            await cargarPerfil();
            print('DEBUG: Perfil recargado después de subir foto');
          } catch (e) {
            print('DEBUG: Error al recargar perfil después de subir foto: $e');
            // Si falla recargar el perfil, al menos la sesión ya está actualizada
          }
        }
      }

      _isUploadingPhoto = false;
      notifyListeners();

      print("Foto de perfil subida correctamente");
      print('Status code: ${response.statusCode}');
      return true;
    } catch (e) {
      _isUploadingPhoto = false;

      if (e is DioException) {
        if (e.response != null) {
          final responseData = e.response?.data;
          if (responseData is Map && responseData['detail'] != null) {
            _uploadPhotoError = responseData['detail'] as String;
          } else {
            _uploadPhotoError = 'Error ${e.response?.statusCode}: ${e.response?.data}';
          }
          print('Error del servidor: ${e.response?.data}');
        } else {
          _uploadPhotoError = 'Error de conexión: ${e.message ?? e.toString()}';
          print('Error de conexión: ${e.message}');
        }
      } else {
        _uploadPhotoError = 'Error: ${e.toString()}';
        print('Error general: $e');
      }

      notifyListeners();
      return false;
    }
  }

  /// Eliminar/restaurar foto de perfil por defecto
  Future<bool> eliminarFotoPerfil() async {
    final idUsuario = await obtenerIdUsuario();
    if (idUsuario == null) {
      _uploadPhotoError = 'No se pudo obtener el ID del usuario';
      notifyListeners();
      return false;
    }

    _isDeletingPhoto = true;
    _uploadPhotoError = null;
    notifyListeners();

    try {
      final response = await _perfilService.eliminarFotoPerfil(idUsuario);

      // Recargar perfil para obtener la foto por defecto
      await cargarPerfil();

      // Actualizar la sesión con la foto por defecto (o null si no hay)
      if (_usuarioPerfil != null) {
        final urlFotoActual = _usuarioPerfil!.urlFotoPerfil ?? '';
        final sessionUpdated = await _actualizarSesionFotoPerfil(urlFotoActual);
        if (!sessionUpdated) {
          print('WARNING: La sesión no se actualizó correctamente después de eliminar foto');
        }
      }

      _isDeletingPhoto = false;
      notifyListeners();

      print("Foto de perfil eliminada/restaurada correctamente");
      print('Status code: ${response.statusCode}');
      return true;
    } catch (e) {
      _isDeletingPhoto = false;

      if (e is DioException) {
        if (e.response != null) {
          final responseData = e.response?.data;
          if (responseData is Map && responseData['detail'] != null) {
            _uploadPhotoError = responseData['detail'] as String;
          } else {
            _uploadPhotoError = 'Error ${e.response?.statusCode}: ${e.response?.data}';
          }
          print('Error del servidor: ${e.response?.data}');
        } else {
          _uploadPhotoError = 'Error de conexión: ${e.message ?? e.toString()}';
          print('Error de conexión: ${e.message}');
        }
      } else {
        _uploadPhotoError = 'Error: ${e.toString()}';
        print('Error general: $e');
      }

      notifyListeners();
      return false;
    }
  }

  /// Cambiar contraseña
  Future<bool> cambiarPassword(CambiarPasswordModel datos) async {
    if (!datos.passwordsCoinciden) {
      _changePasswordError = 'Las contraseñas no coinciden';
      notifyListeners();
      return false;
    }

    if (!datos.passwordValida) {
      _changePasswordError = 'La contraseña debe tener al menos 6 caracteres';
      notifyListeners();
      return false;
    }

    _isChangingPassword = true;
    _changePasswordError = null;
    notifyListeners();

    try {
      final response = await _perfilService.cambiarPasswordTemporal(datos.toJson());

      _isChangingPassword = false;
      notifyListeners();

      print("Contraseña cambiada correctamente");
      print('Status code: ${response.statusCode}');
      return true;
    } catch (e) {
      _isChangingPassword = false;

      if (e is DioException) {
        if (e.response != null) {
          final responseData = e.response?.data;
          if (responseData is Map && responseData['detail'] != null) {
            _changePasswordError = responseData['detail'] as String;
          } else {
            _changePasswordError = 'Error ${e.response?.statusCode}: ${e.response?.data}';
          }
          print('Error del servidor: ${e.response?.data}');
        } else {
          _changePasswordError = 'Error de conexión: ${e.message ?? e.toString()}';
          print('Error de conexión: ${e.message}');
        }
      } else {
        _changePasswordError = 'Error: ${e.toString()}';
        print('Error general: $e');
      }

      notifyListeners();
      return false;
    }
  }

  /// Actualizar la sesión guardada con los nuevos datos del perfil
  Future<void> _actualizarSesion(Map<String, dynamic> nuevosDatos) async {
    try {
      final session = await SessionStorage.getSession();
      if (session != null) {
        // Actualizar el objeto usuario en la sesión
        if (session['usuario'] is Map<String, dynamic>) {
          (session['usuario'] as Map<String, dynamic>).addAll({
            'login': nuevosDatos['login'] ?? session['usuario']['login'],
            'correo_electronico': nuevosDatos['correo_electronico'] ?? session['usuario']['correo_electronico'],
          });
        }
        
        // Guardar sesión actualizada
        await SessionStorage.saveSession(session);
      }
    } catch (e) {
      print('Error al actualizar sesión: $e');
    }
  }

  /// Actualizar la sesión guardada con la nueva URL de foto de perfil
  /// Crea copias nuevas de los objetos para asegurar que Flutter detecte los cambios
  /// Retorna true si se guardó correctamente, false en caso contrario
  Future<bool> _actualizarSesionFotoPerfil(String nuevaUrlFoto) async {
    try {
      final session = await SessionStorage.getSession();
      if (session == null) {
        print('ERROR: No hay sesión disponible para actualizar');
        return false;
      }
      
      print('DEBUG: Actualizando sesión con nueva foto: $nuevaUrlFoto');
      
      // Crear una copia nueva del objeto usuario
      Map<String, dynamic> usuarioActualizado;
      if (session['usuario'] is Map<String, dynamic>) {
        usuarioActualizado = Map<String, dynamic>.from(session['usuario'] as Map<String, dynamic>);
      } else {
        usuarioActualizado = {
          'id_usuario': session['usuario']?['id_usuario'] ?? 0,
          'login': session['usuario']?['login'] ?? '',
          'correo_electronico': session['usuario']?['correo_electronico'] ?? '',
        };
      }
      
      // Agregar la URL de la foto y un timestamp de actualización para evitar caché
      final timestampActualizacion = DateTime.now().millisecondsSinceEpoch;
      usuarioActualizado['url_foto_perfil'] = nuevaUrlFoto;
      usuarioActualizado['foto_perfil_timestamp'] = timestampActualizacion;
      
      // Crear una copia nueva de la sesión completa
      final sessionActualizada = Map<String, dynamic>.from(session);
      sessionActualizada['usuario'] = usuarioActualizado;
      sessionActualizada['url_foto_perfil'] = nuevaUrlFoto;
      sessionActualizada['foto_perfil_timestamp'] = timestampActualizacion;
      
      // Guardar sesión actualizada y esperar a que se complete
      final saved = await SessionStorage.saveSession(sessionActualizada);
      if (!saved) {
        print('ERROR: No se pudo guardar la sesión');
        return false;
      }
      
      // Verificar que se guardó correctamente leyendo de nuevo
      final verifySession = await SessionStorage.getSession();
      if (verifySession != null) {
        final fotoGuardada = verifySession['usuario']?['url_foto_perfil'];
        final timestampGuardado = verifySession['usuario']?['foto_perfil_timestamp'];
        if (fotoGuardada == nuevaUrlFoto && timestampGuardado == timestampActualizacion) {
          print('DEBUG: Sesión guardada y verificada exitosamente');
          print('DEBUG: Foto: $fotoGuardada');
          print('DEBUG: Timestamp: $timestampGuardado');
          
          // Pequeño delay para asegurar persistencia completa según el plan
          await Future.delayed(const Duration(milliseconds: 50));
          
          return true;
        } else {
          print('ERROR: La sesión guardada no coincide con lo esperado');
          return false;
        }
      } else {
        print('ERROR: No se pudo verificar la sesión guardada');
        return false;
      }
    } catch (e, stackTrace) {
      print('ERROR al actualizar sesión con foto: $e');
      print('Stack trace: $stackTrace');
      return false;
    }
  }

  /// Limpiar estados de error
  void limpiarErrores() {
    _errorMessage = null;
    _updateProfileError = null;
    _uploadPhotoError = null;
    _changePasswordError = null;
    notifyListeners();
  }
}


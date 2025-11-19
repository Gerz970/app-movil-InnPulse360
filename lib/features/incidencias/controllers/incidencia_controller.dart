import 'package:flutter/foundation.dart'; // Para uso de ChangeNotifier
import '../services/incidencia_service.dart'; // para conexion con servicio
import '../models/incidencia_model.dart'; // modelo de Incidencia
import '../models/habitacion_area_model.dart'; // modelo de HabitacionArea
import '../models/galeria_imagen_model.dart'; // modelo de Galería
import 'package:dio/dio.dart'; // clase dio para construir objeto de http
import '../../../core/auth/services/session_storage.dart'; // para obtener token de sesión

/// Controlador para manejar el estado del módulo de incidencias
/// Usa ChangeNotifier para notificar cambios de estado
class IncidenciaController extends ChangeNotifier {
  // Instancia de IncidenciaService
  final IncidenciaService _incidenciaService = IncidenciaService();

  // Estados privados para listado
  bool _isLoading = false; // Estado de carga
  List<Incidencia> _incidencias = []; // Lista de incidencias
  String? _errorMessage; // Mensaje de error (puede ser null)
  bool _isNotAuthenticated = false; // Estado de autenticación

  // Estados para catálogos (habitaciones/áreas)
  List<HabitacionArea> _habitacionesAreas = []; // Lista de habitaciones/áreas
  bool _isLoadingCatalogs = false; // Estado de carga de catálogos

  // Estados para creación
  bool _isCreating = false; // Estado de creación de incidencia
  String? _createErrorMessage; // Mensaje de error al crear

  // Estados para detalle y actualización
  Incidencia? _incidenciaDetail; // Incidencia en detalle
  bool _isLoadingDetail = false; // Estado de carga de detalle
  String? _detailErrorMessage; // Mensaje de error al cargar detalle
  bool _isUpdating = false; // Estado de actualización
  String? _updateErrorMessage; // Mensaje de error al actualizar
  
  // Estados para eliminación
  bool _isDeleting = false; // Estado de eliminación
  String? _deleteErrorMessage; // Mensaje de error al eliminar

  // Estados para galería
  List<GaleriaImagen> _galeriaImagenes = []; // Lista de imágenes de la galería
  bool _isLoadingGaleria = false; // Estado de carga de galería
  String? _galeriaErrorMessage; // Mensaje de error al cargar galería
  bool _isUploadingPhoto = false; // Estado de subida de foto
  String? _uploadPhotoError; // Mensaje de error al subir foto
  bool _isDeletingPhoto = false; // Estado de eliminación de foto

  // Getters para listado
  bool get isLoading => _isLoading;
  List<Incidencia> get incidencias => _incidencias;
  String? get errorMessage => _errorMessage;
  bool get isNotAuthenticated => _isNotAuthenticated;
  bool get isEmpty => _incidencias.isEmpty && !_isLoading && _errorMessage == null;
  
  // Getters para catálogos
  List<HabitacionArea> get habitacionesAreas => _habitacionesAreas;
  bool get isLoadingCatalogs => _isLoadingCatalogs;
  
  // Getters para creación
  bool get isCreating => _isCreating;
  String? get createErrorMessage => _createErrorMessage;
  
  // Getters para detalle y actualización
  Incidencia? get incidenciaDetail => _incidenciaDetail;
  bool get isLoadingDetail => _isLoadingDetail;
  String? get detailErrorMessage => _detailErrorMessage;
  bool get isUpdating => _isUpdating;
  String? get updateErrorMessage => _updateErrorMessage;
  
  // Getters para eliminación
  bool get isDeleting => _isDeleting;
  String? get deleteErrorMessage => _deleteErrorMessage;
  
  // Getters para galería
  List<GaleriaImagen> get galeriaImagenes => _galeriaImagenes;
  bool get isLoadingGaleria => _isLoadingGaleria;
  String? get galeriaErrorMessage => _galeriaErrorMessage;
  bool get isUploadingPhoto => _isUploadingPhoto;
  String? get uploadPhotoError => _uploadPhotoError;
  bool get isDeletingPhoto => _isDeletingPhoto;
  bool get canAddMorePhotos => _galeriaImagenes.length < 5;

  /// Método para obtener el listado de incidencias
  Future<void> fetchIncidencias() async {
    // 1.- Preparar petición
    _isLoading = true; // activar loading
    _errorMessage = null; // limpiar error anterior
    _isNotAuthenticated = false; // limpiar estado de autenticación
    notifyListeners(); // Notificar cambio de estado

    try {
      // 2.- hacer peticion al API
      final response = await _incidenciaService.fetchIncidencias();

      // 3.- Parsear respuesta a lista de Incidencia
      if (response.data != null && response.data is List) {
        _incidencias = (response.data as List)
            .map((json) => Incidencia.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        _incidencias = [];
      }

      // 4.- desactivar loading y notificar estado
      _isLoading = false;
      notifyListeners();

      // 5.- imprimir en consola la respuesta
      print("Incidencias obtenidas correctamente");
      print('Status code: ${response.statusCode}');
      print('Total de incidencias: ${_incidencias.length}');
    } catch (e) {
      // 6. Desactivar loading
      _isLoading = false;

      // 7. Manejar errores
      if (e is DioException) {
        // Verificar si hay respuesta del servidor
        if (e.response != null) {
          final responseData = e.response?.data;
          
          // Verificar si es error de autenticación
          if (responseData is Map<String, dynamic> && 
              responseData['detail'] == 'Not authenticated') {
            _isNotAuthenticated = true;
            _errorMessage = 'No estás autenticado. Por favor, inicia sesión nuevamente.';
            print('Error de autenticación: ${e.response?.data}');
          } else {
            // Otro error del servidor
            _errorMessage = 'Error ${e.response?.statusCode}: ${e.response?.data}';
            print('Error del servidor: ${e.response?.data}');
          }
        } else {
          // Error de conexión (sin respuesta del servidor)
          // Limpiar el mensaje técnico y mostrar uno más amigable
          final errorMsg = e.message ?? e.toString();
          if (errorMsg.contains('XMLHttpRequest') || 
              errorMsg.contains('connection') ||
              errorMsg.contains('network')) {
            _errorMessage = 'Error de conexión. Verifica tu conexión a internet e intenta nuevamente.';
          } else {
            _errorMessage = 'Error de conexión: ${errorMsg.length > 100 ? errorMsg.substring(0, 100) + '...' : errorMsg}';
          }
          print('Error de conexión: ${e.message}');
        }
      } else {
        // Otro tipo de error (no es DioException)
        _errorMessage = 'Error: ${e.toString()}';
        print('Error general: $e');
      }

      // Notificar cambio de estado
      notifyListeners();
    }
  }

  /// Método para cargar las habitaciones reservadas por el cliente
  /// Obtiene la lista de habitaciones que el cliente ha reservado para poder crear incidencias
  Future<void> loadHabitacionesReservadasCliente() async {
    print('🔄 Iniciando carga de habitaciones reservadas por cliente...');
    _isLoadingCatalogs = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Obtener cliente_id desde la sesión (está dentro del objeto 'usuario')
      final session = await SessionStorage.getSession();
      final usuario = session?['usuario'] as Map<String, dynamic>?;
      final clienteId = usuario?['cliente_id'] as int?;

      if (clienteId == null || clienteId == 0) {
        throw DioException(
          requestOptions: RequestOptions(path: ''),
          error: 'Cliente ID no encontrado en la sesión',
          type: DioExceptionType.unknown,
        );
      }

      // Hacer petición al API directamente con el cliente_id
      final response = await _incidenciaService.fetchHabitacionesReservadasCliente(clienteId);

      // Parsear respuesta a lista de HabitacionArea
      if (response.data != null && response.data is List) {
        _habitacionesAreas = (response.data as List)
            .map((json) => HabitacionArea.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        _habitacionesAreas = [];
      }

      _isLoadingCatalogs = false;
      notifyListeners();

      print("✅ Habitaciones reservadas cargadas correctamente");
      print('Cliente ID: $clienteId');
      print('Total de habitaciones: ${_habitacionesAreas.length}');
      } catch (e) {
      _isLoadingCatalogs = false;
      print('❌ Error cargando habitaciones reservadas: $e');

      if (e is DioException) {
        if (e.response != null) {
          final responseData = e.response?.data;

          // Error 401 - No autenticado
          if (e.response?.statusCode == 401 ||
              (responseData is Map<String, dynamic> &&
               responseData['detail'] == 'Not authenticated')) {
            _isNotAuthenticated = true;
            _errorMessage = 'No estás autenticado. Por favor, inicia sesión nuevamente.';
            print('Error de autenticación al cargar habitaciones: ${e.response?.data}');
          } else {
            _errorMessage = 'Error al cargar habitaciones: ${e.response?.statusCode}';
            print('Error del servidor al cargar habitaciones: ${e.response?.data}');
          }
        } else {
          _errorMessage = 'Error de conexión al cargar habitaciones: ${e.message ?? e.toString()}';
          print('Error de conexión al cargar habitaciones: ${e.message}');
        }
      } else {
        _errorMessage = 'Error al cargar habitaciones: ${e.toString()}';
        print('Error general al cargar habitaciones: $e');
      }

      notifyListeners();
    }
  }

  /// Método para crear una nueva incidencia
  /// Recibe un Map con los datos de la incidencia
  Future<bool> createIncidencia(Map<String, dynamic> incidenciaData) async {
    _isCreating = true;
    _createErrorMessage = null;
    notifyListeners();

    try {
      // Crear incidencia mediante el servicio
      final response = await _incidenciaService.createIncidencia(incidenciaData);

      // Si éxito, guardar el detalle de la incidencia creada
      if (response.data != null && response.data is Map<String, dynamic>) {
        _incidenciaDetail = Incidencia.fromJson(response.data as Map<String, dynamic>);
      }

      _isCreating = false;
      notifyListeners();

      print("Incidencia creada correctamente");
      print('Status code: ${response.statusCode}');
      print(response.data);

      // Refrescar lista de incidencias
      await fetchIncidencias();

      return true;
    } catch (e) {
      _isCreating = false;

      // Manejar errores
      if (e is DioException) {
        if (e.response != null) {
          final responseData = e.response?.data;
          final statusCode = e.response?.statusCode;

          // Error 401 - No autenticado
          if (statusCode == 401 || 
              (responseData is Map<String, dynamic> && 
               responseData['detail'] == 'Not authenticated')) {
            _isNotAuthenticated = true;
            _createErrorMessage = 'No estás autenticado. Por favor, inicia sesión nuevamente.';
            print('Error de autenticación al crear incidencia: ${e.response?.data}');
          }
          // Error 422 - Validación
          else if (statusCode == 422) {
            _createErrorMessage = 'Error de validación: ${e.response?.data}';
            print('Error de validación al crear incidencia: ${e.response?.data}');
          }
          // Otro error del servidor
          else {
            _createErrorMessage = 'Error ${statusCode}: ${e.response?.data}';
            print('Error del servidor al crear incidencia: ${e.response?.data}');
          }
        } else {
          // Error de conexión
          _createErrorMessage = 'Error de conexión: ${e.message ?? e.toString()}';
          print('Error de conexión al crear incidencia: ${e.message}');
        }
      } else {
        // Otro tipo de error
        _createErrorMessage = 'Error: ${e.toString()}';
        print('Error general al crear incidencia: $e');
      }

      notifyListeners();
      return false;
    }
  }

  /// Método para cargar el detalle de una incidencia
  /// Carga el detalle de la incidencia mediante GET por incidenciaId
  Future<void> loadIncidenciaDetail(int incidenciaId) async {
    _isLoadingDetail = true;
    _detailErrorMessage = null;
    _incidenciaDetail = null;
    notifyListeners();

    try {
      // Cargar detalle de la incidencia
      final response = await _incidenciaService.fetchIncidenciaDetail(incidenciaId);
      
      // Parsear respuesta a Incidencia
      if (response.data != null && response.data is Map<String, dynamic>) {
        _incidenciaDetail = Incidencia.fromJson(response.data as Map<String, dynamic>);

        // Si la habitación no viene en la respuesta, intentar cargarla por separado
        if (_incidenciaDetail != null && _incidenciaDetail!.habitacionArea == null) {
          try {
            print('Habitación no incluida en respuesta, cargando por separado...');
            final habitacionResponse = await _incidenciaService.fetchHabitacionArea(_incidenciaDetail!.habitacionAreaId);

            if (habitacionResponse.data != null && habitacionResponse.data is Map<String, dynamic>) {
              final habitacionArea = HabitacionArea.fromJson(habitacionResponse.data as Map<String, dynamic>);
              // Crear una nueva instancia de Incidencia con la habitación cargada
              _incidenciaDetail = Incidencia(
                idIncidencia: _incidenciaDetail!.idIncidencia,
                habitacionAreaId: _incidenciaDetail!.habitacionAreaId,
                incidencia: _incidenciaDetail!.incidencia,
                descripcion: _incidenciaDetail!.descripcion,
                fechaIncidencia: _incidenciaDetail!.fechaIncidencia,
                idEstatus: _incidenciaDetail!.idEstatus,
                habitacionArea: habitacionArea,
              );
              print('Habitación cargada correctamente por separado');
            }
          } catch (habitacionError) {
            print('Error al cargar habitación por separado: $habitacionError');
            // No es un error crítico, continuar sin la habitación
          }
        }
      } else {
        _detailErrorMessage = 'No se pudo obtener el detalle de la incidencia';
      }

      _isLoadingDetail = false;
      notifyListeners();

      print("Detalle de incidencia obtenido correctamente");
      print('Status code: ${response.statusCode}');
    } catch (e) {
      _isLoadingDetail = false;

      // Manejar errores
      if (e is DioException) {
        if (e.response != null) {
          final responseData = e.response?.data;
          final statusCode = e.response?.statusCode;

          // Error 401 - No autenticado
          if (statusCode == 401 || 
              (responseData is Map<String, dynamic> && 
               responseData['detail'] == 'Not authenticated')) {
            _isNotAuthenticated = true;
            _detailErrorMessage = 'No estás autenticado. Por favor, inicia sesión nuevamente.';
            print('Error de autenticación al cargar detalle: ${e.response?.data}');
          }
          // Otro error del servidor
          else {
            _detailErrorMessage = 'Error ${statusCode}: ${e.response?.data}';
            print('Error del servidor al cargar detalle: ${e.response?.data}');
          }
        } else {
          // Error de conexión
          _detailErrorMessage = 'Error de conexión: ${e.message ?? e.toString()}';
          print('Error de conexión al cargar detalle: ${e.message}');
        }
      } else {
        // Otro tipo de error
        _detailErrorMessage = 'Error: ${e.toString()}';
        print('Error general al cargar detalle: $e');
      }

      notifyListeners();
    }
  }

  /// Método para actualizar una incidencia
  /// Recibe incidenciaId y Map con los datos a actualizar
  Future<bool> updateIncidencia(int incidenciaId, Map<String, dynamic> incidenciaData) async {
    _isUpdating = true;
    _updateErrorMessage = null;
    notifyListeners();

    try {
      // Actualizar incidencia mediante el servicio
      final response = await _incidenciaService.updateIncidencia(incidenciaId, incidenciaData);

      // Si éxito, actualizar _incidenciaDetail con los nuevos datos
      if (response.data != null && response.data is Map<String, dynamic>) {
        _incidenciaDetail = Incidencia.fromJson(response.data as Map<String, dynamic>);
      }

      _isUpdating = false;
      notifyListeners();

      print("Incidencia actualizada correctamente");
      print('Status code: ${response.statusCode}');
      print(response.data);

      return true;
    } catch (e) {
      _isUpdating = false;

      // Manejar errores
      if (e is DioException) {
        if (e.response != null) {
          final responseData = e.response?.data;
          final statusCode = e.response?.statusCode;

          // Error 401 - No autenticado
          if (statusCode == 401 || 
              (responseData is Map<String, dynamic> && 
               responseData['detail'] == 'Not authenticated')) {
            _isNotAuthenticated = true;
            _updateErrorMessage = 'No estás autenticado. Por favor, inicia sesión nuevamente.';
            print('Error de autenticación al actualizar incidencia: ${e.response?.data}');
          }
          // Error 422 - Validación
          else if (statusCode == 422) {
            _updateErrorMessage = 'Error de validación: ${e.response?.data}';
            print('Error de validación al actualizar incidencia: ${e.response?.data}');
          }
          // Otro error del servidor
          else {
            _updateErrorMessage = 'Error ${statusCode}: ${e.response?.data}';
            print('Error del servidor al actualizar incidencia: ${e.response?.data}');
          }
        } else {
          // Error de conexión
          _updateErrorMessage = 'Error de conexión: ${e.message ?? e.toString()}';
          print('Error de conexión al actualizar incidencia: ${e.message}');
        }
      } else {
        // Otro tipo de error
        _updateErrorMessage = 'Error: ${e.toString()}';
        print('Error general al actualizar incidencia: $e');
      }

      notifyListeners();
      return false;
    }
  }

  /// Método para eliminar una incidencia
  /// Recibe incidenciaId de la incidencia a eliminar
  /// Retorna true en éxito, false en error
  Future<bool> deleteIncidencia(int incidenciaId) async {
    _isDeleting = true;
    _deleteErrorMessage = null;
    _isNotAuthenticated = false;
    notifyListeners();

    try {
      // Eliminar incidencia mediante el servicio
      final response = await _incidenciaService.deleteIncidencia(incidenciaId);

      // Verificar código de respuesta
      if (response.statusCode == 200 || response.statusCode == 204) {
        // Eliminar incidencia de la lista local
        _incidencias.removeWhere((incidencia) => incidencia.idIncidencia == incidenciaId);
        
        _isDeleting = false;
        notifyListeners();

        print("Incidencia eliminada correctamente");
        print('Status code: ${response.statusCode}');

        return true;
      } else {
        _isDeleting = false;
        _deleteErrorMessage = 'Error inesperado: ${response.statusCode}';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _isDeleting = false;

      // Manejar errores
      if (e is DioException) {
        if (e.response != null) {
          final responseData = e.response?.data;
          final statusCode = e.response?.statusCode;

          // Error 401 - No autenticado
          if (statusCode == 401 || 
              (responseData is Map<String, dynamic> && 
               responseData['detail'] == 'Not authenticated')) {
            _isNotAuthenticated = true;
            _deleteErrorMessage = 'No estás autenticado. Por favor, inicia sesión nuevamente.';
            print('Error de autenticación al eliminar incidencia: ${e.response?.data}');
          }
          // Error 404 - No existe
          else if (statusCode == 404) {
            _deleteErrorMessage = 'La incidencia ya no existe.';
            print('Error 404 al eliminar incidencia: ${e.response?.data}');
          }
          // Error 409/422 - Dependencias activas
          else if (statusCode == 409 || statusCode == 422) {
            _deleteErrorMessage = 'No es posible eliminar la incidencia por dependencias activas.';
            print('Error de dependencias al eliminar incidencia: ${e.response?.data}');
          }
          // Otro error del servidor (500+)
          else {
            _deleteErrorMessage = 'Error del servidor: ${e.response?.data ?? statusCode}';
            print('Error del servidor al eliminar incidencia: ${e.response?.data}');
          }
        } else {
          // Error de conexión
          _deleteErrorMessage = 'Error de conexión: ${e.message ?? e.toString()}';
          print('Error de conexión al eliminar incidencia: ${e.message}');
        }
      } else {
        // Otro tipo de error
        _deleteErrorMessage = 'Error: ${e.toString()}';
        print('Error general al eliminar incidencia: $e');
      }

      notifyListeners();
      return false;
    }
  }

  /// Método para cargar la galería de una incidencia
  /// Carga todas las imágenes asociadas a la incidencia
  Future<void> fetchGaleria(int incidenciaId) async {
    _isLoadingGaleria = true;
    _galeriaErrorMessage = null;
    notifyListeners();

    try {
      final response = await _incidenciaService.fetchGaleria(incidenciaId);

      print('📦 Response recibida. Tipo: ${response.data.runtimeType}');
      print('📦 Response data: ${response.data}');

      if (response.data != null && response.data is Map<String, dynamic>) {
        final galeriaResponse = GaleriaResponse.fromJson(response.data as Map<String, dynamic>);
        _galeriaImagenes = galeriaResponse.imagenes;
        print('✅ Galería parseada correctamente');
        print('Total de imágenes: ${_galeriaImagenes.length}');
        if (_galeriaImagenes.isNotEmpty) {
          print('Primera imagen: ${_galeriaImagenes.first.nombre}');
        }
      } else {
        print('⚠️ Response data no es Map o es null');
        print('Tipo de response.data: ${response.data?.runtimeType}');
        _galeriaImagenes = [];
      }

      _isLoadingGaleria = false;
      notifyListeners();

      print("✅ Galería cargada correctamente");
      print('Total de imágenes: ${_galeriaImagenes.length}');
    } catch (e) {
      _isLoadingGaleria = false;
      _galeriaImagenes = [];

      if (e is DioException) {
        if (e.response != null) {
          final responseData = e.response?.data;
          
          if (responseData is Map<String, dynamic> && 
              responseData['detail'] == 'Not authenticated') {
            _isNotAuthenticated = true;
            _galeriaErrorMessage = 'No estás autenticado. Por favor, inicia sesión nuevamente.';
          } else {
            _galeriaErrorMessage = 'Error al cargar galería: ${e.response?.statusCode}';
          }
        } else {
          _galeriaErrorMessage = 'Error de conexión al cargar galería: ${e.message ?? e.toString()}';
        }
      } else {
        _galeriaErrorMessage = 'Error al cargar galería: ${e.toString()}';
      }

      notifyListeners();
      print('Error al cargar galería: $e');
    }
  }

  /// Método para subir una foto a la galería de una incidencia
  /// Recibe incidenciaId y filePath del archivo a subir
  /// Retorna true en éxito, false en error
  Future<bool> uploadPhoto(int incidenciaId, String filePath) async {
    _isUploadingPhoto = true;
    _uploadPhotoError = null;
    notifyListeners();

    try {
      await _incidenciaService.uploadFotoGaleria(incidenciaId, filePath);
      
      _isUploadingPhoto = false;
      notifyListeners();

      print("Foto subida correctamente");

      // Refrescar galería después de subir
      await fetchGaleria(incidenciaId);
      
      return true;
    } catch (e) {
      _isUploadingPhoto = false;

      if (e is DioException) {
        if (e.response != null) {
          final responseData = e.response?.data;
          final statusCode = e.response?.statusCode;

          if (statusCode == 401 || 
              (responseData is Map<String, dynamic> && 
               responseData['detail'] == 'Not authenticated')) {
            _isNotAuthenticated = true;
            _uploadPhotoError = 'No estás autenticado. Por favor, inicia sesión nuevamente.';
          } else {
            _uploadPhotoError = 'Error al subir foto: ${e.response?.statusCode}';
          }
        } else {
          _uploadPhotoError = 'Error de conexión al subir foto: ${e.message ?? e.toString()}';
        }
      } else {
        _uploadPhotoError = 'Error al subir foto: ${e.toString()}';
      }

      notifyListeners();
      print('Error al subir foto: $e');
      return false;
    }
  }

  /// Método para eliminar una foto de la galería de una incidencia
  /// Recibe incidenciaId y nombreArchivo de la imagen a eliminar
  /// Retorna true en éxito, false en error
  /// Después de eliminar exitosamente, recarga la galería automáticamente
  Future<bool> deletePhoto(int incidenciaId, String nombreArchivo) async {
    _isDeletingPhoto = true;
    _uploadPhotoError = null; // Limpiar error anterior
    notifyListeners();

    try {
      print('🗑️ Iniciando eliminación de foto: $nombreArchivo');
      
      // Hacer la petición DELETE al endpoint
      final response = await _incidenciaService.deleteFotoGaleria(incidenciaId, nombreArchivo);
      
      // Verificar que la respuesta sea exitosa
      if (response.statusCode == 200 || response.statusCode == 204) {
        print("✅ Foto eliminada correctamente. Status: ${response.statusCode}");
        
        _isDeletingPhoto = false;
        notifyListeners();

        // Esperar un momento para que el servidor procese la eliminación
        await Future.delayed(const Duration(milliseconds: 200));
        
        // Refrescar galería después de eliminar exitosamente
        print('🔄 Recargando galería después de eliminar...');
        await fetchGaleria(incidenciaId);
        print('✅ Galería recargada correctamente');
        
        return true;
      } else {
        // Respuesta inesperada
        _isDeletingPhoto = false;
        _uploadPhotoError = 'Error inesperado al eliminar foto: ${response.statusCode}';
        notifyListeners();
        print('⚠️ Respuesta inesperada al eliminar: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      _isDeletingPhoto = false;

      if (e is DioException) {
        if (e.response != null) {
          final responseData = e.response?.data;
          final statusCode = e.response?.statusCode;
          
          if (statusCode == 401 || 
              (responseData is Map<String, dynamic> && 
               responseData['detail'] == 'Not authenticated')) {
            _isNotAuthenticated = true;
            _uploadPhotoError = 'No estás autenticado. Por favor, inicia sesión nuevamente.';
          } else if (statusCode == 404) {
            _uploadPhotoError = 'La foto no existe o ya fue eliminada.';
            // Aún así, intentar recargar la galería por si acaso
            await fetchGaleria(incidenciaId);
          } else {
            _uploadPhotoError = 'Error al eliminar foto: ${responseData ?? statusCode}';
          }
        } else {
          // Error de conexión
          _uploadPhotoError = 'Error de conexión al eliminar foto: ${e.message ?? e.toString()}';
        }
      } else {
        _uploadPhotoError = 'Error al eliminar foto: ${e.toString()}';
      }

      notifyListeners();
      print('❌ Error al eliminar foto: $e');
      return false;
    }
  }
}


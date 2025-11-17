import 'package:flutter/foundation.dart'; // Para uso de ChangeNotifier
import '../services/hotel_service.dart'; // para conexion con servicio
import '../models/hotel_model.dart'; // modelo de Hotel
import '../models/pais_model.dart'; // modelo de País
import '../models/estado_model.dart'; // modelo de Estado
import 'package:dio/dio.dart'; // clase dio para construir objeto de http

/// Controlador para manejar el estado del módulo de hoteles
/// Usa ChangeNotifier para notificar cambios de estado
class HotelController extends ChangeNotifier {
  // Instancia de HotelService
  final HotelService _hotelService = HotelService();

  // Estados privados
  bool _isLoading = false; // Estado de carga
  List<Hotel> _hotels = []; // Lista de hoteles
  String? _errorMessage; // Mensaje de error (puede ser null)
  bool _isNotAuthenticated = false; // Estado de autenticación

  // Estados para catálogos y creación
  List<Pais> _paises = []; // Lista de países
  List<Estado> _estados = []; // Lista de estados
  bool _isLoadingCatalogs = false; // Estado de carga de catálogos
  bool _isCreating = false; // Estado de creación de hotel
  String? _createErrorMessage; // Mensaje de error al crear
  
  // Estados para foto de hotel
  bool _isUploadingPhoto = false; // Estado de subida de foto
  String? _uploadPhotoError; // Mensaje de error al subir foto
  bool _isDeletingPhoto = false; // Estado de eliminación de foto
  
  // Estados para detalle (país y estado específicos)
  Pais? _paisDetail; // País específico para detalle
  Estado? _estadoDetail; // Estado específico para detalle

  // Estados para detalle y actualización
  Hotel? _hotelDetail; // Hotel en detalle
  bool _isLoadingDetail = false; // Estado de carga de detalle
  String? _detailErrorMessage; // Mensaje de error al cargar detalle
  bool _isUpdating = false; // Estado de actualización
  String? _updateErrorMessage; // Mensaje de error al actualizar
  
  // Estados para eliminación
  bool _isDeleting = false; // Estado de eliminación
  String? _deleteErrorMessage; // Mensaje de error al eliminar

  // Getters
  bool get isLoading => _isLoading;
  List<Hotel> get hotels => _hotels;
  String? get errorMessage => _errorMessage;
  bool get isNotAuthenticated => _isNotAuthenticated;
  bool get isEmpty => _hotels.isEmpty && !_isLoading && _errorMessage == null;
  
  // Getters para catálogos y creación
  List<Pais> get paises => _paises;
  List<Estado> get estados => _estados;
  bool get isLoadingCatalogs => _isLoadingCatalogs;
  bool get isCreating => _isCreating;
  String? get createErrorMessage => _createErrorMessage;
  
  // Getters para foto de hotel
  bool get isUploadingPhoto => _isUploadingPhoto;
  String? get uploadPhotoError => _uploadPhotoError;
  bool get isDeletingPhoto => _isDeletingPhoto;
  
  // Getters para detalle
  Pais? get paisDetail => _paisDetail;
  Estado? get estadoDetail => _estadoDetail;
  
  // Getters para detalle y actualización
  Hotel? get hotelDetail => _hotelDetail;
  bool get isLoadingDetail => _isLoadingDetail;
  String? get detailErrorMessage => _detailErrorMessage;
  bool get isUpdating => _isUpdating;
  String? get updateErrorMessage => _updateErrorMessage;
  
  // Getters para eliminación
  bool get isDeleting => _isDeleting;
  String? get deleteErrorMessage => _deleteErrorMessage;

  /// Método para obtener el listado de hoteles
  Future<void> fetchHotels({int skip = 0, int limit = 100}) async {
    // 1.- Preparar petición
    _isLoading = true; // activar loading
    _errorMessage = null; // limpiar error anterior
    _isNotAuthenticated = false; // limpiar estado de autenticación
    notifyListeners(); // Notificar cambio de estado

    try {
      // 2.- hacer peticion al API
      final response = await _hotelService.fetchHotels(skip: skip, limit: limit);

      // 3.- Parsear respuesta a lista de Hotel
      if (response.data != null && response.data is List) {
        _hotels = (response.data as List)
            .map((json) => Hotel.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        _hotels = [];
      }

      // 4.- desactivar loading y notificar estado
      _isLoading = false;
      notifyListeners();

      // 5.- imprimir en consola la respuesta
      print("Hoteles obtenidos correctamente");
      print('Status code: ${response.statusCode}');
      print('Total de hoteles: ${_hotels.length}');
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
          _errorMessage = 'Error de conexión: ${e.message ?? e.toString()}';
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

  /// Método para cargar los catálogos de países y estados
  /// Carga todos los países con paginación (múltiples peticiones si es necesario)
  /// Usado para creación de hotel
  Future<void> loadCatalogs() async {
    _isLoadingCatalogs = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Cargar todos los países con paginación
      _paises = [];
      int skip = 0;
      const int limit = 100;
      bool hasMore = true;

      while (hasMore) {
        final paisesResponse = await _hotelService.fetchPaises(skip: skip, limit: limit);
        
        if (paisesResponse.data != null && paisesResponse.data is List) {
          final paisesPage = (paisesResponse.data as List)
              .map((json) => Pais.fromJson(json as Map<String, dynamic>))
              .toList();
          
          _paises.addAll(paisesPage);
          
          // Si la página tiene menos de limit elementos, no hay más páginas
          hasMore = paisesPage.length == limit;
          skip += limit;
        } else {
          hasMore = false;
        }
      }

      _isLoadingCatalogs = false;
      notifyListeners();

      print("Catálogos cargados correctamente");
      print('Total de países: ${_paises.length}');
    } catch (e) {
      _isLoadingCatalogs = false;

      if (e is DioException) {
        if (e.response != null) {
          _errorMessage = 'Error al cargar catálogos: ${e.response?.statusCode}';
          print('Error del servidor al cargar catálogos: ${e.response?.data}');
        } else {
          _errorMessage = 'Error de conexión al cargar catálogos: ${e.message ?? e.toString()}';
          print('Error de conexión al cargar catálogos: ${e.message}');
        }
      } else {
        _errorMessage = 'Error al cargar catálogos: ${e.toString()}';
        print('Error general al cargar catálogos: $e');
      }

      notifyListeners();
    }
  }

  /// Método para cargar estados por país seleccionado
  /// Limpia la lista de estados anterior y carga los nuevos
  /// Carga todos los estados con paginación (múltiples peticiones si es necesario)
  Future<void> loadEstadosByPais(int idPais) async {
    _estados = []; // Limpiar estados anteriores
    notifyListeners();

    try {
      // Cargar todos los estados del país con paginación
      int skip = 0;
      const int limit = 100;
      bool hasMore = true;

      while (hasMore) {
        final estadosResponse = await _hotelService.fetchEstados(
          skip: skip,
          limit: limit,
          idPais: idPais,
        );
        
        if (estadosResponse.data != null && estadosResponse.data is List) {
          final estadosPage = (estadosResponse.data as List)
              .map((json) => Estado.fromJson(json as Map<String, dynamic>))
              .toList();
          
          _estados.addAll(estadosPage);
          
          // Si la página tiene menos de limit elementos, no hay más páginas
          hasMore = estadosPage.length == limit;
          skip += limit;
        } else {
          hasMore = false;
        }
      }

      notifyListeners();
      print("Estados cargados correctamente para país $idPais");
      print('Total de estados: ${_estados.length}');
    } catch (e) {
      _estados = [];

      if (e is DioException) {
        if (e.response != null) {
          print('Error del servidor al cargar estados: ${e.response?.data}');
        } else {
          print('Error de conexión al cargar estados: ${e.message}');
        }
      } else {
        print('Error general al cargar estados: $e');
      }

      notifyListeners();
    }
  }

  /// Método para cargar un país específico por ID
  /// Usado para detalle de hotel (no necesita cargar todos los países)
  Future<void> loadPaisById(int idPais) async {
    try {
      final response = await _hotelService.fetchPaisById(idPais);
      
      if (response.data != null && response.data is Map<String, dynamic>) {
        _paisDetail = Pais.fromJson(response.data as Map<String, dynamic>);
      } else {
        _paisDetail = null;
      }

      notifyListeners();
      print("País cargado correctamente: ${_paisDetail?.nombre}");
    } catch (e) {
      _paisDetail = null;

      if (e is DioException) {
        if (e.response != null) {
          print('Error del servidor al cargar país: ${e.response?.data}');
        } else {
          print('Error de conexión al cargar país: ${e.message}');
        }
      } else {
        print('Error general al cargar país: $e');
      }

      notifyListeners();
    }
  }

  /// Método para cargar un estado específico por ID
  /// Usado para detalle de hotel (no necesita cargar todos los estados)
  Future<void> loadEstadoById(int idEstado) async {
    try {
      final response = await _hotelService.fetchEstadoById(idEstado);
      
      if (response.data != null && response.data is Map<String, dynamic>) {
        _estadoDetail = Estado.fromJson(response.data as Map<String, dynamic>);
      } else {
        _estadoDetail = null;
      }

      notifyListeners();
      print("Estado cargado correctamente: ${_estadoDetail?.nombre}");
    } catch (e) {
      _estadoDetail = null;

      if (e is DioException) {
        if (e.response != null) {
          print('Error del servidor al cargar estado: ${e.response?.data}');
        } else {
          print('Error de conexión al cargar estado: ${e.message}');
        }
      } else {
        print('Error general al cargar estado: $e');
      }

      notifyListeners();
    }
  }

  /// Método para crear un nuevo hotel
  /// Recibe un Map con los datos del hotel
  Future<bool> createHotel(Map<String, dynamic> hotelData) async {
    _isCreating = true;
    _createErrorMessage = null;
    notifyListeners();

    try {
      // Crear hotel mediante el servicio
      final response = await _hotelService.createHotel(hotelData);

      // Si éxito, refrescar la lista de hoteles
      _isCreating = false;
      notifyListeners();

      print("Hotel creado correctamente");
      print('Status code: ${response.statusCode}');
      print(response.data);

      // Refrescar lista de hoteles
      await fetchHotels();

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
            print('Error de autenticación al crear hotel: ${e.response?.data}');
          }
          // Error 422 - Validación
          else if (statusCode == 422) {
            _createErrorMessage = 'Error de validación: ${e.response?.data}';
            print('Error de validación al crear hotel: ${e.response?.data}');
          }
          // Otro error del servidor
          else {
            _createErrorMessage = 'Error ${statusCode}: ${e.response?.data}';
            print('Error del servidor al crear hotel: ${e.response?.data}');
          }
        } else {
          // Error de conexión
          _createErrorMessage = 'Error de conexión: ${e.message ?? e.toString()}';
          print('Error de conexión al crear hotel: ${e.message}');
        }
      } else {
        // Otro tipo de error
        _createErrorMessage = 'Error: ${e.toString()}';
        print('Error general al crear hotel: $e');
      }

      notifyListeners();
      return false;
    }
  }

  /// Método para cargar el detalle de un hotel
  /// Carga el detalle del hotel mediante GET por hotelId
  Future<void> loadHotelDetail(int hotelId) async {
    _isLoadingDetail = true;
    _detailErrorMessage = null;
    _hotelDetail = null;
    notifyListeners();

    try {
      // Cargar detalle del hotel
      final response = await _hotelService.fetchHotelDetail(hotelId);
      
      // Parsear respuesta a Hotel
      if (response.data != null && response.data is Map<String, dynamic>) {
        _hotelDetail = Hotel.fromJson(response.data as Map<String, dynamic>);
      } else {
        _detailErrorMessage = 'No se pudo obtener el detalle del hotel';
      }

      _isLoadingDetail = false;
      notifyListeners();

      print("Detalle de hotel obtenido correctamente");
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

  /// Método para actualizar un hotel
  /// Recibe hotelId y Map con los datos a actualizar (solo campos editables)
  Future<bool> updateHotel(int hotelId, Map<String, dynamic> hotelData) async {
    _isUpdating = true;
    _updateErrorMessage = null;
    notifyListeners();

    try {
      // Actualizar hotel mediante el servicio
      final response = await _hotelService.updateHotel(hotelId, hotelData);

      // Si éxito, actualizar _hotelDetail con los nuevos datos
      if (response.data != null && response.data is Map<String, dynamic>) {
        _hotelDetail = Hotel.fromJson(response.data as Map<String, dynamic>);
      } else if (_hotelDetail != null) {
        // Si no hay respuesta completa, actualizar solo los campos editables
        _hotelDetail = Hotel(
          idHotel: _hotelDetail!.idHotel,
          nombre: hotelData['nombre'] as String? ?? _hotelDetail!.nombre,
          direccion: _hotelDetail!.direccion,
          codigoPostal: _hotelDetail!.codigoPostal,
          telefono: hotelData['telefono'] as String? ?? _hotelDetail!.telefono,
          emailContacto: _hotelDetail!.emailContacto,
          idPais: _hotelDetail!.idPais,
          idEstado: _hotelDetail!.idEstado,
          numeroEstrellas: hotelData['numero_estrellas'] as int? ?? _hotelDetail!.numeroEstrellas,
          urlFotoPerfil: _hotelDetail!.urlFotoPerfil,
        );
      }

      _isUpdating = false;
      notifyListeners();

      print("Hotel actualizado correctamente");
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
            print('Error de autenticación al actualizar hotel: ${e.response?.data}');
          }
          // Error 422 - Validación
          else if (statusCode == 422) {
            _updateErrorMessage = 'Error de validación: ${e.response?.data}';
            print('Error de validación al actualizar hotel: ${e.response?.data}');
          }
          // Otro error del servidor
          else {
            _updateErrorMessage = 'Error ${statusCode}: ${e.response?.data}';
            print('Error del servidor al actualizar hotel: ${e.response?.data}');
          }
        } else {
          // Error de conexión
          _updateErrorMessage = 'Error de conexión: ${e.message ?? e.toString()}';
          print('Error de conexión al actualizar hotel: ${e.message}');
        }
      } else {
        // Otro tipo de error
        _updateErrorMessage = 'Error: ${e.toString()}';
        print('Error general al actualizar hotel: $e');
      }

      notifyListeners();
      return false;
    }
  }

  /// Método para eliminar un hotel
  /// Recibe hotelId del hotel a eliminar
  /// Retorna true en éxito, false en error
  Future<bool> deleteHotel(int hotelId) async {
    _isDeleting = true;
    _deleteErrorMessage = null;
    _isNotAuthenticated = false;
    notifyListeners();

    try {
      // Eliminar hotel mediante el servicio
      final response = await _hotelService.deleteHotel(hotelId);

      // Verificar código de respuesta
      if (response.statusCode == 200 || response.statusCode == 204) {
        // Eliminar hotel de la lista local
        _hotels.removeWhere((hotel) => hotel.idHotel == hotelId);
        
        _isDeleting = false;
        notifyListeners();

        print("Hotel eliminado correctamente");
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
            print('Error de autenticación al eliminar hotel: ${e.response?.data}');
          }
          // Error 404 - No existe
          else if (statusCode == 404) {
            _deleteErrorMessage = 'El hotel ya no existe.';
            print('Error 404 al eliminar hotel: ${e.response?.data}');
          }
          // Error 409/422 - Dependencias activas
          else if (statusCode == 409 || statusCode == 422) {
            _deleteErrorMessage = 'No es posible eliminar el hotel por dependencias activas.';
            print('Error de dependencias al eliminar hotel: ${e.response?.data}');
          }
          // Otro error del servidor (500+)
          else {
            _deleteErrorMessage = 'Error del servidor: ${e.response?.data ?? statusCode}';
            print('Error del servidor al eliminar hotel: ${e.response?.data}');
          }
        } else {
          // Error de conexión
          _deleteErrorMessage = 'Error de conexión: ${e.message ?? e.toString()}';
          print('Error de conexión al eliminar hotel: ${e.message}');
        }
      } else {
        // Otro tipo de error
        _deleteErrorMessage = 'Error: ${e.toString()}';
        print('Error general al eliminar hotel: $e');
      }

      notifyListeners();
      return false;
    }
  }

  /// Subir foto de hotel
  /// Recibe hotelId, los bytes del archivo y el nombre del archivo
  Future<bool> subirFotoHotel(int hotelId, List<int> fileBytes, String fileName) async {
    _isUploadingPhoto = true;
    _uploadPhotoError = null;
    notifyListeners();

    try {
      final response = await _hotelService.subirFotoHotel(hotelId, fileBytes, fileName);

      if (response.data != null) {
        final responseData = response.data as Map<String, dynamic>;
        
        // Actualizar la URL de la foto en el hotel del detalle
        if (_hotelDetail != null && responseData['public_url'] != null) {
          final nuevaUrlFoto = responseData['public_url'] as String;
          _hotelDetail = Hotel(
            idHotel: _hotelDetail!.idHotel,
            nombre: _hotelDetail!.nombre,
            direccion: _hotelDetail!.direccion,
            codigoPostal: _hotelDetail!.codigoPostal,
            telefono: _hotelDetail!.telefono,
            emailContacto: _hotelDetail!.emailContacto,
            idPais: _hotelDetail!.idPais,
            idEstado: _hotelDetail!.idEstado,
            numeroEstrellas: _hotelDetail!.numeroEstrellas,
            urlFotoPerfil: nuevaUrlFoto,
          );
        }
        
        // Recargar detalle para obtener datos actualizados del backend
        try {
          await loadHotelDetail(hotelId);
          print('DEBUG: Detalle de hotel recargado después de subir foto');
        } catch (e) {
          print('DEBUG: Error al recargar detalle después de subir foto: $e');
        }
      }

      _isUploadingPhoto = false;
      notifyListeners();

      print("Foto de hotel subida correctamente");
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
          print('Error del servidor al subir foto: ${e.response?.data}');
        } else {
          _uploadPhotoError = 'Error de conexión: ${e.message ?? e.toString()}';
          print('Error de conexión al subir foto: ${e.message}');
        }
      } else {
        _uploadPhotoError = 'Error: ${e.toString()}';
        print('Error general al subir foto: $e');
      }

      notifyListeners();
      return false;
    }
  }

  /// Eliminar/restaurar foto de hotel por defecto
  Future<bool> eliminarFotoHotel(int hotelId) async {
    _isDeletingPhoto = true;
    _uploadPhotoError = null;
    notifyListeners();

    try {
      final response = await _hotelService.eliminarFotoHotel(hotelId);

      // Recargar detalle para obtener la foto por defecto
      await loadHotelDetail(hotelId);

      _isDeletingPhoto = false;
      notifyListeners();

      print("Foto de hotel eliminada/restaurada correctamente");
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
          print('Error del servidor al eliminar foto: ${e.response?.data}');
        } else {
          _uploadPhotoError = 'Error de conexión: ${e.message ?? e.toString()}';
          print('Error de conexión al eliminar foto: ${e.message}');
        }
      } else {
        _uploadPhotoError = 'Error: ${e.toString()}';
        print('Error general al eliminar foto: $e');
      }

      notifyListeners();
      return false;
    }
  }
}


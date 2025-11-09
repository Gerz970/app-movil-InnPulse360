import 'package:flutter/foundation.dart'; // Para uso de ChangeNotifier
import '../services/cliente_service.dart'; // para conexion con servicio
import '../models/cliente_model.dart'; // modelo de Cliente
import '../../hoteles/models/pais_model.dart'; // modelo de País (reutilizado)
import '../../hoteles/models/estado_model.dart'; // modelo de Estado (reutilizado)
import 'package:dio/dio.dart'; // clase dio para construir objeto de http

/// Controlador para manejar el estado del módulo de clientes
/// Usa ChangeNotifier para notificar cambios de estado
class ClienteController extends ChangeNotifier {
  // Instancia de ClienteService
  final ClienteService _clienteService = ClienteService();

  // Estados privados para listado
  bool _isLoading = false; // Estado de carga
  List<Cliente> _clientes = []; // Lista de clientes
  String? _errorMessage; // Mensaje de error (puede ser null)
  bool _isNotAuthenticated = false; // Estado de autenticación

  // Estados para catálogos
  List<Pais> _paises = []; // Lista de países
  List<Estado> _estados = []; // Lista de estados
  bool _isLoadingCatalogs = false; // Estado de carga de catálogos
  
  // Estados para creación
  bool _isCreating = false; // Estado de creación de cliente
  String? _createErrorMessage; // Mensaje de error al crear
  bool _rfcDuplicadoError = false; // Flag especial para RFC duplicado
  
  // Estados para detalle (país y estado específicos)
  Pais? _paisDetail; // País específico para detalle
  Estado? _estadoDetail; // Estado específico para detalle

  // Estados para detalle y actualización
  Cliente? _clienteDetail; // Cliente en detalle
  bool _isLoadingDetail = false; // Estado de carga de detalle
  String? _detailErrorMessage; // Mensaje de error al cargar detalle
  bool _isUpdating = false; // Estado de actualización
  String? _updateErrorMessage; // Mensaje de error al actualizar
  
  // Estados para eliminación
  bool _isDeleting = false; // Estado de eliminación
  String? _deleteErrorMessage; // Mensaje de error al eliminar

  // Getters para listado
  bool get isLoading => _isLoading;
  List<Cliente> get clientes => _clientes;
  String? get errorMessage => _errorMessage;
  bool get isNotAuthenticated => _isNotAuthenticated;
  bool get isEmpty => _clientes.isEmpty && !_isLoading && _errorMessage == null;
  
  // Getters para catálogos
  List<Pais> get paises => _paises;
  List<Estado> get estados => _estados;
  bool get isLoadingCatalogs => _isLoadingCatalogs;
  
  // Getters para creación
  bool get isCreating => _isCreating;
  String? get createErrorMessage => _createErrorMessage;
  bool get rfcDuplicadoError => _rfcDuplicadoError;
  
  // Getters para detalle
  Pais? get paisDetail => _paisDetail;
  Estado? get estadoDetail => _estadoDetail;
  
  // Getters para detalle y actualización
  Cliente? get clienteDetail => _clienteDetail;
  bool get isLoadingDetail => _isLoadingDetail;
  String? get detailErrorMessage => _detailErrorMessage;
  bool get isUpdating => _isUpdating;
  String? get updateErrorMessage => _updateErrorMessage;
  
  // Getters para eliminación
  bool get isDeleting => _isDeleting;
  String? get deleteErrorMessage => _deleteErrorMessage;

  /// Método para obtener el listado de clientes
  Future<void> fetchClientes({int skip = 0, int limit = 100}) async {
    // 1.- Preparar petición
    _isLoading = true; // activar loading
    _errorMessage = null; // limpiar error anterior
    _isNotAuthenticated = false; // limpiar estado de autenticación
    notifyListeners(); // Notificar cambio de estado

    try {
      // 2.- hacer peticion al API
      final response = await _clienteService.fetchClientes(skip: skip, limit: limit);

      // 3.- Parsear respuesta a lista de Cliente
      if (response.data != null && response.data is List) {
        _clientes = (response.data as List)
            .map((json) => Cliente.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        _clientes = [];
      }

      // 4.- actualizar estado local
      _isLoading = false; // desactivar loading
      _errorMessage = null; // limpiar error
      notifyListeners(); // Notificar cambio de estado

      print("Clientes cargados correctamente");
      print('Total de clientes: ${_clientes.length}');
    } catch (e) {
      // 5.- manejar error
      _isLoading = false;

      // Manejar diferentes tipos de errores
      if (e is DioException) {
        if (e.response != null) {
          final responseData = e.response?.data;
          final statusCode = e.response?.statusCode;

          // Error 401 - No autenticado
          if (statusCode == 401 || 
              (responseData is Map<String, dynamic> && 
               responseData['detail'] == 'Not authenticated')) {
            _isNotAuthenticated = true;
            _errorMessage = 'No estás autenticado. Por favor, inicia sesión nuevamente.';
            print('Error de autenticación al cargar clientes: ${e.response?.data}');
          }
          // Otro error del servidor
          else {
            _errorMessage = 'Error ${statusCode}: ${e.response?.data}';
            print('Error del servidor al cargar clientes: ${e.response?.data}');
          }
        } else {
          // Error de conexión
          _errorMessage = 'Error de conexión: ${e.message ?? e.toString()}';
          print('Error de conexión al cargar clientes: ${e.message}');
        }
      } else {
        // Otro tipo de error
        _errorMessage = 'Error: ${e.toString()}';
        print('Error general al cargar clientes: $e');
      }

      // Notificar cambio de estado
      notifyListeners();
    }
  }

  /// Método para cargar los catálogos de países y estados
  /// Carga todos los países con paginación (múltiples peticiones si es necesario)
  /// Usado para creación de cliente
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
        final paisesResponse = await _clienteService.fetchPaises(skip: skip, limit: limit);
        
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
        final estadosResponse = await _clienteService.fetchEstados(
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
  /// Usado para detalle de cliente (no necesita cargar todos los países)
  Future<void> loadPaisById(int idPais) async {
    try {
      final response = await _clienteService.fetchPaisById(idPais);
      
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
  /// Usado para detalle de cliente (no necesita cargar todos los estados)
  Future<void> loadEstadoById(int idEstado) async {
    try {
      final response = await _clienteService.fetchEstadoById(idEstado);
      
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

  /// Método para crear un nuevo cliente
  /// Recibe un Map con los datos del cliente
  /// Maneja especialmente el error 400 de RFC duplicado
  Future<bool> createCliente(Map<String, dynamic> clienteData) async {
    _isCreating = true;
    _createErrorMessage = null;
    _rfcDuplicadoError = false; // Limpiar flag de RFC duplicado
    notifyListeners();

    try {
      // Crear cliente mediante el servicio
      final response = await _clienteService.createCliente(clienteData);

      // Si éxito, refrescar la lista de clientes
      _isCreating = false;
      notifyListeners();

      print("Cliente creado correctamente");
      print('Status code: ${response.statusCode}');
      print(response.data);

      // Refrescar lista de clientes
      await fetchClientes();

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
            print('Error de autenticación al crear cliente: ${e.response?.data}');
          }
          // Error 400 - RFC duplicado
          else if (statusCode == 400) {
            final dataStr = responseData.toString().toLowerCase();
            if (dataStr.contains('rfc') || dataStr.contains('duplicado') || dataStr.contains('existe')) {
              _rfcDuplicadoError = true;
              _createErrorMessage = 'El RFC ya está registrado';
            } else {
              _createErrorMessage = 'Error de validación: ${e.response?.data}';
            }
            print('Error 400 al crear cliente: ${e.response?.data}');
          }
          // Error 422 - Validación
          else if (statusCode == 422) {
            _createErrorMessage = 'Error de validación: ${e.response?.data}';
            print('Error de validación al crear cliente: ${e.response?.data}');
          }
          // Otro error del servidor
          else {
            _createErrorMessage = 'Error ${statusCode}: ${e.response?.data}';
            print('Error del servidor al crear cliente: ${e.response?.data}');
          }
        } else {
          // Error de conexión
          _createErrorMessage = 'Error de conexión: ${e.message ?? e.toString()}';
          print('Error de conexión al crear cliente: ${e.message}');
        }
      } else {
        // Otro tipo de error
        _createErrorMessage = 'Error: ${e.toString()}';
        print('Error general al crear cliente: $e');
      }

      notifyListeners();
      return false;
    }
  }

  /// Método para cargar el detalle de un cliente
  /// Carga el detalle del cliente mediante GET por clienteId
  Future<void> loadClienteDetail(int clienteId) async {
    _isLoadingDetail = true;
    _detailErrorMessage = null;
    _clienteDetail = null;
    notifyListeners();

    try {
      // Cargar detalle del cliente
      final response = await _clienteService.fetchClienteDetail(clienteId);
      
      // Parsear respuesta a Cliente
      if (response.data != null && response.data is Map<String, dynamic>) {
        _clienteDetail = Cliente.fromJson(response.data as Map<String, dynamic>);
      } else {
        _detailErrorMessage = 'No se pudo obtener el detalle del cliente';
      }

      _isLoadingDetail = false;
      notifyListeners();

      print("Detalle del cliente cargado correctamente");
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

  /// Método para actualizar un cliente
  /// Recibe clienteId y Map con los datos a actualizar (solo campos editables)
  /// Campos editables: nombre_razon_social, telefono, direccion, id_estatus
  Future<bool> updateCliente(int clienteId, Map<String, dynamic> clienteData) async {
    _isUpdating = true;
    _updateErrorMessage = null;
    notifyListeners();

    try {
      // Actualizar cliente mediante el servicio
      final response = await _clienteService.updateCliente(clienteId, clienteData);

      // Si éxito, actualizar _clienteDetail con los nuevos datos
      if (response.data != null && response.data is Map<String, dynamic>) {
        _clienteDetail = Cliente.fromJson(response.data as Map<String, dynamic>);
      } else if (_clienteDetail != null) {
        // Si no hay respuesta completa, actualizar solo los campos editables
        _clienteDetail = Cliente(
          idCliente: _clienteDetail!.idCliente,
          nombreRazonSocial: clienteData['nombre_razon_social'] as String? ?? _clienteDetail!.nombreRazonSocial,
          apellidoPaterno: _clienteDetail!.apellidoPaterno,
          apellidoMaterno: _clienteDetail!.apellidoMaterno,
          rfc: _clienteDetail!.rfc,
          curp: _clienteDetail!.curp,
          correoElectronico: _clienteDetail!.correoElectronico,
          telefono: clienteData['telefono'] as String? ?? _clienteDetail!.telefono,
          direccion: clienteData['direccion'] as String? ?? _clienteDetail!.direccion,
          documentoIdentificacion: _clienteDetail!.documentoIdentificacion,
          paisId: _clienteDetail!.paisId,
          estadoId: _clienteDetail!.estadoId,
          idEstatus: clienteData['id_estatus'] as int? ?? _clienteDetail!.idEstatus,
          tipoPersona: _clienteDetail!.tipoPersona,
          representante: _clienteDetail!.representante,
        );
      }

      _isUpdating = false;
      notifyListeners();

      print("Cliente actualizado correctamente");
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
            print('Error de autenticación al actualizar cliente: ${e.response?.data}');
          }
          // Error 422 - Validación
          else if (statusCode == 422) {
            _updateErrorMessage = 'Error de validación: ${e.response?.data}';
            print('Error de validación al actualizar cliente: ${e.response?.data}');
          }
          // Otro error del servidor
          else {
            _updateErrorMessage = 'Error ${statusCode}: ${e.response?.data}';
            print('Error del servidor al actualizar cliente: ${e.response?.data}');
          }
        } else {
          // Error de conexión
          _updateErrorMessage = 'Error de conexión: ${e.message ?? e.toString()}';
          print('Error de conexión al actualizar cliente: ${e.message}');
        }
      } else {
        // Otro tipo de error
        _updateErrorMessage = 'Error: ${e.toString()}';
        print('Error general al actualizar cliente: $e');
      }

      notifyListeners();
      return false;
    }
  }

  /// Método para eliminar un cliente
  /// Recibe clienteId del cliente a eliminar
  /// Retorna true en éxito, false en error
  Future<bool> deleteCliente(int clienteId) async {
    _isDeleting = true;
    _deleteErrorMessage = null;
    _isNotAuthenticated = false;
    notifyListeners();

    try {
      // Eliminar cliente mediante el servicio
      final response = await _clienteService.deleteCliente(clienteId);

      // Verificar código de respuesta
      if (response.statusCode == 200 || response.statusCode == 204) {
        // Eliminar cliente de la lista local
        _clientes.removeWhere((cliente) => cliente.idCliente == clienteId);
        
        _isDeleting = false;
        notifyListeners();

        print("Cliente eliminado correctamente");
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
            print('Error de autenticación al eliminar cliente: ${e.response?.data}');
          }
          // Error 404 - No existe
          else if (statusCode == 404) {
            _deleteErrorMessage = 'El cliente ya no existe.';
            print('Error 404 al eliminar cliente: ${e.response?.data}');
          }
          // Error 409/422 - Dependencias activas
          else if (statusCode == 409 || statusCode == 422) {
            _deleteErrorMessage = 'No es posible eliminar el cliente por dependencias activas.';
            print('Error de dependencias al eliminar cliente: ${e.response?.data}');
          }
          // Otro error del servidor (500+)
          else {
            _deleteErrorMessage = 'Error del servidor: ${e.response?.data ?? statusCode}';
            print('Error del servidor al eliminar cliente: ${e.response?.data}');
          }
        } else {
          // Error de conexión
          _deleteErrorMessage = 'Error de conexión: ${e.message ?? e.toString()}';
          print('Error de conexión al eliminar cliente: ${e.message}');
        }
      } else {
        // Otro tipo de error
        _deleteErrorMessage = 'Error: ${e.toString()}';
        print('Error general al eliminar cliente: $e');
      }

      notifyListeners();
      return false;
    }
  }
}


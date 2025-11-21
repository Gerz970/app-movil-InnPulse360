import 'package:flutter/foundation.dart'; // Para uso de ChangeNotifier
import '../services/limpieza_service.dart'; // para conexion con servicio
import '../services/empleado_service.dart'; // para conexion con servicio de empleados
import '../services/habitacion_area_service.dart'; // para conexion con servicio de habitaciones
import '../services/tipo_limpieza_service.dart'; // para conexion con servicio de tipos de limpieza
import '../models/limpieza_model.dart' hide HabitacionArea, TipoLimpieza; // modelo de Limpieza
import '../models/empleado_simple_model.dart'; // modelo de EmpleadoSimple
import '../models/habitacion_area_model.dart'; // modelo de HabitacionArea
import '../models/habitacion_area_con_estado_model.dart'; // modelo de HabitacionAreaConEstado
import '../models/tipo_limpieza_model.dart'; // modelo de TipoLimpieza
import '../../hoteles/models/hotel_model.dart'; // modelo de Hotel
import '../../pisos/models/piso_model.dart'; // modelo de Piso
import '../../pisos/services/piso_service.dart'; // servicio de pisos
import 'package:dio/dio.dart'; // clase dio para construir objeto de http

/// Controlador para manejar el estado del módulo de limpieza
/// Usa ChangeNotifier para notificar cambios de estado
class LimpiezaController extends ChangeNotifier {
  // Instancia de LimpiezaService
  final LimpiezaService _limpiezaService = LimpiezaService();
  // Instancia de EmpleadoService
  final EmpleadoService _empleadoService = EmpleadoService();
  // Instancia de HabitacionAreaService
  final HabitacionAreaService _habitacionAreaService = HabitacionAreaService();
  // Instancia de PisoService
  final PisoService _pisoService = PisoService();
  // Instancia de TipoLimpiezaService
  final TipoLimpiezaService _tipoLimpiezaService = TipoLimpiezaService();

  /// Método helper para notificar listeners de forma segura
  void _safeNotifyListeners() {
    if (hasListeners) {
      try {
        notifyListeners();
      } catch (e) {
        print('Error al notificar listeners: $e');
      }
    }
  }

  // Estados privados para listado
  bool _isLoading = false; // Estado de carga
  List<Limpieza> _limpiezas = []; // Lista de limpiezas
  String? _errorMessage; // Mensaje de error (puede ser null)
  bool _isNotAuthenticated = false; // Estado de autenticación

  // Estados para empleados
  List<EmpleadoSimple> _empleados = []; // Lista de empleados
  bool _isLoadingEmpleados = false; // Estado de carga de empleados
  String? _empleadosErrorMessage; // Mensaje de error para empleados

  // Estados para actualización
  bool _isUpdating = false; // Estado de actualización
  String? _updateErrorMessage; // Mensaje de error para actualización

  // Estados para creación
  bool _isCreating = false;
  String? _createErrorMessage;

  // Estados para hoteles del empleado
  List<Hotel> _hotelesEmpleado = [];
  bool _isLoadingHotelesEmpleado = false;
  String? _hotelesEmpleadoErrorMessage;

  // Estados para pisos
  List<Piso> _pisos = [];
  bool _isLoadingPisos = false;
  String? _pisosErrorMessage;

  // Estados para habitaciones disponibles
  List<HabitacionArea> _habitacionesDisponibles = [];
  bool _isLoadingHabitaciones = false;
  String? _habitacionesErrorMessage;

  // Estados para habitaciones con estado
  List<HabitacionAreaConEstado> _habitacionesConEstado = [];
  bool _isLoadingHabitacionesConEstado = false;
  String? _habitacionesConEstadoErrorMessage;

  // Estados para tipos de limpieza
  List<TipoLimpieza> _tiposLimpieza = [];
  bool _isLoadingTiposLimpieza = false;
  String? _tiposLimpiezaErrorMessage;

  // Estados para creación masiva
  bool _isCreatingMasivo = false;
  String? _createMasivoErrorMessage;

  // Getters para listado
  bool get isLoading => _isLoading;
  List<Limpieza> get limpiezas => _limpiezas;
  String? get errorMessage => _errorMessage;
  bool get isNotAuthenticated => _isNotAuthenticated;
  bool get isEmpty => _limpiezas.isEmpty && !_isLoading && _errorMessage == null;

  // Getters para empleados
  List<EmpleadoSimple> get empleados => _empleados;
  bool get isLoadingEmpleados => _isLoadingEmpleados;
  String? get empleadosErrorMessage => _empleadosErrorMessage;

  // Getters para actualización
  bool get isUpdating => _isUpdating;
  String? get updateErrorMessage => _updateErrorMessage;

  // Getters para creación
  bool get isCreating => _isCreating;
  String? get createErrorMessage => _createErrorMessage;

  // Getters para hoteles del empleado
  List<Hotel> get hotelesEmpleado => _hotelesEmpleado;
  bool get isLoadingHotelesEmpleado => _isLoadingHotelesEmpleado;
  String? get hotelesEmpleadoErrorMessage => _hotelesEmpleadoErrorMessage;

  // Getters para pisos
  List<Piso> get pisos => _pisos;
  bool get isLoadingPisos => _isLoadingPisos;
  String? get pisosErrorMessage => _pisosErrorMessage;

  // Getters para habitaciones disponibles
  List<HabitacionArea> get habitacionesDisponibles => _habitacionesDisponibles;
  bool get isLoadingHabitaciones => _isLoadingHabitaciones;
  String? get habitacionesErrorMessage => _habitacionesErrorMessage;

  // Getters para habitaciones con estado
  List<HabitacionAreaConEstado> get habitacionesConEstado => _habitacionesConEstado;
  bool get isLoadingHabitacionesConEstado => _isLoadingHabitacionesConEstado;
  String? get habitacionesConEstadoErrorMessage => _habitacionesConEstadoErrorMessage;

  // Getters para tipos de limpieza
  List<TipoLimpieza> get tiposLimpieza => _tiposLimpieza;
  bool get isLoadingTiposLimpieza => _isLoadingTiposLimpieza;
  String? get tiposLimpiezaErrorMessage => _tiposLimpiezaErrorMessage;

  // Getters para creación masiva
  bool get isCreatingMasivo => _isCreatingMasivo;
  String? get createMasivoErrorMessage => _createMasivoErrorMessage;

  /// Método para obtener el listado de limpiezas por estatus
  Future<void> fetchLimpiezasPorEstatus(int estatusLimpiezaId) async {
    // 1.- Preparar petición
    _isLoading = true; // activar loading
    _errorMessage = null; // limpiar error anterior
    _isNotAuthenticated = false; // limpiar estado de autenticación
    notifyListeners(); // Notificar cambio de estado

    try {
      // 2.- hacer peticion al API
      final response = await _limpiezaService.fetchLimpiezasPorEstatus(estatusLimpiezaId);

      // 3.- Parsear respuesta a lista de Limpieza
      if (response.data != null && response.data is List) {
        _limpiezas = (response.data as List)
            .map((json) => Limpieza.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        _limpiezas = [];
      }

      // 4.- actualizar estado local
      _isLoading = false; // desactivar loading
      _errorMessage = null; // limpiar error
      notifyListeners(); // Notificar cambio de estado

      print("Limpiezas cargadas correctamente");
      print('Total de limpiezas: ${_limpiezas.length}');
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
            print('Error de autenticación al cargar limpiezas: ${e.response?.data}');
          }
          // Otro error del servidor
          else {
            _errorMessage = 'Error ${statusCode}: ${e.response?.data}';
            print('Error del servidor al cargar limpiezas: ${e.response?.data}');
          }
        } else {
          // Error de conexión
          _errorMessage = 'Error de conexión: ${e.message ?? e.toString()}';
          print('Error de conexión al cargar limpiezas: ${e.message}');
        }
      } else {
        // Otro tipo de error
        _errorMessage = 'Error: ${e.toString()}';
        print('Error general al cargar limpiezas: $e');
      }

      // Notificar cambio de estado
      notifyListeners();
    }
  }

  /// Método para obtener empleados por hotel y filtrar camaristas
  /// Carga empleados del hotel especificado y filtra solo los camaristas
  Future<void> fetchEmpleadosPorHotel(int hotelId) async {
    // Preparar petición
    _isLoadingEmpleados = true;
    _empleadosErrorMessage = null;
    _empleados = []; // Limpiar lista anterior
    notifyListeners();

    try {
      // Hacer petición al API
      final response = await _empleadoService.fetchEmpleadosPorHotel(hotelId);

      // Parsear respuesta a lista de EmpleadoSimple
      if (response.data != null && response.data is List) {
        final empleadosRaw = (response.data as List)
            .map((json) => EmpleadoSimple.fromJson(json as Map<String, dynamic>))
            .toList();

        // Filtrar solo camaristas (empleados con puesto_id == 2)
        _empleados = empleadosRaw.where((empleado) => empleado.esCamarista).toList();

        print("Empleados cargados correctamente");
        print('Total de empleados: ${empleadosRaw.length}');
        print('Total de camaristas filtrados: ${_empleados.length}');
      } else {
        _empleados = [];
      }

      // Actualizar estado local
      _isLoadingEmpleados = false;
      notifyListeners();
    } catch (e) {
      // Manejar error
      _isLoadingEmpleados = false;

      // Manejar diferentes tipos de errores
      if (e is DioException) {
        if (e.response != null) {
          final responseData = e.response?.data;
          final statusCode = e.response?.statusCode;

          // Error 401 - No autenticado
          if (statusCode == 401 ||
              (responseData is Map<String, dynamic> &&
               responseData['detail'] == 'Not authenticated')) {
            _empleadosErrorMessage = 'No estás autenticado. Por favor, inicia sesión nuevamente.';
            print('Error de autenticación al cargar empleados: ${e.response?.data}');
          }
          // Otro error del servidor
          else {
            _empleadosErrorMessage = 'Error ${statusCode}: ${e.response?.data}';
            print('Error del servidor al cargar empleados: ${e.response?.data}');
          }
        } else {
          // Error de conexión
          _empleadosErrorMessage = 'Error de conexión: ${e.message ?? e.toString()}';
          print('Error de conexión al cargar empleados: ${e.message}');
        }
      } else {
        // Otro tipo de error
        _empleadosErrorMessage = 'Error: ${e.toString()}';
        print('Error general al cargar empleados: $e');
      }

      // Notificar cambio de estado
      notifyListeners();
    }
  }

  /// Método para actualizar una limpieza
  /// Actualiza empleado_id y descripcion de una limpieza específica
  Future<bool> updateLimpieza(int limpiezaId, int? empleadoId, String? descripcion) async {
    // Preparar petición
    _isUpdating = true;
    _updateErrorMessage = null;
    notifyListeners();

    try {
      // Preparar datos para actualizar
      final Map<String, dynamic> data = {};
      if (empleadoId != null) {
        data['empleado_id'] = empleadoId;
      }
      if (descripcion != null) {
        data['descripcion'] = descripcion;
      }

      // Hacer petición al API
      final response = await _limpiezaService.updateLimpieza(limpiezaId, data);

      // Si éxito, refrescar la lista de limpiezas
      _isUpdating = false;
      notifyListeners();

      print("Limpieza actualizada correctamente");
      print('Status code: ${response.statusCode}');
      print(response.data);

      return true;
    } catch (e) {
      // Manejar error
      _isUpdating = false;

      // Manejar diferentes tipos de errores
      if (e is DioException) {
        if (e.response != null) {
          final responseData = e.response?.data;
          final statusCode = e.response?.statusCode;

          // Error 401 - No autenticado
          if (statusCode == 401 ||
              (responseData is Map<String, dynamic> &&
               responseData['detail'] == 'Not authenticated')) {
            _updateErrorMessage = 'No estás autenticado. Por favor, inicia sesión nuevamente.';
            print('Error de autenticación al actualizar limpieza: ${e.response?.data}');
          }
          // Otro error del servidor
          else {
            _updateErrorMessage = 'Error ${statusCode}: ${e.response?.data}';
            print('Error del servidor al actualizar limpieza: ${e.response?.data}');
          }
        } else {
          // Error de conexión
          _updateErrorMessage = 'Error de conexión: ${e.message ?? e.toString()}';
          print('Error de conexión al actualizar limpieza: ${e.message}');
        }
      } else {
        // Otro tipo de error
        _updateErrorMessage = 'Error: ${e.toString()}';
        print('Error general al actualizar limpieza: $e');
      }

      // Notificar cambio de estado
      notifyListeners();

      return false;
    }
  }

  /// Método para obtener hoteles por empleado
  Future<void> fetchHotelesPorEmpleado(int empleadoId) async {
    _isLoadingHotelesEmpleado = true;
    _hotelesEmpleadoErrorMessage = null;
    _hotelesEmpleado = [];
    notifyListeners();

    try {
      final response = await _empleadoService.fetchHotelesPorEmpleado(empleadoId);
      if (response.data != null && response.data is List) {
        _hotelesEmpleado = (response.data as List)
            .map((json) => Hotel.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        _hotelesEmpleado = [];
      }
      _isLoadingHotelesEmpleado = false;
      notifyListeners();
    } catch (e) {
      _isLoadingHotelesEmpleado = false;
      _hotelesEmpleadoErrorMessage = _handleDioError(e, 'Error al cargar hoteles');
      notifyListeners();
    }
  }

  /// Método para obtener pisos por hotel
  Future<void> fetchPisosPorHotel(int hotelId) async {
    _isLoadingPisos = true;
    _pisosErrorMessage = null;
    _pisos = [];
    notifyListeners();

    try {
      final pisos = await _pisoService.getPisosByHotel(hotelId);
      _pisos = pisos;
      _isLoadingPisos = false;
      notifyListeners();
    } catch (e) {
      _isLoadingPisos = false;
      _pisosErrorMessage = _handleDioError(e, 'Error al cargar pisos');
      notifyListeners();
    }
  }

  /// Método para obtener habitaciones disponibles por piso
  Future<void> fetchHabitacionesDisponiblesPorPiso(int pisoId) async {
    _isLoadingHabitaciones = true;
    _habitacionesErrorMessage = null;
    _habitacionesDisponibles = [];
    notifyListeners();

    try {
      final response = await _habitacionAreaService.fetchHabitacionesDisponiblesPorPiso(pisoId);
      if (response.data != null && response.data is List) {
        _habitacionesDisponibles = (response.data as List)
            .map((json) => HabitacionArea.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        _habitacionesDisponibles = [];
      }
      _isLoadingHabitaciones = false;
      notifyListeners();
    } catch (e) {
      _isLoadingHabitaciones = false;
      _habitacionesErrorMessage = _handleDioError(e, 'Error al cargar habitaciones');
      notifyListeners();
    }
  }

  /// Método para crear una nueva limpieza
  Future<bool> crearLimpieza(Map<String, dynamic> data) async {
    _isCreating = true;
    _createErrorMessage = null;
    notifyListeners();

    try {
      final response = await _limpiezaService.crearLimpieza(data);
      _isCreating = false;
      notifyListeners();
      print("Limpieza creada correctamente");
      print('Status code: ${response.statusCode}');
      return true;
    } catch (e) {
      _isCreating = false;
      _createErrorMessage = _handleDioError(e, 'Error al crear limpieza');
      notifyListeners();
      return false;
    }
  }

  /// Método helper para manejar errores de Dio
  String _handleDioError(dynamic e, String defaultMessage) {
    if (e is DioException) {
      if (e.response != null) {
        final responseData = e.response?.data;
        final statusCode = e.response?.statusCode;

        if (statusCode == 401 ||
            (responseData is Map<String, dynamic> &&
             responseData['detail'] == 'Not authenticated')) {
          return 'No estás autenticado. Por favor, inicia sesión nuevamente.';
        } else {
          return 'Error ${statusCode}: ${e.response?.data ?? defaultMessage}';
        }
      } else {
        return 'Error de conexión: ${e.message ?? defaultMessage}';
      }
    } else {
      return 'Error: ${e.toString()}';
    }
  }

  /// Método para obtener tipos de limpieza
  Future<void> fetchTiposLimpieza() async {
    print('🚀 [LimpiezaController] fetchTiposLimpieza() llamado');
    _isLoadingTiposLimpieza = true;
    _tiposLimpiezaErrorMessage = null;
    _tiposLimpieza = [];
    _safeNotifyListeners();

    try {
      print('📡 [LimpiezaController] Llamando a _tipoLimpiezaService.fetchTiposLimpieza()');
      final response = await _tipoLimpiezaService.fetchTiposLimpieza();
      print('✅ [LimpiezaController] Respuesta recibida del servicio');
      
      if (response.data != null && response.data is List) {
        _tiposLimpieza = (response.data as List)
            .map((json) => TipoLimpieza.fromJson(json as Map<String, dynamic>))
            .toList();
        print('✅ [LimpiezaController] ${_tiposLimpieza.length} tipos de limpieza cargados');
      } else {
        _tiposLimpieza = [];
        print('⚠️ [LimpiezaController] Respuesta vacía o formato incorrecto');
      }
      _isLoadingTiposLimpieza = false;
      _safeNotifyListeners();
    } catch (e) {
      print('❌ [LimpiezaController] Error al cargar tipos de limpieza: $e');
      _isLoadingTiposLimpieza = false;
      _tiposLimpiezaErrorMessage = _handleDioError(e, 'Error al cargar tipos de limpieza');
      _safeNotifyListeners();
    }
  }

  /// Método para obtener habitaciones con estado por piso
  Future<void> fetchHabitacionesConEstadoPorPiso(int pisoId) async {
    _isLoadingHabitacionesConEstado = true;
    _habitacionesConEstadoErrorMessage = null;
    _habitacionesConEstado = [];
    _safeNotifyListeners();

    try {
      final response = await _habitacionAreaService.fetchHabitacionesConEstadoPorPiso(pisoId);
      if (response.data != null && response.data is List) {
        _habitacionesConEstado = (response.data as List)
            .map((json) => HabitacionAreaConEstado.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        _habitacionesConEstado = [];
      }
      _isLoadingHabitacionesConEstado = false;
      _safeNotifyListeners();
    } catch (e) {
      _isLoadingHabitacionesConEstado = false;
      _habitacionesConEstadoErrorMessage = _handleDioError(e, 'Error al cargar habitaciones con estado');
      _safeNotifyListeners();
    }
  }

  /// Método para crear múltiples limpiezas en una sola petición
  Future<bool> crearLimpiezasMasivo(List<Map<String, dynamic>> limpiezasData) async {
    _isCreatingMasivo = true;
    _createMasivoErrorMessage = null;
    _safeNotifyListeners();

    try {
      final response = await _limpiezaService.crearLimpiezasMasivo(limpiezasData);
      _isCreatingMasivo = false;
      _safeNotifyListeners();
      print("Limpiezas creadas masivamente correctamente");
      print('Status code: ${response.statusCode}');
      print('Limpiezas creadas: ${(response.data as List).length}');
      return true;
    } catch (e) {
      _isCreatingMasivo = false;
      _createMasivoErrorMessage = _handleDioError(e, 'Error al crear limpiezas masivamente');
      _safeNotifyListeners();
      return false;
    }
  }

  /// Método para limpiar estados de creación
  void limpiarEstadosCreacion() {
    _hotelesEmpleado = [];
    _pisos = [];
    _habitacionesDisponibles = [];
    _habitacionesConEstado = [];
    _isLoadingHotelesEmpleado = false;
    _isLoadingPisos = false;
    _isLoadingHabitaciones = false;
    _isLoadingHabitacionesConEstado = false;
    _hotelesEmpleadoErrorMessage = null;
    _pisosErrorMessage = null;
    _habitacionesErrorMessage = null;
    _habitacionesConEstadoErrorMessage = null;
    _createErrorMessage = null;
    _createMasivoErrorMessage = null;
    _safeNotifyListeners();
  }
}

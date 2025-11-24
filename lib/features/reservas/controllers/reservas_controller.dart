import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../models/reservas_model.dart';
import '../models/galeria_imagen_model.dart';
import '../services/reserva_service.dart';
import '../../../core/auth/services/session_storage.dart'; // para obtener token de sesión
import '../models/habitacion_dispobile_model.dart';
import '../models/tipo_habitacion_model.dart';
import '../models/tipo_habitacion_disponible_model.dart';
import '../../../features/hoteles/models/hotel_model.dart';

class ReservacionController with ChangeNotifier {
  List<Reservacion> reservaciones = [];
  List<HabitacionDisponible> habitaciones = [];
  bool isLoading = false;
  String? errorMessage;
  bool _isNotAuthenticated = false; // Estado de autenticación

  // Estado de galería
  List<GaleriaImagen> _galeriaImagenes = [];
  bool _isLoadingGaleria = false;
  String? _galeriaErrorMessage;

  // Estados para nuevo flujo de reservación
  Hotel? _hotelSeleccionado;
  List<TipoHabitacionDisponible> _tiposDisponibles = [];
  TipoHabitacion? _tipoHabitacionDetail;
  List<GaleriaImagen> _galeriaTipoHabitacion = [];
  bool _isLoadingTiposDisponibles = false;
  bool _isLoadingTipoDetail = false;
  String? _tiposDisponiblesErrorMessage;
  String? _tipoDetailErrorMessage;

  final ReservaService _service = ReservaService();

  // Getters para galería
  List<GaleriaImagen> get galeriaImagenes => _galeriaImagenes;
  bool get isLoadingGaleria => _isLoadingGaleria;
  String? get galeriaErrorMessage => _galeriaErrorMessage;

  // Getters para nuevo flujo
  Hotel? get hotelSeleccionado => _hotelSeleccionado;
  List<TipoHabitacionDisponible> get tiposDisponibles => _tiposDisponibles;
  TipoHabitacion? get tipoHabitacionDetail => _tipoHabitacionDetail;
  List<GaleriaImagen> get galeriaTipoHabitacion => _galeriaTipoHabitacion;
  bool get isLoadingTiposDisponibles => _isLoadingTiposDisponibles;
  bool get isLoadingTipoDetail => _isLoadingTipoDetail;
  String? get tiposDisponiblesErrorMessage => _tiposDisponiblesErrorMessage;
  String? get tipoDetailErrorMessage => _tipoDetailErrorMessage;

  Future<void> fetchReservaciones() async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      final session = await SessionStorage.getSession();
      final usuario = session?['usuario'] as Map<String, dynamic>?;
      final clienteId = usuario?['cliente_id'] as int;

      final response = await _service.fetchReservaciones(clienteId);
      final data = response.data as List;

      reservaciones = data.map((e) => Reservacion.fromJson(e)).toList();

      Future.wait(
        reservaciones.map((h) async {
          try {
            h.imagenUrl = await _service.obtenerImagenHabitacion(
              h.habitacionAreaId,
            );
          } catch (_) {
            h.imagenUrl = "";
          }
        }),
      ).then((_) {
        notifyListeners(); // actualizar después de cargar imágenes
      });
    } catch (e) {
      errorMessage = "Error al cargar reservaciones: $e";
    }

    isLoading = false;
    notifyListeners();
  }

  Future<void> fetchDisponibles(String inicio, String fin) async {
    try {
      isLoading = true;
      notifyListeners();

      final response = await _service.fetchDisponibles(inicio, fin);
      final data = response.data as List;

      habitaciones = data.map((e) => HabitacionDisponible.fromJson(e)).toList();

      Future.wait(
        habitaciones.map((h) async {
          try {
            h.imagenUrl = await _service.obtenerImagenHabitacion(
              h.idHabitacionArea,
            );
          } catch (_) {
            h.imagenUrl = "";
          }
        }),
      ).then((_) {
        notifyListeners(); // actualizar después de cargar imágenes
      });
    } catch (e) {
      print("Error en fetchDisponibles: $e");
    }

    isLoading = false;
    notifyListeners();
  }

  Future<bool> createReserva(Map<String, dynamic> reservaData) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    final session = await SessionStorage.getSession();
    if (session == null) {
      errorMessage = 'No hay sesión activa';
      isLoading = false;
      notifyListeners();
      return false;
    }

    final usuario = session['usuario'] as Map<String, dynamic>?;
    if (usuario == null) {
      errorMessage = 'No se encontró información del usuario';
      isLoading = false;
      notifyListeners();
      return false;
    }

    final clienteId = usuario['cliente_id'] as int?;
    if (clienteId == null) {
      errorMessage = 'No se encontró el ID del cliente';
      isLoading = false;
      notifyListeners();
      return false;
    }

    reservaData['cliente_id'] = clienteId;

    try {
      final response = await _service.createReserva(reservaData);
      isLoading = false;
      notifyListeners();

      // Verificar si el backend devolvió el código de reservación
      if (response.data != null && response.data is Map<String, dynamic>) {
        final responseData = response.data as Map<String, dynamic>;
        if (responseData['codigo_reservacion'] != null) {
          print("🔵 [ReservacionController] Código de reservación recibido del backend: ${responseData['codigo_reservacion']}");
        }
      }

      await fetchReservaciones();

      return true;
    } catch (e) {
      isLoading = false;

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
            errorMessage =
                'No estás autenticado. Por favor, inicia sesión nuevamente.';
            print(
              'Error de autenticación al crear incidencia: ${e.response?.data}',
            );
          }
          // Error 422 - Validación
          else if (statusCode == 422) {
            errorMessage = 'Error de validación: ${e.response?.data}';
            print(
              'Error de validación al crear incidencia: ${e.response?.data}',
            );
          }
          // Otro error del servidor
          else {
            errorMessage = 'Error ${statusCode}: ${e.response?.data}';
            print(
              'Error del servidor al crear incidencia: ${e.response?.data}',
            );
          }
        } else {
          // Error de conexión
          errorMessage = 'Error de conexión: ${e.message ?? e.toString()}';
          print('Error de conexión al crear incidencia: ${e.message}');
        }
      } else {
        // Otro tipo de error
        errorMessage = 'Error: ${e.toString()}';
        print('Error general al crear incidencia: $e');
      }

      notifyListeners();
      return false;
    }
  }

  Future<bool> cancelarReserva(int idReserva) async {
    isLoading = true;
    notifyListeners();

    try {
      await _service.cancelarReserva(idReserva);
      isLoading = false;
      notifyListeners();
      await fetchReservaciones();
      return true;
    } catch (e) {
      isLoading = false;
      errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  void clearHabitaciones() {
    habitaciones = [];
    notifyListeners();
  }

  Future<void> fetchGaleria(int habitacionAreaId) async {
    _isLoadingGaleria = true;
    _galeriaErrorMessage = null;
    _galeriaImagenes = [];
    notifyListeners();

    try {
      final response = await _service.fetchGaleriaHabitacion(habitacionAreaId);

      if (response.data is Map && response.data['imagenes'] is List) {
        _galeriaImagenes = (response.data['imagenes'] as List)
            .map((img) => GaleriaImagen.fromJson(img as Map<String, dynamic>))
            .toList();
      } else {
        _galeriaImagenes = [];
      }
    } catch (e) {
      _galeriaErrorMessage = 'Error al cargar galería: ${e.toString()}';
      _galeriaImagenes = [];
    }

    _isLoadingGaleria = false;
    notifyListeners();
  }

  // Métodos para nuevo flujo de reservación

  /// Seleccionar un hotel
  void seleccionarHotel(Hotel hotel) {
    _hotelSeleccionado = hotel;
    notifyListeners();
  }

  /// Limpiar selección de hotel
  void clearHotelSeleccionado() {
    _hotelSeleccionado = null;
    notifyListeners();
  }

  /// Obtener tipos de habitación disponibles agrupados por tipo
  Future<void> fetchTiposHabitacionDisponibles(String inicio, String fin, {int? idHotel}) async {
    // Evitar llamadas duplicadas
    if (_isLoadingTiposDisponibles) {
      return;
    }

    _isLoadingTiposDisponibles = true;
    _tiposDisponiblesErrorMessage = null;
    _tiposDisponibles = [];
    notifyListeners();

    try {
      // Convertir fechas ISO8601 a formato YYYY-MM-DD si es necesario
      String fechaInicio = inicio;
      String fechaFin = fin;
      
      // Si las fechas vienen en formato ISO8601 completo, extraer solo la fecha
      if (inicio.contains('T')) {
        fechaInicio = inicio.split('T')[0];
      }
      if (fin.contains('T')) {
        fechaFin = fin.split('T')[0];
      }

      print("Consultando tipos disponibles: $fechaInicio - $fechaFin, hotel: ${idHotel ?? _hotelSeleccionado?.idHotel}");

      final response = await _service.fetchTiposHabitacionDisponibles(
        fechaInicio, 
        fechaFin,
        idHotel: idHotel ?? _hotelSeleccionado?.idHotel,
      );

      print("Respuesta recibida: ${response.statusCode}");
      print("Datos: ${response.data}");

      if (response.data == null) {
        throw Exception("Respuesta vacía del servidor");
      }

      final data = response.data as List;

      _tiposDisponibles = data
          .map((e) {
            try {
              return TipoHabitacionDisponible.fromJson(e as Map<String, dynamic>);
            } catch (parseError) {
              print("Error parseando tipo: $parseError");
              print("Datos del tipo: $e");
              rethrow;
            }
          })
          .toList();

      print("Tipos disponibles cargados: ${_tiposDisponibles.length}");
    } catch (e) {
      _tiposDisponiblesErrorMessage = 'Error al cargar tipos disponibles: ${e.toString()}';
      print("Error en fetchTiposHabitacionDisponibles: $e");
      if (e is DioException) {
        print("DioException details: ${e.response?.data}");
        print("Status code: ${e.response?.statusCode}");
      }
    } finally {
      _isLoadingTiposDisponibles = false;
      notifyListeners();
    }
  }

  /// Obtener detalle completo de un tipo de habitación
  Future<void> fetchTipoHabitacionDetail(int tipoHabitacionId) async {
    _isLoadingTipoDetail = true;
    _tipoDetailErrorMessage = null;
    _tipoHabitacionDetail = null;
    notifyListeners();

    try {
      print("🔵 [ReservacionController] Iniciando fetchTipoHabitacionDetail para ID: $tipoHabitacionId");
      
      final response = await _service.fetchTipoHabitacionDetail(tipoHabitacionId);
      
      print("🔵 [ReservacionController] Respuesta recibida: statusCode=${response.statusCode}");
      print("🔵 [ReservacionController] response.data: ${response.data}");
      print("🔵 [ReservacionController] Tipo de response.data: ${response.data.runtimeType}");
      
      // Validar que response.data no sea null
      if (response.data == null) {
        throw Exception("El servidor no devolvió datos (response.data es null)");
      }
      
      // Validar que response.data sea un Map
      if (response.data is! Map<String, dynamic>) {
        throw Exception("Formato de respuesta inválido. Se esperaba Map<String, dynamic>, se recibió: ${response.data.runtimeType}");
      }
      
      final data = response.data as Map<String, dynamic>;
      print("🔵 [ReservacionController] Datos parseados: $data");
      
      // Validar campos críticos antes de parsear
      if (data['id_tipoHabitacion'] == null) {
        throw Exception("El campo 'id_tipoHabitacion' es requerido pero es null");
      }
      if (data['clave'] == null) {
        throw Exception("El campo 'clave' es requerido pero es null");
      }
      if (data['tipo_habitacion'] == null) {
        throw Exception("El campo 'tipo_habitacion' es requerido pero es null");
      }
      if (data['precio_unitario'] == null) {
        throw Exception("El campo 'precio_unitario' es requerido pero es null");
      }
      if (data['periodicidad_id'] == null) {
        throw Exception("El campo 'periodicidad_id' es requerido pero es null");
      }
      
      print("🔵 [ReservacionController] Todos los campos críticos están presentes, parseando...");
      _tipoHabitacionDetail = TipoHabitacion.fromJson(data);
      print("✅ [ReservacionController] TipoHabitacion parseado exitosamente");
    } catch (e, stackTrace) {
      _tipoDetailErrorMessage = 'Error al cargar detalle del tipo: ${e.toString()}';
      print("🔴 [ReservacionController] Error en fetchTipoHabitacionDetail: $e");
      print("🔴 [ReservacionController] Stack trace: $stackTrace");
      _tipoHabitacionDetail = null;
    }

    _isLoadingTipoDetail = false;
    notifyListeners();
  }

  /// Obtener galería de imágenes de un tipo de habitación
  Future<void> fetchGaleriaTipoHabitacion(int tipoHabitacionId) async {
    _isLoadingGaleria = true;
    _galeriaErrorMessage = null;
    _galeriaTipoHabitacion = [];
    notifyListeners();

    try {
      final response = await _service.fetchGaleriaTipoHabitacion(tipoHabitacionId);

      if (response.data is Map && response.data['imagenes'] is List) {
        _galeriaTipoHabitacion = (response.data['imagenes'] as List)
            .map((img) => GaleriaImagen.fromJson(img as Map<String, dynamic>))
            .toList();
      } else {
        _galeriaTipoHabitacion = [];
      }
    } catch (e) {
      _galeriaErrorMessage = 'Error al cargar galería del tipo: ${e.toString()}';
      _galeriaTipoHabitacion = [];
    }

    _isLoadingGaleria = false;
    notifyListeners();
  }

  /// Calcular precio total según periodicidad y duración
  double calcularPrecioTotal(double precioUnitario, int periodicidadId, int duracionDias) {
    // Lógica básica: si periodicidad es "Por noche" (id=1 generalmente), multiplicar por días
    // Si es "Por estadía" (id=2), usar precio unitario
    // Ajustar según la lógica de negocio real
    if (periodicidadId == 1) {
      // Por noche
      return precioUnitario * duracionDias;
    } else {
      // Por estadía u otra periodicidad
      return precioUnitario;
    }
  }

  /// Limpiar tipos disponibles
  void clearTiposDisponibles() {
    _tiposDisponibles = [];
    notifyListeners();
  }

  /// Limpiar detalle de tipo
  void clearTipoHabitacionDetail() {
    _tipoHabitacionDetail = null;
    _galeriaTipoHabitacion = [];
    notifyListeners();
  }
}

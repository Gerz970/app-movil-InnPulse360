import 'package:flutter/foundation.dart'; // Para uso de ChangeNotifier
import '../services/limpieza_service.dart'; // para conexion con servicio
import '../models/limpieza_model.dart'; // modelo de Limpieza
import 'package:dio/dio.dart'; // clase dio para construir objeto de http

/// Controlador para manejar el estado del módulo de limpieza
/// Usa ChangeNotifier para notificar cambios de estado
class LimpiezaController extends ChangeNotifier {
  // Instancia de LimpiezaService
  final LimpiezaService _limpiezaService = LimpiezaService();

  // Estados privados para listado
  bool _isLoading = false; // Estado de carga
  List<Limpieza> _limpiezas = []; // Lista de limpiezas
  String? _errorMessage; // Mensaje de error (puede ser null)
  bool _isNotAuthenticated = false; // Estado de autenticación

  // Getters para listado
  bool get isLoading => _isLoading;
  List<Limpieza> get limpiezas => _limpiezas;
  String? get errorMessage => _errorMessage;
  bool get isNotAuthenticated => _isNotAuthenticated;
  bool get isEmpty => _limpiezas.isEmpty && !_isLoading && _errorMessage == null;

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
}

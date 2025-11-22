import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../models/reservas_model.dart';
import '../services/reserva_service.dart';
import '../../../core/auth/services/session_storage.dart'; // para obtener token de sesión
import '../models/habitacion_dispobile_model.dart';

class ReservacionController with ChangeNotifier {
  List<Reservacion> reservaciones = [];
  List<HabitacionDisponible> habitaciones = [];
  bool isLoading = false;
  String? errorMessage;
  bool _isNotAuthenticated = false; // Estado de autenticación

  final ReservaService _service = ReservaService();

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
    } catch (e) {
      habitaciones = [];
    }

    isLoading = false;
    notifyListeners();
  }

  Future<bool> createReserva(Map<String, dynamic> reservaData) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    final session = await SessionStorage.getSession();
    final usuario = session?['usuario'] as Map<String, dynamic>?;
    final clienteId = usuario?['cliente_id'] as int;

    reservaData['cliente_id'] = clienteId;

    try {
      final response = await _service.createReserva(reservaData);
      isLoading = false;
      notifyListeners();

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
            errorMessage = 'No estás autenticado. Por favor, inicia sesión nuevamente.';
            print('Error de autenticación al crear incidencia: ${e.response?.data}');
          }
          // Error 422 - Validación
          else if (statusCode == 422) {
            errorMessage = 'Error de validación: ${e.response?.data}';
            print('Error de validación al crear incidencia: ${e.response?.data}');
          }
          // Otro error del servidor
          else {
            errorMessage = 'Error ${statusCode}: ${e.response?.data}';
            print('Error del servidor al crear incidencia: ${e.response?.data}');
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

  void clearHabitaciones() {
    habitaciones = [];
    notifyListeners();
  }
}

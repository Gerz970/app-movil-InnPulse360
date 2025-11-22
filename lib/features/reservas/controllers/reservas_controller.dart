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
}

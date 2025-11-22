import 'package:flutter/material.dart';
import '../models/reservas_model.dart';
import '../services/reserva_service.dart';
import '../../../core/auth/services/session_storage.dart'; // para obtener token de sesión

class ReservacionController with ChangeNotifier {
  List<Reservacion> reservaciones = [];
  bool isLoading = false;
  String? errorMessage;

  final IncidenciaService _service = IncidenciaService();

  Future<void> fetchReservaciones() async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      final session = await SessionStorage.getSession();
      print("SESSION: $session");

      final usuario = session?['usuario'] as Map<String, dynamic>?;
      print("USUARIO: $usuario");

      final clienteId = usuario?['cliente_id'] as int;
      print("CLIENTE_ID: $clienteId");

      final response = await _service.fetchReservaciones(clienteId);
      final data = response.data as List;

      reservaciones = data.map((e) => Reservacion.fromJson(e)).toList();

    } catch (e) {
      errorMessage = "Error al cargar reservaciones: $e";
    }

    isLoading = false;
    notifyListeners();
  }
}

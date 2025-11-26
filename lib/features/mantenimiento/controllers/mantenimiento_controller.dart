import 'package:flutter/material.dart';
import '../models/mantenimiento_model.dart';
import '../services/mantenimiento_service.dart';

class MantenimientoController extends ChangeNotifier {
  final MantenimientoService _service = MantenimientoService();

  List<Mantenimiento> mantenimientos = [];
  bool isLoading = false;
  String? errorMessage;
  bool isNotAuthenticated = false;

  bool get isEmpty => !isLoading && mantenimientos.isEmpty;

  Future<void> fetchMantenimientos() async {
  isLoading = true;
  errorMessage = null;
  notifyListeners();

  try {
    final result = await _service.fetchMantenimiento();
    mantenimientos = result;     // <- ❗ FALTABA ESTO
  } catch (e) {
    if ("$e".contains("NOT_AUTH")) {
      isNotAuthenticated = true;
      errorMessage = "Sesión expirada";
    } else {
      errorMessage = e.toString();
    }
  } finally {
    isLoading = false;
    notifyListeners();
  }
}

}

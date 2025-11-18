import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../services/piso_service.dart';
import '../models/piso_model.dart';
import 'package:provider/provider.dart';
import '../../hoteles/controllers/hotel_controller.dart';

class PisoController extends ChangeNotifier {
  final PisoService _service = PisoService();

  List<Piso> pisos = [];
  Piso? pisoSeleccionado;

  bool isLoading = false;
  String? error;

  Future<void> cargarPisosPorHotel(BuildContext context) async {
    final hotelController = Provider.of<HotelController>(
      context,
      listen: false,
    );

    if (hotelController.hotelSeleccionado == null) return;

    final idHotel = hotelController.hotelSeleccionado!.idHotel;

    try {
      isLoading = true;
      notifyListeners();

      pisos = await _service.getPisosByHotel(idHotel);
      error = null;
    } catch (e) {
      error = "Error cargando pisos: $e";
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> crearPiso(PisoCreateModel pisoData) async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      // Crear hotel mediante el servicio
      final response = await _service.createPiso(pisoData);
      isLoading = false;

      // Si éxito, refrescar la lista de hoteles
      notifyListeners();

      print("Piso creado correctamente");
      print(response);

      // Refrescar lista de hoteles

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
            error =
                'No estás autenticado. Por favor, inicia sesión nuevamente.';
            print('Error de autenticación al crear piso: ${e.response?.data}');
          }
          // Error 422 - Validación
          else if (statusCode == 422) {
            error = 'Error de validación: ${e.response?.data}';
            print('Error de validación al crear piso: ${e.response?.data}');
          }
          // Otro error del servidor
          else {
            error = 'Error ${statusCode}: ${e.response?.data}';
            print('Error del servidor al crear piso: ${e.response?.data}');
          }
        } else {
          // Error de conexión
          error = 'Error de conexión: ${e.message ?? e.toString()}';
          print('Error de conexión al crear piso: ${e.message}');
        }
      } else {
        // Otro tipo de error
        error = 'Error: ${e.toString()}';
        print('Error general al crear piso: $e');
      }

      notifyListeners();
      return false;
    }
  }

  Future<bool> actualizarPiso(Piso piso) async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final response = await _service.updatePiso(piso.idPiso, piso);

      isLoading = false;
      notifyListeners();

      print("Piso actualizado: $response");

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
            error =
                'No estás autenticado. Por favor, inicia sesión nuevamente.';
            print('Error de autenticación al crear piso: ${e.response?.data}');
          }
          // Error 422 - Validación
          else if (statusCode == 422) {
            error = 'Error de validación: ${e.response?.data}';
            print('Error de validación al crear piso: ${e.response?.data}');
          }
          // Otro error del servidor
          else {
            error = 'Error ${statusCode}: ${e.response?.data}';
            print('Error del servidor al crear piso: ${e.response?.data}');
          }
        } else {
          // Error de conexión
          error = 'Error de conexión: ${e.message ?? e.toString()}';
          print('Error de conexión al crear piso: ${e.message}');
        }
      } else {
        // Otro tipo de error
        error = 'Error: ${e.toString()}';
        print('Error general al crear piso: $e');
      }

      notifyListeners();
      return false;
    }
  }

  void seleccionarPiso(Piso piso) {
    pisoSeleccionado = piso;
    notifyListeners();
  }
}

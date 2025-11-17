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
    final hotelController = Provider.of<HotelController>(context, listen: false);

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

  void seleccionarPiso(Piso piso) {
    pisoSeleccionado = piso;
    notifyListeners();
  }
}

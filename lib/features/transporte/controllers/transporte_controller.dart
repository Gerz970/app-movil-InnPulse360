import 'package:flutter/material.dart';
import '../models/servicio_transporte_model.dart';
import '../services/transporte_service.dart';
import '../../../core/services/geolocalizacion_service.dart';

class TransporteController extends ChangeNotifier {
  final TransporteService _service = TransporteService();
  final GeolocalizacionService _geoService = GeolocalizacionService();

  List<ServicioTransporteModel> _servicios = [];
  bool _isLoading = false;
  String? _error;

  List<ServicioTransporteModel> get servicios => _servicios;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchServicios() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _service.fetchServicios();
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        _servicios = data.map((json) => ServicioTransporteModel.fromJson(json)).toList();
      }
    } catch (e) {
      _error = e.toString();
      print('Error fetching servicios: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> crearServicio(ServicioTransporteModel servicio) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _service.createServicio(servicio.toJson());
      if (response.statusCode == 200 || response.statusCode == 201) {
        await fetchServicios();
        return true;
      }
      return false;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<dynamic> obtenerUbicacionActual() async {
    try {
      return await _geoService.obtenerUbicacionActual();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return null;
    }
  }
}


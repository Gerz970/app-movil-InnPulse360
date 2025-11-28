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

  Future<void> fetchServiciosConductor(int empleadoId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _service.fetchServiciosPorEmpleado(empleadoId);
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        _servicios = data.map((json) => ServicioTransporteModel.fromJson(json)).toList();
      }
    } catch (e) {
      _error = e.toString();
      print('Error fetching servicios conductor: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  List<ServicioTransporteModel> getServiciosPorEstatus(int estatusId) {
    return _servicios.where((servicio) => servicio.idEstatus == estatusId).toList();
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

  Future<bool> crearServicioDesdeReservacion(ServicioTransporteModel servicio, int reservacionId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _service.createServicioDesdeReservacion(servicio.toJson(), reservacionId);
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

  Future<bool> iniciarViaje(int idServicio, String comentario) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _service.iniciarViaje(idServicio, comentario);
      if (response.statusCode == 200 || response.statusCode == 201) {
        _isLoading = false;
        notifyListeners();
        return true;
      }
      _isLoading = false;
      _error = 'Error al iniciar viaje';
      notifyListeners();
      return false;
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      print('Error iniciar viaje: $e');
      notifyListeners();
      return false;
    }
  }

  Future<bool> terminarViaje(int idServicio, String comentario) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _service.terminarViaje(idServicio, comentario);
      if (response.statusCode == 200 || response.statusCode == 201) {
        _isLoading = false;
        notifyListeners();
        return true;
      }
      _isLoading = false;
      _error = 'Error al terminar viaje';
      notifyListeners();
      return false;
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      print('Error terminar viaje: $e');
      notifyListeners();
      return false;
    }
  }

  Future<ServicioTransporteModel?> obtenerDetalleServicio(int idServicio) async {
    try {
      final response = await _service.getServicioDetail(idServicio);
      if (response.statusCode == 200 && response.data != null) {
        return ServicioTransporteModel.fromJson(response.data);
      }
      return null;
    } catch (e) {
      _error = e.toString();
      print('Error obtener detalle servicio: $e');
      return null;
    }
  }

  List<ServicioTransporteModel> getServiciosPendientesPorCalificar() {
    return _servicios.where((servicio) => 
      servicio.idEstatus == 3 && // Terminado
      servicio.calificacionViaje == null
    ).toList();
  }

  Future<bool> calificarViaje(int idServicio, int calificacion, String? comentario) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _service.calificarViaje(idServicio, calificacion, comentario);
      if (response.statusCode == 200 || response.statusCode == 201) {
        // Recargar servicios para reflejar el cambio
        await fetchServicios();
        _isLoading = false;
        notifyListeners();
        return true;
      }
      _isLoading = false;
      _error = 'Error al calificar viaje';
      notifyListeners();
      return false;
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      print('Error calificar viaje: $e');
      notifyListeners();
      return false;
    }
  }
}


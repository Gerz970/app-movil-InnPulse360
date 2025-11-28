import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/mantenimiento_model.dart';
import '../services/mantenimiento_service.dart';
import '../models/galeria_imagen_model.dart';

class MantenimientoController extends ChangeNotifier {
  final MantenimientoService _service = MantenimientoService();

  List<Mantenimiento> mantenimientos = [];
  bool isLoading = false;
  String? errorMessage;
  bool isNotAuthenticated = false;

  bool get isEmpty => !isLoading && mantenimientos.isEmpty;

  // --- GALERÍA ---
  List<GaleriaImagen> galeriaImagenes = [];
  String? _galeriaErrorMessage;
  bool _isLoadingGaleria = false;

  // Getters:
  bool get isLoadingGaleria => _isLoadingGaleria;
  String? get galeriaErrorMessage => _galeriaErrorMessage;

  // --- SUBIR FOTO ---
  bool _isUploadingPhoto = false;
  String? uploadPhotoError;

  bool get isUploadingPhoto => _isUploadingPhoto;

  // --- Fotos locales ---
  Map<int, File> fotos = {};

  // ---------------------------------------------------------
  //  CARGAR MANTENIMIENTOS
  // ---------------------------------------------------------
  Future<void> fetchMantenimientos() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final result = await _service.fetchMantenimiento();
      mantenimientos = result;
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

  // ---------------------------------------------------------
  //  CARGAR GALERÍA
  // ---------------------------------------------------------
  Future<void> fetchGaleria(int incidenciaId) async {
    _isLoadingGaleria = true;
    _galeriaErrorMessage = null;

    // Limpia la última galería mientras carga
    galeriaImagenes = [];
    notifyListeners();

    try {
      final response = await _service.fetchGaleria(incidenciaId);

      if (response.data != null && response.data is Map<String, dynamic>) {
        final galeriaResponse =
            GaleriaResponse.fromJson(response.data as Map<String, dynamic>);
        galeriaImagenes = galeriaResponse.imagenes;
      } else {
        galeriaImagenes = [];
      }

      _isLoadingGaleria = false;
      notifyListeners();
    } catch (e) {
      _isLoadingGaleria = false;
      galeriaImagenes = [];

      if (e is DioException) {
        if (e.response != null) {
          final responseData = e.response?.data;

          if (responseData is Map<String, dynamic> &&
              responseData['detail'] == 'Not authenticated') {
            isNotAuthenticated = true;
            _galeriaErrorMessage =
                'No estás autenticado. Por favor, inicia sesión nuevamente.';
          } else {
            _galeriaErrorMessage =
                'Error al cargar galería: ${e.response?.statusCode}';
          }
        } else {
          _galeriaErrorMessage =
              'Error de conexión: ${e.message ?? e.toString()}';
        }
      } else {
        _galeriaErrorMessage = 'Error al cargar galería: ${e.toString()}';
      }

      notifyListeners();
    }
  }

  // ---------------------------------------------------------
  //  SUBIR FOTO
  // ---------------------------------------------------------
  Future<bool> uploadPhoto(int incidenciaId, XFile xFile, String tipo) async {
    _isUploadingPhoto = true;
    uploadPhotoError = null;
    notifyListeners();

    try {
      await _service.uploadFotoGaleria(incidenciaId, xFile, tipo);

      _isUploadingPhoto = false;
      notifyListeners();

      // Refrescar galería
      await fetchGaleria(incidenciaId);

      return true;
    } catch (e) {
      _isUploadingPhoto = false;

      if (e is DioException) {
        if (e.response != null) {
          final responseData = e.response?.data;
          final statusCode = e.response?.statusCode;

          if (statusCode == 401 ||
              (responseData is Map<String, dynamic> &&
                  responseData['detail'] == 'Not authenticated')) {
            isNotAuthenticated = true;
            uploadPhotoError =
                'No estás autenticado. Por favor, inicia sesión nuevamente.';
          } else {
            uploadPhotoError =
                'Error al subir foto: ${e.response?.statusCode}';
          }
        } else {
          uploadPhotoError =
              'Error de conexión: ${e.message ?? e.toString()}';
        }
      } else {
        uploadPhotoError = 'Error desconocido: ${e.toString()}';
      }

      notifyListeners();
      return false;
    }
  }

  Future<bool> cambiarEstatusMantenimiento(int mantenimientoId) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    final Map<String, dynamic> data = {};
    final hoy = DateTime.now();
    final soloFecha = "${hoy.year}-${hoy.month.toString().padLeft(2, '0')}-${hoy.day.toString().padLeft(2, '0')}";
    data['fecha_termino'] = soloFecha;
    data['estatus'] = 2;

    try {
      await _service.cambiarEstatusMantenimiento(mantenimientoId, data);
      isLoading = false;
      notifyListeners();
      fetchMantenimientos();
      return true;
    } catch (e) {
      if ("$e".contains("NOT_AUTH")) {
        isNotAuthenticated = true;
        errorMessage = "Sesión expirada";
      } else {
        errorMessage = e.toString();
      }
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}

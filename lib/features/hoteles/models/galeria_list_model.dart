/*
  Modelo para la respuesta de listado de galería de un hotel
  Corresponde al schema GaleriaListResponse del backend
*/

import 'galeria_image_model.dart';

class GaleriaList {
  final bool success;
  final List<GaleriaImage> imagenes;
  final int total;
  final String? message;

  GaleriaList({
    required this.success,
    required this.imagenes,
    this.total = 0,
    this.message,
  });

  // Método para deserializar desde JSON
  factory GaleriaList.fromJson(Map<String, dynamic> json) {
    List<GaleriaImage> imagenesList = [];
    if (json['imagenes'] != null && json['imagenes'] is List) {
      imagenesList = (json['imagenes'] as List)
          .map((img) => GaleriaImage.fromJson(img as Map<String, dynamic>))
          .toList();
    }

    return GaleriaList(
      success: json['success'] as bool? ?? false,
      imagenes: imagenesList,
      total: json['total'] as int? ?? 0,
      message: json['message'] as String?,
    );
  }

  // Método para serializar a JSON
  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'imagenes': imagenes.map((img) => img.toJson()).toList(),
      'total': total,
      'message': message,
    };
  }
}


/*
  Este modelo es para definir la estructura de una Imagen de Galería obtenida del API
  Usado para la galería de imágenes de incidencias
*/

class GaleriaImagen {
  // Atributos del modelo
  final String nombre;
  final String ruta;
  final int tamanio;
  final String urlPublica;

  // Constructor con valores por defecto para null-safety
  GaleriaImagen({
    required this.nombre,
    required this.ruta,
    required this.tamanio,
    required this.urlPublica,
  });

  // Método para deserializar desde JSON
  factory GaleriaImagen.fromJson(Map<String, dynamic> json) {
    return GaleriaImagen(
      nombre: json['nombre'] as String? ?? '',
      ruta: json['ruta'] as String? ?? '',
      tamanio: json['tamaño'] as int? ?? 0,  // Nota: acento en tamaño
      urlPublica: json['url_publica'] as String? ?? '',
    );
  }
}

/*
  Este modelo es para definir la estructura de la respuesta de la galería
  Incluye la lista de imágenes y metadatos
*/
class GaleriaResponse {
  // Atributos del modelo
  final List<GaleriaImagen> imagenes;
  final bool success;
  final int total;

  // Constructor con valores por defecto para null-safety
  GaleriaResponse({
    required this.imagenes,
    required this.success,
    required this.total,
  });

  // Método para deserializar desde JSON
  factory GaleriaResponse.fromJson(Map<String, dynamic> json) {
    return GaleriaResponse(
      imagenes: (json['imagenes'] as List? ?? [])
          .map((img) => GaleriaImagen.fromJson(img as Map<String, dynamic>))
          .toList(),
      success: json['success'] as bool? ?? false,
      total: json['total'] as int? ?? 0,
    );
  }
}


/*
  Modelo para una imagen individual en la galería de un hotel
  Corresponde al schema GaleriaImageResponse del backend
*/

class GaleriaImage {
  final String nombre;
  final String ruta;
  final String? urlPublica;
  final int tamano;
  final String? tipo;

  GaleriaImage({
    required this.nombre,
    required this.ruta,
    this.urlPublica,
    this.tamano = 0,
    this.tipo,
  });

  // Método para deserializar desde JSON
  factory GaleriaImage.fromJson(Map<String, dynamic> json) {
    return GaleriaImage(
      nombre: json['nombre'] as String? ?? '',
      ruta: json['ruta'] as String? ?? '',
      urlPublica: json['url_publica'] as String?,
      tamano: json['tamaño'] as int? ?? 0,
      tipo: json['tipo'] as String?,
    );
  }

  // Método para serializar a JSON
  Map<String, dynamic> toJson() {
    return {
      'nombre': nombre,
      'ruta': ruta,
      'url_publica': urlPublica,
      'tamaño': tamano,
      'tipo': tipo,
    };
  }
}


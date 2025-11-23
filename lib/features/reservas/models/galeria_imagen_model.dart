class GaleriaImagen {
  final String nombre;
  final String urlPublica;
  final String? tipo;
  final DateTime? fechaCreacion;

  GaleriaImagen({
    required this.nombre,
    required this.urlPublica,
    this.tipo,
    this.fechaCreacion,
  });

  factory GaleriaImagen.fromJson(Map<String, dynamic> json) {
    return GaleriaImagen(
      nombre: json['nombre'] ?? '',
      urlPublica: json['url_publica'] ?? '',
      tipo: json['tipo'],
      fechaCreacion: json['fecha_creacion'] != null
          ? DateTime.parse(json['fecha_creacion'])
          : null,
    );
  }
}


/*
  Este modelo es para definir la estructura de un País obtenido del API
  Usado para el catálogo de países en el formulario de creación de hoteles
*/

class Pais {
  // Atributos del modelo
  final int idPais;
  final String nombre;
  final int idEstatus;

  // Constructor con valores por defecto para null-safety
  Pais({
    required this.idPais,
    required this.nombre,
    required this.idEstatus,
  });

  // Método para deserializar desde JSON
  factory Pais.fromJson(Map<String, dynamic> json) {
    return Pais(
      idPais: json['id_pais'] as int? ?? 0,
      nombre: json['nombre'] as String? ?? '',
      idEstatus: json['id_estatus'] as int? ?? 1,
    );
  }
}


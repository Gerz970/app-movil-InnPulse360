/*
  Este modelo es para definir la estructura de un Estado obtenido del API
  Usado para el catálogo de estados en el formulario de creación de hoteles
*/

class Estado {
  // Atributos del modelo
  final int idEstado;
  final String nombre;
  final int idPais;
  final int idEstatus;

  // Constructor con valores por defecto para null-safety
  Estado({
    required this.idEstado,
    required this.nombre,
    required this.idPais,
    required this.idEstatus,
  });

  // Método para deserializar desde JSON
  factory Estado.fromJson(Map<String, dynamic> json) {
    return Estado(
      idEstado: json['id_estado'] as int? ?? 0,
      nombre: json['nombre'] as String? ?? '',
      idPais: json['id_pais'] as int? ?? 0,
      idEstatus: json['id_estatus'] as int? ?? 1,
    );
  }
}


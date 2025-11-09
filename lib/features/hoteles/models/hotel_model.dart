/*
  Este modelo es para definir la estructura de un Hotel obtenido del API
  Solo incluye los campos visibles para el usuario final
*/

class Hotel {
  // Atributos del modelo
  final int idHotel;
  final String nombre;
  final String direccion;
  final String? codigoPostal;
  final String? telefono;
  final String? emailContacto;
  final int? idPais;
  final int? idEstado;
  final int numeroEstrellas;

  // Constructor con valores por defecto para null-safety
  Hotel({
    required this.idHotel,
    required this.nombre,
    required this.direccion,
    this.codigoPostal,
    this.telefono,
    this.emailContacto,
    this.idPais,
    this.idEstado,
    required this.numeroEstrellas,
  });

  // Método para deserializar desde JSON
  factory Hotel.fromJson(Map<String, dynamic> json) {
    return Hotel(
      idHotel: json['id_hotel'] as int? ?? 0,
      nombre: json['nombre'] as String? ?? '',
      direccion: json['direccion'] as String? ?? '',
      codigoPostal: json['codigo_postal'] as String?,
      telefono: json['telefono'] as String?,
      emailContacto: json['email_contacto'] as String?,
      idPais: json['id_pais'] as int?,
      idEstado: json['id_estado'] as int?,
      numeroEstrellas: json['numero_estrellas'] as int? ?? 0,
    );
  }
}


class Piso {
  final int idPiso;
  final int idHotel;
  final String nombre;
  final String descripcion;
  final int nivel;
  final int idEstatus;

  Piso({
    required this.idPiso,
    required this.idHotel,
    required this.nombre,
    required this.descripcion,
    required this.nivel,
    required this.idEstatus,
  });

  factory Piso.fromJson(Map<String, dynamic> json) {
    return Piso(
      idPiso: json['id_piso'],
      idHotel: json['id_hotel'],
      nombre: json['nombre'],
      descripcion: json['descripcion'],
      nivel: json['numero_pisos'],
      idEstatus: json['estatus_id']
    );
  }

   Map<String, dynamic> toJson() {
    return {
      "id_piso": idPiso,
      "id_hotel": idHotel,
      "numero_pisos": nivel,
      "nombre": nombre,
      "descripcion": descripcion,
      "estatus_id": idEstatus,
      "nivel": nivel,
    };
  }
}

class PisoCreateModel {
  final int idHotel;
  final int nivel;
  final String nombre;
  final String descripcion;
  final int idEstatus;

  PisoCreateModel({
    required this.idHotel,
    required this.nivel,
    required this.nombre,
    required this.descripcion,
    required this.idEstatus
  });

  Map<String, dynamic> toJson() => {
        'descripcion': descripcion,
        'estatus_id': idEstatus,
        'id_hotel': idHotel,
        'nombre': nombre,
        'numero_pisos': nivel
      };
}

class PisoUpdateModel {
  final String nombre;
  final int nivel;

  PisoUpdateModel({
    required this.nombre,
    required this.nivel,
  });

  Map<String, dynamic> toJson() => {
        'nombre': nombre,
        'nivel': nivel,
      };
}

class Piso {
  final int idPiso;
  final int idHotel;
  final String nombre;
  final int nivel;

  Piso({
    required this.idPiso,
    required this.idHotel,
    required this.nombre,
    required this.nivel,
  });

  factory Piso.fromJson(Map<String, dynamic> json) {
    return Piso(
      idPiso: json['id_piso'],
      idHotel: json['id_hotel'],
      nombre: json['nombre'],
      nivel: json['numero_pisos'],
    );
  }
}

class PisoCreateModel {
  final int idHotel;
  final String nombre;
  final int nivel;

  PisoCreateModel({
    required this.idHotel,
    required this.nombre,
    required this.nivel,
  });

  Map<String, dynamic> toJson() => {
        'id_hotel': idHotel,
        'nombre': nombre,
        'nivel': nivel,
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

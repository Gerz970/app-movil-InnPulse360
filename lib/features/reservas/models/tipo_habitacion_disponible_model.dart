import 'tipo_habitacion_model.dart';

class TipoHabitacionDisponible {
  final TipoHabitacion tipoHabitacion;
  final int cantidadDisponible;

  TipoHabitacionDisponible({
    required this.tipoHabitacion,
    required this.cantidadDisponible,
  });

  factory TipoHabitacionDisponible.fromJson(Map<String, dynamic> json) {
    return TipoHabitacionDisponible(
      tipoHabitacion: TipoHabitacion.fromJson(json['tipo_habitacion'] as Map<String, dynamic>),
      cantidadDisponible: json['cantidad_disponible'] as int? ?? 0,
    );
  }
}


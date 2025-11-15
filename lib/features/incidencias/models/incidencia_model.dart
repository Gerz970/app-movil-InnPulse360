/*
  Este modelo es para definir la estructura de una Incidencia obtenida del API
  Incluye el modelo anidado de habitacion_area
*/

import 'habitacion_area_model.dart';

class Incidencia {
  // Atributos del modelo
  final int idIncidencia;
  final int habitacionAreaId;
  final String incidencia;
  final String descripcion;
  final DateTime fechaIncidencia;
  final int idEstatus;
  final HabitacionArea? habitacionArea;

  // Constructor con valores por defecto para null-safety
  Incidencia({
    required this.idIncidencia,
    required this.habitacionAreaId,
    required this.incidencia,
    required this.descripcion,
    required this.fechaIncidencia,
    required this.idEstatus,
    this.habitacionArea,
  });

  // Método para deserializar desde JSON
  factory Incidencia.fromJson(Map<String, dynamic> json) {
    // Parsear fecha desde formato ISO 8601
    DateTime? fechaIncidencia;
    if (json['fecha_incidencia'] != null) {
      try {
        fechaIncidencia = DateTime.parse(json['fecha_incidencia'] as String);
      } catch (e) {
        fechaIncidencia = DateTime.now();
      }
    } else {
      fechaIncidencia = DateTime.now();
    }

    // Parsear habitacion_area si existe
    HabitacionArea? habitacionArea;
    if (json['habitacion_area'] != null && json['habitacion_area'] is Map<String, dynamic>) {
      habitacionArea = HabitacionArea.fromJson(json['habitacion_area'] as Map<String, dynamic>);
    }

    return Incidencia(
      idIncidencia: json['id_incidencia'] as int? ?? 0,
      habitacionAreaId: json['habitacion_area_id'] as int? ?? 0,
      incidencia: json['incidencia'] as String? ?? '',
      descripcion: json['descripcion'] as String? ?? '',
      fechaIncidencia: fechaIncidencia,
      idEstatus: json['id_estatus'] as int? ?? 0,
      habitacionArea: habitacionArea,
    );
  }

  // Método para convertir a JSON (para POST/PUT)
  Map<String, dynamic> toJson() {
    return {
      'habitacion_area_id': habitacionAreaId,
      'incidencia': incidencia,
      'descripcion': descripcion,
      'fecha_incidencia': fechaIncidencia.toUtc().toIso8601String(),
      'id_estatus': idEstatus,
    };
  }

  // Método helper para formatear fecha para mostrar en UI
  String get fechaFormateada {
    final meses = [
      'enero', 'febrero', 'marzo', 'abril', 'mayo', 'junio',
      'julio', 'agosto', 'septiembre', 'octubre', 'noviembre', 'diciembre'
    ];
    return '${fechaIncidencia.day} de ${meses[fechaIncidencia.month - 1]} de ${fechaIncidencia.year}';
  }
}


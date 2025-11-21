/*
  Modelo extendido de HabitacionArea con información de estado
  Incluye información sobre reservaciones activas y limpiezas pendientes/en proceso
*/

import 'habitacion_area_model.dart';

/// Modelo extendido de HabitacionArea con información de estado
class HabitacionAreaConEstado extends HabitacionArea {
  final bool tieneReservacionActiva;
  final bool tieneLimpiezaPendiente;
  final bool tieneLimpiezaEnProceso;
  final bool puedeSeleccionarse;

  HabitacionAreaConEstado({
    required super.idHabitacionArea,
    required super.pisoId,
    required super.tipoHabitacionId,
    required super.nombreClave,
    required super.descripcion,
    required super.estatusId,
    required this.tieneReservacionActiva,
    required this.tieneLimpiezaPendiente,
    required this.tieneLimpiezaEnProceso,
    required this.puedeSeleccionarse,
  });

  factory HabitacionAreaConEstado.fromJson(Map<String, dynamic> json) {
    return HabitacionAreaConEstado(
      idHabitacionArea: json['id_habitacion_area'] as int? ?? 0,
      pisoId: json['piso_id'] as int? ?? 0,
      tipoHabitacionId: json['tipo_habitacion_id'] as int? ?? 0,
      nombreClave: json['nombre_clave'] as String? ?? '',
      descripcion: json['descripcion'] as String? ?? '',
      estatusId: json['estatus_id'] as int? ?? 1,
      tieneReservacionActiva: json['tiene_reservacion_activa'] as bool? ?? false,
      tieneLimpiezaPendiente: json['tiene_limpieza_pendiente'] as bool? ?? false,
      tieneLimpiezaEnProceso: json['tiene_limpieza_en_proceso'] as bool? ?? false,
      puedeSeleccionarse: json['puede_seleccionarse'] as bool? ?? true,
    );
  }

  /// Convierte HabitacionArea a HabitacionAreaConEstado con valores por defecto
  factory HabitacionAreaConEstado.fromHabitacionArea(
    HabitacionArea habitacion, {
    bool tieneReservacionActiva = false,
    bool tieneLimpiezaPendiente = false,
    bool tieneLimpiezaEnProceso = false,
  }) {
    return HabitacionAreaConEstado(
      idHabitacionArea: habitacion.idHabitacionArea,
      pisoId: habitacion.pisoId,
      tipoHabitacionId: habitacion.tipoHabitacionId,
      nombreClave: habitacion.nombreClave,
      descripcion: habitacion.descripcion,
      estatusId: habitacion.estatusId,
      tieneReservacionActiva: tieneReservacionActiva,
      tieneLimpiezaPendiente: tieneLimpiezaPendiente,
      tieneLimpiezaEnProceso: tieneLimpiezaEnProceso,
      puedeSeleccionarse: !tieneLimpiezaPendiente && !tieneLimpiezaEnProceso,
    );
  }
}


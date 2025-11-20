/*
  Modelo simplificado de Empleado para la funcionalidad de asignación de limpiezas
  Solo incluye los campos necesarios para mostrar y seleccionar camaristas
*/

/// Modelo para Puesto (simplificado)
class PuestoSimple {
  final int idPuesto;
  final String puesto;

  PuestoSimple({
    required this.idPuesto,
    required this.puesto,
  });

  factory PuestoSimple.fromJson(Map<String, dynamic> json) {
    return PuestoSimple(
      idPuesto: json['id_puesto'] as int? ?? 0,
      puesto: json['puesto'] as String? ?? '',
    );
  }
}

/// Modelo simplificado de Empleado para asignación de limpiezas
class EmpleadoSimple {
  final int idEmpleado;
  final String claveEmpleado;
  final String nombre;
  final String apellidoPaterno;
  final String apellidoMaterno;
  final List<PuestoSimple> puestos;

  // Constante hardcodeada por diseño del sistema
  static const int ID_PUESTO_CAMARISTA = 2;

  EmpleadoSimple({
    required this.idEmpleado,
    required this.claveEmpleado,
    required this.nombre,
    required this.apellidoPaterno,
    required this.apellidoMaterno,
    required this.puestos,
  });

  factory EmpleadoSimple.fromJson(Map<String, dynamic> json) {
    return EmpleadoSimple(
      idEmpleado: json['id_empleado'] as int? ?? 0,
      claveEmpleado: json['clave_empleado'] as String? ?? '',
      nombre: json['nombre'] as String? ?? '',
      apellidoPaterno: json['apellido_paterno'] as String? ?? '',
      apellidoMaterno: json['apellido_materno'] as String? ?? '',
      puestos: (json['puestos'] as List<dynamic>? ?? [])
          .map((puesto) => PuestoSimple.fromJson(puesto as Map<String, dynamic>))
          .toList(),
    );
  }

  /// Método helper para obtener el nombre completo del empleado
  String get nombreCompleto => '$nombre $apellidoPaterno $apellidoMaterno'.trim();

  /// Método helper para verificar si el empleado es camarista
  /// Retorna true si tiene al menos un puesto con id_puesto == 2 (Camarista)
  bool get esCamarista {
    return puestos.any((puesto) => puesto.idPuesto == ID_PUESTO_CAMARISTA);
  }

  /// Método helper para obtener el nombre del primer puesto
  String get primerPuesto {
    return puestos.isNotEmpty ? puestos.first.puesto : 'Sin puesto asignado';
  }
}

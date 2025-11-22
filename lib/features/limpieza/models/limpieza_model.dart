/*
  Modelos para el módulo de limpieza
  Incluye Limpieza y sus objetos relacionados: TipoLimpieza, HabitacionArea, Empleado
*/

/// Modelo para Tipo de Limpieza
class TipoLimpieza {
  final int idTipoLimpieza;
  final String nombreTipo;
  final String descripcion;
  final int idEstatus;

  TipoLimpieza({
    required this.idTipoLimpieza,
    required this.nombreTipo,
    required this.descripcion,
    required this.idEstatus,
  });

  factory TipoLimpieza.fromJson(Map<String, dynamic> json) {
    return TipoLimpieza(
      idTipoLimpieza: json['id_tipo_limpieza'] as int? ?? 0,
      nombreTipo: json['nombre_tipo'] as String? ?? '',
      descripcion: json['descripcion'] as String? ?? '',
      idEstatus: json['id_estatus'] as int? ?? 1,
    );
  }
}

/// Modelo para Habitación/Área
class HabitacionArea {
  final int idHabitacionArea;
  final int pisoId;
  final int tipoHabitacionId;
  final String nombreClave;
  final String descripcion;
  final int estatusId;

  HabitacionArea({
    required this.idHabitacionArea,
    required this.pisoId,
    required this.tipoHabitacionId,
    required this.nombreClave,
    required this.descripcion,
    required this.estatusId,
  });

  factory HabitacionArea.fromJson(Map<String, dynamic> json) {
    return HabitacionArea(
      idHabitacionArea: json['id_habitacion_area'] as int? ?? 0,
      pisoId: json['piso_id'] as int? ?? 0,
      tipoHabitacionId: json['tipo_habitacion_id'] as int? ?? 0,
      nombreClave: json['nombre_clave'] as String? ?? '',
      descripcion: json['descripcion'] as String? ?? '',
      estatusId: json['estatus_id'] as int? ?? 1,
    );
  }
}

/// Modelo para Domicilio del Empleado
class Domicilio {
  final String calle;
  final String numeroExterior;
  final String? numeroInterior;
  final String colonia;
  final String municipio;
  final String estado;
  final String codigoPostal;
  final int paisId;

  Domicilio({
    required this.calle,
    required this.numeroExterior,
    this.numeroInterior,
    required this.colonia,
    required this.municipio,
    required this.estado,
    required this.codigoPostal,
    required this.paisId,
  });

  factory Domicilio.fromJson(Map<String, dynamic> json) {
    return Domicilio(
      calle: json['calle'] as String? ?? '',
      numeroExterior: json['numero_exterior'] as String? ?? '',
      numeroInterior: json['numero_interior'] as String?,
      colonia: json['colonia'] as String? ?? '',
      municipio: json['municipio'] as String? ?? '',
      estado: json['estado'] as String? ?? '',
      codigoPostal: json['codigo_postal'] as String? ?? '',
      paisId: json['pais_id'] as int? ?? 0,
    );
  }
}

/// Modelo para Empleado
class Empleado {
  final String claveEmpleado;
  final String nombre;
  final String apellidoPaterno;
  final String apellidoMaterno;
  final String fechaNacimiento;
  final String rfc;
  final String curp;
  final Domicilio domicilio;

  Empleado({
    required this.claveEmpleado,
    required this.nombre,
    required this.apellidoPaterno,
    required this.apellidoMaterno,
    required this.fechaNacimiento,
    required this.rfc,
    required this.curp,
    required this.domicilio,
  });

  factory Empleado.fromJson(Map<String, dynamic> json) {
    return Empleado(
      claveEmpleado: json['clave_empleado'] as String? ?? '',
      nombre: json['nombre'] as String? ?? '',
      apellidoPaterno: json['apellido_paterno'] as String? ?? '',
      apellidoMaterno: json['apellido_materno'] as String? ?? '',
      fechaNacimiento: json['fecha_nacimiento'] as String? ?? '',
      rfc: json['rfc'] as String? ?? '',
      curp: json['curp'] as String? ?? '',
      domicilio: json['domicilio'] != null && json['domicilio'] is Map<String, dynamic>
          ? Domicilio.fromJson(json['domicilio'] as Map<String, dynamic>)
          : Domicilio(calle: '', numeroExterior: '', colonia: '', municipio: '', estado: '', codigoPostal: '', paisId: 0),
    );
  }

  /// Método helper para obtener el nombre completo del empleado
  String get nombreCompleto => '$nombre $apellidoPaterno $apellidoMaterno';
}

/// Modelo principal para Limpieza
class Limpieza {
  final int idLimpieza;
  final int habitacionAreaId;
  final String? descripcion;
  final String fechaProgramada;
  final String? fechaInicioLimpieza;
  final String? fechaTermino;
  final int tipoLimpiezaId;
  final int estatusLimpiezaId;
  final String? comentariosObservaciones;
  final int empleadoId;
  final int? empleadoAsignaId;

  // Objetos relacionados
  final TipoLimpieza tipoLimpieza;
  final HabitacionArea habitacionArea;
  final Empleado empleado;

  Limpieza({
    required this.idLimpieza,
    required this.habitacionAreaId,
    this.descripcion,
    required this.fechaProgramada,
    this.fechaInicioLimpieza,
    this.fechaTermino,
    required this.tipoLimpiezaId,
    required this.estatusLimpiezaId,
    this.comentariosObservaciones,
    required this.empleadoId,
    this.empleadoAsignaId,
    required this.tipoLimpieza,
    required this.habitacionArea,
    required this.empleado,
  });

  factory Limpieza.fromJson(Map<String, dynamic> json) {
    return Limpieza(
      idLimpieza: json['id_limpieza'] as int? ?? 0,
      habitacionAreaId: json['habitacion_area_id'] as int? ?? 0,
      descripcion: json['descripcion'] as String?,
      fechaProgramada: json['fecha_programada'] as String? ?? '',
      fechaInicioLimpieza: json['fecha_inicio_limpieza'] as String?,
      fechaTermino: json['fecha_termino'] as String?,
      tipoLimpiezaId: json['tipo_limpieza_id'] as int? ?? 0,
      estatusLimpiezaId: json['estatus_limpieza_id'] as int? ?? 0,
      comentariosObservaciones: json['comentarios_observaciones'] as String?,
      empleadoId: json['empleado_id'] as int? ?? 0,
      empleadoAsignaId: json['empleado_asigna_id'] as int?,
      tipoLimpieza: TipoLimpieza.fromJson(json['tipo_limpieza'] as Map<String, dynamic>? ?? {}),
      habitacionArea: HabitacionArea.fromJson(json['habitacion_area'] as Map<String, dynamic>? ?? {}),
      empleado: json['empleado'] != null && json['empleado'] is Map<String, dynamic>
          ? Empleado.fromJson(json['empleado'] as Map<String, dynamic>)
          : Empleado(claveEmpleado: '', nombre: '', apellidoPaterno: '', apellidoMaterno: '', fechaNacimiento: '', rfc: '', curp: '', domicilio: Domicilio(calle: '', numeroExterior: '', colonia: '', municipio: '', estado: '', codigoPostal: '', paisId: 0)),
    );
  }

  /// Método helper para obtener la fecha programada formateada
  String get fechaProgramadaFormateada {
    try {
      final dateTime = DateTime.parse(fechaProgramada);
      return '${dateTime.day.toString().padLeft(2, '0')}/'
             '${dateTime.month.toString().padLeft(2, '0')}/'
             '${dateTime.year} '
             '${dateTime.hour.toString().padLeft(2, '0')}:'
             '${dateTime.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return fechaProgramada;
    }
  }

  /// Método helper para obtener la fecha de inicio de limpieza formateada
  String? get fechaInicioLimpiezaFormateada {
    if (fechaInicioLimpieza == null) return null;
    try {
      final dateTime = DateTime.parse(fechaInicioLimpieza!);
      return '${dateTime.day.toString().padLeft(2, '0')}/'
             '${dateTime.month.toString().padLeft(2, '0')}/'
             '${dateTime.year} '
             '${dateTime.hour.toString().padLeft(2, '0')}:'
             '${dateTime.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return fechaInicioLimpieza;
    }
  }

  /// Método helper para obtener la fecha de término formateada
  String? get fechaTerminoFormateada {
    if (fechaTermino == null) return null;
    try {
      final dateTime = DateTime.parse(fechaTermino!);
      return '${dateTime.day.toString().padLeft(2, '0')}/'
             '${dateTime.month.toString().padLeft(2, '0')}/'
             '${dateTime.year} '
             '${dateTime.hour.toString().padLeft(2, '0')}:'
             '${dateTime.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return fechaTermino;
    }
  }

  /// Método helper para obtener el texto del estatus de limpieza
  String get estatusLimpiezaTexto {
    switch (estatusLimpiezaId) {
      case 1:
        return 'Pendiente';
      case 2:
        return 'En Progreso';
      case 3:
        return 'Completada';
      case 4:
        return 'Cancelada';
      default:
        return 'Desconocido';
    }
  }

  /// Método helper para obtener el color del estatus
  int get estatusLimpiezaColor {
    switch (estatusLimpiezaId) {
      case 1:
        return 0xFFFFA726; // Naranja para pendiente
      case 2:
        return 0xFF42A5F5; // Azul para en progreso
      case 3:
        return 0xFF66BB6A; // Verde para completada
      case 4:
        return 0xFFEF5350; // Rojo para cancelada
      default:
        return 0xFF9E9E9E; // Gris para desconocido
    }
  }
}

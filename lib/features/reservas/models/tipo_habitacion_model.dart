class Periodicidad {
  final int idPeriodicidad;
  final String periodicidad;
  final String? descripcion;
  final int idEstatus;

  Periodicidad({
    required this.idPeriodicidad,
    required this.periodicidad,
    this.descripcion,
    required this.idEstatus,
  });

  factory Periodicidad.fromJson(Map<String, dynamic> json) {
    // Manejar id_estatus que puede venir como bool o int
    int idEstatus = 1;
    if (json['id_estatus'] != null) {
      if (json['id_estatus'] is int) {
        idEstatus = json['id_estatus'] as int;
      } else if (json['id_estatus'] is bool) {
        idEstatus = (json['id_estatus'] as bool) ? 1 : 0;
      } else if (json['id_estatus'] is num) {
        idEstatus = (json['id_estatus'] as num).toInt();
      }
    }

    // Validar que todos los campos requeridos no sean null
    final idPeriodicidad = json['id_periodicidad'];
    if (idPeriodicidad == null) {
      throw ArgumentError("id_periodicidad no puede ser null");
    }

    final periodicidad = json['periodicidad'];
    if (periodicidad == null) {
      throw ArgumentError("periodicidad no puede ser null");
    }

    return Periodicidad(
      idPeriodicidad: (idPeriodicidad is num) ? idPeriodicidad.toInt() : (idPeriodicidad as int? ?? 0),
      periodicidad: periodicidad as String? ?? '',
      descripcion: json['descripcion'] as String?,
      idEstatus: idEstatus,
    );
  }
}

class TipoHabitacion {
  final int idTipoHabitacion;
  final String clave;
  final double precioUnitario;
  final int periodicidadId;
  final String tipoHabitacion;
  final int estatusId;
  final String? urlFotoPerfil;
  final Periodicidad? periodicidad;
  final List<String>? galeriaTipoHabitacion;

  TipoHabitacion({
    required this.idTipoHabitacion,
    required this.clave,
    required this.precioUnitario,
    required this.periodicidadId,
    required this.tipoHabitacion,
    required this.estatusId,
    this.urlFotoPerfil,
    this.periodicidad,
    this.galeriaTipoHabitacion,
  });

  factory TipoHabitacion.fromJson(Map<String, dynamic> json) {
    try {
      // Validar que json no sea null (esta validación es redundante pero se mantiene por seguridad)
      // El parámetro json ya está tipado como Map<String, dynamic> y no puede ser null en Dart

      // Manejar precio_unitario que puede venir como num o String
      double precioUnitario = 0.0;
      if (json['precio_unitario'] != null) {
        if (json['precio_unitario'] is num) {
          precioUnitario = (json['precio_unitario'] as num).toDouble();
        } else if (json['precio_unitario'] is String) {
          precioUnitario = double.tryParse(json['precio_unitario'] as String) ?? 0.0;
        }
      }

      // Manejar estatus_id que puede venir como bool o int
      int estatusId = 1;
      if (json['estatus_id'] != null) {
        if (json['estatus_id'] is int) {
          estatusId = json['estatus_id'] as int;
        } else if (json['estatus_id'] is bool) {
          estatusId = (json['estatus_id'] as bool) ? 1 : 0;
        } else if (json['estatus_id'] is num) {
          estatusId = (json['estatus_id'] as num).toInt();
        }
      }

      // Validar campos requeridos con mensajes más descriptivos
      final idTipoHabitacion = json['id_tipoHabitacion'];
      if (idTipoHabitacion == null) {
        throw ArgumentError("id_tipoHabitacion no puede ser null. JSON recibido: $json");
      }

      // Clave puede ser null según el modelo de la base de datos
      final clave = json['clave'] as String? ?? '';

      final tipoHabitacion = json['tipo_habitacion'];
      if (tipoHabitacion == null) {
        throw ArgumentError("tipo_habitacion no puede ser null. JSON recibido: $json");
      }
      
      // Validar periodicidad_id con valor por defecto si es null
      int periodicidadIdValue = 1; // Valor por defecto
      if (json['periodicidad_id'] != null) {
        if (json['periodicidad_id'] is num) {
          periodicidadIdValue = (json['periodicidad_id'] as num).toInt();
        } else if (json['periodicidad_id'] is int) {
          periodicidadIdValue = json['periodicidad_id'] as int;
        }
      } else {
        print("⚠️ [TipoHabitacion.fromJson] periodicidad_id es null, usando valor por defecto: 1");
      }

      // Manejar periodicidad de forma segura
      Periodicidad? periodicidadObj;
      if (json['periodicidad'] != null) {
        try {
          if (json['periodicidad'] is Map<String, dynamic>) {
            periodicidadObj = Periodicidad.fromJson(json['periodicidad'] as Map<String, dynamic>);
          }
        } catch (e) {
          print("⚠️ Error parseando periodicidad: $e");
          periodicidadObj = null;
        }
      }

      // Manejar galería de forma segura
      List<String>? galeria;
      if (json['galeria_tipo_habitacion'] != null) {
        try {
          if (json['galeria_tipo_habitacion'] is List) {
            galeria = (json['galeria_tipo_habitacion'] as List)
                .map((e) => e?.toString() ?? '')
                .where((s) => s.isNotEmpty)
                .toList();
          }
        } catch (e) {
          print("⚠️ Error parseando galeria_tipo_habitacion: $e");
          galeria = null;
        }
      }

      return TipoHabitacion(
        idTipoHabitacion: (idTipoHabitacion is num) ? idTipoHabitacion.toInt() : (idTipoHabitacion as int? ?? 0),
        clave: clave as String? ?? '',
        precioUnitario: precioUnitario,
        periodicidadId: periodicidadIdValue,
        tipoHabitacion: tipoHabitacion as String? ?? '',
        estatusId: estatusId,
        urlFotoPerfil: json['url_foto_perfil'] as String?,
        periodicidad: periodicidadObj,
        galeriaTipoHabitacion: galeria,
      );
    } catch (e, stackTrace) {
      print("🔴 [TipoHabitacion.fromJson] Error: $e");
      print("🔴 JSON recibido: $json");
      print("🔴 Stack trace: $stackTrace");
      rethrow;
    }
  }
}


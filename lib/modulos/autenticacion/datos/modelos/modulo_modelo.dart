/// Importar la entidad del dominio
import '../../dominio/entidades/respuesta_autenticacion.dart';

/// Modelo de Módulo para la capa de datos
/// Representa un módulo del sistema asignado al usuario
class ModuloModelo {
  final int idModulo;
  final String nombre;
  final String descripcion;
  final String icono;
  final String ruta;
  
  const ModuloModelo({
    required this.idModulo,
    required this.nombre,
    required this.descripcion,
    required this.icono,
    required this.ruta,
  });
  
  /// Crear ModuloModelo desde JSON
  /// JSON esperado:
  /// {
  ///   "id_modulo": 1,
  ///   "nombre": "Dashboard",
  ///   "descripcion": "Panel principal del sistema",
  ///   "icono": "fas fa-dashboard",
  ///   "ruta": "/dashboard"
  /// }
  factory ModuloModelo.desdeJson(Map<String, dynamic> json) {
    // Validar campos requeridos
    if (json['id_modulo'] == null) {
      throw ArgumentError('id_modulo no puede ser null');
    }
    if (json['nombre'] == null) {
      throw ArgumentError('nombre no puede ser null');
    }
    if (json['descripcion'] == null) {
      throw ArgumentError('descripcion no puede ser null');
    }
    if (json['icono'] == null) {
      throw ArgumentError('icono no puede ser null');
    }
    if (json['ruta'] == null) {
      throw ArgumentError('ruta no puede ser null');
    }
    
    return ModuloModelo(
      idModulo: json['id_modulo'] as int,
      nombre: json['nombre'] as String,
      descripcion: json['descripcion'] as String,
      icono: json['icono'] as String,
      ruta: json['ruta'] as String,
    );
  }
  
  /// Convertir ModuloModelo a JSON
  Map<String, dynamic> aJson() {
    return {
      'id_modulo': idModulo,
      'nombre': nombre,
      'descripcion': descripcion,
      'icono': icono,
      'ruta': ruta,
    };
  }
  
  /// Convertir a entidad de dominio
  Modulo aEntidad() {
    return Modulo(
      idModulo: idModulo,
      nombre: nombre,
      descripcion: descripcion,
      icono: icono,
      ruta: ruta,
    );
  }
}

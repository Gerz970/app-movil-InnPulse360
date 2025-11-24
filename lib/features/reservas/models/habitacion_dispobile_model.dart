class HabitacionDisponible {
  final int idHabitacionArea;
  final String nombreClave;
  final String descripcion;
  final int tipoHabitacionId;
  String imagenUrl;

  HabitacionDisponible({
    required this.idHabitacionArea,
    required this.nombreClave,
    required this.descripcion,
    required this.tipoHabitacionId,
    required this.imagenUrl,
  });

  factory HabitacionDisponible.fromJson(Map<String, dynamic> json) {
    try {
      // Validar que json no sea null
      if (json == null) {
        throw ArgumentError("json no puede ser null");
      }
      
      // Extraer y validar cada campo con logging
      final idHabitacionArea = json['id_habitacion_area'];
      if (idHabitacionArea == null) {
        print("⚠️ [HabitacionDisponible] id_habitacion_area es null");
      }
      
      final nombreClave = json['nombre_clave'];
      if (nombreClave == null) {
        print("⚠️ [HabitacionDisponible] nombre_clave es null");
      }
      
      final descripcion = json['descripcion'];
      if (descripcion == null) {
        print("⚠️ [HabitacionDisponible] descripcion es null");
      }
      
      final tipoHabitacionId = json['tipo_habitacion_id'];
      if (tipoHabitacionId == null) {
        print("⚠️ [HabitacionDisponible] tipo_habitacion_id es null");
      }
      
      final imagenUrl = json['imagen_url'];
      
      return HabitacionDisponible(
        idHabitacionArea: (idHabitacionArea as num?)?.toInt() ?? 0,
        nombreClave: (nombreClave as String?) ?? '',
        descripcion: (descripcion as String?) ?? '',
        tipoHabitacionId: (tipoHabitacionId as num?)?.toInt() ?? 0,
        imagenUrl: (imagenUrl as String?) ?? "", 
      );
    } catch (e, stackTrace) {
      print("🔴 [HabitacionDisponible.fromJson] Error: $e");
      print("🔴 JSON recibido: $json");
      print("🔴 Stack trace: $stackTrace");
      rethrow;
    }
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import './controllers/reservas_controller.dart';
import './reservas_list_screen.dart';
import './models/habitacion_dispobile_model.dart';
import './services/reserva_service.dart';

class ReservasConfirmacionScreen extends StatefulWidget {
  final int tipoHabitacionId;
  final DateTime fechaInicio;
  final DateTime fechaFin;
  final double precioTotal;

  const ReservasConfirmacionScreen({
    super.key,
    required this.tipoHabitacionId,
    required this.fechaInicio,
    required this.fechaFin,
    required this.precioTotal,
  });

  @override
  State<ReservasConfirmacionScreen> createState() =>
      _ReservasConfirmacionScreenState();
}

class _ReservasConfirmacionScreenState
    extends State<ReservasConfirmacionScreen> {
  bool _isCreating = true; // Iniciar como true para mostrar loading
  String? _codigoReservacion;
  String? _errorMessage;
  bool _hasStarted = false;

  @override
  void initState() {
    super.initState();
    // Inicializar estado
    _codigoReservacion = null;
    _errorMessage = null;
    _hasStarted = false;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Iniciar la creación de reserva después de que el widget esté completamente construido
    if (!_hasStarted) {
      _hasStarted = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _crearReservacion();
        }
      });
    }
  }

  Future<void> _crearReservacion() async {
    try {
      print("🔵 [ReservasConfirmacion] Iniciando creación de reservación");
      
      if (!mounted) {
        print("🔴 [ReservasConfirmacion] Widget no está montado, abortando");
        return;
      }
      
      // Asegurar que no estamos en medio de un build
      await Future.delayed(const Duration(milliseconds: 100));
      
      if (!mounted) {
        print("🔴 [ReservasConfirmacion] Widget desmontado después del delay");
        return;
      }
      
      // Solo actualizar si el estado cambió
      if (!_isCreating || _errorMessage != null || _codigoReservacion != null) {
        setState(() {
          _isCreating = true;
          _errorMessage = null;
          _codigoReservacion = null;
        });
      }

      print("🔵 [ReservasConfirmacion] Validando datos de entrada...");
      print("  - tipoHabitacionId: ${widget.tipoHabitacionId}");
      print("  - fechaInicio: ${widget.fechaInicio}");
      print("  - fechaFin: ${widget.fechaFin}");
      print("  - precioTotal: ${widget.precioTotal}");
      
      if (widget.tipoHabitacionId == 0 || widget.tipoHabitacionId == null) {
        throw Exception("tipoHabitacionId es inválido: ${widget.tipoHabitacionId}");
      }
      
      if (!mounted) {
        print("🔴 [ReservasConfirmacion] Widget desmontado antes de obtener controller");
        return;
      }
      
      print("🔵 [ReservasConfirmacion] Obteniendo controller y service...");
      final controller = Provider.of<ReservacionController>(context, listen: false);
      if (controller == null) {
        throw Exception("ReservacionController es null");
      }
      
      final service = ReservaService();
      if (service == null) {
        throw Exception("ReservaService es null");
      }
      
      print("🔵 [ReservasConfirmacion] Controller y service obtenidos correctamente");

      // Obtener una habitación disponible del tipo seleccionado
      print("🔵 [ReservasConfirmacion] Obteniendo habitaciones disponibles...");
      
      String fechaInicioStr;
      String fechaFinStr;
      try {
        fechaInicioStr = widget.fechaInicio.toIso8601String();
        fechaFinStr = widget.fechaFin.toIso8601String();
        print("  - fechaInicioStr: $fechaInicioStr");
        print("  - fechaFinStr: $fechaFinStr");
      } catch (e) {
        throw Exception("Error al formatear fechas: $e");
      }
      
      final response = await service.fetchDisponibles(fechaInicioStr, fechaFinStr);
      print("🔵 [ReservasConfirmacion] Respuesta recibida del servidor");
      
      // Validar que la respuesta tenga datos
      if (response == null) {
        throw Exception("Response es null");
      }
      
      if (response.data == null) {
        print("🔴 [ReservasConfirmacion] response.data es null");
        if (!mounted) return;
        setState(() {
          _isCreating = false;
          _errorMessage = "No se recibieron datos del servidor";
        });
        return;
      }

      final data = response.data;
      print("🔵 [ReservasConfirmacion] Tipo de data: ${data.runtimeType}");
      
      if (data is! List) {
        print("🔴 [ReservasConfirmacion] data no es una List, es: ${data.runtimeType}");
        if (!mounted) return;
        setState(() {
          _isCreating = false;
          _errorMessage = "Formato de respuesta inválido del servidor";
        });
        return;
      }
      
      print("🔵 [ReservasConfirmacion] Data es una List con ${data.length} elementos");

      print("🔵 [ReservasConfirmacion] Parseando habitaciones disponibles...");
      final habitacionesDisponibles = <HabitacionDisponible>[];
      
      for (int i = 0; i < data.length; i++) {
        try {
          final e = data[i];
          if (e == null) {
            print("  ⚠️ Elemento $i es null, saltando");
            continue;
          }
          
          if (e is! Map<String, dynamic>) {
            print("  ⚠️ Elemento $i no es Map, es: ${e.runtimeType}");
            continue;
          }
          
          print("  🔵 Parseando elemento $i: $e");
          final habitacion = HabitacionDisponible.fromJson(e);
          habitacionesDisponibles.add(habitacion);
          print("  ✅ Habitación parseada: id=${habitacion.idHabitacionArea}, tipo=${habitacion.tipoHabitacionId}");
        } catch (e, stackTrace) {
          print("  🔴 Error parseando elemento $i: $e");
          print("  Stack trace: $stackTrace");
          // Continuar con el siguiente elemento
        }
      }
      
      print("🔵 [ReservasConfirmacion] Total de habitaciones parseadas: ${habitacionesDisponibles.length}");

      // Verificar que haya habitaciones disponibles
      if (habitacionesDisponibles.isEmpty) {
        if (!mounted) return;
        setState(() {
          _isCreating = false;
          _errorMessage = "No hay habitaciones disponibles para las fechas seleccionadas";
        });
        return;
      }

      // Buscar una habitación del tipo seleccionado
      print("🔵 [ReservasConfirmacion] Buscando habitación del tipo ${widget.tipoHabitacionId}...");
      
      HabitacionDisponible? habitacion;
      try {
        habitacion = habitacionesDisponibles.firstWhere(
          (h) {
            print("  - Comparando: h.tipoHabitacionId=${h.tipoHabitacionId} == widget.tipoHabitacionId=${widget.tipoHabitacionId}");
            return h.tipoHabitacionId == widget.tipoHabitacionId;
          },
        );
        print("✅ Habitación encontrada: id=${habitacion.idHabitacionArea}");
      } catch (e) {
        print("🔴 No se encontró habitación del tipo ${widget.tipoHabitacionId}");
        print("  Tipos disponibles: ${habitacionesDisponibles.map((h) => h.tipoHabitacionId).toList()}");
        if (!mounted) return;
        setState(() {
          _isCreating = false;
          _errorMessage = "No hay habitaciones disponibles del tipo seleccionado para las fechas indicadas";
        });
        return;
      }

      if (habitacion == null) {
        throw Exception("habitacion es null después de firstWhere");
      }

      // Verificar que la habitación sea válida
      print("🔵 [ReservasConfirmacion] Validando habitación...");
      print("  - idHabitacionArea: ${habitacion.idHabitacionArea}");
      print("  - tipoHabitacionId: ${habitacion.tipoHabitacionId}");
      
      if (habitacion.idHabitacionArea == null || habitacion.idHabitacionArea == 0) {
        print("🔴 ID de habitación inválido: ${habitacion.idHabitacionArea}");
        if (!mounted) return;
        setState(() {
          _isCreating = false;
          _errorMessage = "No se pudo encontrar una habitación válida";
        });
        return;
      }
      print("🔵 [ReservasConfirmacion] Calculando duración...");
      final duracion = widget.fechaFin.difference(widget.fechaInicio).inDays;
      print("  - duracion: $duracion días");
      
      // Validar que la duración sea válida
      if (duracion <= 0) {
        print("🔴 Duración inválida: $duracion");
        if (!mounted) return;
        setState(() {
          _isCreating = false;
          _errorMessage = "La fecha de fin debe ser posterior a la fecha de inicio";
        });
        return;
      }

      // Formatear fechas correctamente (solo fecha, sin hora)
      print("🔵 [ReservasConfirmacion] Formateando fechas para reserva...");
      final fechaInicioReserva = "${widget.fechaInicio.year}-${widget.fechaInicio.month.toString().padLeft(2, '0')}-${widget.fechaInicio.day.toString().padLeft(2, '0')}";
      final fechaFinReserva = "${widget.fechaFin.year}-${widget.fechaFin.month.toString().padLeft(2, '0')}-${widget.fechaFin.day.toString().padLeft(2, '0')}";
      print("  - fechaInicioReserva: $fechaInicioReserva");
      print("  - fechaFinReserva: $fechaFinReserva");

      // Generar código de reservación antes de crear la reserva
      print("🔵 [ReservasConfirmacion] Generando código de reservación...");
      final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      final codigo = timestamp.length > 7 
          ? timestamp.substring(timestamp.length - 7)
          : timestamp;
      final codigoReservacion = "RES-$codigo";
      print("  - codigoReservacion: $codigoReservacion");

      print("🔵 [ReservasConfirmacion] Creando objeto reservaData...");
      final reservaData = <String, dynamic>{
        'habitacion_area_id': habitacion.idHabitacionArea,
        'fecha_reserva': fechaInicioReserva,
        'fecha_salida': fechaFinReserva,
        'duracion': duracion,
        'id_estatus': 1,
        'codigo_reservacion': codigoReservacion,
      };
      print("  - reservaData: $reservaData");

      print("🔵 [ReservasConfirmacion] Llamando a controller.createReserva...");
      if (!mounted) return;
      
      final ok = await controller.createReserva(reservaData);
      print("🔵 [ReservasConfirmacion] createReserva retornó: $ok");

      if (!mounted) return;
      
      if (ok) {
        // Usar el código generado (el backend debería devolverlo también en la respuesta)
        if (!mounted) return;
        setState(() {
          _isCreating = false;
          _codigoReservacion = codigoReservacion;
        });
        print("✅ [ReservasConfirmacion] Código de reservación guardado: $codigoReservacion");
      } else {
        if (!mounted) return;
        setState(() {
          _isCreating = false;
          _errorMessage = controller.errorMessage ?? "Error al crear la reservación";
        });
      }
    } catch (e, stackTrace) {
      print("🔴🔴🔴 ERROR EN _crearReservacion 🔴🔴🔴");
      print("🔴 Tipo de error: ${e.runtimeType}");
      print("🔴 Mensaje: $e");
      print("🔴 Stack trace completo:");
      print(stackTrace);
      
      // Intentar obtener más información del error
      if (e is TypeError) {
        print("🔴 Es TypeError - probablemente un null value");
        print("🔴 Detalles: ${e.toString()}");
      } else if (e is NoSuchMethodError) {
        print("🔴 Es NoSuchMethodError - método llamado en null");
        print("🔴 Detalles: ${e.toString()}");
      } else if (e is ArgumentError) {
        print("🔴 Es ArgumentError - argumento inválido");
        print("🔴 Detalles: ${e.toString()}");
      }
      
      if (!mounted) {
        print("🔴 Widget no está montado, no se puede actualizar estado");
        return;
      }
      
      // Asegurar que no estamos en medio de un build antes de llamar setState
      await Future.delayed(const Duration(milliseconds: 50));
      if (!mounted) {
        print("🔴 Widget desmontado después del delay");
        return;
      }
      
      try {
        setState(() {
          _isCreating = false;
          _errorMessage = "Error: ${e.toString()}";
        });
        print("✅ Estado actualizado con error");
      } catch (setStateError) {
        print("🔴🔴🔴 ERROR AL HACER setState: $setStateError");
        print("🔴 Esto indica que estamos en medio de un build");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Validar que los widgets no sean null antes de usarlos
    try {
      print("🔵 [ReservasConfirmacion] Build iniciado");
      print("  - tipoHabitacionId: ${widget.tipoHabitacionId}");
      print("  - fechaInicio: ${widget.fechaInicio}");
      print("  - fechaFin: ${widget.fechaFin}");
      print("  - precioTotal: ${widget.precioTotal}");
      
      // Validar fechas
      if (widget.fechaInicio == null) {
        throw Exception("fechaInicio es null");
      }
      if (widget.fechaFin == null) {
        throw Exception("fechaFin es null");
      }
      
      final duracionDias = widget.fechaFin.difference(widget.fechaInicio).inDays;
      print("  - duracionDias: $duracionDias");
      
      return Scaffold(
      appBar: AppBar(
        title: const Text("Confirmación de Reservación"),
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_isCreating)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: Column(
                    children: [
                      CircularProgressIndicator(
                        color: Color(0xFF667eea),
                      ),
                      SizedBox(height: 16),
                      Text("Creando reservación..."),
                    ],
                  ),
                ),
              )
            else if (_errorMessage != null)
              Card(
                color: Colors.red[50],
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.error_outline,
                        color: Colors.red,
                        size: 48,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _errorMessage!,
                        style: const TextStyle(color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text("Volver"),
                      ),
                    ],
                  ),
                ),
              )
            else if (_codigoReservacion != null)
              Column(
                children: [
                  // Mensaje de éxito
                  Card(
                    color: Colors.green[50],
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        children: [
                          const Icon(
                            Icons.check_circle,
                            color: Colors.green,
                            size: 64,
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            "¡Reservación creada con éxito!",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 24),
                          // Código de reservación
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: const Color(0xFF667eea),
                                width: 2,
                              ),
                            ),
                            child: Column(
                              children: [
                                const Text(
                                  "Código de Reservación",
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  _codigoReservacion!,
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF667eea),
                                    letterSpacing: 2,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Resumen de reservación
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Resumen de Reservación",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          _buildResumenRow("Fechas", "Del ${widget.fechaInicio.toString().substring(0, 10)} al ${widget.fechaFin.toString().substring(0, 10)}"),
                          const Divider(),
                          _buildResumenRow("Duración", "$duracionDias ${duracionDias == 1 ? 'día' : 'días'}"),
                          const Divider(),
                          _buildResumenRow("Precio Total", "\$${(widget.precioTotal ?? 0.0).toStringAsFixed(2)}"),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  // Botones de acción
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ReservacionesListScreen(),
                        ),
                        (route) => false,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF667eea),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      "Ver Mis Reservaciones",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () {
                      Navigator.popUntil(context, (route) => route.isFirst);
                    },
                    child: const Text("Volver al Inicio"),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
    } catch (e, stackTrace) {
      print("🔴🔴🔴 ERROR EN BUILD 🔴🔴🔴");
      print("🔴 Error: $e");
      print("🔴 Stack trace: $stackTrace");
      
      // Retornar un Scaffold con error en lugar de crashear
      return Scaffold(
        appBar: AppBar(
          title: const Text("Error"),
          backgroundColor: Colors.red,
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error, color: Colors.red, size: 64),
                const SizedBox(height: 16),
                const Text(
                  "Error al cargar la pantalla:",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  e.toString(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.red),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Volver"),
                ),
              ],
            ),
          ),
        ),
      );
    }
  }

  Widget _buildResumenRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}


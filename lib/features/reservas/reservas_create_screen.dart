import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import './controllers/reservas_controller.dart';
import './models/habitacion_dispobile_model.dart';

class NuevaReservaScreen extends StatefulWidget {
  const NuevaReservaScreen({super.key});

  @override
  State<NuevaReservaScreen> createState() => _NuevaReservaScreenState();
}

class _NuevaReservaScreenState extends State<NuevaReservaScreen> {
  DateTime? fechaInicio;
  DateTime? fechaFin;

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<ReservacionController>(
      context,
      listen: false,
    );
    controller.clearHabitaciones();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Nueva Reserva"),
        backgroundColor: const Color(0xFF667eea),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildDatePicker(
              label: "Fecha Inicio",
              date: fechaInicio,
              onSelect: (value) {
                setState(() => fechaInicio = value);
                _tryLoadDisponibles();
              },
            ),

            const SizedBox(height: 16),

            _buildDatePicker(
              label: "Fecha Fin",
              date: fechaFin,
              onSelect: (value) {
                setState(() => fechaFin = value);
                _tryLoadDisponibles();
              },
            ),

            const SizedBox(height: 20),

            Expanded(
              child: Consumer<ReservacionController>(
                builder: (context, controller, _) {
                  if (controller.isLoading) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF667eea),
                      ),
                    );
                  }

                  if (controller.habitaciones.isEmpty) {
                    return const Center(
                      child: Text("Selecciona fechas para ver disponibilidad"),
                    );
                  }

                  return _buildHabitacionesGrid(controller.habitaciones);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDatePicker({
    required String label,
    required DateTime? date,
    required Function(DateTime) onSelect,
  }) {
    return InkWell(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          firstDate: DateTime.now(),
          lastDate: DateTime(2030),
          initialDate: date ?? DateTime.now(),
        );
        if (picked != null) onSelect(picked);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today, color: Colors.grey),
            const SizedBox(width: 12),
            Text(
              date == null
                  ? label
                  : "$label: ${date.toString().substring(0, 10)}",
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHabitacionesGrid(List<HabitacionDisponible> habitaciones) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 1, // 1 por fila, estilo catálogo premium
        childAspectRatio: 16 / 9, // Alargado horizontal estilo tarjeta de hotel
        mainAxisSpacing: 20,
      ),
      itemCount: habitaciones.length,
      itemBuilder: (context, index) {
        final h = habitaciones[index];

        return GestureDetector(
          onTap: () {}, // Si quieres agregar acción al card completo
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: Stack(
                children: [
                  // IMAGEN DE FONDO (placeholder)
                  Positioned.fill(
                    child: Image.network(
                      "https://2.bp.blogspot.com/-9e1ZZEaTv8w/XJTrxHzY9YI/AAAAAAAADSk/3tOUwztxkmoP9iVMYeGlGhf9wXxezHrYACLcBGAs/s1600/habitaciones-minimalista-2019-26.jpg",
                      fit: BoxFit.cover,
                    ),
                  ),

                  // DEGRADADO OSCURO
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.black.withOpacity(0.6),
                            Colors.transparent,
                          ],
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                        ),
                      ),
                    ),
                  ),

                  // INFORMACIÓN PRINCIPAL
                  Positioned(
                    left: 16,
                    right: 16,
                    bottom: 16,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          h.nombreClave,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          h.descripcion,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 12),

                        // BOTÓN RESERVAR
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF667eea),
                            foregroundColor: Colors.white,
                            minimumSize: const Size(double.infinity, 42),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () {
                            _confirmarReserva(context, h.idHabitacionArea);
                          },
                          child: const Text(
                            "Reservar",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHabitacionCard(HabitacionDisponible h) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              h.nombreClave,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Text(h.descripcion, style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 12),

            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                onPressed: () {
                  _confirmarReserva(context, h.idHabitacionArea);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF667eea),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                ),
                child: const Text(
                  "Reservar",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmarReserva(BuildContext context, int idHabitacion) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Crear reservación'),
        content: const Text(
          '¿Estás seguro de que deseas realizar esta reservación?',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _reservarHabitacion(idHabitacion);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF667eea),
            ),
            child: const Text('Aceptar'),
          ),
        ],
      ),
    );
  }

  void _tryLoadDisponibles() {
    if (fechaInicio == null || fechaFin == null) return;

    // VALIDACIÓN: fecha inicio < fecha fin
    if (fechaInicio!.isAfter(fechaFin!) ||
        fechaInicio!.isAtSameMomentAs(fechaFin!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("La fecha de inicio debe ser menor a la fecha de fin"),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );

      // Limpia habitaciones para evitar mostrar resultados inválidos
      Provider.of<ReservacionController>(
        context,
        listen: false,
      ).clearHabitaciones();
      return;
    }
    final controller = Provider.of<ReservacionController>(
      context,
      listen: false,
    );
    controller.fetchDisponibles(
      fechaInicio!.toIso8601String(),
      fechaFin!.toIso8601String(),
    );
  }

  void _reservarHabitacion(int idHabitacion) async {
    print("Ejecutando reservar habitación");

    final controller = Provider.of<ReservacionController>(
      context,
      listen: false,
    );

    print("Controller obtenido");

    print("Fechas: $fechaInicio / $fechaFin");

    final duracion = fechaFin!.difference(fechaInicio!).inDays;

    final reservaData = {
      'habitacion_area_id': idHabitacion,
      'fecha_reserva': fechaInicio!.toIso8601String(),
      'fecha_salida': fechaFin!.toIso8601String(),
      'duracion': duracion,
      'id_estatus': 1,
    };

    print("ReservaData: $reservaData");

    final ok = await controller.createReserva(reservaData);

    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Reservación creada con éxito 🎉"),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );

      // Opcional: regresar a la pantalla anterior
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Error al crear la reservación"),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }
}

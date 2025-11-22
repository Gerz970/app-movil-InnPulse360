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
                      child: CircularProgressIndicator(color: Color(0xFF667eea)),
                    );
                  }

                  if (controller.habitaciones.isEmpty) {
                    return const Center(
                      child: Text("Selecciona fechas para ver disponibilidad"),
                    );
                  }

                  return ListView.builder(
                    itemCount: controller.habitaciones.length,
                    itemBuilder: (context, index) {
                      return _buildHabitacionCard(controller.habitaciones[index]);
                    },
                  );
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
              date == null ? label : "$label: ${date.toString().substring(0, 10)}",
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
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
            Text(h.nombreClave, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Text(h.descripcion, style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 12),

            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                onPressed: () {
                  print("Reservar habitación ${h.idHabitacionArea}");
                  // Aquí harías la llamada a reservar
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF667eea),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
                child: const Text(
                  "Reservar",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  void _tryLoadDisponibles() {
    if (fechaInicio != null && fechaFin != null) {
      final controller = Provider.of<ReservacionController>(context, listen: false);
      controller.fetchDisponibles(
        fechaInicio!.toIso8601String(),
        fechaFin!.toIso8601String(),
      );
    }
  }
}

import 'package:app_movil_innpulse/features/reservas/reservas_create_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import './controllers/reservas_controller.dart';
import './models/reservas_model.dart';
import '../../widgets/app_header.dart';
import '../../widgets/app_sidebar.dart';

class ReservacionesListScreen extends StatefulWidget {
  const ReservacionesListScreen({super.key});

  @override
  State<ReservacionesListScreen> createState() =>
      _ReservacionesListScreenState();
}

class _ReservacionesListScreenState extends State<ReservacionesListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final controller = Provider.of<ReservacionController>(
          context,
          listen: false,
        );
        controller.fetchReservaciones();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppSidebar(),
      backgroundColor: Colors.white,

      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: ElevatedButton(
          onPressed: () {
              Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const NuevaReservaScreen()),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF667eea),
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Text(
            "Nueva reserva",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ),

      body: SafeArea(
        child: Column(
          children: [
            const AppHeader(),
            Expanded(
              child: Consumer<ReservacionController>(
                builder: (context, controller, child) {
                  if (controller.isLoading) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF667eea),
                      ),
                    );
                  }

                  if (controller.errorMessage != null) {
                    return Center(child: Text(controller.errorMessage!));
                  }

                  if (controller.reservaciones.isEmpty) {
                    return const Center(
                      child: Text("No hay reservaciones para este cliente."),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: controller.reservaciones.length,
                    itemBuilder: (context, index) {
                      return _buildReservacionCard(
                        controller.reservaciones[index],
                      );
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

  Widget _buildReservacionCard(Reservacion r) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: const Color(0xFF667eea).withOpacity(0.2),
                  child: const Icon(
                    Icons.bed,
                    color: Color(0xFF667eea),
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    r.habitacion.nombreClave,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1a1a1a),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              r.habitacion.descripcion,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 12),

            Row(
              children: [
                const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                const SizedBox(width: 6),
                Text("Entrada: ${r.fechaReserva.substring(0, 10)}"),
                const SizedBox(width: 16),
                const Icon(Icons.logout, size: 16, color: Colors.grey),
                const SizedBox(width: 6),
                Text("Salida: ${r.fechaSalida.substring(0, 10)}"),
              ],
            ),
            const SizedBox(height: 10),

            Row(
              children: [
                const Icon(Icons.timer, size: 16, color: Colors.grey),
                const SizedBox(width: 6),
                Text("Duración: ${r.duracion} días"),
              ],
            ),
            const SizedBox(height: 10),

            _buildStatusBadge(r.idEstatus),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(int status) {
    final isActive = status == 1;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isActive ? Colors.green.shade50 : Colors.red.shade50,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isActive ? Icons.check_circle : Icons.cancel,
            size: 14,
            color: isActive ? Colors.green : Colors.red,
          ),
          const SizedBox(width: 4),
          Text(
            isActive ? "Activa" : "Inactiva",
            style: TextStyle(
              fontSize: 12,
              color: isActive ? Colors.green : Colors.red,
            ),
          ),
        ],
      ),
    );
  }
}

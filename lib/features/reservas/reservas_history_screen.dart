import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import './controllers/reservas_controller.dart';
import './models/reservas_model.dart';
import '../../widgets/app_header.dart';
import '../../widgets/app_sidebar.dart';

/// Pantalla que muestra el historial de reservaciones (reservaciones inactivas/canceladas)
class ReservasHistoryScreen extends StatefulWidget {
  const ReservasHistoryScreen({super.key});

  @override
  State<ReservasHistoryScreen> createState() => _ReservasHistoryScreenState();
}

class _ReservasHistoryScreenState extends State<ReservasHistoryScreen> {
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

                  // Filtrar reservaciones inactivas (idEstatus != 1)
                  final historialReservaciones = controller.reservaciones
                      .where((r) => r.idEstatus != 1)
                      .toList();

                  if (historialReservaciones.isEmpty) {
                    return const Center(
                      child: Text("No hay historial de reservaciones."),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: historialReservaciones.length,
                    itemBuilder: (context, index) {
                      return _buildReservacionCard(
                        historialReservaciones[index],
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
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Column(
          children: [
            Stack(
              children: [
                SizedBox(
                  height: 140,
                  width: double.infinity,
                  child: Image.network(
                    r.imagenUrl.isEmpty
                        ? "https://2.bp.blogspot.com/-9e1ZZEaTv8w/XJTrxHzY9YI/AAAAAAAADSk/3tOUwztxkmoP9iVMYeGlGhf9wXxezHrYACLcBGAs/s1600/habitaciones-minimalista-2019-26.jpg"
                        : r.imagenUrl,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned.fill(
                  child: Container(
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
                Positioned(
                  left: 16,
                  right: 16,
                  bottom: 12,
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 24,
                        backgroundColor: Colors.white.withOpacity(0.8),
                        child: const Icon(
                          Icons.bed,
                          color: Color(0xFF667eea),
                          size: 26,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Text(
                          r.habitacion.nombreClave,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    r.habitacion.descripcion,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(
                        Icons.calendar_today,
                        size: 16,
                        color: Colors.grey,
                      ),
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
                  const SizedBox(height: 12),
                  _buildStatusBadge(r.idEstatus),
                ],
              ),
            ),
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


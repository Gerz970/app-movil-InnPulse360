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
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Column(
          children: [
            /// ---------------------------
            /// ENCABEZADO VISUAL CON IMAGEN
            /// ---------------------------
            Stack(
              children: [
                // IMAGEN DE HABITACIÓN (si tienes url)
                SizedBox(
                  height: 140,
                  width: double.infinity,
                  child: Image.network(
                    r.imagenUrl ??
                        "https://2.bp.blogspot.com/-9e1ZZEaTv8w/XJTrxHzY9YI/AAAAAAAADSk/3tOUwztxkmoP9iVMYeGlGhf9wXxezHrYACLcBGAs/s1600/habitaciones-minimalista-2019-26.jpg",
                    fit: BoxFit.cover,
                  ),
                ),

                // DEGRADADO OSCURO PARA TEXTO LEGIBLE
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

                // CONTENIDO ENCIMA DE LA IMAGEN
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

                      /// Nombre habitación
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

                      /// Menú opciones
                      PopupMenuButton<String>(
                        color: Colors.white,
                        icon: const Icon(Icons.more_vert, color: Colors.white),
                        onSelected: (value) {
                          if (value == 'cancelar') {
                            _cancelarReserva(r.idReservacion);
                          }
                        },
                        itemBuilder: (context) => [
                          if (r.idEstatus == 1)
                            const PopupMenuItem(
                              value: 'cancelar',
                              child: Text("Cancelar reserva"),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),

            /// ---------------------------
            /// CONTENIDO INFERIOR DEL CARD
            /// ---------------------------
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

  Future<void> _cancelarReserva(int idReserva) async {
    final controller = Provider.of<ReservacionController>(
      context,
      listen: false,
    );

    // Diálogo de confirmación
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancelar reservación'),
        content: const Text('¿Seguro que deseas cancelar esta reservación?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('No'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Sí, cancelar'),
          ),
        ],
      ),
    );

    if (confirmar != true) return;

    final ok = await controller.cancelarReserva(idReserva);

    if (!context.mounted) return;

    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Reservación cancelada correctamente"),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );

      controller.fetchReservaciones(); // recarga la lista
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error al cancelar: ${controller.errorMessage ?? ''}"),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }
}

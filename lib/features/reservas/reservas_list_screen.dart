import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import './controllers/reservas_controller.dart';
import './models/reservas_model.dart';
import './reservas_detail_screen.dart';
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

                  // Filtrar solo reservaciones activas
                  final reservacionesActivas = controller.reservaciones
                      .where((r) => r.idEstatus == 1)
                      .toList();

                  if (reservacionesActivas.isEmpty) {
                    return const Center(
                      child: Text("No hay reservaciones activas."),
                    );
                  }

                  return GridView.builder(
                    padding: const EdgeInsets.all(12),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 0.7,
                    ),
                    itemCount: reservacionesActivas.length,
                    itemBuilder: (context, index) {
                      return _buildReservacionCard(
                        reservacionesActivas[index],
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
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Imagen clickeable
          InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ReservasDetailScreen(reservacion: r),
                ),
              );
            },
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              child: AspectRatio(
                aspectRatio: 1.1,
                child: Image.network(
                  r.imagenUrl.isEmpty
                      ? "https://2.bp.blogspot.com/-9e1ZZEaTv8w/XJTrxHzY9YI/AAAAAAAADSk/3tOUwztxkmoP9iVMYeGlGhf9wXxezHrYACLcBGAs/s1600/habitaciones-minimalista-2019-26.jpg"
                      : r.imagenUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey[200],
                      child: const Icon(
                        Icons.bed,
                        color: Color(0xFF667eea),
                        size: 32,
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
          // Contenido
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Nombre de habitación
                  Text(
                    r.habitacion.nombreClave,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  // Código de reservación
                  if (r.codigoReservacion != null && r.codigoReservacion!.isNotEmpty)
                    Flexible(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFF667eea).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          r.codigoReservacion!,
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF667eea),
                            letterSpacing: 0.5,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  const SizedBox(height: 6),
                  // Cantidad (duración)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.timer,
                        size: 12,
                        color: Color(0xFF667eea),
                      ),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          "${r.duracion} días",
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: Colors.black87,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

}

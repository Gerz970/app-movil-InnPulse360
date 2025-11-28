import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import './controllers/reservas_controller.dart';
import './models/reservas_model.dart';
import './reservas_detail_screen.dart';
import '../../widgets/app_header.dart';
import '../../widgets/app_sidebar.dart';
import '../../core/theme/app_theme.dart';

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
      backgroundColor: AppColors.background,
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
                        color: AppColors.primary,
                      ),
                    );
                  }

                  if (controller.errorMessage != null) {
                    return Center(
                      child: Text(
                        controller.errorMessage!,
                        style: AppTextStyles.bodyLarge,
                      ),
                    );
                  }

                  if (controller.reservaciones.isEmpty) {
                    return Center(
                      child: Text(
                        "No hay reservaciones para este cliente.",
                        style: AppTextStyles.bodyMedium,
                      ),
                    );
                  }

                  // Filtrar solo reservaciones activas
                  final reservacionesActivas = controller.reservaciones
                      .where((r) => r.idEstatus == 1)
                      .toList();

                  if (reservacionesActivas.isEmpty) {
                    return Center(
                      child: Text(
                        "No hay reservaciones activas.",
                        style: AppTextStyles.bodyMedium,
                      ),
                    );
                  }

                  return GridView.builder(
                    padding: AppSpacing.allMd,
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
      shape: RoundedRectangleBorder(borderRadius: AppRadius.mdBorder),
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
            borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.md)),
            child: ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.md)),
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
                      child: Icon(
                        Icons.bed,
                        color: AppColors.primary,
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
              padding: AppSpacing.allSm,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Nombre de habitación
                  Text(
                    r.habitacion.nombreClave,
                    style: AppTextStyles.bodySmall.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: AppSpacing.xs),
                  // Código de reservación
                  if (r.codigoReservacion != null && r.codigoReservacion!.isNotEmpty)
                    Flexible(
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          r.codigoReservacion!,
                          style: AppTextStyles.caption.copyWith(
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                            letterSpacing: 0.5,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  SizedBox(height: 6),
                  // Cantidad (duración)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.timer,
                        size: 12,
                        color: AppColors.primary,
                      ),
                      SizedBox(width: AppSpacing.xs),
                      Flexible(
                        child: Text(
                          "${r.duracion} días",
                          style: AppTextStyles.bodySmall.copyWith(
                            fontWeight: FontWeight.w500,
                            color: AppColors.textPrimary,
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

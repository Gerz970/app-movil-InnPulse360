import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../widgets/app_header.dart';
import '../../widgets/app_sidebar.dart';
import 'controllers/incidencia_controller.dart';
import 'incidencia_edit_screen.dart';

/// Pantalla para mostrar el detalle completo de una incidencia
/// Muestra todos los campos en modo solo lectura y la galería de fotos
class IncidenciaDetailScreen extends StatefulWidget {
  final int incidenciaId;

  const IncidenciaDetailScreen({
    required this.incidenciaId,
    super.key,
  });

  @override
  State<IncidenciaDetailScreen> createState() => _IncidenciaDetailScreenState();
}

class _IncidenciaDetailScreenState extends State<IncidenciaDetailScreen> {
  @override
  void initState() {
    super.initState();
    // Cargar detalle y galería al iniciar
    // Hacer las peticiones de forma secuencial para evitar conflictos
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (mounted) {
        final controller = Provider.of<IncidenciaController>(context, listen: false);
        // Primero cargar el detalle
        await controller.loadIncidenciaDetail(widget.incidenciaId);
        // Esperar un momento antes de cargar la galería
        await Future.delayed(const Duration(milliseconds: 300));
        // Luego cargar la galería
        if (mounted) {
          await controller.fetchGaleria(widget.incidenciaId);
        }
      }
    });
  }

  /// Formatear fecha para mostrar
  String _formatDate(DateTime date) {
    // Formatear fecha manualmente sin dependencia externa
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '$day/$month/$year $hour:$minute';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      drawer: const AppSidebar(),
      body: SafeArea(
        child: Column(
          children: [
            // Header global reutilizable
            const AppHeader(),
            // Contenido principal
            Expanded(
              child: Consumer<IncidenciaController>(
                builder: (context, controller, child) {
                  // Estado de carga de detalle
                  if (controller.isLoadingDetail) {
                    return const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(
                            color: Color(0xFF667eea),
                          ),
                          SizedBox(height: 16),
                          Text(
                            'Cargando incidencia...',
                            style: TextStyle(
                              fontSize: 16,
                              color: Color(0xFF6b7280),
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  // Estado de error al cargar detalle
                  if (controller.detailErrorMessage != null) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.error_outline,
                              size: 64,
                              color: Colors.red.shade300,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              controller.detailErrorMessage ?? 'Error desconocido',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF1a1a1a),
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 24),
                            ElevatedButton(
                              onPressed: () {
                                controller.loadIncidenciaDetail(widget.incidenciaId);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF667eea),
                                foregroundColor: Colors.white,
                              ),
                              child: const Text('Reintentar'),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  // Si no hay detalle cargado
                  if (controller.incidenciaDetail == null) {
                    return const Center(
                      child: Text(
                        'No se pudo cargar el detalle de la incidencia',
                        style: TextStyle(
                          fontSize: 16,
                          color: Color(0xFF6b7280),
                        ),
                      ),
                    );
                  }

                  final incidencia = controller.incidenciaDetail!;

                  // Contenido principal con scroll
                  return SingleChildScrollView(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Título de la pantalla
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.arrow_back),
                              onPressed: () => Navigator.pop(context),
                              color: const Color(0xFF1a1a1a),
                            ),
                            const Expanded(
                              child: Text(
                                'Detalle de Incidencia',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1a1a1a),
                                  letterSpacing: -0.5,
                                ),
                              ),
                            ),
                            // Botón Editar
                            ElevatedButton.icon(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => IncidenciaEditScreen(
                                      incidenciaId: widget.incidenciaId,
                                    ),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.edit, size: 18),
                              label: const Text('Editar'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF667eea),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 32),
                        // Información de la incidencia
                        _buildInfoCard(
                          'Título',
                          incidencia.incidencia,
                          Icons.title,
                        ),
                        const SizedBox(height: 16),
                        _buildInfoCard(
                          'Descripción',
                          incidencia.descripcion,
                          Icons.description,
                        ),
                        const SizedBox(height: 16),
                        _buildInfoCard(
                          'Fecha de Incidencia',
                          _formatDate(incidencia.fechaIncidencia),
                          Icons.calendar_today,
                        ),
                        const SizedBox(height: 16),
                        _buildInfoCard(
                          'Habitación/Área',
                          incidencia.habitacionArea?.nombreClave ??
                          'Habitación ${incidencia.habitacionAreaId}',
                          Icons.room,
                        ),
                        const SizedBox(height: 16),
                        _buildInfoCard(
                          'Estatus',
                          incidencia.idEstatus == 1 ? 'Activo' : 'Inactivo',
                          Icons.check_circle,
                          statusColor: incidencia.idEstatus == 1 
                              ? Colors.green 
                              : Colors.red,
                        ),
                        const SizedBox(height: 32),
                        // Galería de fotos
                        _buildGallerySection(controller),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Widget para construir una card de información
  Widget _buildInfoCard(String label, String value, IconData icon, {Color? statusColor}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFe5e7eb),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: statusColor ?? const Color(0xFF667eea),
            size: 24,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF6b7280),
                    letterSpacing: 0.2,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: statusColor ?? const Color(0xFF1a1a1a),
                    letterSpacing: -0.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Widget para construir la sección de galería
  Widget _buildGallerySection(IncidenciaController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(
              Icons.photo_library,
              color: Color(0xFF667eea),
              size: 24,
            ),
            SizedBox(width: 8),
            Text(
              'Galería de Fotos',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1a1a1a),
                letterSpacing: -0.5,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        // Estado de carga de galería
        if (controller.isLoadingGaleria)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(32.0),
              child: CircularProgressIndicator(
                color: Color(0xFF667eea),
              ),
            ),
          )
        // Estado vacío
        else if (controller.galeriaImagenes.isEmpty)
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFFe5e7eb),
                width: 1,
              ),
            ),
            child: const Center(
              child: Column(
                children: [
                  Icon(
                    Icons.photo_library_outlined,
                    size: 48,
                    color: Color(0xFF9ca3af),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'No hay fotos disponibles',
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF6b7280),
                    ),
                  ),
                ],
              ),
            ),
          )
        // Grid de fotos
        else
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.zero,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1,
            ),
            itemCount: controller.galeriaImagenes.length,
            itemBuilder: (context, index) {
              final imagen = controller.galeriaImagenes[index];
              return ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: CachedNetworkImage(
                  imageUrl: imagen.urlPublica,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    color: Colors.grey.shade200,
                    child: const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF667eea),
                      ),
                    ),
                  ),
                  errorWidget: (context, url, error) => Container(
                    color: Colors.grey.shade200,
                    child: const Icon(
                      Icons.error_outline,
                      color: Colors.red,
                      size: 40,
                    ),
                  ),
                ),
              );
            },
          ),
      ],
    );
  }
}


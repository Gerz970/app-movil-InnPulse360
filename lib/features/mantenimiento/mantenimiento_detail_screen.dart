import 'package:app_movil_innpulse/features/mantenimiento/controllers/mantenimiento_controller.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'models/mantenimiento_model.dart';
import '../../widgets/app_sidebar.dart';
import '../../widgets/app_header.dart';
import 'package:provider/provider.dart';

class MantenimientoDetailScreen extends StatefulWidget {
  final Mantenimiento mantenimiento;

  const MantenimientoDetailScreen({
    super.key,
    required this.mantenimiento,
  });

  @override
  State<MantenimientoDetailScreen> createState() =>
      _MantenimientoDetailScreenState();
}

class _MantenimientoDetailScreenState
    extends State<MantenimientoDetailScreen> {
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();

    // Carga la galería al abrir la pantalla
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final controller =
          Provider.of<MantenimientoController>(context, listen: false);

      controller.fetchGaleria(widget.mantenimiento.idMantenimiento);
    });
  }

  // ---------------------------
  //     SUBIR FOTO
  // ---------------------------
  Future<void> _elegirFoto(BuildContext context) async {
    final controller =
        Provider.of<MantenimientoController>(context, listen: false);

    final XFile? foto = await _picker.pickImage(source: ImageSource.camera);

    if (foto == null) return;

    final success = await controller.uploadPhoto(
      widget.mantenimiento.idMantenimiento,
      foto.path,
    );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Foto subida con éxito")),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text(controller.uploadPhotoError ?? "Error al subir foto"),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final estatusColor = const Color(0xFF22c55e);

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      drawer: const AppSidebar(),
      body: SafeArea(
        child: Column(
          children: [
            const AppHeader(),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildBackButton(context),
                    const SizedBox(height: 16),

                    const Text(
                      'Detalle del Mantenimiento',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1a1a1a),
                        letterSpacing: -0.5,
                      ),
                    ),

                    const SizedBox(height: 20),

                    _buildDetalleMantenimientoCard(
                      context,
                      widget.mantenimiento,
                      estatusColor,
                    ),

                    const SizedBox(height: 30),

                    // ---------------------------
                    //   BOTÓN SUBIR FOTO
                    // ---------------------------
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF6366f1),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () => _elegirFoto(context),
                        icon: const Icon(Icons.camera_alt_rounded,
                            color: Colors.white),
                        label: const Text(
                          "Subir Foto",
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 30),

                    // ---------------------------
                    //   GALERÍA
                    // ---------------------------
                    _buildGaleria(),

                    const SizedBox(height: 30),

                    // ---------------------------
                    //   BOTÓN FINALIZAR
                    // ---------------------------
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF22c55e),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () {},
                        child: const Text(
                          "Marcar como finalizada",
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ------------------------------
  //     CARD PRINCIPAL
  // ------------------------------
  Widget _buildDetalleMantenimientoCard(
    BuildContext context,
    Mantenimiento mantenimiento,
    Color estatusColor,
  ) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [estatusColor.withOpacity(0.1), Colors.white],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: estatusColor.withOpacity(0.2), width: 1.5),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: estatusColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.build_rounded,
                    color: estatusColor, size: 28),
              ),
              const SizedBox(width: 16),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Detalle de Mantenimiento',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      mantenimiento.descripcion,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1a1a1a),
                        letterSpacing: -0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          Row(
            children: [
              Expanded(
                child: _buildInfoCard(
                  Icons.calendar_today_rounded,
                  'Fecha',
                  mantenimiento.fechaFormateada,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildInfoCard(
                  Icons.build_circle_rounded,
                  'Tipo',
                  'No especificado',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ------------------------------
  //     BOTÓN BACK
  // ------------------------------
  Widget _buildBackButton(BuildContext context) {
    return InkWell(
      onTap: () => Navigator.pop(context),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200, width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.arrow_back_rounded,
                color: Colors.grey.shade700, size: 20),
            const SizedBox(width: 8),
            Text(
              'Regresar al listado',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ------------------------------
  //     INFO CARD
  // ------------------------------
  Widget _buildInfoCard(IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: Colors.grey.shade600),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1a1a1a),
            ),
          ),
        ],
      ),
    );
  }

  // ------------------------------
  //     GALERÍA
  // ------------------------------
  Widget _buildGaleria() {
    return Consumer<MantenimientoController>(
      builder: (context, controller, child) {
        if (controller.isLoading) {
          return Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child:
                  CircularProgressIndicator(color: Color(0xFF667eea)),
            ),
          );
        }

        if (controller.galeriaImagenes.isEmpty) {
          return const SizedBox.shrink();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF667eea).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.photo_library_rounded,
                    color: Color(0xFF667eea),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Galería de Fotos',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1a1a1a),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: controller.galeriaImagenes.length,
              itemBuilder: (context, index) {
                final foto = controller.galeriaImagenes[index];

                return GestureDetector(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (_) => Dialog(
                        child:
                            Image.network(foto.ruta, fit: BoxFit.contain),
                      ),
                    );
                  },
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      foto.ruta,
                      fit: BoxFit.cover,
                    ),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }
}

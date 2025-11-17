import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../widgets/app_header.dart';
import '../../widgets/app_sidebar.dart';
import '../hoteles/controllers/hotel_controller.dart';
import 'controllers/piso_controller.dart';
import 'models/piso_model.dart';
import 'piso_create_screen.dart';

class PisosListScreen extends StatefulWidget {
  const PisosListScreen({super.key});

  @override
  State<PisosListScreen> createState() => _PisosListScreenState();
}

class _PisosListScreenState extends State<PisosListScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final pisoController = Provider.of<PisoController>(context, listen: false);
      pisoController.cargarPisosPorHotel(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      drawer: const AppSidebar(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {

        },
        backgroundColor: const Color(0xFF667eea),
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
      body: SafeArea(
        child: Column(
          children: [
            const AppHeader(),
            Expanded(
              child: Consumer<PisoController>(
                builder: (context, controller, child) {
                  if (controller.isLoading) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF667eea),
                      ),
                    );
                  }

                  if (controller.error != null) {
                    return _buildErrorState(context, controller);
                  }

                  if (controller.pisos.isEmpty) {
                    return _buildEmptyState();
                  }

                  return _buildPisosList(controller);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// ------------------------------
  ///  ESTADO: ERROR
  /// ------------------------------
  Widget _buildErrorState(BuildContext context, PisoController controller) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red.shade300),
            const SizedBox(height: 16),
            Text(
              controller.error!,
              style: const TextStyle(fontSize: 16, color: Color(0xFF1a1a1a)),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                controller.cargarPisosPorHotel(context);
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

  /// ------------------------------
  ///  ESTADO: VACÍO
  /// ------------------------------
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.layers_outlined,
            size: 80,
            color: const Color(0xFF667eea).withOpacity(0.3),
          ),
          const SizedBox(height: 24),
          const Text(
            'Aún no hay pisos registrados para este hotel',
            style: TextStyle(
              fontSize: 18,
              color: Color(0xFF6b7280),
            ),
          ),
        ],
      ),
    );
  }

  /// ------------------------------
  ///  LISTA DE PISOS
  /// ------------------------------
  Widget _buildPisosList(PisoController controller) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: controller.pisos.length,
      itemBuilder: (context, index) {
        final piso = controller.pisos[index];
        return _buildPisoCard(piso);
      },
    );
  }

  /// ------------------------------
  ///  CARD DE PISO
  /// ------------------------------
  Widget _buildPisoCard(Piso piso) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 2,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {}, // puedes abrir detalle si lo deseas
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF667eea).withOpacity(0.1),
                ),
                child: const Icon(
                  Icons.layers,
                  color: Color(0xFF667eea),
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      piso.nombre,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1a1a1a),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Nivel: ${piso.nivel}",
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF6b7280),
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
  }
}

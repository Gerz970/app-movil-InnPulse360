import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import './controllers/mantenimiento_controller.dart';
import './models/mantenimiento_model.dart';
import '../../widgets/app_header.dart';
import '../../widgets/app_sidebar.dart';
import '../login/login_screen.dart';
import 'mantenimiento_detail_screen.dart';

class MantenimientosListScreen extends StatefulWidget {
  const MantenimientosListScreen({super.key});

  @override
  State<MantenimientosListScreen> createState() =>
      _MantenimientosListScreenState();
}

class _MantenimientosListScreenState extends State<MantenimientosListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<MantenimientoController>(
        context,
        listen: false,
      ).fetchMantenimientos();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppSidebar(),
      body: SafeArea(
        child: Column(
          children: [
            const AppHeader(),
            Expanded(
              child: Consumer<MantenimientoController>(
                builder: (_, controller, __) {
                  if (controller.isLoading) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF667eea),
                      ),
                    );
                  }

                  if (controller.errorMessage != null) {
                    return _buildError(controller);
                  }

                  if (controller.isEmpty) {
                    return _buildEmpty();
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 16),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          'Mis mantenimientos',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1a1a1a),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          'Mantenimientos asignados a ti',
                          style: TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                      ),

                      const SizedBox(height: 12),

                      // La lista debe estar dentro de Expanded
                      Expanded(child: _buildList(controller)),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Estado de error
  Widget _buildError(MantenimientoController controller) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 12),
          Text(controller.errorMessage!, textAlign: TextAlign.center),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              controller.fetchMantenimientos();
            },
            child: const Text("Reintentar"),
          ),
          if (controller.isNotAuthenticated)
            TextButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                );
              },
              child: const Text("Reautenticar"),
            ),
        ],
      ),
    );
  }

  // Estado vacío
  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.home_repair_service, size: 80, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            "¡No hay mantenimientos para tí el día de hoy. Disfruta tu día!",
          ),
        ],
      ),
    );
  }

  // Lista
  Widget _buildList(MantenimientoController controller) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: controller.mantenimientos.length,
      itemBuilder: (_, index) =>
          _buildMantenimientoCard(controller.mantenimientos[index]),
    );
  }

  Widget _buildMantenimientoCard(Mantenimiento m) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => MantenimientoDetailScreen(mantenimiento: m),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // -------- HEADER (Estatus) ----------
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Badge de estatus
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: _estatusColor(m.estatus).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: _estatusColor(m.estatus).withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      _estatusTexto(m.estatus),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: _estatusColor(m.estatus),
                      ),
                    ),
                  ),

                  // Tipo (si no tienes tipo, puedes dejar esto o eliminarlo)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      "Mantenimiento",
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // -------- DESCRIPCIÓN PRINCIPAL ----------
              Row(
                children: [
                  Icon(Icons.build, size: 20, color: Colors.grey[600]),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      m.descripcion,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1a1a1a),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // -------- FECHAS ----------
              Row(
                children: [
                  Expanded(
                    child: _buildFechaInfo(
                      Icons.calendar_today,
                      'Programado',
                      m.fechaFormateada,
                    ),
                  ),
                  if (m.fechaTermino != null)
                    Expanded(
                      child: _buildFechaInfo(
                        Icons.check_circle,
                        'Terminado',
                        m.fechaFormateada ?? '',
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFechaInfo(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 6),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF1a1a1a),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

String _estatusTexto(int estatus) {
  switch (estatus) {
    case 0:
      return "Pendiente";
    case 1:
      return "Pendiente";
    case 2:
      return "Terminado";
    default:
      return "Desconocido";
  }
}

Color _estatusColor(int estatus) {
  switch (estatus) {
    case 0:
      return Colors.orange;
    case 1:
      return Colors.orange;
    case 2:
      return Colors.green;
    default:
      return Colors.grey;
  }
}

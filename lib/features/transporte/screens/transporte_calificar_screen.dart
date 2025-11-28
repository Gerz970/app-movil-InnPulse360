import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/transporte_controller.dart';
import '../models/servicio_transporte_model.dart';
import 'transporte_calificar_detail_screen.dart';

class TransporteCalificarScreen extends StatefulWidget {
  const TransporteCalificarScreen({super.key});

  @override
  State<TransporteCalificarScreen> createState() => _TransporteCalificarScreenState();
}

class _TransporteCalificarScreenState extends State<TransporteCalificarScreen> {
  @override
  void initState() {
    super.initState();
    // Cargar servicios al iniciar si no están cargados
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final controller = Provider.of<TransporteController>(context, listen: false);
      if (controller.servicios.isEmpty) {
        controller.fetchServicios();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TransporteController>(
      builder: (context, controller, _) {
        if (controller.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.error != null) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
                  const SizedBox(height: 16),
                  Text(
                    'Error: ${controller.error}',
                    style: const TextStyle(fontSize: 16, color: Color(0xFF1a1a1a)),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => controller.fetchServicios(),
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

        // Filtrar servicios pendientes por calificar
        final serviciosPendientes = controller.getServiciosPendientesPorCalificar();

        if (serviciosPendientes.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.star_outline,
                  size: 64,
                  color: Colors.grey.shade300,
                ),
                const SizedBox(height: 16),
                Text(
                  'No tienes viajes pendientes por calificar',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () => controller.fetchServicios(),
          color: const Color(0xFF667eea),
          child: Column(
            children: [
              // Título de la sección
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border(
                    bottom: BorderSide(color: Colors.grey.shade200),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(Icons.star_outline, color: Colors.amber[700], size: 24),
                    const SizedBox(width: 8),
                    const Text(
                      'Pendientes por Calificar',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1a1a1a),
                      ),
                    ),
                  ],
                ),
              ),
              // Lista de viajes
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: serviciosPendientes.length,
                  itemBuilder: (context, index) {
                    final servicio = serviciosPendientes[index];
                    return _buildServicioCard(servicio);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildServicioCard(ServicioTransporteModel servicio) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TransporteCalificarDetailScreen(servicio: servicio),
            ),
          ).then((_) {
            // Recargar servicios al volver para actualizar la lista
            final controller = Provider.of<TransporteController>(context, listen: false);
            controller.fetchServicios();
          });
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    servicio.fechaServicio.toString().split(' ')[0],
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.amber.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.amber.shade300),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.star_outline, size: 14, color: Colors.amber[700]),
                        const SizedBox(width: 4),
                        Text(
                          'Pendiente',
                          style: TextStyle(
                            color: Colors.amber[700],
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.location_on, color: Colors.red, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      servicio.destino,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              if (servicio.direccionOrigen != null) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.my_location, color: Colors.green, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        servicio.direccionOrigen!,
                        style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
              if (servicio.distanciaKm != null) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.directions_car, color: Colors.grey.shade500, size: 16),
                    const SizedBox(width: 8),
                    Text(
                      '${servicio.distanciaKm!.toStringAsFixed(1)} km',
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '\$${servicio.costoViaje.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Color(0xFF667eea),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF667eea),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.star, color: Colors.white, size: 16),
                        SizedBox(width: 4),
                        Text(
                          'Calificar',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
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
}


import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/transporte_controller.dart';
import '../models/servicio_transporte_model.dart';
import 'transporte_detail_screen.dart';

class TransporteListScreen extends StatefulWidget {
  final bool mostrarActivos;
  const TransporteListScreen({super.key, this.mostrarActivos = true});

  @override
  State<TransporteListScreen> createState() => _TransporteListScreenState();
}

class _TransporteListScreenState extends State<TransporteListScreen> {
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
    // Remover Scaffold - ahora el Scaffold principal está en TransporteMainScreen
    return Consumer<TransporteController>(
      builder: (context, controller, _) {
        if (controller.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.error != null) {
          return Center(child: Text('Error: ${controller.error}'));
        }

        // Filtrar servicios según la pestaña
        final serviciosFiltrados = controller.servicios.where((s) {
          // Asumimos: 1 = Activo, 2 = Completado/Cancelado
          // Ajustar lógica según valores reales de idEstatus
          if (widget.mostrarActivos) {
            return s.idEstatus == 1;
          } else {
            return s.idEstatus != 1;
          }
        }).toList();

        if (serviciosFiltrados.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  widget.mostrarActivos ? Icons.directions_car : Icons.history,
                  size: 64,
                  color: Colors.grey.shade300,
                ),
                const SizedBox(height: 16),
                Text(
                  widget.mostrarActivos 
                      ? 'No tienes viajes activos' 
                      : 'No tienes historial de viajes',
                  style: TextStyle(color: Colors.grey.shade600),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () => controller.fetchServicios(),
          child: Column(
            children: [
              // Título de la sección (reemplaza el AppBar)
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
                    Text(
                      widget.mostrarActivos ? 'Viajes Solicitados' : 'Historial de Viajes',
                      style: const TextStyle(
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
                  itemCount: serviciosFiltrados.length,
                  itemBuilder: (context, index) {
                    final servicio = serviciosFiltrados[index];
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
              builder: (context) => TransporteDetailScreen(servicio: servicio),
            ),
          );
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
                      color: servicio.idEstatus == 1 ? Colors.blue.shade50 : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      servicio.idEstatus == 1 ? 'Activo' : 'Finalizado',
                      style: TextStyle(
                        color: servicio.idEstatus == 1 ? Colors.blue.shade700 : Colors.grey.shade700,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
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
              if (servicio.distanciaKm != null) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.directions_car, color: Colors.grey.shade500, size: 16),
                    const SizedBox(width: 8),
                    Text(
                      '${servicio.distanciaKm} km',
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    '\$${servicio.costoViaje.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Color(0xFF667eea),
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

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/auth/services/session_storage.dart';
import '../controllers/transporte_controller.dart';
import 'transportista_detail_screen.dart';

class TransportistaScreen extends StatefulWidget {
  const TransportistaScreen({super.key});

  @override
  State<TransportistaScreen> createState() => _TransportistaScreenState();
}

class _TransportistaScreenState extends State<TransportistaScreen> {
  int? _empleadoId;

  @override
  void initState() {
    super.initState();
    _cargarServicios();
  }

  Future<void> _cargarServicios() async {
    final session = await SessionStorage.getSession();
    if (session != null) {
      final usuario = session['usuario'] as Map<String, dynamic>?;
      
      // Intentar obtener empleado_id de varias formas
      int? empId;
      if (usuario != null) {
        empId = usuario['empleado_id'] as int? ?? usuario['empleadoId'] as int?;
      }
      if (empId == null) {
        empId = session['empleado_id'] as int? ?? session['empleadoId'] as int?;
      }

      if (empId != null) {
        setState(() {
          _empleadoId = empId;
        });
        if (mounted) {
          Provider.of<TransporteController>(context, listen: false)
              .fetchServiciosConductor(empId);
        }
      } else {
        print("⚠️ No se pudo encontrar el empleado_id en la sesión");
      }
    }
  }

  Color _getStatusColor(int? status) {
    switch (status) {
      case 1: // Pendiente
        return Colors.orange;
      case 2: // Aceptado
        return Colors.blue;
      case 3: // En curso
        return Colors.green;
      case 4: // Terminado
        return Colors.grey;
      case 0: // Cancelado
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(int? status) {
    switch (status) {
      case 1:
        return "Pendiente";
      case 2:
        return "Aceptado";
      case 3:
        return "En curso";
      case 4:
        return "Terminado";
      case 0:
        return "Cancelado";
      default:
        return "Desconocido";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Viajes Asignados'),
      ),
      body: Consumer<TransporteController>(
        builder: (context, controller, child) {
          if (controller.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (controller.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Error: ${controller.error}'),
                  ElevatedButton(
                    onPressed: () {
                      if (_empleadoId != null) {
                        controller.fetchServiciosConductor(_empleadoId!);
                      }
                    },
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            );
          }

          final servicios = controller.servicios;

          if (servicios.isEmpty) {
            return const Center(child: Text('No tienes viajes asignados.'));
          }

          return RefreshIndicator(
            onRefresh: () async {
              if (_empleadoId != null) {
                await controller.fetchServiciosConductor(_empleadoId!);
              }
            },
            child: ListView.builder(
              itemCount: servicios.length,
              padding: const EdgeInsets.all(16),
              itemBuilder: (context, index) {
                final servicio = servicios[index];
                return Card(
                  elevation: 3,
                  margin: const EdgeInsets.only(bottom: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: InkWell(
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TransportistaDetailScreen(servicio: servicio),
                        ),
                      );
                      // Recargar lista al volver
                      if (_empleadoId != null) {
                        controller.fetchServiciosConductor(_empleadoId!);
                      }
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
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: _getStatusColor(servicio.idEstatus).withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: _getStatusColor(servicio.idEstatus)),
                                ),
                                child: Text(
                                  _getStatusText(servicio.idEstatus),
                                  style: TextStyle(
                                    color: _getStatusColor(servicio.idEstatus),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                              Text(
                                servicio.fechaServicio.toIso8601String().split('T')[0],
                                style: const TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              const Icon(Icons.location_on_outlined, color: Colors.green, size: 20),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  servicio.direccionOrigen ?? "Origen no especificado",
                                  style: const TextStyle(fontWeight: FontWeight.w500),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.flag_outlined, color: Colors.red, size: 20),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  servicio.destino,
                                  style: const TextStyle(fontWeight: FontWeight.w500),
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
                );
              },
            ),
          );
        },
      ),
    );
  }
}


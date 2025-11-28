import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/auth/services/session_storage.dart';
import '../../../widgets/app_header.dart';
import '../../../widgets/app_sidebar.dart';
import '../controllers/transporte_controller.dart';
import '../models/servicio_transporte_model.dart';
import 'transportista_detail_screen.dart';

class TransportistaScreen extends StatefulWidget {
  const TransportistaScreen({super.key});

  @override
  State<TransportistaScreen> createState() => _TransportistaScreenState();
}

class _TransportistaScreenState extends State<TransportistaScreen> {
  int? _empleadoId;
  bool _isLoadingEmpleadoId = true;
  int? _selectedEstatus; // null = Todas, 1 = Asignados, 4 = En Curso, 3 = Terminados

  // Opciones de estatus de transporte
  final List<Map<String, dynamic>> _estatusOptions = [
    {'id': null, 'nombre': 'Todas', 'color': Colors.grey},
    {'id': 1, 'nombre': 'Asignados', 'color': Colors.orange},
    {'id': 4, 'nombre': 'En Curso', 'color': Colors.green},
    {'id': 3, 'nombre': 'Terminados', 'color': Colors.grey},
  ];

  @override
  void initState() {
    super.initState();
    _selectedEstatus = null; // Iniciar con "Todas"
    _obtenerEmpleadoId();
  }

  /// Obtener empleado_id de la sesión
  Future<void> _obtenerEmpleadoId() async {
    try {
    final session = await SessionStorage.getSession();
      if (session == null) {
        setState(() {
          _isLoadingEmpleadoId = false;
        });
        return;
      }

      // Intentar obtener desde usuario
      final usuario = session['usuario'];
      if (usuario is Map<String, dynamic>) {
        _empleadoId = usuario['empleado_id'] as int?;
      }

      // Si no está en usuario, intentar directamente en session
      if (_empleadoId == null) {
        _empleadoId = session['empleado_id'] as int? ??
                     session['id_empleado'] as int? ??
                     session['empleadoId'] as int?;
      }

        setState(() {
        _isLoadingEmpleadoId = false;
      });

      // Cargar servicios si tenemos empleado_id
      if (_empleadoId != null && mounted) {
        final controller = Provider.of<TransporteController>(context, listen: false);
        await controller.fetchServiciosConductor(_empleadoId!);
      }
    } catch (e) {
      print('Error al obtener empleado_id: $e');
      setState(() {
        _isLoadingEmpleadoId = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      drawer: const AppSidebar(),
      body: SafeArea(
        child: Column(
          children: [
            const AppHeader(),
            // Título y descripción
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Transporte',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1a1a1a),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Servicios de transporte asignados a ti',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            // Selector de estatus
            _buildEstatusSelector(),
            // Contenido principal
            Expanded(
              child: _isLoadingEmpleadoId
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF667eea),
                      ),
                    )
                  : _empleadoId == null
                      ? _buildErrorEmpleadoId()
                      : _buildServiciosList(_selectedEstatus),
            ),
          ],
        ),
      ),
    );
  }

  /// Widget para el selector de estatus
  Widget _buildEstatusSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: _estatusOptions.map((estatus) {
            final isSelected = _selectedEstatus == estatus['id'];
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                selected: isSelected,
                label: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: estatus['color'],
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      estatus['nombre'],
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                        color: isSelected ? Colors.white : Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
                selectedColor: estatus['color'],
                backgroundColor: Colors.grey.shade100,
                onSelected: (selected) {
                  if (selected) {
                    setState(() {
                      _selectedEstatus = estatus['id'];
                    });
                  }
                },
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildErrorEmpleadoId() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
            const SizedBox(height: 16),
            const Text(
              'No se pudo obtener tu información de empleado',
              style: TextStyle(fontSize: 16, color: Color(0xFF1a1a1a)),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _obtenerEmpleadoId,
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

  Widget _buildServiciosList(int? estatusId) {
    return Consumer<TransporteController>(
      builder: (context, controller, child) {
        if (controller.isLoading) {
          return const Center(
            child: CircularProgressIndicator(
              color: Color(0xFF667eea),
            ),
          );
        }

        if (controller.error != null) {
          return _buildErrorState(controller);
        }

        // Filtrar servicios por estatus si se especifica
        final servicios = estatusId == null
            ? controller.servicios
            : controller.getServiciosPorEstatus(estatusId);

        if (servicios.isEmpty) {
          return _buildEmptyState(estatusId);
        }

        return RefreshIndicator(
          onRefresh: () async {
            if (_empleadoId != null) {
              await controller.fetchServiciosConductor(_empleadoId!);
            }
          },
          color: const Color(0xFF667eea),
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: servicios.length,
            itemBuilder: (context, index) {
              return _buildServicioCard(servicios[index]);
            },
          ),
        );
      },
    );
  }

  Widget _buildErrorState(TransporteController controller) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
            const SizedBox(height: 16),
            Text(
              controller.error ?? 'Error desconocido',
              style: const TextStyle(fontSize: 16, color: Color(0xFF1a1a1a)),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                if (_empleadoId != null) {
                  controller.fetchServiciosConductor(_empleadoId!);
                }
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

  Widget _buildEmptyState(int? estatusId) {
    String mensaje;
    IconData icono;

    switch (estatusId) {
      case 1:
        mensaje = 'No tienes servicios asignados';
        icono = Icons.pending_outlined;
        break;
      case 4:
        mensaje = 'No tienes servicios en curso';
        icono = Icons.directions_car_outlined;
        break;
      case 3:
        mensaje = 'No tienes servicios terminados';
        icono = Icons.check_circle_outline;
        break;
      default:
        mensaje = 'No tienes servicios de transporte asignados';
        icono = Icons.local_taxi_outlined;
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icono,
            size: 80,
            color: const Color(0xFF667eea).withOpacity(0.3),
          ),
          const SizedBox(height: 24),
          Text(
            mensaje,
            style: const TextStyle(
              fontSize: 18,
              color: Color(0xFF6b7280),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServicioCard(ServicioTransporteModel servicio) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 2,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TransportistaDetailScreen(servicio: servicio),
            ),
          ).then((refrescar) {
            if (refrescar == true && _empleadoId != null) {
              final controller = Provider.of<TransporteController>(context, listen: false);
              controller.fetchServiciosConductor(_empleadoId!);
            }
          });
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header con estatus
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Badge de estatus
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: _getStatusColor(servicio.idEstatus).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: _getStatusColor(servicio.idEstatus).withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      _getStatusText(servicio.idEstatus),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: _getStatusColor(servicio.idEstatus),
                      ),
                    ),
                  ),
                  // Fecha del servicio
                  Text(
                    servicio.fechaServicio.toIso8601String().split('T')[0],
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Origen
              Row(
                children: [
                  Icon(Icons.location_on_outlined, size: 20, color: Colors.green[600]),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Origen',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          servicio.direccionOrigen ?? "Origen no especificado",
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1a1a1a),
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Destino
              Row(
                children: [
                  Icon(Icons.flag_outlined, size: 20, color: Colors.red[600]),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Destino',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          servicio.destino,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1a1a1a),
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Información adicional
              Row(
                children: [
                  if (servicio.distanciaKm != null)
                    Expanded(
                      child: _buildInfoItem(
                        Icons.straighten,
                        'Distancia',
                        '${servicio.distanciaKm!.toStringAsFixed(1)} km',
                      ),
                    ),
                  Expanded(
                    child: _buildInfoItem(
                      Icons.access_time,
                      'Hora',
                      servicio.horaServicio,
                    ),
                  ),
                  Expanded(
                    child: _buildInfoItem(
                      Icons.attach_money,
                      'Costo',
                      '\$${servicio.costoViaje.toStringAsFixed(2)}',
                    ),
                  ),
                ],
              ),
              // Observaciones si existen
              if (servicio.observacionesCliente != null && servicio.observacionesCliente!.isNotEmpty) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.description, size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Observaciones del cliente',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              servicio.observacionesCliente!,
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey[700],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String label, String value) {
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

  Color _getStatusColor(int? status) {
    switch (status) {
      case 1: // Pendiente/Asignado
        return Colors.orange;
      case 2: // Aceptado
        return Colors.blue;
      case 4: // En curso
        return Colors.green;
      case 3: // Terminado
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
        return "Asignado";
      case 2:
        return "Aceptado";
      case 4:
        return "En Curso";
      case 3:
        return "Terminado";
      case 0:
        return "Cancelado";
      default:
        return "Desconocido";
    }
  }
}

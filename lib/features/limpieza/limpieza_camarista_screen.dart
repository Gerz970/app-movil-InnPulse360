import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/auth/services/session_storage.dart';
import '../../widgets/app_header.dart';
import '../../widgets/app_sidebar.dart';
import 'controllers/limpieza_controller.dart';
import 'models/limpieza_model.dart';
import 'limpieza_detail_screen.dart';

class LimpiezaCamaristaScreen extends StatefulWidget {
  const LimpiezaCamaristaScreen({super.key});

  @override
  State<LimpiezaCamaristaScreen> createState() => _LimpiezaCamaristaScreenState();
}

class _LimpiezaCamaristaScreenState extends State<LimpiezaCamaristaScreen> {
  int? _empleadoId;
  bool _isLoadingEmpleadoId = true;
  int? _selectedEstatus; // null = Todas, 1 = Pendientes, 2 = En Progreso, 3 = Completadas

  // Opciones de estatus de limpieza
  final List<Map<String, dynamic>> _estatusOptions = [
    {'id': null, 'nombre': 'Todas', 'color': Colors.grey},
    {'id': 1, 'nombre': 'Pendiente', 'color': Colors.orange},
    {'id': 2, 'nombre': 'En Progreso', 'color': Colors.blue},
    {'id': 3, 'nombre': 'Completada', 'color': Colors.green},
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

      // Cargar limpiezas si tenemos empleado_id
      if (_empleadoId != null && mounted) {
        final controller = Provider.of<LimpiezaController>(context, listen: false);
        await controller.fetchLimpiezasPorEmpleado(_empleadoId!);
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
                    'Mis Limpiezas',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1a1a1a),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Limpiezas asignadas a ti',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            // Selector de estatus (igual que en asignaciones)
            _buildEstatusSelector(),
            // Contenido principal
            Expanded(
              child: _isLoadingEmpleadoId
                  ? const Center(child: CircularProgressIndicator())
                  : _empleadoId == null
                      ? _buildErrorEmpleadoId()
                      : _buildLimpiezasList(_selectedEstatus),
            ),
          ],
        ),
      ),
    );
  }

  /// Widget para el selector de estatus (igual que en asignaciones)
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

  Widget _buildLimpiezasList(int? estatusId) {
    return Consumer<LimpiezaController>(
      builder: (context, controller, child) {
        if (controller.isLoading) {
          return const Center(
            child: CircularProgressIndicator(
              color: Color(0xFF667eea),
            ),
          );
        }

        if (controller.errorMessage != null) {
          return _buildErrorState(controller);
        }

        // Filtrar limpiezas por estatus si se especifica
        final limpiezas = estatusId == null
            ? controller.limpiezas
            : controller.getLimpiezasPorEstatus(estatusId);

        if (limpiezas.isEmpty) {
          return _buildEmptyState(estatusId);
        }

        return RefreshIndicator(
          onRefresh: () async {
            if (_empleadoId != null) {
              await controller.fetchLimpiezasPorEmpleado(_empleadoId!);
            }
          },
          color: const Color(0xFF667eea),
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: limpiezas.length,
            itemBuilder: (context, index) {
              return _buildLimpiezaCard(limpiezas[index]);
            },
          ),
        );
      },
    );
  }

  Widget _buildErrorState(LimpiezaController controller) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
            const SizedBox(height: 16),
            Text(
              controller.errorMessage ?? 'Error desconocido',
              style: const TextStyle(fontSize: 16, color: Color(0xFF1a1a1a)),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                if (_empleadoId != null) {
                  controller.fetchLimpiezasPorEmpleado(_empleadoId!);
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
        mensaje = 'No tienes limpiezas pendientes';
        icono = Icons.pending_outlined;
        break;
      case 2:
        mensaje = 'No tienes limpiezas en progreso';
        icono = Icons.work_outline;
        break;
      case 3:
        mensaje = 'No tienes limpiezas completadas';
        icono = Icons.check_circle_outline;
        break;
      default:
        mensaje = 'No tienes limpiezas asignadas';
        icono = Icons.cleaning_services_outlined;
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

  Widget _buildLimpiezaCard(Limpieza limpieza) {
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
              builder: (context) => LimpiezaDetailScreen(limpieza: limpieza),
            ),
          ).then((refrescar) {
            if (refrescar == true && _empleadoId != null) {
              final controller = Provider.of<LimpiezaController>(context, listen: false);
              controller.fetchLimpiezasPorEmpleado(_empleadoId!);
            }
          });
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header con estatus y tipo
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Badge de estatus
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Color(limpieza.estatusLimpiezaColor).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Color(limpieza.estatusLimpiezaColor).withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      limpieza.estatusLimpiezaTexto,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(limpieza.estatusLimpiezaColor),
                      ),
                    ),
                  ),
                  // Tipo de limpieza
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      limpieza.tipoLimpieza.nombreTipo,
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
              // Habitación/Área
              Row(
                children: [
                  Icon(Icons.room, size: 20, color: Colors.grey[600]),
                  const SizedBox(width: 8),
                  Text(
                    limpieza.habitacionArea.nombreClave,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1a1a1a),
                    ),
                  ),
                ],
              ),
              if (limpieza.habitacionArea.descripcion.isNotEmpty) ...[
                const SizedBox(height: 4),
                Padding(
                  padding: const EdgeInsets.only(left: 28),
                  child: Text(
                    limpieza.habitacionArea.descripcion,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 16),
              // Fechas
              Row(
                children: [
                  Expanded(
                    child: _buildFechaInfo(
                      Icons.calendar_today,
                      'Programada',
                      limpieza.fechaProgramadaFormateada,
                    ),
                  ),
                  if (limpieza.fechaTermino != null)
                    Expanded(
                      child: _buildFechaInfo(
                        Icons.check_circle,
                        'Terminada',
                        limpieza.fechaTerminoFormateada ?? '',
                      ),
                    ),
                ],
              ),
              // Descripción si existe
              if (limpieza.descripcion != null && limpieza.descripcion!.isNotEmpty) ...[
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
                        child: Text(
                          limpieza.descripcion!,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[700],
                          ),
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


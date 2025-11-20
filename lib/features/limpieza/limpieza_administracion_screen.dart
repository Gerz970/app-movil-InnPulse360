import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../widgets/app_header.dart';
import '../../widgets/app_sidebar.dart';
import 'controllers/limpieza_controller.dart';
import 'models/limpieza_model.dart';
import 'limpieza_asignar_screen.dart';
import '../login/login_screen.dart';

/// Pantalla de administración de limpiezas
/// Muestra las limpiezas filtradas por estatus con un selector
class LimpiezaAdministracionScreen extends StatefulWidget {
  const LimpiezaAdministracionScreen({super.key});

  @override
  State<LimpiezaAdministracionScreen> createState() => _LimpiezaAdministracionScreenState();
}

class _LimpiezaAdministracionScreenState extends State<LimpiezaAdministracionScreen> {
  int _selectedEstatus = 1; // Estatus seleccionado por defecto (Pendiente)

  // Opciones de estatus de limpieza
  final List<Map<String, dynamic>> _estatusOptions = [
    {'id': 1, 'nombre': 'Pendiente', 'color': Colors.orange},
    {'id': 2, 'nombre': 'En Progreso', 'color': Colors.blue},
    {'id': 3, 'nombre': 'Completada', 'color': Colors.green},
    {'id': 4, 'nombre': 'Cancelada', 'color': Colors.red},
  ];

  @override
  void initState() {
    super.initState();
    // Cargar limpiezas al iniciar la pantalla con el estatus por defecto
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final controller = Provider.of<LimpiezaController>(context, listen: false);
        controller.fetchLimpiezasPorEstatus(_selectedEstatus);
      }
    });
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
            // Selector de estatus
            _buildEstatusSelector(),
            // Contenido principal
            Expanded(
              child: Consumer<LimpiezaController>(
                builder: (context, controller, child) {
                  // Estado de carga
                  if (controller.isLoading) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF667eea),
                      ),
                    );
                  }

                  // Estado de error
                  if (controller.errorMessage != null) {
                    return _buildErrorState(context, controller);
                  }

                  // Estado vacío
                  if (controller.isEmpty) {
                    return _buildEmptyState();
                  }

                  // Estado exitoso - Lista de limpiezas
                  return _buildLimpiezasList(controller);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Widget para el selector de estatus
  Widget _buildEstatusSelector() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.grey.shade50,
      child: Row(
        children: [
          const Text(
            'Filtrar por estatus:',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Color(0xFF1a1a1a),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
                color: Colors.white,
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<int>(
                  value: _selectedEstatus,
                  isExpanded: true,
                  items: _estatusOptions.map((estatus) {
                    return DropdownMenuItem<int>(
                      value: estatus['id'],
                      child: Row(
                        children: [
                          Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: estatus['color'],
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            estatus['nombre'],
                            style: const TextStyle(
                              fontSize: 14,
                              color: Color(0xFF1a1a1a),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null && value != _selectedEstatus) {
                      setState(() {
                        _selectedEstatus = value;
                      });
                      // Cargar limpiezas con el nuevo estatus
                      final controller = Provider.of<LimpiezaController>(context, listen: false);
                      controller.fetchLimpiezasPorEstatus(_selectedEstatus);
                    }
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Widget para mostrar estado de error
  Widget _buildErrorState(BuildContext context, LimpiezaController controller) {
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
              controller.errorMessage ?? 'Error desconocido',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Color(0xFF1a1a1a),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    controller.fetchLimpiezasPorEstatus(_selectedEstatus);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF667eea),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Reintentar'),
                ),
                if (controller.isNotAuthenticated) ...[
                  const SizedBox(width: 12),
                  OutlinedButton(
                    onPressed: () {
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(
                          builder: (context) => const LoginScreen(),
                        ),
                        (route) => false,
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF667eea),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      side: const BorderSide(
                        color: Color(0xFF667eea),
                        width: 1,
                      ),
                    ),
                    child: const Text('Reautenticar'),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Widget para mostrar estado vacío
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF4CAF50).withOpacity(0.1),
            ),
            child: Icon(
              Icons.cleaning_services,
              size: 40,
              color: const Color(0xFF4CAF50).withOpacity(0.5),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'No hay limpiezas ${_estatusOptions.firstWhere((e) => e['id'] == _selectedEstatus)['nombre'].toLowerCase()}',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Color(0xFF6b7280),
              letterSpacing: -0.2,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// Widget para mostrar lista de limpiezas
  Widget _buildLimpiezasList(LimpiezaController controller) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: controller.limpiezas.length,
      itemBuilder: (context, index) {
        final limpieza = controller.limpiezas[index];
        return _buildLimpiezaCard(limpieza);
      },
    );
  }

  /// Widget para construir una card de limpieza
  Widget _buildLimpiezaCard(Limpieza limpieza) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () async {
          // Solo permitir navegación si la limpieza está en estatus Pendiente (1)
          if (limpieza.estatusLimpiezaId != 1) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Solo se pueden asignar limpiezas en estatus Pendiente'),
                backgroundColor: Colors.orange,
              ),
            );
            return;
          }

          // Navegar a la pantalla de asignación
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => LimpiezaAsignarScreen(
                limpiezaId: limpieza.idLimpieza,
                estatusLimpiezaId: limpieza.estatusLimpiezaId,
              ),
            ),
          );

          // Si se actualizó la limpieza, refrescar el listado
          if (result == true && mounted) {
            final controller = Provider.of<LimpiezaController>(context, listen: false);
            controller.fetchLimpiezasPorEstatus(_selectedEstatus);
          }
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Ícono principal de limpieza
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF4CAF50).withOpacity(0.1),
                ),
                child: const Icon(
                  Icons.cleaning_services,
                  color: Color(0xFF4CAF50),
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),

              // Información principal
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Habitación/Área
                    Text(
                      limpieza.habitacionArea.nombreClave,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1a1a1a),
                        letterSpacing: -0.3,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),

                    // Tipo de limpieza y empleado en una fila
                    Row(
                      children: [
                        Icon(
                          Icons.category,
                          size: 14,
                          color: const Color(0xFF6b7280),
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            limpieza.tipoLimpieza.nombreTipo,
                            style: const TextStyle(
                              fontSize: 13,
                              color: Color(0xFF6b7280),
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Icon(
                          Icons.person_outline,
                          size: 14,
                          color: const Color(0xFF6b7280),
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            limpieza.empleado.nombre,
                            style: const TextStyle(
                              fontSize: 13,
                              color: Color(0xFF6b7280),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    // Fecha programada
                    Row(
                      children: [
                        Icon(
                          Icons.schedule,
                          size: 14,
                          color: const Color(0xFF6b7280),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          limpieza.fechaProgramadaFormateada,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF6b7280),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 12),

              // Badge de estatus y indicador de acción
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Badge de estatus
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Color(limpieza.estatusLimpiezaColor).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Color(limpieza.estatusLimpiezaColor).withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      limpieza.estatusLimpiezaTexto,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Color(limpieza.estatusLimpiezaColor),
                        letterSpacing: -0.1,
                      ),
                    ),
                  ),

                  // Indicador de acción disponible (solo para pendientes)
                  if (limpieza.estatusLimpiezaId == 1) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFF4CAF50).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'Toca para asignar',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF4CAF50),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

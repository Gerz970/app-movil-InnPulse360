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
                    // Cargar limpiezas con el nuevo estatus
                    final controller = Provider.of<LimpiezaController>(context, listen: false);
                    controller.fetchLimpiezasPorEstatus(_selectedEstatus);
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
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.70,
      ),
      itemCount: controller.limpiezas.length,
      itemBuilder: (context, index) {
        final limpieza = controller.limpiezas[index];
        return _buildLimpiezaCard(limpieza);
      },
    );
  }

  /// Widget para construir una card de limpieza
  Widget _buildLimpiezaCard(Limpieza limpieza) {
    final estatusColor = Color(limpieza.estatusLimpiezaColor);
    final isPendiente = limpieza.estatusLimpiezaId == 1;
    
    return Card(
      margin: EdgeInsets.zero,
      elevation: isPendiente ? 4 : 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isPendiente ? estatusColor.withOpacity(0.3) : Colors.transparent,
          width: isPendiente ? 2 : 0,
        ),
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
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: isPendiente
                ? LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      estatusColor.withOpacity(0.05),
                      Colors.white,
                    ],
                  )
                : null,
          ),
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header con icono y estatus
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: estatusColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.cleaning_services_rounded,
                      color: estatusColor,
                      size: 18,
                    ),
                  ),
                  Flexible(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                      decoration: BoxDecoration(
                        color: estatusColor.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        limpieza.estatusLimpiezaTexto,
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w600,
                          color: estatusColor,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 10),
              
              // Habitación/Área - Destacado
              Text(
                limpieza.habitacionArea.nombreClave,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1a1a1a),
                  letterSpacing: -0.5,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              
              if (limpieza.habitacionArea.descripcion.isNotEmpty) ...[
                const SizedBox(height: 2),
                Text(
                  limpieza.habitacionArea.descripcion,
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey.shade600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              
              const SizedBox(height: 10),
              
              // Información detallada
              Flexible(
                child: _buildInfoRow(
                  Icons.category_rounded,
                  limpieza.tipoLimpieza.nombreTipo,
                ),
              ),
              const SizedBox(height: 5),
              Flexible(
                child: _buildInfoRow(
                  Icons.person_outline_rounded,
                  limpieza.empleado.nombre.isNotEmpty 
                      ? limpieza.empleado.nombre 
                      : 'Sin asignar',
                ),
              ),
              const SizedBox(height: 5),
              Flexible(
                child: _buildInfoRow(
                  Icons.schedule_rounded,
                  limpieza.fechaProgramadaFormateada,
                ),
              ),
              
              const SizedBox(height: 6),
              
              // Indicador de acción (solo para pendientes)
              if (isPendiente)
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4CAF50).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.touch_app_rounded,
                        size: 12,
                        color: const Color(0xFF4CAF50),
                      ),
                      const SizedBox(width: 3),
                      Flexible(
                        child: Text(
                          'Toca para asignar',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF4CAF50),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
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

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 14,
          color: Colors.grey.shade600,
        ),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade700,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

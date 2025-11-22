import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../widgets/app_header.dart';
import '../../widgets/app_sidebar.dart';
import 'controllers/limpieza_controller.dart';
import 'models/limpieza_model.dart';
import 'limpieza_asignar_screen.dart';
import '../login/login_screen.dart';
import 'widgets/limpieza_bottom_nav_bar.dart';

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
            // Barra inferior con opciones de navegación
            const LimpiezaBottomNavBar(
              currentScreen: LimpiezaScreenType.asignaciones,
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
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: controller.limpiezas.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
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
    final isCancelada = limpieza.estatusLimpiezaId == 4;
    
    return Card(
      margin: EdgeInsets.zero,
      elevation: 2,
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
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border(
              left: BorderSide(
                color: estatusColor,
                width: 4,
              ),
            ),
            color: isCancelada 
                ? Colors.grey.shade50 
                : (isPendiente 
                    ? estatusColor.withOpacity(0.02) 
                    : Colors.white),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header con icono, estatus y flecha
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: estatusColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.cleaning_services_rounded,
                      color: estatusColor,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: estatusColor.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        limpieza.estatusLimpiezaTexto,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: estatusColor,
                        ),
                      ),
                    ),
                  ),
                  if (isPendiente)
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 16,
                      color: Colors.grey.shade400,
                    ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Habitación/Área - Título principal
              Text(
                limpieza.habitacionArea.nombreClave,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: isCancelada ? Colors.grey.shade600 : const Color(0xFF1a1a1a),
                  letterSpacing: -0.5,
                ),
              ),
              
              // Descripción de habitación (si existe)
              if (limpieza.habitacionArea.descripcion.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  limpieza.habitacionArea.descripcion,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                    height: 1.4,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              
              const SizedBox(height: 16),
              
              // Sección de detalles con fondo
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    _buildDetailRow(
                      Icons.category_rounded,
                      'Tipo',
                      limpieza.tipoLimpieza.nombreTipo,
                    ),
                    const SizedBox(height: 10),
                    _buildDetailRow(
                      Icons.person_outline_rounded,
                      'Empleado',
                      limpieza.empleado.nombre.isNotEmpty 
                          ? limpieza.empleado.nombre 
                          : 'Sin asignar',
                      isSecondary: limpieza.empleado.nombre.isEmpty,
                    ),
                    const SizedBox(height: 10),
                    _buildDetailRow(
                      Icons.schedule_rounded,
                      'Fecha Programada',
                      limpieza.fechaProgramadaFormateada,
                    ),
                  ],
                ),
              ),
              
              // Botón de acción para pendientes
              if (isPendiente) ...[
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4CAF50).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: const Color(0xFF4CAF50).withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.touch_app_rounded,
                        size: 16,
                        color: const Color(0xFF4CAF50),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Toca para asignar',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF4CAF50),
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

  /// Widget para construir una fila de detalle mejorada
  Widget _buildDetailRow(IconData icon, String label, String value, {bool isSecondary = false}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 18,
          color: isSecondary ? Colors.grey.shade400 : Colors.grey.shade600,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey.shade500,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.2,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  color: isSecondary ? Colors.grey.shade500 : const Color(0xFF1a1a1a),
                  fontWeight: isSecondary ? FontWeight.w400 : FontWeight.w600,
                  height: 1.3,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

}

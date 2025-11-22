import 'package:flutter/material.dart';
import '../limpieza_administracion_screen.dart';
import '../limpieza_crear_screen.dart';
import '../../common/under_construction_screen.dart';

/// Tipo de pantalla para identificar cuál está activa
enum LimpiezaScreenType {
  estadistica,
  asignaciones,
  crearLimpieza,
  historico,
}

/// Widget reutilizable para la barra inferior de navegación del módulo de limpieza
class LimpiezaBottomNavBar extends StatelessWidget {
  /// Tipo de pantalla actual para marcar el botón correspondiente como seleccionado
  final LimpiezaScreenType currentScreen;

  const LimpiezaBottomNavBar({
    super.key,
    required this.currentScreen,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildBottomNavButton(
                context: context,
                icon: Icons.bar_chart,
                label: 'Estadística',
                color: const Color(0xFF667eea),
                isSelected: currentScreen == LimpiezaScreenType.estadistica,
                onTap: () {
                  // Solo navegar si no estamos ya en esta pantalla
                  if (currentScreen != LimpiezaScreenType.estadistica) {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const UnderConstructionScreen(
                          title: 'Estadística Limpieza',
                          limpiezaScreenType: LimpiezaScreenType.estadistica,
                        ),
                      ),
                    );
                  }
                },
              ),
              _buildBottomNavButton(
                context: context,
                icon: Icons.assignment,
                label: 'Asignaciones',
                color: const Color(0xFF4CAF50),
                isSelected: currentScreen == LimpiezaScreenType.asignaciones,
                onTap: () {
                  // Solo navegar si no estamos ya en esta pantalla
                  if (currentScreen != LimpiezaScreenType.asignaciones) {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LimpiezaAdministracionScreen(),
                      ),
                    );
                  }
                },
              ),
              _buildBottomNavButton(
                context: context,
                icon: Icons.add_circle,
                label: 'Crear Limpieza',
                color: const Color(0xFF2196F3),
                isSelected: currentScreen == LimpiezaScreenType.crearLimpieza,
                onTap: () {
                  // Solo navegar si no estamos ya en esta pantalla
                  if (currentScreen != LimpiezaScreenType.crearLimpieza) {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LimpiezaCrearScreen(),
                      ),
                    );
                  }
                },
              ),
              _buildBottomNavButton(
                context: context,
                icon: Icons.history,
                label: 'Histórico',
                color: const Color(0xFFFF9800),
                isSelected: currentScreen == LimpiezaScreenType.historico,
                onTap: () {
                  // Solo navegar si no estamos ya en esta pantalla
                  if (currentScreen != LimpiezaScreenType.historico) {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const UnderConstructionScreen(
                          title: 'Histórico',
                          limpiezaScreenType: LimpiezaScreenType.historico,
                        ),
                      ),
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Widget para construir un botón de la barra inferior
  Widget _buildBottomNavButton({
    required BuildContext context,
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
    required bool isSelected,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          decoration: BoxDecoration(
            color: isSelected ? color.withOpacity(0.1) : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: isSelected ? color : Colors.grey.shade600,
                size: 24,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected ? color : Colors.grey.shade600,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}


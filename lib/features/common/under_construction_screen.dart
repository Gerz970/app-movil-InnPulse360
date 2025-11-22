import 'package:flutter/material.dart';
import '../../widgets/app_header.dart';
import '../../widgets/app_sidebar.dart';
import '../../features/limpieza/widgets/limpieza_bottom_nav_bar.dart';

/// Pantalla genérica para módulos en construcción
/// Muestra un mensaje "En construcción" con un ícono informativo
class UnderConstructionScreen extends StatelessWidget {
  /// Título del módulo que se mostrará en la pantalla
  final String title;

  /// Tipo de pantalla de limpieza si esta pantalla pertenece al módulo de limpieza
  final LimpiezaScreenType? limpiezaScreenType;

  /// Constructor de la pantalla
  const UnderConstructionScreen({
    super.key,
    required this.title,
    this.limpiezaScreenType,
  });

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
            // Contenido principal
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Ícono de construcción
                    Icon(
                      Icons.construction,
                      size: 80,
                      color: const Color(0xFF667eea).withOpacity(0.3),
                    ),
                    const SizedBox(height: 24),
                    // Texto "En construcción"
                    const Text(
                      'En construcción',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF6b7280),
                        letterSpacing: -0.3,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Barra inferior de limpieza si corresponde
            if (limpiezaScreenType != null)
              LimpiezaBottomNavBar(
                currentScreen: limpiezaScreenType!,
              ),
          ],
        ),
      ),
    );
  }
}


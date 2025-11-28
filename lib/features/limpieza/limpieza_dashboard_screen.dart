import 'package:flutter/material.dart';
import '../../widgets/app_header.dart';
import '../../widgets/app_sidebar.dart';
import '../../core/theme/app_theme.dart';
import '../common/under_construction_screen.dart';
import 'limpieza_administracion_screen.dart';
import 'limpieza_crear_screen.dart';

/// Dashboard principal para el módulo de administración de limpieza
/// Muestra opciones de navegación hacia diferentes secciones del módulo
class LimpiezaDashboardScreen extends StatelessWidget {
  const LimpiezaDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      drawer: const AppSidebar(),
      body: SafeArea(
        child: Column(
          children: [
            // Header global reutilizable
            const AppHeader(),
            // Contenido principal
            Expanded(
              child: SingleChildScrollView(
                padding: AppSpacing.allLg,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Título del módulo
                    Text(
                      'Administración de Limpieza',
                      style: AppTextStyles.h1,
                    ),
                    SizedBox(height: AppSpacing.sm),
                    // Subtítulo descriptivo
                    Text(
                      'Gestiona asignaciones, estadísticas e histórico de limpieza',
                      style: AppTextStyles.bodyLarge.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    SizedBox(height: AppSpacing.xxxl),

                    // Grid de opciones (2 columnas en pantallas grandes, 1 en pequeñas)
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final isWideScreen = constraints.maxWidth > 600;
                        return GridView.count(
                          crossAxisCount: isWideScreen ? 2 : 1,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          children: const [
                            _DashboardCard(
                              title: 'Estadística Limpieza',
                              description: 'Métricas y reportes de rendimiento',
                              icon: Icons.bar_chart,
                              color: AppColors.primary,
                              isAvailable: false,
                              onTap: _navigateToEstadistica,
                            ),
                            _DashboardCard(
                              title: 'Asignaciones',
                              description: 'Gestionar tareas de limpieza por estatus',
                              icon: Icons.assignment,
                              color: AppColors.success,
                              isAvailable: true,
                              onTap: _navigateToAsignaciones,
                            ),
                            _DashboardCard(
                              title: 'Crear Limpieza',
                              description: 'Programar nueva tarea de limpieza',
                              icon: Icons.add_circle,
                              color: AppColors.info,
                              isAvailable: true,
                              onTap: _navigateToCrearLimpieza,
                            ),
                            _DashboardCard(
                              title: 'Histórico',
                              description: 'Registro histórico de actividades',
                              icon: Icons.history,
                              color: AppColors.warning,
                              isAvailable: false,
                              onTap: _navigateToHistorico,
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Método estático para navegación a Estadística
  static void _navigateToEstadistica(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const UnderConstructionScreen(
          title: 'Estadística Limpieza',
        ),
      ),
    );
  }

  // Método estático para navegación a Asignaciones
  static void _navigateToAsignaciones(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const LimpiezaAdministracionScreen(),
      ),
    );
  }

  // Método estático para navegación a Histórico
  static void _navigateToHistorico(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const UnderConstructionScreen(
          title: 'Histórico',
        ),
      ),
    );
  }

  // Método estático para navegación a Crear Limpieza
  static void _navigateToCrearLimpieza(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const LimpiezaCrearScreen(),
      ),
    );
  }
}

/// Widget para las cards del dashboard
class _DashboardCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final bool isAvailable;
  final Function(BuildContext) onTap;

  const _DashboardCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.isAvailable,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: AppRadius.lgBorder,
      ),
      child: InkWell(
        onTap: isAvailable ? () => onTap(context) : null,
        borderRadius: AppRadius.lgBorder,
        child: Container(
          padding: AppSpacing.allXxl,
          decoration: BoxDecoration(
            borderRadius: AppRadius.lgBorder,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                color.withOpacity(isAvailable ? 0.1 : 0.05),
                color.withOpacity(isAvailable ? 0.05 : 0.02),
              ],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Ícono principal
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: color.withOpacity(isAvailable ? 0.2 : 0.1),
                ),
                child: Icon(
                  icon,
                  size: 32,
                  color: color.withOpacity(isAvailable ? 1.0 : 0.6),
                ),
              ),
              SizedBox(height: AppSpacing.lg),

              // Título
              Text(
                title,
                style: AppTextStyles.h3.copyWith(
                  fontSize: 18,
                  color: AppColors.textPrimary.withOpacity(isAvailable ? 1.0 : 0.7),
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: AppSpacing.sm),

              // Descripción
              Text(
                description,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary.withOpacity(isAvailable ? 0.9 : 0.6),
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: AppSpacing.lg),

              // Badge de estado
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: isAvailable
                      ? color.withOpacity(0.1)
                      : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isAvailable
                        ? color.withOpacity(0.3)
                        : Colors.grey.shade300,
                    width: 1,
                  ),
                ),
                child: Text(
                  isAvailable ? 'Disponible' : 'Próximamente',
                  style: AppTextStyles.caption.copyWith(
                    fontWeight: FontWeight.w500,
                    color: isAvailable ? color : Colors.grey.shade600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

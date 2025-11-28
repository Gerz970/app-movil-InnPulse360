import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';

/// Widget reutilizable para mostrar estados vacíos
/// 
/// Muestra un mensaje consistente cuando no hay datos disponibles con:
/// - Icono grande centrado
/// - Título y mensaje opcional
/// - Estilo consistente en toda la aplicación
class AppEmptyState extends StatelessWidget {
  /// Icono a mostrar
  final IconData icon;
  
  /// Título del estado vacío
  final String title;
  
  /// Mensaje adicional (opcional)
  final String? message;
  
  /// Tamaño del icono (por defecto 80)
  final double iconSize;

  const AppEmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.message,
    this.iconSize = 80,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: iconSize,
            color: AppColors.primary.withOpacity(0.3),
          ),
          SizedBox(height: AppSpacing.xxl),
          Text(
            title,
            style: AppTextStyles.h3.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          if (message != null) ...[
            SizedBox(height: AppSpacing.sm),
            Padding(
              padding: AppSpacing.horizontalXl,
              child: Text(
                message!,
                style: AppTextStyles.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ],
      ),
    );
  }
}


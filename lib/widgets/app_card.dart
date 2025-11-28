import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';

/// Widget de card reutilizable con estilo estandarizado
/// 
/// Proporciona una card consistente en toda la aplicación con:
/// - Border radius estandarizado
/// - Elevación consistente
/// - Padding configurable
/// - Soporte para onTap
class AppCard extends StatelessWidget {
  /// Contenido de la card
  final Widget child;
  
  /// Padding interno de la card
  final EdgeInsetsGeometry? padding;
  
  /// Callback cuando se toca la card
  final VoidCallback? onTap;
  
  /// Elevación de la card (por defecto 2)
  final double? elevation;
  
  /// Margen externo de la card
  final EdgeInsetsGeometry? margin;

  const AppCard({
    super.key,
    required this.child,
    this.padding,
    this.onTap,
    this.elevation,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: elevation ?? 2,
      margin: margin ?? const EdgeInsets.only(bottom: AppSpacing.lg),
      shape: RoundedRectangleBorder(
        borderRadius: AppRadius.lgBorder,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.lgBorder,
        child: Padding(
          padding: padding ?? const EdgeInsets.all(AppSpacing.lg),
          child: child,
        ),
      ),
    );
  }
}


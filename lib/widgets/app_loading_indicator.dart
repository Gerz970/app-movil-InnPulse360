import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';

/// Widget reutilizable para indicadores de carga
/// 
/// Muestra un indicador de carga consistente con:
/// - CircularProgressIndicator estandarizado
/// - Mensaje opcional
/// - Estilo consistente en toda la aplicación
class AppLoadingIndicator extends StatelessWidget {
  /// Mensaje opcional a mostrar debajo del indicador
  final String? message;
  
  /// Tamaño del indicador (por defecto null, usa el tamaño por defecto)
  final double? size;

  const AppLoadingIndicator({
    super.key,
    this.message,
    this.size,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: size,
            height: size,
            child: const CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          ),
          if (message != null) ...[
            SizedBox(height: AppSpacing.lg),
            Text(
              message!,
              style: AppTextStyles.bodyMedium,
            ),
          ],
        ],
      ),
    );
  }
}


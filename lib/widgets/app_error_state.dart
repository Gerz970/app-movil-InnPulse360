import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import 'app_button.dart';

/// Widget reutilizable para mostrar estados de error
/// 
/// Muestra un mensaje de error consistente con opciones para:
/// - Reintentar la acción
/// - Reautenticar si es necesario
/// - Estilo consistente en toda la aplicación
class AppErrorState extends StatelessWidget {
  /// Mensaje de error a mostrar
  final String message;
  
  /// Callback cuando se presiona reintentar
  final VoidCallback? onRetry;
  
  /// Si se debe mostrar el botón de reautenticar
  final bool showReauthenticate;
  
  /// Callback cuando se presiona reautenticar
  final VoidCallback? onReauthenticate;

  const AppErrorState({
    super.key,
    required this.message,
    this.onRetry,
    this.showReauthenticate = false,
    this.onReauthenticate,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: AppSpacing.allXxl,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: AppColors.error.withOpacity(0.7),
            ),
            SizedBox(height: AppSpacing.lg),
            Text(
              message,
              style: AppTextStyles.bodyLarge.copyWith(
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: AppSpacing.xxl),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (onRetry != null)
                  AppButton(
                    text: 'Reintentar',
                    onPressed: onRetry,
                    width: null,
                  ),
                if (onRetry != null && showReauthenticate)
                  SizedBox(width: AppSpacing.md),
                if (showReauthenticate && onReauthenticate != null)
                  AppButton(
                    text: 'Reautenticar',
                    onPressed: onReauthenticate,
                    isOutlined: true,
                    width: null,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}


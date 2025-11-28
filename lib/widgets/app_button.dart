import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';

/// Widget de botón reutilizable con estilo estandarizado
/// 
/// Proporciona botones consistentes en toda la aplicación con:
/// - Estilos predefinidos (primary, outlined)
/// - Indicador de carga integrado
/// - Altura fija de 52px
class AppButton extends StatelessWidget {
  /// Texto del botón
  final String text;
  
  /// Callback cuando se presiona el botón
  final VoidCallback? onPressed;
  
  /// Si el botón está en estado de carga
  final bool isLoading;
  
  /// Si el botón es de tipo outlined
  final bool isOutlined;
  
  /// Ancho del botón (por defecto double.infinity)
  final double? width;
  
  /// Altura del botón (por defecto 52)
  final double? height;

  const AppButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.isOutlined = false,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final buttonWidth = width ?? double.infinity;
    final buttonHeight = height ?? 52.0;

    return SizedBox(
      width: buttonWidth,
      height: buttonHeight,
      child: isOutlined
          ? OutlinedButton(
              onPressed: isLoading ? null : onPressed,
              style: AppButtonStyles.outlined(context),
              child: isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                      ),
                    )
                  : Text(text),
            )
          : ElevatedButton(
              onPressed: isLoading ? null : onPressed,
              style: AppButtonStyles.primary(context),
              child: isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Text(text),
            ),
    );
  }
}


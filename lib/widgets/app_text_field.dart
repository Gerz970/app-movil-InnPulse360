import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';

/// Widget de campo de texto reutilizable con estilo estandarizado
/// 
/// Proporciona campos de texto consistentes en toda la aplicación con:
/// - Decoración estandarizada
/// - Validación integrada
/// - Soporte para iconos prefix y suffix
/// - Campo de contraseña con toggle de visibilidad
class AppTextField extends StatefulWidget {
  /// Controlador del campo de texto
  final TextEditingController controller;
  
  /// Etiqueta del campo
  final String label;
  
  /// Texto de ayuda (hint)
  final String? hint;
  
  /// Icono prefix
  final IconData? prefixIcon;
  
  /// Widget suffix (puede ser un IconButton para mostrar/ocultar contraseña)
  final Widget? suffixIcon;
  
  /// Si el campo es de tipo contraseña
  final bool obscureText;
  
  /// Función de validación
  final String? Function(String?)? validator;
  
  /// Tipo de teclado
  final TextInputType? keyboardType;
  
  /// Acción del teclado
  final TextInputAction? textInputAction;
  
  /// Si el campo está habilitado
  final bool enabled;
  
  /// Máximo número de líneas
  final int? maxLines;

  const AppTextField({
    super.key,
    required this.controller,
    required this.label,
    this.hint,
    this.prefixIcon,
    this.suffixIcon,
    this.obscureText = false,
    this.validator,
    this.keyboardType,
    this.textInputAction,
    this.enabled = true,
    this.maxLines = 1,
  });

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  bool _obscureText = true;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.obscureText;
  }

  @override
  Widget build(BuildContext context) {
    Widget? suffixIcon = widget.suffixIcon;
    
    // Si es campo de contraseña y no se proporcionó suffixIcon, crear uno automático
    if (widget.obscureText && suffixIcon == null) {
      suffixIcon = IconButton(
        icon: Icon(
          _obscureText ? Icons.visibility_outlined : Icons.visibility_off_outlined,
          color: AppColors.textSecondary,
          size: 20,
        ),
        onPressed: () {
          setState(() {
            _obscureText = !_obscureText;
          });
        },
      );
    }

    return TextFormField(
      controller: widget.controller,
      decoration: AppInputStyles.standard(
        label: widget.label,
        hint: widget.hint,
        prefixIcon: widget.prefixIcon,
        suffixIcon: suffixIcon,
      ),
      obscureText: widget.obscureText && _obscureText,
      validator: widget.validator,
      keyboardType: widget.keyboardType,
      textInputAction: widget.textInputAction,
      enabled: widget.enabled,
      maxLines: widget.maxLines,
    );
  }
}


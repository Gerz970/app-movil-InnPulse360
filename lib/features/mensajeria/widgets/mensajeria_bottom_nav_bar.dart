import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

/// Barra de navegación inferior para el módulo de Mensajería
/// Permite navegar entre: Chats y Nueva conversación
class MensajeriaBottomNavBar extends StatelessWidget {
  /// Callback cuando se presiona el botón de nueva conversación
  final VoidCallback onNewConversationTap;

  const MensajeriaBottomNavBar({
    super.key,
    required this.onNewConversationTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
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
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.sm,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                context: context,
                icon: Icons.chat_bubble_outline,
                selectedIcon: Icons.chat_bubble,
                label: 'Chats',
                isSelected: true, // Siempre seleccionado porque estamos en la pantalla de chats
                onTap: () {
                  // No hacer nada, ya estamos en la pantalla de chats
                },
              ),
              _buildNavItem(
                context: context,
                icon: Icons.add_circle_outline,
                selectedIcon: Icons.add_circle,
                label: 'Nueva conversación',
                isSelected: false,
                onTap: onNewConversationTap,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required BuildContext context,
    required IconData icon,
    required IconData selectedIcon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final color = isSelected ? AppColors.primary : AppColors.textTertiary;
    
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.mdBorder,
        child: Container(
          padding: EdgeInsets.symmetric(vertical: AppSpacing.xs),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isSelected ? selectedIcon : icon,
                color: color,
                size: 24,
              ),
              SizedBox(height: AppSpacing.xs),
              Flexible(
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.caption.copyWith(
                    fontSize: 11,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    color: color,
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


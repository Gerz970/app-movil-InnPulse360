import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/mensajeria_controller.dart';
import '../models/conversacion_model.dart';
import 'chat_conversacion_screen.dart';
import 'buscar_usuario_screen.dart';
import '../../../widgets/app_sidebar.dart';
import '../../../widgets/app_header.dart';
import '../../../core/theme/app_theme.dart';
import '../../../widgets/app_empty_state.dart';
import '../../../widgets/app_error_state.dart';
import '../../../widgets/app_loading_indicator.dart';
import '../../../widgets/app_card.dart';
import '../../../widgets/app_button.dart';
import '../widgets/mensajeria_bottom_nav_bar.dart';

class ConversacionesListScreen extends StatefulWidget {
  const ConversacionesListScreen({super.key});

  @override
  State<ConversacionesListScreen> createState() => _ConversacionesListScreenState();
}

class _ConversacionesListScreenState extends State<ConversacionesListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final controller = Provider.of<MensajeriaController>(
          context,
          listen: false,
        );
        controller.fetchConversaciones();
        controller.actualizarContadorNoLeidos();
      }
    });
  }

  void _navigateToBuscarUsuario() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const BuscarUsuarioScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppSidebar(),
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header global reutilizable
            const AppHeader(),
            // Contenido principal
            Expanded(
              child: Consumer<MensajeriaController>(
                builder: (context, controller, child) {
                  if (controller.isLoading) {
                    return const AppLoadingIndicator();
                  }

                  if (controller.errorMessage != null) {
                    return AppErrorState(
                      message: controller.errorMessage!,
                      onRetry: () => controller.fetchConversaciones(),
                    );
                  }

                  if (controller.conversaciones.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          AppEmptyState(
                            icon: Icons.chat_bubble_outline,
                            title: 'No tienes conversaciones',
                            message: 'Inicia una nueva conversación con otro usuario',
                          ),
                          SizedBox(height: AppSpacing.xxl),
                          AppButton(
                            text: 'Nueva conversación',
                            onPressed: _navigateToBuscarUsuario,
                            width: null,
                          ),
                        ],
                      ),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: () async {
                      await controller.fetchConversaciones(refresh: true);
                      await controller.actualizarContadorNoLeidos();
                    },
                    child: ListView.builder(
                      padding: AppSpacing.allSm,
                      itemCount: controller.conversaciones.length,
                      itemBuilder: (context, index) {
                        final conversacion = controller.conversaciones[index];
                        return _buildConversacionCard(context, conversacion, controller);
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: MensajeriaBottomNavBar(
        onNewConversationTap: _navigateToBuscarUsuario,
      ),
    );
  }

  Widget _buildConversacionCard(
    BuildContext context,
    ConversacionModel conversacion,
    MensajeriaController controller,
  ) {
    final ultimoMensaje = conversacion.ultimoMensaje;
    final preview = ultimoMensaje?.contenido ?? 'Sin mensajes';
    final fecha = conversacion.fechaUltimoMensaje ?? conversacion.fechaCreacion;
    final timeAgo = _formatTimeAgo(fecha);
    final tieneNoLeidos = conversacion.contadorNoLeidos > 0;

    return AppCard(
      margin: EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatConversacionScreen(
              conversacionId: conversacion.idConversacion,
            ),
          ),
        );
      },
      child: Row(
        children: [
          // Avatar
          CircleAvatar(
            radius: 28,
            backgroundColor: AppColors.primary.withOpacity(0.1),
            child: conversacion.otroUsuarioFoto != null
                ? ClipOval(
                    child: Image.network(
                      conversacion.otroUsuarioFoto!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(
                          Icons.person,
                          color: AppColors.primary,
                          size: 28,
                        );
                      },
                    ),
                  )
                : Icon(
                    Icons.person,
                    color: AppColors.primary,
                    size: 28,
                  ),
          ),
          SizedBox(width: AppSpacing.md),
          // Contenido
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        conversacion.otroUsuarioNombre ?? 'Usuario',
                        style: AppTextStyles.h3.copyWith(
                          fontWeight: tieneNoLeidos
                              ? FontWeight.w700
                              : FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    SizedBox(width: AppSpacing.xs),
                    Text(
                      timeAgo,
                      style: AppTextStyles.caption,
                    ),
                  ],
                ),
                SizedBox(height: AppSpacing.xs),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        preview,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontWeight: tieneNoLeidos
                              ? FontWeight.w500
                              : FontWeight.w400,
                          color: tieneNoLeidos
                              ? AppColors.textPrimary
                              : AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Badge de no leídos
          if (tieneNoLeidos) ...[
            SizedBox(width: AppSpacing.sm),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: conversacion.contadorNoLeidos > 9 ? 8 : 10,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: AppRadius.xlBorder,
              ),
              child: Text(
                conversacion.contadorNoLeidos > 9
                    ? '9+'
                    : conversacion.contadorNoLeidos.toString(),
                style: AppTextStyles.caption.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _formatTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 7) {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    } else if (difference.inDays > 0) {
      return 'Hace ${difference.inDays} día${difference.inDays > 1 ? 's' : ''}';
    } else if (difference.inHours > 0) {
      return 'Hace ${difference.inHours} hora${difference.inHours > 1 ? 's' : ''}';
    } else if (difference.inMinutes > 0) {
      return 'Hace ${difference.inMinutes} minuto${difference.inMinutes > 1 ? 's' : ''}';
    } else {
      return 'Ahora';
    }
  }
}


import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/mensajeria_controller.dart';
import '../models/mensaje_model.dart';
import '../../../core/auth/services/session_storage.dart';
import '../../../core/theme/app_theme.dart';
import '../../../widgets/app_loading_indicator.dart';

class ChatConversacionScreen extends StatefulWidget {
  final int conversacionId;

  const ChatConversacionScreen({
    super.key,
    required this.conversacionId,
  });

  @override
  State<ChatConversacionScreen> createState() => _ChatConversacionScreenState();
}

class _ChatConversacionScreenState extends State<ChatConversacionScreen> {
  final TextEditingController _mensajeController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  int? _usuarioActualId;

  @override
  void initState() {
    super.initState();
    _initUsuario();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final controller = Provider.of<MensajeriaController>(
          context,
          listen: false,
        );
        controller.fetchConversacion(widget.conversacionId);
        controller.fetchMensajes(widget.conversacionId);
        controller.conectarWebSocket();
      }
    });
  }

  Future<void> _initUsuario() async {
    final session = await SessionStorage.getSession();
    final usuario = session?['usuario'] as Map<String, dynamic>?;
    setState(() {
      _usuarioActualId = usuario?['id_usuario'] as int?;
    });
  }

  @override
  void dispose() {
    _mensajeController.dispose();
    _scrollController.dispose();
    final controller = Provider.of<MensajeriaController>(
      context,
      listen: false,
    );
    controller.desconectarWebSocket();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _enviarMensaje() async {
    final texto = _mensajeController.text.trim();
    if (texto.isEmpty) return;

    final controller = Provider.of<MensajeriaController>(
      context,
      listen: false,
    );

    try {
      await controller.enviarMensaje(widget.conversacionId, texto);
      _mensajeController.clear();
      _scrollToBottom();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al enviar mensaje: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Consumer<MensajeriaController>(
          builder: (context, controller, child) {
            final conversacion = controller.conversacionActual;
            return Text(
              conversacion?.otroUsuarioNombre ?? 'Chat',
            );
          },
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Consumer<MensajeriaController>(
        builder: (context, controller, child) {
          if (controller.isLoadingMensajes && controller.mensajes.isEmpty) {
            return const AppLoadingIndicator();
          }

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  reverse: true,
                  padding: AppSpacing.allLg,
                  itemCount: controller.mensajes.length,
                  itemBuilder: (context, index) {
                    final mensaje = controller.mensajes[index];
                    final esMio = _usuarioActualId != null &&
                        mensaje.esMio(_usuarioActualId!);
                    return _buildMensajeBubble(mensaje, esMio);
                  },
                ),
              ),
              _buildInputArea(controller),
            ],
          );
        },
      ),
    );
  }

  Widget _buildMensajeBubble(MensajeModel mensaje, bool esMio) {
    return Align(
      alignment: esMio ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.only(bottom: AppSpacing.md),
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        decoration: BoxDecoration(
          color: esMio ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(esMio ? AppRadius.lg : AppRadius.sm),
            topRight: Radius.circular(esMio ? AppRadius.sm : AppRadius.lg),
            bottomLeft: Radius.circular(AppRadius.lg),
            bottomRight: Radius.circular(AppRadius.lg),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              mensaje.contenido,
              style: AppTextStyles.bodyMedium.copyWith(
                color: esMio ? Colors.white : AppColors.textPrimary,
                fontSize: 15,
                height: 1.4,
              ),
            ),
            SizedBox(height: AppSpacing.xs),
            Text(
              _formatTime(mensaje.fechaEnvio),
              style: AppTextStyles.caption.copyWith(
                color: esMio ? Colors.white70 : AppColors.textTertiary,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputArea(MensajeriaController controller) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.background,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: AppRadius.xlBorder,
                ),
                child: TextField(
                  controller: _mensajeController,
                  decoration: InputDecoration(
                    hintText: 'Escribe un mensaje...',
                    hintStyle: AppTextStyles.caption,
                    border: OutlineInputBorder(
                      borderRadius: AppRadius.xlBorder,
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: AppRadius.xlBorder,
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: AppRadius.xlBorder,
                      borderSide: BorderSide(
                        color: AppColors.primary,
                        width: 1,
                      ),
                    ),
                    filled: true,
                    fillColor: AppColors.surface,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg,
                      vertical: AppSpacing.md,
                    ),
                  ),
                  maxLines: null,
                  textCapitalization: TextCapitalization.sentences,
                  style: AppTextStyles.bodyMedium,
                ),
              ),
            ),
            SizedBox(width: AppSpacing.sm),
            Container(
              decoration: BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: _enviarMensaje,
                  borderRadius: BorderRadius.circular(28),
                  child: Container(
                    width: 56,
                    height: 56,
                    padding: EdgeInsets.all(AppSpacing.md),
                    child: const Icon(
                      Icons.send,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}


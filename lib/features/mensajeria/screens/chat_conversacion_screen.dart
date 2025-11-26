import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/mensajeria_controller.dart';
import '../models/mensaje_model.dart';
import '../../../core/auth/services/session_storage.dart';

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
        backgroundColor: const Color(0xFF667eea),
        foregroundColor: Colors.white,
      ),
      body: Consumer<MensajeriaController>(
        builder: (context, controller, child) {
          if (controller.isLoadingMensajes && controller.mensajes.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF667eea),
              ),
            );
          }

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  reverse: true,
                  padding: const EdgeInsets.all(16),
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
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: esMio
              ? const Color(0xFF667eea)
              : const Color(0xFFe5e7eb),
          borderRadius: BorderRadius.circular(18),
        ),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              mensaje.contenido,
              style: TextStyle(
                color: esMio ? Colors.white : Colors.black87,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _formatTime(mensaje.fechaEnvio),
              style: TextStyle(
                color: esMio
                    ? Colors.white70
                    : Colors.black54,
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
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _mensajeController,
              decoration: InputDecoration(
                hintText: 'Escribe un mensaje...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: const Color(0xFFf3f4f6),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
              ),
              maxLines: null,
              textCapitalization: TextCapitalization.sentences,
            ),
          ),
          const SizedBox(width: 8),
          CircleAvatar(
            backgroundColor: const Color(0xFF667eea),
            child: IconButton(
              icon: const Icon(Icons.send, color: Colors.white),
              onPressed: _enviarMensaje,
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}


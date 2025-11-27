import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/mensajeria_controller.dart';
import '../models/conversacion_model.dart';
import 'chat_conversacion_screen.dart';
import 'buscar_usuario_screen.dart';
import '../../../widgets/app_sidebar.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppSidebar(),
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Mensajería'),
        backgroundColor: const Color(0xFF667eea),
        foregroundColor: Colors.white,
      ),
      body: Consumer<MensajeriaController>(
        builder: (context, controller, child) {
          if (controller.isLoading) {
            return const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF667eea),
              ),
            );
          }

          if (controller.errorMessage != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    controller.errorMessage!,
                    style: const TextStyle(color: Colors.red),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => controller.fetchConversaciones(),
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            );
          }

          if (controller.conversaciones.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.chat_bubble_outline,
                    size: 64,
                    color: Color(0xFF6b7280),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'No tienes conversaciones',
                    style: TextStyle(
                      fontSize: 16,
                      color: Color(0xFF6b7280),
                    ),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const BuscarUsuarioScreen(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Nueva conversación'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF667eea),
                      foregroundColor: Colors.white,
                    ),
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
              padding: const EdgeInsets.all(8),
              itemCount: controller.conversaciones.length,
              itemBuilder: (context, index) {
                final conversacion = controller.conversaciones[index];
                return _buildConversacionCard(context, conversacion, controller);
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const BuscarUsuarioScreen(),
            ),
          );
        },
        backgroundColor: const Color(0xFF667eea),
        child: const Icon(Icons.add, color: Colors.white),
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

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: const Color(0xFF667eea).withOpacity(0.1),
          child: conversacion.otroUsuarioFoto != null
              ? ClipOval(
                  child: Image.network(
                    conversacion.otroUsuarioFoto!,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(
                        Icons.person,
                        color: Color(0xFF667eea),
                      );
                    },
                  ),
                )
              : const Icon(
                  Icons.person,
                  color: Color(0xFF667eea),
                ),
        ),
        title: Text(
          conversacion.otroUsuarioNombre ?? 'Usuario',
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              preview,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF6b7280),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              timeAgo,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF9ca3af),
              ),
            ),
          ],
        ),
        trailing: conversacion.contadorNoLeidos > 0
            ? Container(
                padding: const EdgeInsets.all(6),
                decoration: const BoxDecoration(
                  color: Color(0xFF667eea),
                  shape: BoxShape.circle,
                ),
                child: Text(
                  conversacion.contadorNoLeidos > 9
                      ? '9+'
                      : conversacion.contadorNoLeidos.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
            : null,
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


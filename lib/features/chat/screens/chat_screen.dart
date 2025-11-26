import 'package:flutter/material.dart';
import '../models/mensaje_chat_model.dart';
import '../services/chat_service.dart';
import '../../../widgets/app_header.dart';
import '../../../widgets/app_sidebar.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _mensajeController = TextEditingController();
  final ChatService _chatService = ChatService();
  final List<MensajeChat> _mensajes = [];
  final ScrollController _scrollController = ScrollController();
  bool _estaEnviando = false;

  @override
  void initState() {
    super.initState();
    // Mensaje de bienvenida
    _mensajes.add(MensajeChat(
      id: 'bienvenida',
      contenido: '¡Hola! Soy tu asistente virtual de InnPulse360. ¿En qué puedo ayudarte? Puedes preguntarme sobre cómo usar la aplicación, crear reservas, reportar incidencias y más.',
      esUsuario: false,
      timestamp: DateTime.now(),
    ));
  }

  @override
  void dispose() {
    _mensajeController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _enviarMensaje() async {
    final texto = _mensajeController.text.trim();
    if (texto.isEmpty || _estaEnviando) return;

    // Agregar mensaje del usuario
    final mensajeUsuario = MensajeChat(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      contenido: texto,
      esUsuario: true,
      timestamp: DateTime.now(),
    );

    setState(() {
      _mensajes.add(mensajeUsuario);
      _estaEnviando = true;
    });

    _mensajeController.clear();
    _scrollToBottom();

    try {
      // Enviar al API
      final respuesta = await _chatService.enviarMensaje(texto);

      // Agregar respuesta del asistente
      final mensajeAsistente = MensajeChat(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        contenido: respuesta['response'] ?? 'Lo siento, no pude procesar tu mensaje.',
        esUsuario: false,
        timestamp: respuesta['timestamp'] != null
            ? DateTime.parse(respuesta['timestamp'])
            : DateTime.now(),
      );

      setState(() {
        _mensajes.add(mensajeAsistente);
        _estaEnviando = false;
      });

      _scrollToBottom();
    } catch (e) {
      setState(() {
        _mensajes.add(MensajeChat(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          contenido: 'Lo siento, hubo un error al procesar tu mensaje. Por favor verifica tu conexión e intenta de nuevo.',
          esUsuario: false,
          timestamp: DateTime.now(),
        ));
        _estaEnviando = false;
      });
      _scrollToBottom();
    }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppSidebar(),
      backgroundColor: Colors.grey.shade100,
      body: SafeArea(
        child: Column(
          children: [
            const AppHeader(),
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(16),
                itemCount: _mensajes.length + (_estaEnviando ? 1 : 0),
                itemBuilder: (context, index) {
                  if (_estaEnviando && index == _mensajes.length) {
                    // Mostrar efecto de estrellas cuando está pensando
                    return _buildEstrellasPensando();
                  }
                  final mensaje = _mensajes[index];
                  return _buildMensajeBurbuja(mensaje);
                },
              ),
            ),
            _buildInputMensaje(),
          ],
        ),
      ),
    );
  }

  Widget _buildMensajeBurbuja(MensajeChat mensaje) {
    final esUsuario = mensaje.esUsuario;
    
    return Align(
      alignment: esUsuario ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: esUsuario ? const Color(0xFF667eea) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Text(
          mensaje.contenido,
          style: TextStyle(
            color: esUsuario ? Colors.white : Colors.black87,
            fontSize: 15,
          ),
        ),
      ),
    );
  }

  Widget _buildEstrellasPensando() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: _EstrellasAnimadas(),
      ),
    );
  }

  Widget _buildInputMensaje() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
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
                hintText: 'Escribe tu mensaje...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey.shade100,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
              ),
              maxLines: null,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => _enviarMensaje(),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF667eea),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.send, color: Colors.white),
              onPressed: _estaEnviando ? null : _enviarMensaje,
            ),
          ),
        ],
      ),
    );
  }
}

/// Widget animado con efecto de estrellas mientras el asistente piensa
class _EstrellasAnimadas extends StatefulWidget {
  const _EstrellasAnimadas();

  @override
  State<_EstrellasAnimadas> createState() => _EstrellasAnimadasState();
}

class _EstrellasAnimadasState extends State<_EstrellasAnimadas>
    with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<double>> _animations;

  @override
  void initState() {
    super.initState();
    // Crear 3 animaciones para 3 estrellas
    _controllers = List.generate(
      3,
      (index) => AnimationController(
        duration: Duration(milliseconds: 800 + (index * 200)),
        vsync: this,
      )..repeat(),
    );

    _animations = _controllers.map((controller) {
      return Tween<double>(begin: 0.3, end: 1.0).animate(
        CurvedAnimation(
          parent: controller,
          curve: Curves.easeInOut,
        ),
      );
    }).toList();
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (index) {
        return AnimatedBuilder(
          animation: _animations[index],
          builder: (context, child) {
            return Opacity(
              opacity: _animations[index].value,
              child: Transform.scale(
                scale: 0.8 + (_animations[index].value * 0.2),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4),
                  child: Icon(
                    Icons.star,
                    color: Color(0xFF667eea),
                    size: 20,
                  ),
                ),
              ),
            );
          },
        );
      }),
    );
  }
}


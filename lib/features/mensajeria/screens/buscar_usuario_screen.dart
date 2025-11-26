import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/mensajeria_controller.dart';
import '../models/conversacion_model.dart';
import '../models/usuario_chat_model.dart';
import 'chat_conversacion_screen.dart';
import '../../../core/auth/services/session_storage.dart';

class BuscarUsuarioScreen extends StatefulWidget {
  const BuscarUsuarioScreen({super.key});

  @override
  State<BuscarUsuarioScreen> createState() => _BuscarUsuarioScreenState();
}

class _BuscarUsuarioScreenState extends State<BuscarUsuarioScreen> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final controller = Provider.of<MensajeriaController>(
          context,
          listen: false,
        );
        controller.buscarUsuarios(null);
      }
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      final controller = Provider.of<MensajeriaController>(
        context,
        listen: false,
      );
      controller.buscarUsuarios(_searchController.text.isEmpty
          ? null
          : _searchController.text);
    });
  }

  Future<void> _crearConversacion(UsuarioChatModel usuario) async {
    final controller = Provider.of<MensajeriaController>(
      context,
      listen: false,
    );

    try {
      ConversacionModel conversacion;
      final session = await SessionStorage.getSession();
      final usuarioActual = session?['usuario'] as Map<String, dynamic>?;
      final clienteId = usuarioActual?['cliente_id'] as int?;
      final empleadoId = usuarioActual?['empleado_id'] as int?;

      if (clienteId != null) {
        // Cliente creando conversación con admin
        conversacion = await controller.crearConversacionClienteAdmin(
          clienteId: clienteId,
          adminId: usuario.idUsuario,
        );
      } else if (empleadoId != null && usuario.empleadoId != null) {
        // Empleado creando conversación con otro empleado
        conversacion = await controller.crearConversacionEmpleadoEmpleado(
          empleado1Id: empleadoId,
          empleado2Id: usuario.empleadoId!,
        );
      } else {
        throw Exception('No se puede crear la conversación');
      }

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ChatConversacionScreen(
              conversacionId: conversacion.idConversacion,
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nueva conversación'),
        backgroundColor: const Color(0xFF667eea),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Buscar usuario...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          Expanded(
            child: Consumer<MensajeriaController>(
              builder: (context, controller, child) {
                if (controller.isLoading) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFF667eea),
                    ),
                  );
                }

                if (controller.usuariosDisponibles.isEmpty) {
                  return const Center(
                    child: Text('No se encontraron usuarios'),
                  );
                }

                return ListView.builder(
                  itemCount: controller.usuariosDisponibles.length,
                  itemBuilder: (context, index) {
                    final usuario = controller.usuariosDisponibles[index];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: const Color(0xFF667eea).withOpacity(0.1),
                        child: usuario.urlFotoPerfil != null
                            ? ClipOval(
                                child: Image.network(
                                  usuario.urlFotoPerfil!,
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
                      title: Text(usuario.nombre),
                      subtitle: Text(usuario.tipoUsuario),
                      onTap: () => _crearConversacion(usuario),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}


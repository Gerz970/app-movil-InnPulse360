import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/mensajeria_controller.dart';
import '../models/conversacion_model.dart';
import '../models/usuario_chat_model.dart';
import 'chat_conversacion_screen.dart';
import '../../../core/auth/services/session_storage.dart';
import '../../../core/theme/app_theme.dart';
import '../../../widgets/app_text_field.dart';
import '../../../widgets/app_loading_indicator.dart';
import '../../../widgets/app_empty_state.dart';
import '../../../widgets/app_card.dart';

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

  Widget _buildUsuarioCard(UsuarioChatModel usuario) {
    return AppCard(
      margin: EdgeInsets.symmetric(
        horizontal: AppSpacing.xs,
        vertical: AppSpacing.xs,
      ),
      onTap: () => _crearConversacion(usuario),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: AppColors.primary.withOpacity(0.1),
            child: usuario.urlFotoPerfil != null
                ? ClipOval(
                    child: Image.network(
                      usuario.urlFotoPerfil!,
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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  usuario.nombre,
                  style: AppTextStyles.h3,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: AppSpacing.xs),
                Text(
                  usuario.tipoUsuario,
                  style: AppTextStyles.bodyMedium,
                ),
              ],
            ),
          ),
          Icon(
            Icons.arrow_forward_ios,
            size: 16,
            color: AppColors.textTertiary,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nueva conversación'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Padding(
            padding: AppSpacing.allLg,
            child: AppTextField(
              controller: _searchController,
              label: 'Buscar usuario',
              hint: 'Escribe el nombre del usuario...',
              prefixIcon: Icons.search,
            ),
          ),
          Expanded(
            child: Consumer<MensajeriaController>(
              builder: (context, controller, child) {
                if (controller.isLoading) {
                  return const AppLoadingIndicator();
                }

                // Mostrar error si existe
                if (controller.errorMessage != null) {
                  return Center(
                    child: Padding(
                      padding: AppSpacing.allLg,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: 64,
                            color: AppColors.error,
                          ),
                          SizedBox(height: AppSpacing.md),
                          Text(
                            'Error al buscar usuarios',
                            style: AppTextStyles.h2.copyWith(
                              color: AppColors.error,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: AppSpacing.sm),
                          Text(
                            controller.errorMessage!,
                            style: AppTextStyles.bodyMedium,
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: AppSpacing.lg),
                          ElevatedButton.icon(
                            onPressed: () {
                              controller.buscarUsuarios(
                                _searchController.text.isEmpty
                                    ? null
                                    : _searchController.text,
                              );
                            },
                            icon: const Icon(Icons.refresh),
                            label: const Text('Reintentar'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(
                                horizontal: AppSpacing.lg,
                                vertical: AppSpacing.md,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                // Mostrar mensaje cuando no hay resultados (pero no hay error)
                if (controller.usuariosDisponibles.isEmpty) {
                  return AppEmptyState(
                    icon: Icons.search_off,
                    title: 'No se encontraron usuarios',
                    message: _searchController.text.isEmpty
                        ? 'No hay usuarios disponibles para iniciar una conversación'
                        : 'No se encontraron usuarios que coincidan con "${_searchController.text}"',
                  );
                }

                return ListView.builder(
                  padding: EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                  itemCount: controller.usuariosDisponibles.length,
                  itemBuilder: (context, index) {
                    final usuario = controller.usuariosDisponibles[index];
                    return _buildUsuarioCard(usuario);
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


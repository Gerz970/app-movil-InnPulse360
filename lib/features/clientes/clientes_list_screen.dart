import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../widgets/app_header.dart';
import '../../widgets/app_sidebar.dart';
import '../../widgets/app_card.dart';
import '../../widgets/app_empty_state.dart';
import '../../widgets/app_error_state.dart';
import '../../widgets/app_loading_indicator.dart';
import '../../core/theme/app_theme.dart';
import 'controllers/cliente_controller.dart';
import 'models/cliente_model.dart';
import 'cliente_create_screen.dart';
import 'cliente_detail_screen.dart';
import '../login/login_screen.dart';

/// Pantalla de listado de clientes
/// Muestra los clientes en cards visualmente agradables
class ClientesListScreen extends StatefulWidget {
  const ClientesListScreen({super.key});

  @override
  State<ClientesListScreen> createState() => _ClientesListScreenState();
}

class _ClientesListScreenState extends State<ClientesListScreen> {
  @override
  void initState() {
    super.initState();
    // Cargar clientes al iniciar la pantalla
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final controller = Provider.of<ClienteController>(context, listen: false);
      controller.fetchClientes();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      drawer: const AppSidebar(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navegar a la pantalla de creación de cliente
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const ClienteCreateScreen(),
            ),
          );
        },
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Header global reutilizable
            const AppHeader(),
            // Contenido principal
            Expanded(
              child: Consumer<ClienteController>(
                builder: (context, controller, child) {
                  // Estado de carga
                  if (controller.isLoading) {
                    return const AppLoadingIndicator();
                  }

                  // Estado de error
                  if (controller.errorMessage != null) {
                    return AppErrorState(
                      message: controller.errorMessage ?? 'Error desconocido',
                      onRetry: () => controller.fetchClientes(),
                      showReauthenticate: controller.isNotAuthenticated,
                      onReauthenticate: controller.isNotAuthenticated
                          ? () {
                              Navigator.of(context).pushAndRemoveUntil(
                                MaterialPageRoute(
                                  builder: (context) => const LoginScreen(),
                                ),
                                (route) => false,
                              );
                            }
                          : null,
                    );
                  }

                  // Estado vacío
                  if (controller.isEmpty) {
                    return const AppEmptyState(
                      icon: Icons.people_outline,
                      title: 'No hay clientes',
                    );
                  }

                  // Estado exitoso - Lista de clientes
                  return _buildClientesList(controller);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }


  /// Widget para mostrar lista de clientes
  Widget _buildClientesList(ClienteController controller) {
    return ListView.builder(
      padding: AppSpacing.allLg,
      itemCount: controller.clientes.length,
      itemBuilder: (context, index) {
        final cliente = controller.clientes[index];
        return _buildClienteCard(cliente);
      },
    );
  }

  /// Widget para construir una card de cliente
  Widget _buildClienteCard(Cliente cliente) {
    return AppCard(
      onTap: () async {
        // Navegar a la pantalla de detalle del cliente
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ClienteDetailScreen(
              clienteId: cliente.idCliente,
            ),
          ),
        );
        
        // Si se actualizó el cliente, refrescar la lista
        if (result == true && mounted) {
          final controller = Provider.of<ClienteController>(context, listen: false);
          controller.fetchClientes();
        }
      },
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Ícono según tipo de persona
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primary.withOpacity(0.1),
            ),
            child: Icon(
              cliente.tipoPersona == 1 ? Icons.person : Icons.business,
              color: AppColors.primary,
              size: 28,
            ),
          ),
          SizedBox(width: AppSpacing.lg),
          // Información del cliente
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Nombre/Razón social y menú
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        cliente.nombreRazonSocial,
                        style: AppTextStyles.h3,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    // Menú contextual
                    PopupMenuButton<String>(
                      icon: Icon(
                        Icons.more_vert,
                        color: AppColors.textSecondary,
                        size: 20,
                      ),
                      onSelected: (value) {
                        if (value == 'delete') {
                          _showDeleteConfirmationDialog(context, cliente);
                        }
                      },
                      itemBuilder: (BuildContext context) => [
                        PopupMenuItem<String>(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(
                                Icons.delete,
                                color: AppColors.error,
                                size: 20,
                              ),
                              SizedBox(width: AppSpacing.sm),
                              Text(
                                'Eliminar',
                                style: TextStyle(
                                  color: AppColors.error,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: AppSpacing.sm),
                // Apellidos (solo si es Persona Física)
                if (cliente.tipoPersona == 1 && 
                    (cliente.apellidoPaterno != null || cliente.apellidoMaterno != null))
                  Text(
                    [cliente.apellidoPaterno, cliente.apellidoMaterno]
                        .where((a) => a != null && a.isNotEmpty)
                        .join(' '),
                    style: AppTextStyles.bodyMedium,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                if (cliente.tipoPersona == 1 && 
                    (cliente.apellidoPaterno != null || cliente.apellidoMaterno != null))
                  SizedBox(height: AppSpacing.sm),
                // RFC
                Row(
                  children: [
                    Icon(
                      Icons.badge,
                      size: 16,
                      color: AppColors.textSecondary,
                    ),
                    SizedBox(width: AppSpacing.xs),
                    Text(
                      cliente.rfc,
                      style: AppTextStyles.bodySmall.copyWith(
                        fontFamily: 'monospace',
                      ),
                    ),
                  ],
                ),
                SizedBox(height: AppSpacing.sm),
                // Badge de tipo de persona
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: AppSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: cliente.tipoPersona == 1
                        ? Colors.blue.shade50
                        : Colors.purple.shade50,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: cliente.tipoPersona == 1
                          ? Colors.blue.shade200
                          : Colors.purple.shade200,
                      width: 1,
                    ),
                  ),
                  child: Text(
                    cliente.tipoPersonaTexto,
                    style: AppTextStyles.caption.copyWith(
                      fontWeight: FontWeight.w500,
                      color: cliente.tipoPersona == 1
                          ? Colors.blue.shade700
                          : Colors.purple.shade700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Método para mostrar el modal de confirmación de eliminación
  void _showDeleteConfirmationDialog(BuildContext context, Cliente cliente) {
    final TextEditingController confirmController = TextEditingController();
    final String confirmText = 'Eliminar Cliente';
    bool isValid = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(
                'Eliminar cliente',
                style: AppTextStyles.h2,
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Esta acción es permanente. Escribe \'Eliminar Cliente\' para confirmar.',
                    style: AppTextStyles.bodyMedium,
                  ),
                  SizedBox(height: AppSpacing.lg),
                  TextFormField(
                    controller: confirmController,
                    autofocus: true,
                    decoration: AppInputStyles.standard(
                      label: 'Confirmar eliminación',
                      hint: 'Escribe: Eliminar Cliente',
                    ).copyWith(
                      errorBorder: OutlineInputBorder(
                        borderRadius: AppRadius.smBorder,
                        borderSide: const BorderSide(
                          color: AppColors.error,
                          width: 1,
                        ),
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderRadius: AppRadius.smBorder,
                        borderSide: const BorderSide(
                          color: AppColors.error,
                          width: 2,
                        ),
                      ),
                    ),
                    onChanged: (value) {
                      setState(() {
                        isValid = value.trim() == confirmText;
                      });
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    confirmController.dispose();
                    Navigator.of(dialogContext).pop();
                  },
                  child: Text(
                    'Cancelar',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: isValid
                      ? () {
                          confirmController.dispose();
                          Navigator.of(dialogContext).pop();
                          _handleDelete(context, cliente);
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.error,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: Colors.grey.shade300,
                  ),
                  child: const Text('Eliminar'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  /// Método para manejar la eliminación del cliente
  Future<void> _handleDelete(BuildContext context, Cliente cliente) async {
    final controller = Provider.of<ClienteController>(context, listen: false);

    // Mostrar overlay de carga
    if (!context.mounted) return;
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return const Center(
          child: Card(
            child: Padding(
              padding: EdgeInsets.all(24.0),
              child: AppLoadingIndicator(
                message: 'Eliminando...',
              ),
            ),
          ),
        );
      },
    );

    try {
      // Ejecutar eliminación
      final success = await controller.deleteCliente(cliente.idCliente);

      // Cerrar overlay de carga de forma más agresiva
      if (context.mounted) {
        try {
          Navigator.of(context, rootNavigator: true).pop();
        } catch (e) {
          print('Error al cerrar diálogo: $e');
        }
      }

      // Esperar un momento para que el diálogo se cierre completamente
      await Future.delayed(const Duration(milliseconds: 150));

      if (success) {
        // Mostrar mensaje de éxito
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Cliente eliminado con éxito'),
              backgroundColor: AppColors.success,
            ),
          );
          // Refrescar lista
          controller.fetchClientes();
        }
      } else {
        // Mostrar mensaje de error
        if (context.mounted) {
          final errorMessage = controller.deleteErrorMessage ?? 'Error al eliminar el cliente';
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorMessage),
              backgroundColor: AppColors.error,
              action: SnackBarAction(
                label: 'Reintentar',
                textColor: Colors.white,
                onPressed: () {
                  _handleDelete(context, cliente);
                },
              ),
            ),
          );

          // Si es error de autenticación, redirigir a login
          if (controller.isNotAuthenticated) {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(
                builder: (context) => const LoginScreen(),
              ),
              (route) => false,
            );
          }
        }
      }
    } catch (e) {
      // Cerrar overlay de carga en caso de error
      if (context.mounted) {
        try {
          Navigator.of(context, rootNavigator: true).pop();
        } catch (err) {
          print('Error al cerrar diálogo en catch: $err');
        }
      }
    }
  }
}


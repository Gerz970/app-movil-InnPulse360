import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../widgets/app_header.dart';
import '../../widgets/app_sidebar.dart';
import '../../widgets/app_empty_state.dart';
import '../../widgets/app_error_state.dart';
import '../../widgets/app_loading_indicator.dart';
import '../../core/theme/app_theme.dart';
import 'controllers/incidencia_controller.dart';
import 'models/incidencia_model.dart';
import 'incidencia_create_screen.dart';
import 'incidencia_edit_screen.dart';
import 'incidencia_detail_screen.dart';
import '../login/login_screen.dart';

/// Pantalla de listado de incidencias
/// Muestra las incidencias en cards visualmente agradables
class IncidenciasListScreen extends StatefulWidget {
  const IncidenciasListScreen({super.key});

  @override
  State<IncidenciasListScreen> createState() => _IncidenciasListScreenState();
}

class _IncidenciasListScreenState extends State<IncidenciasListScreen> {
  @override
  void initState() {
    super.initState();
    // Cargar incidencias al iniciar la pantalla
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final controller = Provider.of<IncidenciaController>(context, listen: false);
        controller.fetchIncidencias();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      drawer: const AppSidebar(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navegar a la pantalla de creación de incidencia
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const IncidenciaCreateScreen(),
            ),
          ).then((_) {
            // Refrescar lista al regresar
            final controller = Provider.of<IncidenciaController>(context, listen: false);
            controller.fetchIncidencias();
          });
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
              child: Consumer<IncidenciaController>(
                builder: (context, controller, child) {
                  // Estado de carga
                  if (controller.isLoading) {
                    return const AppLoadingIndicator();
                  }

                  // Estado de error
                  if (controller.errorMessage != null) {
                    return AppErrorState(
                      message: controller.errorMessage ?? 'Error desconocido',
                      onRetry: () => controller.fetchIncidencias(),
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
                      icon: Icons.report_outlined,
                      title: 'Aún no hay incidencias',
                    );
                  }

                  // Estado exitoso - Lista de incidencias
                  return _buildIncidenciasList(controller);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }


  /// Widget para mostrar lista de incidencias
  Widget _buildIncidenciasList(IncidenciaController controller) {
    return Column(
      children: [
        // Header con gradiente
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.primary.withOpacity(0.05),
                Colors.white,
              ],
            ),
            border: Border(
              bottom: BorderSide(color: Colors.grey.shade200),
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.report,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Incidencias',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1a1a1a),
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
        ),
        // Lista de incidencias
        Expanded(
          child: ListView.builder(
            padding: AppSpacing.allLg,
            itemCount: controller.incidencias.length,
            itemBuilder: (context, index) {
              final incidencia = controller.incidencias[index];
              return _buildIncidenciaCard(incidencia, controller);
            },
          ),
        ),
      ],
    );
  }

  /// Widget para construir una card de incidencia
  Widget _buildIncidenciaCard(Incidencia incidencia, IncidenciaController controller) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
            spreadRadius: 0,
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () async {
            // Navegar a la pantalla de edición de incidencia
            final result = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => IncidenciaEditScreen(
                  incidenciaId: incidencia.idIncidencia,
                ),
              ),
            );
            
            // Si se actualizó la incidencia, refrescar la lista
            if (result == true && mounted) {
              controller.fetchIncidencias();
            }
          },
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.grey.shade100,
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header con título y menú
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  AppColors.primary.withOpacity(0.15),
                                  AppColors.primary.withOpacity(0.08),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.report,
                              color: AppColors.primary,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              incidencia.incidencia,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF1a1a1a),
                                letterSpacing: -0.5,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
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
                        if (value == 'edit') {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => IncidenciaEditScreen(
                                incidenciaId: incidencia.idIncidencia,
                              ),
                            ),
                          ).then((result) {
                            if (result == true && mounted) {
                              controller.fetchIncidencias();
                            }
                          });
                        } else if (value == 'delete') {
                          _showDeleteConfirmationDialog(context, incidencia, controller);
                        } else if (value == 'detail') {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => IncidenciaDetailScreen(
                                incidenciaId: incidencia.idIncidencia,
                              ),
                            ),
                          );
                        }
                      },
                      itemBuilder: (BuildContext context) => [
                        PopupMenuItem<String>(
                          value: 'detail',
                          child: Row(
                            children: [
                              Icon(
                                Icons.visibility,
                                color: AppColors.primary,
                                size: 20,
                              ),
                              SizedBox(width: AppSpacing.sm),
                              const Text('Ver detalle'),
                            ],
                          ),
                        ),
                        PopupMenuItem<String>(
                          value: 'edit',
                          child: Row(
                            children: [
                              Icon(
                                Icons.edit,
                                color: AppColors.primary,
                                size: 20,
                              ),
                              SizedBox(width: AppSpacing.sm),
                              const Text('Editar'),
                            ],
                          ),
                        ),
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
                const SizedBox(height: 16),
                // Descripción
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.grey.shade100,
                      width: 1,
                    ),
                  ),
                  child: Text(
                    incidencia.descripcion,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF6b7280),
                      height: 1.5,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(height: 16),
                // Información adicional
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.calendar_today,
                              size: 16,
                              color: Colors.grey.shade600,
                            ),
                            const SizedBox(width: 6),
                            Flexible(
                              child: Text(
                                incidencia.fechaFormateada,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade700,
                                  fontWeight: FontWeight.w500,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (incidencia.habitacionArea != null) ...[
                      const SizedBox(width: 8),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.room,
                                size: 16,
                                color: Colors.grey.shade600,
                              ),
                              const SizedBox(width: 6),
                              Flexible(
                                child: Text(
                                  incidencia.habitacionArea!.nombreClave,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade700,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 16),
                // Badge de estatus mejorado
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: incidencia.idEstatus == 1
                          ? [
                              AppColors.success.withOpacity(0.15),
                              AppColors.success.withOpacity(0.08),
                            ]
                          : [
                              AppColors.error.withOpacity(0.15),
                              AppColors.error.withOpacity(0.08),
                            ],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: (incidencia.idEstatus == 1
                              ? AppColors.success
                              : AppColors.error)
                          .withOpacity(0.3),
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        incidencia.idEstatus == 1
                            ? Icons.check_circle
                            : Icons.cancel,
                        size: 16,
                        color: incidencia.idEstatus == 1
                            ? AppColors.success
                            : AppColors.error,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        incidencia.idEstatus == 1 ? 'Activa' : 'Inactiva',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: incidencia.idEstatus == 1
                              ? AppColors.success
                              : AppColors.error,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Método para mostrar el modal de confirmación de eliminación
  void _showDeleteConfirmationDialog(BuildContext context, Incidencia incidencia, IncidenciaController controller) {
    final TextEditingController confirmController = TextEditingController();
    final String confirmText = 'Eliminar incidencia';
    bool isValid = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(
                'Eliminar incidencia',
                style: AppTextStyles.h2,
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Esta acción es permanente. Escribe \'Eliminar incidencia\' para confirmar.',
                    style: AppTextStyles.bodyMedium,
                  ),
                  SizedBox(height: AppSpacing.lg),
                  TextFormField(
                    controller: confirmController,
                    autofocus: true,
                    decoration: AppInputStyles.standard(
                      label: 'Confirmar eliminación',
                      hint: 'Escribe: Eliminar incidencia',
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
                          _handleDelete(context, incidencia, controller);
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

  /// Método para manejar la eliminación de la incidencia
  Future<void> _handleDelete(BuildContext context, Incidencia incidencia, IncidenciaController controller) async {
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
      final success = await controller.deleteIncidencia(incidencia.idIncidencia);

      // Cerrar overlay de carga
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
              content: const Text('Incidencia eliminada con éxito'),
              backgroundColor: AppColors.success,
            ),
          );
          // Refrescar lista
          controller.fetchIncidencias();
        }
      } else {
        // Mostrar mensaje de error
        if (context.mounted) {
          final errorMessage = controller.deleteErrorMessage ?? 'Error al eliminar la incidencia';
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorMessage),
              backgroundColor: AppColors.error,
              action: SnackBarAction(
                label: 'Reintentar',
                textColor: Colors.white,
                onPressed: () {
                  _handleDelete(context, incidencia, controller);
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


import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../widgets/app_header.dart';
import '../../widgets/app_sidebar.dart';
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
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
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
        backgroundColor: const Color(0xFF667eea),
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
                    return const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF667eea),
                      ),
                    );
                  }

                  // Estado de error
                  if (controller.errorMessage != null) {
                    return _buildErrorState(context, controller);
                  }

                  // Estado vacío
                  if (controller.isEmpty) {
                    return _buildEmptyState();
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

  /// Widget para mostrar estado de error
  Widget _buildErrorState(BuildContext context, IncidenciaController controller) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red.shade300,
            ),
            const SizedBox(height: 16),
            Text(
              controller.errorMessage ?? 'Error desconocido',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Color(0xFF1a1a1a),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    controller.fetchIncidencias();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF667eea),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Reintentar'),
                ),
                if (controller.isNotAuthenticated) ...[
                  const SizedBox(width: 12),
                  OutlinedButton(
                    onPressed: () {
                      // Navegar a LoginScreen
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(
                          builder: (context) => const LoginScreen(),
                        ),
                        (route) => false,
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF667eea),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      side: const BorderSide(
                        color: Color(0xFF667eea),
                        width: 1,
                      ),
                    ),
                    child: const Text('Reautenticar'),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Widget para mostrar estado vacío
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.report_outlined,
            size: 80,
            color: const Color(0xFF667eea).withOpacity(0.3),
          ),
          const SizedBox(height: 24),
          const Text(
            'Aún no hay incidencias',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Color(0xFF6b7280),
              letterSpacing: -0.3,
            ),
          ),
        ],
      ),
    );
  }

  /// Widget para mostrar lista de incidencias
  Widget _buildIncidenciasList(IncidenciaController controller) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: controller.incidencias.length,
      itemBuilder: (context, index) {
        final incidencia = controller.incidencias[index];
        return _buildIncidenciaCard(incidencia, controller);
      },
    );
  }

  /// Widget para construir una card de incidencia
  Widget _buildIncidenciaCard(Incidencia incidencia, IncidenciaController controller) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
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
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Primera fila: Ícono, información y menú
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Ícono de incidencia
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFF667eea).withOpacity(0.1),
                    ),
                    child: const Icon(
                      Icons.report,
                      color: Color(0xFF667eea),
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Información de la incidencia
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Título de la incidencia y menú
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                incidencia.incidencia,
                                style: const TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF1a1a1a),
                                  letterSpacing: -0.3,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            // Menú contextual
                            PopupMenuButton<String>(
                              icon: const Icon(
                                Icons.more_vert,
                                color: Color(0xFF6b7280),
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
                                const PopupMenuItem<String>(
                                  value: 'detail',
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.visibility,
                                        color: Color(0xFF667eea),
                                        size: 20,
                                      ),
                                      SizedBox(width: 8),
                                      Text('Ver detalle'),
                                    ],
                                  ),
                                ),
                                const PopupMenuItem<String>(
                                  value: 'edit',
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.edit,
                                        color: Color(0xFF667eea),
                                        size: 20,
                                      ),
                                      SizedBox(width: 8),
                                      Text('Editar'),
                                    ],
                                  ),
                                ),
                                const PopupMenuItem<String>(
                                  value: 'delete',
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.delete,
                                        color: Colors.red,
                                        size: 20,
                                      ),
                                      SizedBox(width: 8),
                                      Text(
                                        'Eliminar',
                                        style: TextStyle(
                                          color: Colors.red,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        // Descripción truncada
                        Text(
                          incidencia.descripcion,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: const Color(0xFF6b7280),
                            letterSpacing: -0.2,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 12),
                        // Fecha y habitación/área
                        Row(
                          children: [
                            const Icon(
                              Icons.calendar_today,
                              size: 16,
                              color: Color(0xFF6b7280),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              incidencia.fechaFormateada,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF6b7280),
                              ),
                            ),
                            if (incidencia.habitacionArea != null) ...[
                              const SizedBox(width: 16),
                              const Icon(
                                Icons.room,
                                size: 16,
                                color: Color(0xFF6b7280),
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  incidencia.habitacionArea!.nombreClave,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF6b7280),
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 8),
                        // Badge de estatus
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: incidencia.idEstatus == 1
                                ? Colors.green.shade50
                                : Colors.red.shade50,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                incidencia.idEstatus == 1
                                    ? Icons.check_circle
                                    : Icons.cancel,
                                size: 12,
                                color: incidencia.idEstatus == 1
                                    ? Colors.green
                                    : Colors.red,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                incidencia.idEstatus == 1 ? 'Activa' : 'Inactiva',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                  color: incidencia.idEstatus == 1
                                      ? Colors.green
                                      : Colors.red,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
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
              title: const Text(
                'Eliminar incidencia',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1a1a1a),
                ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Esta acción es permanente. Escribe \'Eliminar incidencia\' para confirmar.',
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF6b7280),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: confirmController,
                    autofocus: true,
                    decoration: InputDecoration(
                      labelText: 'Confirmar eliminación',
                      hintText: 'Escribe: Eliminar incidencia',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(
                          color: Colors.red,
                          width: 1,
                        ),
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(
                          color: Colors.red,
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
                  child: const Text(
                    'Cancelar',
                    style: TextStyle(
                      color: Color(0xFF6b7280),
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
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(
                    color: Color(0xFF667eea),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Eliminando...',
                    style: TextStyle(
                      fontSize: 16,
                      color: Color(0xFF6b7280),
                    ),
                  ),
                ],
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
            const SnackBar(
              content: Text('Incidencia eliminada con éxito'),
              backgroundColor: Colors.green,
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
              backgroundColor: Colors.red,
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


import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../widgets/app_header.dart';
import '../../widgets/app_sidebar.dart';
import 'controllers/hotel_controller.dart';
import 'models/hotel_model.dart';
import 'hotel_create_screen.dart';
import 'hotel_detail_screen.dart';
import '../login/login_screen.dart';

/// Pantalla de listado de hoteles
/// Muestra los hoteles en cards visualmente agradables
class HotelsListScreen extends StatefulWidget {
  const HotelsListScreen({super.key});

  @override
  State<HotelsListScreen> createState() => _HotelsListScreenState();
}

class _HotelsListScreenState extends State<HotelsListScreen> {
  @override
  void initState() {
    super.initState();
    // Cargar hoteles al iniciar la pantalla
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final controller = Provider.of<HotelController>(context, listen: false);
      controller.fetchHotels();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      drawer: const AppSidebar(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navegar a la pantalla de creación de hotel
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const HotelCreateScreen(),
            ),
          );
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
              child: Consumer<HotelController>(
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

                  // Estado exitoso - Lista de hoteles
                  return _buildHotelsList(controller);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Widget para mostrar estado de error
  Widget _buildErrorState(BuildContext context, HotelController controller) {
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
                    controller.fetchHotels();
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
            Icons.travel_explore,
            size: 80,
            color: const Color(0xFF667eea).withOpacity(0.3),
          ),
          const SizedBox(height: 24),
          const Text(
            'Aún no hay hoteles',
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

  /// Widget para mostrar lista de hoteles
  Widget _buildHotelsList(HotelController controller) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: controller.hotels.length,
      itemBuilder: (context, index) {
        final hotel = controller.hotels[index];
        return _buildHotelCard(hotel);
      },
    );
  }

  /// Widget para construir una card de hotel
  Widget _buildHotelCard(Hotel hotel) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: () async {
          // Navegar a la pantalla de detalle del hotel
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => HotelDetailScreen(
                hotelId: hotel.idHotel,
              ),
            ),
          );
          
          // Si se actualizó el hotel, refrescar la lista
          if (result == true && mounted) {
            final controller = Provider.of<HotelController>(context, listen: false);
            controller.fetchHotels();
          }
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Foto de hotel
              ClipOval(
                child: hotel.urlFotoPerfil != null && hotel.urlFotoPerfil!.isNotEmpty
                    ? Image.network(
                        hotel.urlFotoPerfil!,
                        width: 56,
                        height: 56,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: const Color(0xFF667eea).withOpacity(0.1),
                            ),
                            child: const Icon(
                              Icons.hotel,
                              color: Color(0xFF667eea),
                              size: 28,
                            ),
                          );
                        },
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: const Color(0xFF667eea).withOpacity(0.1),
                            ),
                            child: const Center(
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Color(0xFF667eea),
                              ),
                            ),
                          );
                        },
                      )
                    : Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFF667eea).withOpacity(0.1),
                        ),
                        child: const Icon(
                          Icons.hotel,
                          color: Color(0xFF667eea),
                          size: 28,
                        ),
                      ),
              ),
              const SizedBox(width: 16),
              // Información del hotel
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Nombre del hotel y menú
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            hotel.nombre,
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
                            if (value == 'delete') {
                              _showDeleteConfirmationDialog(context, hotel);
                            }
                          },
                          itemBuilder: (BuildContext context) => [
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
                    // Dirección
                    Text(
                      hotel.direccion,
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
                    // Teléfono y email
                    if (hotel.telefono != null || hotel.emailContacto != null)
                      Row(
                        children: [
                          if (hotel.telefono != null) ...[
                            const Icon(
                              Icons.phone,
                              size: 16,
                              color: Color(0xFF6b7280),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              hotel.telefono!,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF6b7280),
                              ),
                            ),
                          ],
                          if (hotel.telefono != null &&
                              hotel.emailContacto != null)
                            const SizedBox(width: 16),
                          if (hotel.emailContacto != null) ...[
                            const Icon(
                              Icons.mail,
                              size: 16,
                              color: Color(0xFF6b7280),
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                hotel.emailContacto!,
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
                    // Estrellas
                    Row(
                      children: List.generate(
                        5,
                        (index) => Icon(
                          Icons.star,
                          size: 16,
                          color: index < hotel.numeroEstrellas
                              ? Colors.amber
                              : Colors.grey.shade300,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Método para mostrar el modal de confirmación de eliminación
  void _showDeleteConfirmationDialog(BuildContext context, Hotel hotel) {
    final TextEditingController confirmController = TextEditingController();
    final String confirmText = 'Eliminar hotel';
    bool isValid = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text(
                'Eliminar hotel',
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
                    'Esta acción es permanente. Escribe \'Eliminar hotel\' para confirmar.',
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
                      hintText: 'Escribe: Eliminar hotel',
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
                          _handleDelete(context, hotel);
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

  /// Método para manejar la eliminación del hotel
  Future<void> _handleDelete(BuildContext context, Hotel hotel) async {
    final controller = Provider.of<HotelController>(context, listen: false);

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
      final success = await controller.deleteHotel(hotel.idHotel);

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
            const SnackBar(
              content: Text('Hotel eliminado con éxito'),
              backgroundColor: Colors.green,
            ),
          );
          // Refrescar lista
          controller.fetchHotels();
        }
      } else {
        // Mostrar mensaje de error
        if (context.mounted) {
          final errorMessage = controller.deleteErrorMessage ?? 'Error al eliminar el hotel';
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorMessage),
              backgroundColor: Colors.red,
              action: SnackBarAction(
                label: 'Reintentar',
                textColor: Colors.white,
                onPressed: () {
                  _handleDelete(context, hotel);
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


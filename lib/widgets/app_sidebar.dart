import 'package:app_movil_innpulse/features/pisos/piso_list_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/auth/controllers/auth_controller.dart';
import '../features/hoteles/hotels_list_screen.dart';
import '../features/clientes/clientes_list_screen.dart';
import '../features/incidencias/incidencias_list_screen.dart';
import '../features/common/under_construction_screen.dart';
import '../features/hoteles/controllers/hotel_controller.dart';

/// Widget de sidebar lateral reutilizable para toda la aplicación
/// Muestra información del usuario y lista de módulos disponibles
class AppSidebar extends StatelessWidget {
  const AppSidebar({super.key});

  /// Función auxiliar para extraer un String de forma segura del loginResponse
  String _extractString(Map<String, dynamic>? data, String key) {
    if (data == null) return 'Usuario';
    final value = data[key];
    if (value is String) {
      return value;
    }
    return 'Usuario';
  }

  @override
  Widget build(BuildContext context) {
    final hotelController = Provider.of<HotelController>(context);
    return Consumer<AuthController>(
      builder: (context, authController, child) {
        // Obtener datos del usuario del loginResponse
        final loginResponse = authController.loginResponse;

        // Extraer el campo "login" del usuario
        String userLogin = 'Usuario';
        if (loginResponse != null) {
          userLogin = _extractString(loginResponse, 'login');
          if (userLogin == 'Usuario') {
            userLogin = _extractString(loginResponse, 'username');
          }
          if (userLogin == 'Usuario') {
            userLogin = _extractString(loginResponse, 'usuario');
          }
        }

        return Drawer(
          width: 280,
          child: SafeArea(
            child: Column(
              children: [
                // Sección superior con información del usuario
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border(
                      bottom: BorderSide(
                        color: const Color(0xFFe5e7eb),
                        width: 1,
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      // Foto de perfil circular
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFF667eea).withOpacity(0.1),
                          border: Border.all(
                            color: const Color(0xFF667eea).withOpacity(0.2),
                            width: 2,
                          ),
                        ),
                        child: const Icon(
                          Icons.person,
                          color: Color(0xFF667eea),
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Login del usuario
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              userLogin,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF1a1a1a),
                                letterSpacing: -0.3,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Usuario activo',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                                color: const Color(0xFF6b7280),
                                letterSpacing: -0.2,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                // === SELECTOR DE HOTEL ===
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                  child: Consumer<HotelController>(
                    builder: (context, hotelController, child) {
                      // Mientras está cargando hoteles
                      if (hotelController.isLoading) {
                        return Row(
                          children: const [
                            CircularProgressIndicator(strokeWidth: 2),
                            SizedBox(width: 12),
                            Text(
                              "Cargando hoteles...",
                              style: TextStyle(
                                fontSize: 14,
                                color: Color(0xFF6b7280),
                              ),
                            ),
                          ],
                        );
                      }

                      // Si hubo error
                      if (hotelController.errorMessage != null) {
                        return Text(
                          "Error al cargar hoteles",
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.red[400],
                          ),
                        );
                      }

                      // Si no hay hoteles
                      if (hotelController.hotels.isEmpty) {
                        return const Text(
                          "No hay hoteles",
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFF6b7280),
                          ),
                        );
                      }

                      return DropdownButtonFormField(
                        value: hotelController.hotelSeleccionado,
                        decoration: InputDecoration(
                          labelText: "Hotel",
                          labelStyle: const TextStyle(
                            color: Color(0xFF6b7280),
                            fontSize: 14,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                        ),
                        dropdownColor: Colors.white,
                        items: hotelController.hotels.map((hotel) {
                          return DropdownMenuItem(
                            value: hotel,
                            child: Text(
                              hotel.nombre,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Color(0xFF1a1a1a),
                              ),
                            ),
                          );
                        }).toList(),
                        onChanged: (selectedHotel) {
                          if (selectedHotel != null) {
                            hotelController.seleccionarHotel(selectedHotel);
                          }
                        },
                      );
                    },
                  ),
                ),

                // Lista de módulos
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    children: [
                      // 1. Incidencias
                      _buildModuleItem(
                        context: context,
                        icon: Icons.report,
                        title: 'Incidencias',
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const IncidenciasListScreen(),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 8),
                      // 2. Usuarios
                      _buildModuleItem(
                        context: context,
                        icon: Icons.group,
                        title: 'Usuarios',
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const UnderConstructionScreen(
                                    title: 'Usuarios',
                                  ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 8),
                      // 3. Clientes
                      _buildModuleItem(
                        context: context,
                        icon: Icons.person_outline,
                        title: 'Clientes',
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const ClientesListScreen(),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 8),
                      // 4. Hoteles
                      _buildModuleItem(
                        context: context,
                        icon: Icons.hotel,
                        title: 'Hoteles',
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const HotelsListScreen(),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 8),
                      // 5. Pisos
                      _buildModuleItem(
                        context: context,
                        icon: Icons.layers,
                        title: 'Pisos',
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const PisosListScreen(),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 8),
                      // 6. Habitaciones
                      _buildModuleItem(
                        context: context,
                        icon: Icons.meeting_room,
                        title: 'Habitaciones',
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const UnderConstructionScreen(
                                    title: 'Habitaciones',
                                  ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 8),
                      // 7. Reservaciones
                      _buildModuleItem(
                        context: context,
                        icon: Icons.event_available,
                        title: 'Reservaciones',
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const UnderConstructionScreen(
                                    title: 'Reservaciones',
                                  ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 8),
                      // 8. Mantenimiento
                      _buildModuleItem(
                        context: context,
                        icon: Icons.build,
                        title: 'Mantenimiento',
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const UnderConstructionScreen(
                                    title: 'Mantenimiento',
                                  ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 8),
                      // 9. Limpieza
                      _buildModuleItem(
                        context: context,
                        icon: Icons.cleaning_services,
                        title: 'Limpieza',
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const UnderConstructionScreen(
                                    title: 'Limpieza',
                                  ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Widget para construir un item de módulo en el sidebar
  Widget _buildModuleItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: const Color(0xFF667eea).withOpacity(0.1),
        ),
        child: Icon(icon, color: const Color(0xFF667eea), size: 22),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: Color(0xFF1a1a1a),
          letterSpacing: -0.2,
        ),
      ),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    );
  }
}

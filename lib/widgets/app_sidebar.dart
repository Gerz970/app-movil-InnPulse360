import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/auth/controllers/auth_controller.dart';
import '../features/hoteles/hotels_list_screen.dart';
import '../features/clientes/clientes_list_screen.dart';
import '../features/incidencias/incidencias_list_screen.dart';
import '../features/common/under_construction_screen.dart';
import '../features/perfil/screens/perfil_screen.dart';

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
                InkWell(
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const PerfilScreen(),
                      ),
                    );
                  },
                  child: Container(
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
                        // Foto de perfil circular - construida directamente desde loginResponse
                        _buildAvatarFromSession(loginResponse),
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
                        const Icon(
                          Icons.chevron_right,
                          color: Color(0xFF6b7280),
                          size: 20,
                        ),
                      ],
                    ),
                  ),
                ),
                // Lista de módulos - construida dinámicamente desde el backend
                Expanded(
                  child: _buildModulesList(context, loginResponse),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Construir lista de módulos dinámicamente desde el backend
  Widget _buildModulesList(BuildContext context, Map<String, dynamic>? loginResponse) {
    // Obtener módulos del loginResponse
    List<dynamic> modulos = [];
    if (loginResponse != null && loginResponse['modulos'] is List) {
      modulos = loginResponse['modulos'] as List;
    }

    // Obtener roles del usuario
    List<dynamic> roles = [];
    if (loginResponse != null && loginResponse['roles'] is List) {
      roles = loginResponse['roles'] as List;
    }

    // Filtrar módulos si el usuario tiene rol "Cliente"
    bool tieneRolCliente = false;
    for (var rol in roles) {
      if (rol is Map<String, dynamic>) {
        final nombreRol = rol['rol'] as String? ?? '';
        if (nombreRol.toLowerCase() == 'cliente') {
          tieneRolCliente = true;
          break;
        }
      }
    }

    // Si tiene rol Cliente, solo mostrar módulo "Reservaciones"
    if (tieneRolCliente) {
      modulos = modulos.where((modulo) {
        if (modulo is Map<String, dynamic>) {
          final nombreModulo = modulo['nombre'] as String? ?? '';
          return nombreModulo.toLowerCase().contains('reservacion');
        }
        return false;
      }).toList();
    }

    // Si no hay módulos, mostrar mensaje
    if (modulos.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: Text(
            'No hay módulos disponibles',
            style: TextStyle(
              color: Color(0xFF6b7280),
              fontSize: 14,
            ),
          ),
        ),
      );
    }

    // Construir lista de widgets de módulos
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 8),
      children: modulos.map<Widget>((modulo) {
        final moduloMap = modulo as Map<String, dynamic>;
        final nombreModulo = moduloMap['nombre'] as String? ?? '';
        
        return Column(
          children: [
            _buildModuleItem(
              context: context,
              icon: _getIconForModule(nombreModulo),
              title: nombreModulo,
              onTap: () => _navigateToModuleScreen(context, nombreModulo),
            ),
            const SizedBox(height: 8),
          ],
        );
      }).toList(),
    );
  }

  /// Obtener icono para un módulo basándose en su nombre
  IconData _getIconForModule(String nombreModulo) {
    final nombreLower = nombreModulo.toLowerCase();
    
    if (nombreLower.contains('incidencia')) {
      return Icons.report;
    } else if (nombreLower.contains('usuario')) {
      return Icons.group;
    } else if (nombreLower.contains('cliente')) {
      return Icons.person_outline;
    } else if (nombreLower.contains('hotel')) {
      return Icons.hotel;
    } else if (nombreLower.contains('piso')) {
      return Icons.layers;
    } else if (nombreLower.contains('habitacion')) {
      return Icons.meeting_room;
    } else if (nombreLower.contains('reservacion')) {
      return Icons.event_available;
    } else if (nombreLower.contains('mantenimiento')) {
      return Icons.build;
    } else if (nombreLower.contains('limpieza')) {
      return Icons.cleaning_services;
    } else {
      return Icons.dashboard; // Icono por defecto
    }
  }

  /// Navegar a la pantalla correspondiente según el nombre del módulo
  void _navigateToModuleScreen(BuildContext context, String nombreModulo) {
    Navigator.pop(context);
    
    final nombreLower = nombreModulo.toLowerCase();
    Widget screen;
    
    if (nombreLower.contains('incidencia')) {
      screen = const IncidenciasListScreen();
    } else if (nombreLower.contains('cliente')) {
      screen = const ClientesListScreen();
    } else if (nombreLower.contains('hotel')) {
      screen = const HotelsListScreen();
    } else if (nombreLower.contains('reservacion')) {
      screen = const UnderConstructionScreen(title: 'Reservaciones');
    } else {
      // Para otros módulos, mostrar pantalla de construcción
      screen = UnderConstructionScreen(title: nombreModulo);
    }
    
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => screen),
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
        child: Icon(
          icon,
          color: const Color(0xFF667eea),
          size: 22,
        ),
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
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }

  /// Construir el avatar directamente desde loginResponse
  /// Se ejecuta cada vez que el Consumer se reconstruye
  Widget _buildAvatarFromSession(Map<String, dynamic>? loginResponse) {
    // Intentar obtener foto de perfil desde la sesión
    String? fotoUrl;
    if (loginResponse != null) {
      // Intentar desde objeto usuario
      if (loginResponse['usuario'] is Map<String, dynamic>) {
        fotoUrl = loginResponse['usuario']['url_foto_perfil'] as String?;
      }
      // Intentar desde raíz
      if (fotoUrl == null) {
        fotoUrl = loginResponse['url_foto_perfil'] as String?;
      }
    }
    
    // Obtener timestamp de actualización de la sesión para evitar caché
    int? timestampFoto = loginResponse?['usuario']?['foto_perfil_timestamp'] as int?;
    if (timestampFoto == null) {
      timestampFoto = loginResponse?['foto_perfil_timestamp'] as int?;
    }
    
    // Agregar timestamp a la URL para evitar caché cuando se actualiza la foto
    String? fotoUrlConCache = fotoUrl;
    if (fotoUrl != null && fotoUrl.isNotEmpty) {
      // Agregar parámetro de query único basado en el timestamp guardado
      final separator = fotoUrl.contains('?') ? '&' : '?';
      final cacheBuster = timestampFoto ?? DateTime.now().millisecondsSinceEpoch;
      fotoUrlConCache = '$fotoUrl${separator}t=$cacheBuster';
      print('DEBUG Sidebar: Mostrando foto de perfil: $fotoUrl (timestamp: $cacheBuster)');
    } else {
      print('DEBUG Sidebar: No hay foto de perfil disponible');
    }
    
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: const Color(0xFF667eea).withOpacity(0.3),
          width: 2,
        ),
      ),
      child: ClipOval(
        child: fotoUrlConCache != null && fotoUrlConCache.isNotEmpty
            ? Image.network(
                fotoUrlConCache,
                key: ValueKey('${fotoUrl}_$timestampFoto'), // Key única que incluye URL y timestamp
                fit: BoxFit.cover,
                cacheWidth: 96, // Optimización: cachear a tamaño específico
                cacheHeight: 96,
                errorBuilder: (context, error, stackTrace) {
                  print('DEBUG Sidebar: Error al cargar imagen: $error');
                  return Container(
                    color: const Color(0xFF667eea).withOpacity(0.1),
                    child: const Icon(
                      Icons.person,
                      color: Color(0xFF667eea),
                      size: 28,
                    ),
                  );
                },
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    color: const Color(0xFF667eea).withOpacity(0.1),
                    child: const Center(
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF667eea)),
                      ),
                    ),
                  );
                },
              )
            : Container(
                color: const Color(0xFF667eea).withOpacity(0.1),
                child: const Icon(
                  Icons.person,
                  color: Color(0xFF667eea),
                  size: 28,
                ),
              ),
      ),
    );
  }
}


import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/auth/controllers/auth_controller.dart';
import '../core/theme/app_theme.dart';
import '../core/utils/modules.dart';
import '../features/common/under_construction_screen.dart';
import '../features/hoteles/controllers/hotel_controller.dart';
import '../features/perfil/screens/perfil_screen.dart';
import '../features/chat/screens/chat_screen.dart';
import '../features/mensajeria/screens/conversaciones_list_screen.dart';

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

        // Extraer el campo "login" y "correo_electronico" del usuario
        String userLogin = 'Usuario';
        String userEmail = 'Usuario activo';
        
        if (loginResponse != null) {
          // Intentar obtener desde objeto usuario (estructura del backend)
          if (loginResponse['usuario'] is Map<String, dynamic>) {
            final usuarioObj = loginResponse['usuario'] as Map<String, dynamic>;
            userLogin = _extractString(usuarioObj, 'login');
            final email = _extractString(usuarioObj, 'correo_electronico');
            if (email != 'Usuario' && email.isNotEmpty) {
              userEmail = email;
            }
          }
          
          // Si no encontramos en objeto usuario, intentar desde raíz
          if (userLogin == 'Usuario') {
            userLogin = _extractString(loginResponse, 'login');
          }
          if (userLogin == 'Usuario') {
            userLogin = _extractString(loginResponse, 'username');
          }
          if (userLogin == 'Usuario') {
            userLogin = _extractString(loginResponse, 'usuario');
          }
          
          // Intentar obtener correo desde raíz si no se encontró en usuario
          if (userEmail == 'Usuario activo') {
            final email = _extractString(loginResponse, 'correo_electronico');
            if (email != 'Usuario' && email.isNotEmpty) {
              userEmail = email;
            }
          }
        }

        // Verificar si el usuario tiene el rol "Cliente"
        final esCliente = _esUsuarioCliente(loginResponse);

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
                    padding: AppSpacing.allXl,
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      border: Border(
                        bottom: BorderSide(
                          color: AppColors.border,
                          width: 1,
                        ),
                      ),
                    ),
                    child: Row(
                      children: [
                        // Foto de perfil circular - construida directamente desde loginResponse
                        _buildAvatarFromSession(loginResponse),
                        SizedBox(width: AppSpacing.md),
                        // Login del usuario
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                userLogin,
                                style: AppTextStyles.h3.copyWith(
                                  fontSize: 16,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              SizedBox(height: 2),
                              Text(
                                userEmail,
                                style: AppTextStyles.bodySmall.copyWith(
                                  fontSize: 12,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          Icons.chevron_right,
                          color: AppColors.textSecondary,
                          size: 20,
                        ),
                      ],
                    ),
                  ),
                ),
                // === SELECTOR DE HOTEL ===
                // Solo mostrar si el usuario NO es cliente
                if (!esCliente)
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppSpacing.xl,
                      vertical: AppSpacing.lg,
                    ),
                    child: Consumer<HotelController>(
                    builder: (context, hotelController, child) {
                      // Mientras está cargando hoteles
                      if (hotelController.isLoading) {
                        return Row(
                          children: [
                            CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                            ),
                            SizedBox(width: AppSpacing.md),
                            Text(
                              "Cargando hoteles...",
                              style: AppTextStyles.bodyMedium,
                            ),
                          ],
                        );
                      }

                      // Si hubo error
                      if (hotelController.errorMessage != null) {
                        return Text(
                          "Error al cargar hoteles",
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.error,
                          ),
                        );
                      }

                      // Si no hay hoteles
                      if (hotelController.hotels.isEmpty) {
                        return Text(
                          "No hay hoteles",
                          style: AppTextStyles.bodyMedium,
                        );
                      }

                      return DropdownButtonFormField<int>(
                        value: hotelController.hotelSeleccionado?.idHotel,
                        decoration: AppInputStyles.standard(
                          label: "Hotel",
                        ).copyWith(
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: AppSpacing.md,
                            vertical: AppSpacing.sm,
                          ),
                        ),
                        dropdownColor: AppColors.background,
                        items: hotelController.hotels.map((hotel) {
                          return DropdownMenuItem<int>(
                            value: hotel.idHotel,
                            child: Text(
                              hotel.nombre,
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: AppColors.textPrimary,
                              ),
                            ),
                          );
                        }).toList(),
                        onChanged: (selectedHotelId) {
                          if (selectedHotelId != null) {
                            final selectedHotel = hotelController.hotels.firstWhere(
                              (hotel) => hotel.idHotel == selectedHotelId,
                            );
                            hotelController.seleccionarHotel(selectedHotel);
                          }
                        },
                      );
                    },
                  ),
                ),

                // === ASISTENTE IA ===
                // Item fijo para el chat con IA
                _buildModuleItem(
                  context: context,
                  icon: Icons.smart_toy,
                  title: 'Asistente IA',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ChatScreen(),
                      ),
                    );
                  },
                ),

                // === MENSAJERÍA ===
                // Item fijo para mensajería
                _buildModuleItem(
                  context: context,
                  icon: Icons.message,
                  title: 'Mensajería',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ConversacionesListScreen(),
                      ),
                    );
                  },
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

    // Filtrar solo los módulos que son móvil (movil == 1)
    final modulosMovil = modulos.where((modulo) {
      final moduloMap = modulo as Map<String, dynamic>;
      final movil = moduloMap['movil'];
      
      // Verificar si movil es 1 (puede ser int, num, String '1', o bool true)
      if (movil == null) {
        return false; // Si es null, no es móvil
      }
      
      // Manejar diferentes tipos de datos
      if (movil is int || movil is num) {
        return movil == 1;
      } else if (movil is String) {
        return movil == '1' || movil.toLowerCase() == 'true';
      } else if (movil is bool) {
        return movil == true;
      }
      
      return false; // Por defecto, no es móvil
    }).toList();

    // Si no hay módulos móviles, mostrar mensaje
    if (modulosMovil.isEmpty) {
      return Center(
        child: Padding(
          padding: AppSpacing.allXl,
          child: Text(
            'No hay módulos disponibles',
            style: AppTextStyles.bodyMedium,
          ),
        ),
      );
    }

    // Construir lista de widgets de módulos
    return ListView(
      padding: EdgeInsets.symmetric(vertical: AppSpacing.sm),
      children: modulosMovil.map<Widget>((modulo) {
        final moduloMap = modulo as Map<String, dynamic>;
        final nombreModulo = moduloMap['nombre'] as String? ?? '';
        final rutaModulo = moduloMap['ruta'] as String? ?? '';
        
        return Column(
          children: [
            _buildModuleItem(
              context: context,
              icon: _getIconForModule(nombreModulo),
              title: nombreModulo,
              onTap: () => _navigateToModuleScreen(context, rutaModulo),
            ),
            SizedBox(height: AppSpacing.sm),
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
    } else if (nombreLower.contains('transporte') || nombreLower.contains('transportista')) {
      return Icons.local_taxi;
    } else {
      return Icons.dashboard; // Icono por defecto
    }
  }

  /// Navegar a la pantalla correspondiente según la ruta del módulo
  void _navigateToModuleScreen(BuildContext context, String rutaModulo) {
    Navigator.pop(context);

    final rutaLower = rutaModulo;

    // Buscar coincidencia exacta con la ruta del módulo
    final entry = moduleScreens.entries.firstWhere(
      (e) => rutaLower == e.key,
      orElse: () => MapEntry(
        'default',
        () => UnderConstructionScreen(title: rutaModulo),
      ),
    );

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => entry.value()),
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
          color: AppColors.primary.withOpacity(0.1),
        ),
        child: Icon(icon, color: AppColors.primary, size: 22),
      ),
      title: Text(
        title,
        style: AppTextStyles.bodyMedium.copyWith(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: AppColors.textPrimary,
        ),
      ),
      onTap: onTap,
      contentPadding: EdgeInsets.symmetric(
        horizontal: AppSpacing.xl,
        vertical: AppSpacing.xs,
      ),
      shape: RoundedRectangleBorder(borderRadius: AppRadius.smBorder),
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
          color: AppColors.primary.withOpacity(0.3),
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
                    color: AppColors.primary.withOpacity(0.1),
                    child: Icon(
                      Icons.person,
                      color: AppColors.primary,
                      size: 28,
                    ),
                  );
                },
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    color: AppColors.primary.withOpacity(0.1),
                    child: Center(
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                      ),
                    ),
                  );
                },
              )
            : Container(
                color: AppColors.primary.withOpacity(0.1),
                child: Icon(
                  Icons.person,
                  color: AppColors.primary,
                  size: 28,
                ),
              ),
      ),
    );
  }

  /// Verificar si el usuario tiene el rol "Cliente"
  /// Compara el nombre del rol de forma case-insensitive
  bool _esUsuarioCliente(Map<String, dynamic>? loginResponse) {
    if (loginResponse == null) return false;
    
    // Obtener la lista de roles
    final roles = loginResponse['roles'];
    if (roles == null || roles is! List) return false;
    
    // Verificar si alguno de los roles es "Cliente"
    for (var rol in roles) {
      if (rol is Map<String, dynamic>) {
        final nombreRol = rol['rol'];
        if (nombreRol is String && nombreRol.toLowerCase() == 'cliente') {
          return true;
        }
      }
    }
    
    return false;
  }
}

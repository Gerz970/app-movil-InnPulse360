import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/auth/controllers/auth_controller.dart';
import '../core/theme/app_theme.dart';
import '../features/perfil/screens/perfil_screen.dart';
import '../features/login/login_screen.dart';
import '../features/chat/screens/chat_screen.dart';

/// Widget de header global reutilizable para toda la aplicación
/// Muestra información del usuario, foto de perfil y botones de acción
class AppHeader extends StatelessWidget {
  const AppHeader({super.key});

  /// Función auxiliar para extraer un String de forma segura del loginResponse
  /// Maneja casos donde el valor podría ser un Map o null
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
        
        // Extraer el campo "login" del usuario (prioridad al campo login)
        String userLogin = 'Usuario';
        if (loginResponse != null) {
          // Priorizar el campo "login" de la sesión
          userLogin = _extractString(loginResponse, 'login');
          
          // Si no encontramos "login", intentar otros campos como fallback
          if (userLogin == 'Usuario') {
            userLogin = _extractString(loginResponse, 'username');
          }
          if (userLogin == 'Usuario') {
            userLogin = _extractString(loginResponse, 'usuario');
          }
          if (userLogin == 'Usuario') {
            userLogin = _extractString(loginResponse, 'nombre');
          }
          if (userLogin == 'Usuario') {
            userLogin = _extractString(loginResponse, 'name');
          }
          
          // Si aún no encontramos un login válido, intentar obtenerlo de un objeto anidado
          if (userLogin == 'Usuario' && loginResponse['usuario'] != null) {
            final usuarioObj = loginResponse['usuario'];
            if (usuarioObj is Map<String, dynamic>) {
              userLogin = _extractString(usuarioObj, 'login');
              if (userLogin == 'Usuario') {
                userLogin = _extractString(usuarioObj, 'username');
              }
            }
          }
        }

        return Container(
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.xl,
            vertical: AppSpacing.lg,
          ),
          decoration: BoxDecoration(
            color: AppColors.background,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              // Botón circular hamburguesa (☰) para abrir sidebar
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary.withOpacity(0.1),
                ),
                child: IconButton(
                  padding: EdgeInsets.zero,
                  icon: Icon(
                    Icons.menu,
                    color: AppColors.primary,
                    size: 22,
                  ),
                  onPressed: () {
                    // Abrir el drawer del Scaffold
                    Scaffold.of(context).openDrawer();
                  },
                ),
              ),
              SizedBox(width: AppSpacing.md),
              // Foto de perfil circular - construida directamente desde loginResponse
              _buildAvatarFromSession(loginResponse),
              SizedBox(width: AppSpacing.md),
              // Nombre del usuario y texto secundario
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      userLogin,
                      style: AppTextStyles.h3,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Bienvenido de nuevo',
                      style: AppTextStyles.bodySmall.copyWith(
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: AppSpacing.sm),
              // Botón circular Asistente IA
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary.withOpacity(0.1),
                ),
                child: IconButton(
                  padding: EdgeInsets.zero,
                  icon: Icon(
                    Icons.smart_toy,
                    color: AppColors.primary,
                    size: 22,
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ChatScreen(),
                      ),
                    );
                  },
                ),
              ),
              SizedBox(width: AppSpacing.sm),
              // Botón circular menú "⋮"
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary.withOpacity(0.1),
                ),
                child: PopupMenuButton<String>(
                  padding: EdgeInsets.zero,
                  icon: Icon(
                    Icons.more_vert,
                    color: AppColors.primary,
                    size: 22,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: AppRadius.mdBorder,
                  ),
                  itemBuilder: (BuildContext context) => [
                    PopupMenuItem<String>(
                      value: 'perfil',
                      child: Row(
                        children: [
                          Icon(Icons.person_outline, size: 20, color: AppColors.textSecondary),
                          SizedBox(width: AppSpacing.md),
                          Text('Perfil'),
                        ],
                      ),
                    ),
                    PopupMenuItem<String>(
                      value: 'configuracion',
                      child: Row(
                        children: [
                          Icon(Icons.settings_outlined, size: 20, color: AppColors.textSecondary),
                          SizedBox(width: AppSpacing.md),
                          Text('Configuración'),
                        ],
                      ),
                    ),
                    PopupMenuItem<String>(
                      value: 'ayuda',
                      child: Row(
                        children: [
                          Icon(Icons.help_outline, size: 20, color: AppColors.textSecondary),
                          SizedBox(width: AppSpacing.md),
                          Text('Ayuda'),
                        ],
                      ),
                    ),
                    const PopupMenuDivider(),
                    PopupMenuItem<String>(
                      value: 'cerrar_sesion',
                      child: Row(
                        children: [
                          Icon(Icons.logout, size: 20, color: AppColors.error),
                          SizedBox(width: AppSpacing.md),
                          Text(
                            'Cerrar sesión',
                            style: TextStyle(color: AppColors.error),
                          ),
                        ],
                      ),
                    ),
                  ],
                  onSelected: (String value) {
                    if (value == 'perfil') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const PerfilScreen(),
                        ),
                      );
                    } else if (value == 'configuracion') {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('Configuración en desarrollo'),
                          backgroundColor: AppColors.primary,
                        ),
                      );
                    } else if (value == 'ayuda') {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('Ayuda en desarrollo'),
                          backgroundColor: AppColors.primary,
                        ),
                      );
                    } else if (value == 'cerrar_sesion') {
                      _confirmarCerrarSesion(context, authController);
                    }
                  },
                ),
              ),
            ],
          ),
        );
      },
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
      print('DEBUG Header: Mostrando foto de perfil: $fotoUrl (timestamp: $cacheBuster)');
    } else {
      print('DEBUG Header: No hay foto de perfil disponible');
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
                  print('DEBUG Header: Error al cargar imagen: $error');
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

  /// Confirmar y ejecutar cierre de sesión
  void _confirmarCerrarSesion(BuildContext context, AuthController authController) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cerrar sesión'),
        content: const Text('¿Estás seguro de que deseas cerrar sesión?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await authController.logout();
              
              if (context.mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                  (route) => false,
                );
              }
            },
            child: const Text('Cerrar sesión'),
          ),
        ],
      ),
    );
  }
}


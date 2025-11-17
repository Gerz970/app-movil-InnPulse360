import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../widgets/app_header.dart';
import '../../../../widgets/app_sidebar.dart';
import '../controllers/perfil_controller.dart';
import 'editar_perfil_screen.dart';
import 'cambiar_password_screen.dart';
import '../../../../core/auth/controllers/auth_controller.dart';
import '../../login/login_screen.dart';
import 'package:image_picker/image_picker.dart';

/// Pantalla principal de perfil de usuario
/// Muestra información del usuario, foto de perfil y opciones de gestión
class PerfilScreen extends StatefulWidget {
  const PerfilScreen({super.key});

  @override
  State<PerfilScreen> createState() => _PerfilScreenState();
}

class _PerfilScreenState extends State<PerfilScreen> {
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    // Cargar perfil al iniciar
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final controller = context.read<PerfilController>();
      controller.cargarPerfil();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      drawer: const AppSidebar(),
      body: SafeArea(
        child: Column(
          children: [
            // Header global reutilizable
            const AppHeader(),
            // Contenido principal
            Expanded(
              child: Consumer2<PerfilController, AuthController>(
                builder: (context, controller, authController, child) {
                  if (controller.isLoading) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  if (controller.errorMessage != null) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.error_outline,
                              size: 64,
                              color: Colors.red.withOpacity(0.5),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Error al cargar perfil',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF1a1a1a),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              controller.errorMessage ?? 'Error desconocido',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Color(0xFF6b7280),
                              ),
                            ),
                            const SizedBox(height: 24),
                            ElevatedButton(
                              onPressed: () => controller.cargarPerfil(),
                              child: const Text('Reintentar'),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  final usuario = controller.usuarioPerfil;
                  if (usuario == null) {
                    return const Center(
                      child: Text('No se pudo cargar el perfil'),
                    );
                  }

                  return SingleChildScrollView(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(height: 16),
                        // Foto de perfil - ahora con cache busting
                        _buildFotoPerfil(context, controller, usuario, authController),
                        const SizedBox(height: 24),
                        // Información del usuario
                        _buildInfoUsuario(usuario),
                        const SizedBox(height: 32),
                        // Opciones de menú
                        _buildOpcionesMenu(context, controller),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Widget para construir la foto de perfil
  Widget _buildFotoPerfil(
    BuildContext context,
    PerfilController controller,
    usuario,
    AuthController authController,
  ) {
    // Obtener timestamp de la sesión para evitar caché
    final loginResponse = authController.loginResponse;
    int? timestampFoto = loginResponse?['usuario']?['foto_perfil_timestamp'] as int?;
    if (timestampFoto == null) {
      timestampFoto = loginResponse?['foto_perfil_timestamp'] as int?;
    }
    
    // Construir URL con cache busting
    String? fotoUrlConCache = usuario.urlFotoPerfil;
    if (fotoUrlConCache != null && fotoUrlConCache.isNotEmpty) {
      final separator = fotoUrlConCache.contains('?') ? '&' : '?';
      final cacheBuster = timestampFoto ?? DateTime.now().millisecondsSinceEpoch;
      fotoUrlConCache = '$fotoUrlConCache${separator}t=$cacheBuster';
    }
    
    return Stack(
      children: [
        // Foto de perfil circular
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: const Color(0xFF667eea).withOpacity(0.3),
              width: 3,
            ),
          ),
          child: ClipOval(
            child: fotoUrlConCache != null && fotoUrlConCache.isNotEmpty
                ? Image.network(
                    fotoUrlConCache,
                    key: ValueKey('${usuario.urlFotoPerfil}_$timestampFoto'), // Key única basada en URL y timestamp
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: const Color(0xFF667eea).withOpacity(0.1),
                        child: const Icon(
                          Icons.person,
                          color: Color(0xFF667eea),
                          size: 60,
                        ),
                      );
                    },
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        color: const Color(0xFF667eea).withOpacity(0.1),
                        child: const Center(
                          child: CircularProgressIndicator(),
                        ),
                      );
                    },
                  )
                : Container(
                    color: const Color(0xFF667eea).withOpacity(0.1),
                    child: const Icon(
                      Icons.person,
                      color: Color(0xFF667eea),
                      size: 60,
                    ),
                  ),
          ),
        ),
        // Botón para cambiar foto
        Positioned(
          bottom: 0,
          right: 0,
          child: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF667eea),
              border: Border.all(
                color: Colors.white,
                width: 3,
              ),
            ),
            child: IconButton(
              padding: EdgeInsets.zero,
              icon: controller.isUploadingPhoto || controller.isDeletingPhoto
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Icon(
                      Icons.camera_alt,
                      color: Colors.white,
                      size: 18,
                    ),
              onPressed: controller.isUploadingPhoto || controller.isDeletingPhoto
                  ? null
                  : () => _mostrarOpcionesFoto(context, controller),
            ),
          ),
        ),
      ],
    );
  }

  /// Widget para construir la información del usuario
  Widget _buildInfoUsuario(usuario) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: const Color(0xFFe5e7eb),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoItem(
              icon: Icons.person_outline,
              label: 'Login',
              value: usuario.login,
            ),
            const SizedBox(height: 16),
            _buildInfoItem(
              icon: Icons.email_outlined,
              label: 'Correo electrónico',
              value: usuario.correoElectronico,
            ),
            const SizedBox(height: 16),
            _buildInfoItem(
              icon: Icons.badge_outlined,
              label: 'Roles',
              value: usuario.nombresRoles,
            ),
            const SizedBox(height: 16),
            _buildInfoItem(
              icon: Icons.info_outline,
              label: 'Estado',
              value: usuario.estaActivo ? 'Activo' : 'Inactivo',
            ),
          ],
        ),
      ),
    );
  }

  /// Widget para construir un item de información
  Widget _buildInfoItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 20,
          color: const Color(0xFF667eea),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF6b7280),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1a1a1a),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Widget para construir las opciones del menú
  Widget _buildOpcionesMenu(BuildContext context, PerfilController controller) {
    return Column(
      children: [
        _buildMenuOption(
          context: context,
          icon: Icons.edit_outlined,
          title: 'Editar perfil',
          subtitle: 'Modificar datos básicos',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const EditarPerfilScreen(),
              ),
            );
          },
        ),
        const SizedBox(height: 12),
        _buildMenuOption(
          context: context,
          icon: Icons.lock_outlined,
          title: 'Cambiar contraseña',
          subtitle: 'Actualizar contraseña de acceso',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const CambiarPasswordScreen(),
              ),
            );
          },
        ),
        const SizedBox(height: 12),
        _buildMenuOption(
          context: context,
          icon: Icons.logout,
          title: 'Cerrar sesión',
          subtitle: 'Salir de la aplicación',
          onTap: () => _confirmarCerrarSesion(context),
          isDestructive: true,
        ),
      ],
    );
  }

  /// Widget para construir una opción del menú
  Widget _buildMenuOption({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: const Color(0xFFe5e7eb),
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: (isDestructive ? Colors.red : const Color(0xFF667eea))
                      .withOpacity(0.1),
                ),
                child: Icon(
                  icon,
                  color: isDestructive ? Colors.red : const Color(0xFF667eea),
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: isDestructive ? Colors.red : const Color(0xFF1a1a1a),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF6b7280),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: const Color(0xFF6b7280),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Mostrar opciones para foto de perfil
  void _mostrarOpcionesFoto(BuildContext context, PerfilController controller) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Seleccionar de galería'),
              onTap: () {
                Navigator.pop(context);
                _seleccionarFoto(context, controller, ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Tomar foto'),
              onTap: () {
                Navigator.pop(context);
                _seleccionarFoto(context, controller, ImageSource.camera);
              },
            ),
            if (controller.usuarioPerfil?.urlFotoPerfil != null &&
                controller.usuarioPerfil!.urlFotoPerfil!.isNotEmpty)
              ListTile(
                leading: const Icon(Icons.delete_outline, color: Colors.red),
                title: const Text('Restaurar foto por defecto', style: TextStyle(color: Colors.red)),
                onTap: () {
                  Navigator.pop(context);
                  _eliminarFoto(context, controller);
                },
              ),
            ListTile(
              leading: const Icon(Icons.close),
              title: const Text('Cancelar'),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  /// Seleccionar foto desde galería o cámara
  Future<void> _seleccionarFoto(
    BuildContext context,
    PerfilController controller,
    ImageSource source,
  ) async {
    try {
      final XFile? photo = await _picker.pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 800,
        maxHeight: 800,
      );

      if (photo == null) return;

      // Leer los bytes del archivo (compatible con todas las plataformas)
      final fileBytes = await photo.readAsBytes();
      final fileName = photo.name;

      final success = await controller.subirFotoPerfil(fileBytes, fileName);

      if (context.mounted) {
        if (success) {
          print('DEBUG PerfilScreen: Foto subida exitosamente, recargando sesión...');
          
          // Refrescar AuthController para que actualice la sesión y notifique cambios
          // Esperar a que loadSession() complete completamente
          final authController = context.read<AuthController>();
          await authController.loadSession();
          
          print('DEBUG PerfilScreen: AuthController recargado después de subir foto');
          
          // Pequeño delay para asegurar persistencia completa según el plan
          await Future.delayed(const Duration(milliseconds: 50));
          print('DEBUG PerfilScreen: Delay completado, widgets deberían reconstruirse...');
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success
                  ? 'Foto de perfil actualizada correctamente'
                  : controller.uploadPhotoError ?? 'Error al subir foto',
            ),
            backgroundColor: success ? Colors.green : Colors.red,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al seleccionar foto: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Eliminar foto de perfil
  Future<void> _eliminarFoto(
    BuildContext context,
    PerfilController controller,
  ) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Restaurar foto por defecto'),
        content: const Text(
          '¿Estás seguro de que deseas restaurar la foto de perfil por defecto?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Restaurar'),
          ),
        ],
      ),
    );

    if (confirmar == true) {
      final success = await controller.eliminarFotoPerfil();

      if (context.mounted) {
        if (success) {
          print('DEBUG PerfilScreen: Foto eliminada exitosamente, recargando sesión...');
          
          // Refrescar AuthController para que actualice la sesión y notifique cambios
          // Esperar a que loadSession() complete completamente
          final authController = context.read<AuthController>();
          await authController.loadSession();
          
          print('DEBUG PerfilScreen: AuthController recargado después de eliminar foto');
          
          // Pequeño delay para asegurar persistencia completa según el plan
          await Future.delayed(const Duration(milliseconds: 50));
          print('DEBUG PerfilScreen: Delay completado, widgets deberían reconstruirse...');
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success
                  ? 'Foto restaurada correctamente'
                  : controller.uploadPhotoError ?? 'Error al restaurar foto',
            ),
            backgroundColor: success ? Colors.green : Colors.red,
          ),
        );
      }
    }
  }

  /// Confirmar cerrar sesión
  void _confirmarCerrarSesion(BuildContext context) {
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
              final authController = context.read<AuthController>();
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


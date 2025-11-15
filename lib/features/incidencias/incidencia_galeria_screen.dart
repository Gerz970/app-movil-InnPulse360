import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../widgets/app_header.dart';
import '../../widgets/app_sidebar.dart';
import 'controllers/incidencia_controller.dart';
import 'models/galeria_imagen_model.dart';
import 'incidencia_success_screen.dart';
import '../login/login_screen.dart';

/// Pantalla para agregar fotos a una incidencia
/// Permite capturar hasta 5 fotos usando la cámara del dispositivo
class IncidenciaGaleriaScreen extends StatefulWidget {
  final int incidenciaId;

  const IncidenciaGaleriaScreen({
    required this.incidenciaId,
    super.key,
  });

  @override
  State<IncidenciaGaleriaScreen> createState() => _IncidenciaGaleriaScreenState();
}

class _IncidenciaGaleriaScreenState extends State<IncidenciaGaleriaScreen> {
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    // Cargar galería al iniciar la pantalla
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadGallery();
    });
  }

  /// Cargar galería de la incidencia
  Future<void> _loadGallery() async {
    final controller = Provider.of<IncidenciaController>(context, listen: false);
    await controller.fetchGaleria(widget.incidenciaId);
  }

  /// Capturar foto con la cámara
  Future<void> _takePicture() async {
    // 1. Verificar permisos de cámara
    final status = await Permission.camera.request();

    if (status.isDenied) {
      _showPermissionDialog();
      return;
    }

    if (status.isPermanentlyDenied) {
      _showSettingsDialog();
      return;
    }

    if (!status.isGranted) {
      return;
    }

    // 2. Capturar foto
    final XFile? photo = await _picker.pickImage(
      source: ImageSource.camera,
      maxWidth: 1800,
      maxHeight: 1800,
      imageQuality: 85,
    );

    if (photo == null) {
      // Usuario canceló la captura
      return;
    }

    // 3. Subir foto
    if (!mounted) return;
    final controller = Provider.of<IncidenciaController>(context, listen: false);
    
    final success = await controller.uploadPhoto(widget.incidenciaId, photo.path);

    // 4. Mostrar resultado
    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Foto agregada correctamente'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        final errorMessage = controller.uploadPhotoError ?? 'Error al subir la foto';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
            action: SnackBarAction(
              label: 'Reintentar',
              textColor: Colors.white,
              onPressed: () => _takePicture(),
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
  }

  /// Mostrar diálogo cuando se deniegan permisos
  void _showPermissionDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Permisos de cámara'),
          content: const Text(
            'Necesitamos acceso a la cámara para capturar fotos de incidencias. Por favor, otorga el permiso en la configuración.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                openAppSettings();
              },
              child: const Text('Abrir configuración'),
            ),
          ],
        );
      },
    );
  }

  /// Mostrar diálogo cuando los permisos están permanentemente denegados
  void _showSettingsDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Permisos requeridos'),
          content: const Text(
            'Los permisos de cámara están deshabilitados permanentemente. Por favor, habilítalos en la configuración de la aplicación.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                openAppSettings();
              },
              child: const Text('Ir a configuración'),
            ),
          ],
        );
      },
    );
  }

  /// Confirmar eliminación de foto
  void _confirmDeletePhoto(String nombreArchivo, IncidenciaController controller) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Eliminar foto'),
          content: const Text('¿Estás seguro de que deseas eliminar esta foto?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await _deletePhoto(nombreArchivo, controller);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Eliminar'),
            ),
          ],
        );
      },
    );
  }

  /// Eliminar foto
  Future<void> _deletePhoto(String nombreArchivo, IncidenciaController controller) async {
    final success = await controller.deletePhoto(widget.incidenciaId, nombreArchivo);

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Foto eliminada correctamente'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error al eliminar la foto'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Navegar a pantalla de confirmación
  void _navigateToSuccess() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => IncidenciaSuccessScreen(
          incidenciaId: widget.incidenciaId,
        ),
      ),
    );
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
              child: Consumer<IncidenciaController>(
                builder: (context, controller, child) {
                  // Estado de carga inicial
                  if (controller.isLoadingGaleria) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF667eea),
                      ),
                    );
                  }

                  // Estado de error
                  if (controller.galeriaErrorMessage != null) {
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
                              controller.galeriaErrorMessage ?? 'Error desconocido',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF1a1a1a),
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 24),
                            ElevatedButton(
                              onPressed: () => _loadGallery(),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF667eea),
                                foregroundColor: Colors.white,
                              ),
                              child: const Text('Reintentar'),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  // Contenido principal
                  return Column(
                    children: [
                      // Título con contador
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Agregar fotos',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1a1a1a),
                                letterSpacing: -0.5,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFF667eea),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                '${controller.galeriaImagenes.length}/5',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Grid de fotos
                      Expanded(
                        child: controller.galeriaImagenes.isEmpty
                            ? _buildEmptyState()
                            : _buildPhotoGrid(controller),
                      ),
                      // Botones de acción
                      _buildActionButtons(controller),
                    ],
                  );
                },
              ),
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
            Icons.photo_library_outlined,
            size: 80,
            color: const Color(0xFF667eea).withOpacity(0.3),
          ),
          const SizedBox(height: 24),
          const Text(
            'Aún no hay fotos',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Color(0xFF6b7280),
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Puedes tomar hasta 5 fotos',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF9ca3af),
            ),
          ),
        ],
      ),
    );
  }

  /// Widget para construir grid de fotos
  Widget _buildPhotoGrid(IncidenciaController controller) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1,
      ),
      itemCount: controller.galeriaImagenes.length,
      itemBuilder: (context, index) {
        final imagen = controller.galeriaImagenes[index];
        return _buildPhotoCard(imagen, controller);
      },
    );
  }

  /// Widget para construir una card de foto
  Widget _buildPhotoCard(GaleriaImagen imagen, IncidenciaController controller) {
    return Stack(
      children: [
        // Imagen con CachedNetworkImage
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: CachedNetworkImage(
            imageUrl: imagen.urlPublica,
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
            placeholder: (context, url) => Container(
              color: Colors.grey.shade200,
              child: const Center(
                child: CircularProgressIndicator(
                  color: Color(0xFF667eea),
                ),
              ),
            ),
            errorWidget: (context, url, error) => Container(
              color: Colors.grey.shade200,
              child: const Icon(
                Icons.error_outline,
                color: Colors.red,
                size: 40,
              ),
            ),
          ),
        ),
        // Botón eliminar
        Positioned(
          top: 4,
          right: 4,
          child: IconButton(
            icon: const Icon(Icons.delete, color: Colors.white, size: 20),
            style: IconButton.styleFrom(
              backgroundColor: Colors.red.withOpacity(0.8),
              padding: const EdgeInsets.all(8),
            ),
            onPressed: controller.isDeletingPhoto
                ? null
                : () => _confirmDeletePhoto(imagen.nombre, controller),
          ),
        ),
      ],
    );
  }

  /// Widget para construir botones de acción
  Widget _buildActionButtons(IncidenciaController controller) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Botón Tomar Foto
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton.icon(
              onPressed: controller.canAddMorePhotos && 
                        !controller.isUploadingPhoto && 
                        !controller.isDeletingPhoto
                  ? _takePicture
                  : null,
              icon: controller.isUploadingPhoto
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.camera_alt),
              label: Text(
                controller.isUploadingPhoto ? 'Subiendo...' : 'Tomar Foto',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF667eea),
                foregroundColor: Colors.white,
                disabledBackgroundColor: Colors.grey.shade300,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          if (!controller.canAddMorePhotos)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.info_outline, size: 16, color: Colors.red.shade400),
                  const SizedBox(width: 4),
                  Text(
                    'Máximo 5 fotos alcanzado',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.red.shade400,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 12),
          // Botones Omitir / Finalizar
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _navigateToSuccess(),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF667eea),
                    side: const BorderSide(color: Color(0xFF667eea)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Omitir',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _navigateToSuccess(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF667eea),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Finalizar',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}


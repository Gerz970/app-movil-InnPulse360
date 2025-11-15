import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../widgets/app_header.dart';
import '../../widgets/app_sidebar.dart';
import 'controllers/incidencia_controller.dart';
import 'models/galeria_imagen_model.dart';
import '../login/login_screen.dart';

/// Pantalla de formulario para editar una incidencia existente
/// Muestra formulario en modo edición con campos precargados
class IncidenciaEditScreen extends StatefulWidget {
  final int incidenciaId;

  const IncidenciaEditScreen({
    super.key,
    required this.incidenciaId,
  });

  @override
  State<IncidenciaEditScreen> createState() => _IncidenciaEditScreenState();
}

class _IncidenciaEditScreenState extends State<IncidenciaEditScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Controladores de texto
  final _habitacionAreaIdController = TextEditingController();
  final _incidenciaController = TextEditingController();
  final _descripcionController = TextEditingController();
  
  // Valores seleccionados
  DateTime? _fechaIncidencia;
  int? _idEstatus;
  
  bool _isInitialized = false;

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    // Cargar detalle de la incidencia y galería al iniciar
    // Hacer las peticiones de forma secuencial para evitar conflictos
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (mounted) {
        final controller = Provider.of<IncidenciaController>(context, listen: false);
        // Primero cargar el detalle
        await controller.loadIncidenciaDetail(widget.incidenciaId);
        // Esperar un momento antes de cargar la galería
        await Future.delayed(const Duration(milliseconds: 300));
        // Luego cargar la galería
        if (mounted) {
          await controller.fetchGaleria(widget.incidenciaId);
        }
      }
    });
  }

  @override
  void dispose() {
    _habitacionAreaIdController.dispose();
    _incidenciaController.dispose();
    _descripcionController.dispose();
    super.dispose();
  }

  /// Método para precargar valores de la incidencia en los controladores
  void _preloadIncidenciaData(IncidenciaController controller) {
    if (_isInitialized || controller.incidenciaDetail == null) return;
    
    final incidencia = controller.incidenciaDetail!;
    
    print('🔍 Precargando datos de la incidencia: ${incidencia.incidencia}');
    
    // Precargar valores en controladores
    _habitacionAreaIdController.text = incidencia.habitacionAreaId.toString();
    _incidenciaController.text = incidencia.incidencia;
    _descripcionController.text = incidencia.descripcion;
    _fechaIncidencia = incidencia.fechaIncidencia;
    
    // Validar que el estatus sea válido (0 o 1) antes de asignarlo
    // Si el valor no está en la lista de items válidos, usar null
    final estatusValue = incidencia.idEstatus;
    if (estatusValue == 0 || estatusValue == 1) {
      _idEstatus = estatusValue;
    } else {
      // Si el valor no es válido, usar null para que el dropdown no tenga valor seleccionado
      _idEstatus = null;
      print('⚠️ Advertencia: El estatus de la incidencia ($estatusValue) no es válido. Se establecerá como null.');
    }
    
    // Marcar como inicializado
    _isInitialized = true;
    
    // Forzar rebuild para mostrar el formulario
    if (mounted) {
      setState(() {});
    }
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
                  // Estado de carga de detalle
                  if (controller.isLoadingDetail) {
                    return const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(
                            color: Color(0xFF667eea),
                          ),
                          SizedBox(height: 16),
                          Text(
                            'Cargando incidencia...',
                            style: TextStyle(
                              fontSize: 16,
                              color: Color(0xFF6b7280),
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  // Estado de error al cargar detalle
                  if (controller.detailErrorMessage != null) {
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
                              controller.detailErrorMessage ?? 'Error desconocido',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF1a1a1a),
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 24),
                            ElevatedButton(
                              onPressed: () {
                                controller.loadIncidenciaDetail(widget.incidenciaId);
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
                          ],
                        ),
                      ),
                    );
                  }

                  // Precargar datos si están disponibles (usar postFrameCallback para evitar setState durante build)
                  if (controller.incidenciaDetail != null && !_isInitialized) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (mounted && !_isInitialized) {
                        _preloadIncidenciaData(controller);
                      }
                    });
                  }

                  // Formulario
                  return _buildForm(context, controller);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Widget para construir el formulario
  Widget _buildForm(BuildContext context, IncidenciaController controller) {
    return Stack(
      children: [
        // Formulario
        SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Título
                const Text(
                  'Editar incidencia',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1a1a1a),
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 32),
                // Campo: Habitación/Área ID
                _buildTextField(
                  controller: _habitacionAreaIdController,
                  label: 'ID de Habitación/Área',
                  hint: 'Ingresa el ID de la habitación o área',
                  icon: Icons.room,
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty || value.trim().isEmpty) {
                      return 'El ID de habitación/área es requerido';
                    }
                    final id = int.tryParse(value.trim());
                    if (id == null || id <= 0) {
                      return 'Ingresa un ID válido';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                // Campo: Título de la incidencia
                _buildTextField(
                  controller: _incidenciaController,
                  label: 'Título de la incidencia',
                  hint: 'Ingresa el título de la incidencia',
                  icon: Icons.report,
                  validator: (value) {
                    if (value == null || value.isEmpty || value.trim().isEmpty) {
                      return 'El título es requerido';
                    }
                    final trimmedValue = value.trim();
                    if (trimmedValue.length < 3) {
                      return 'El título debe tener al menos 3 caracteres';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                // Campo: Descripción
                _buildTextField(
                  controller: _descripcionController,
                  label: 'Descripción',
                  hint: 'Ingresa la descripción de la incidencia',
                  icon: Icons.description,
                  maxLines: 4,
                  validator: (value) {
                    if (value == null || value.isEmpty || value.trim().isEmpty) {
                      return 'La descripción es requerida';
                    }
                    final trimmedValue = value.trim();
                    if (trimmedValue.length < 10) {
                      return 'La descripción debe tener al menos 10 caracteres';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                // Campo: Fecha de incidencia
                _buildDateField(),
                const SizedBox(height: 20),
                // Campo: Estatus
                _buildEstatusDropdown(),
                const SizedBox(height: 32),
                // Sección de Galería
                _buildGallerySection(controller),
                const SizedBox(height: 32),
                // Botón Actualizar
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: controller.isUpdating ? null : () => _handleSubmit(context, controller),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF667eea),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      disabledBackgroundColor: const Color(0xFF9ca3af),
                    ),
                    child: const Text(
                      'Actualizar Incidencia',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // Mostrar error de actualización si existe
                if (controller.updateErrorMessage != null)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.error_outline, color: Colors.red.shade700, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            controller.updateErrorMessage!,
                            style: TextStyle(
                              color: Colors.red.shade700,
                              fontSize: 14,
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
        // Overlay de actualizando
        if (controller.isUpdating)
          Container(
            color: Colors.black.withOpacity(0.3),
            child: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    color: Color(0xFF667eea),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Actualizando incidencia...',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  /// Widget para construir un campo de texto
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(
          icon,
          color: const Color(0xFF6b7280),
          size: 20,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: Color(0xFFe5e7eb),
            width: 1,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: Color(0xFFe5e7eb),
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: Color(0xFF667eea),
            width: 2,
          ),
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        labelStyle: const TextStyle(
          color: Color(0xFF6b7280),
          fontSize: 14,
        ),
        hintStyle: const TextStyle(
          color: Color(0xFF9ca3af),
          fontSize: 14,
        ),
      ),
    );
  }

  /// Widget para construir campo de fecha
  Widget _buildDateField() {
    return InkWell(
      onTap: () async {
        final DateTime? picked = await showDatePicker(
          context: context,
          initialDate: _fechaIncidencia ?? DateTime.now(),
          firstDate: DateTime(2000),
          lastDate: DateTime(2100),
          locale: const Locale('es', 'ES'),
        );
        if (picked != null && picked != _fechaIncidencia) {
          setState(() {
            _fechaIncidencia = picked;
          });
        }
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: 'Fecha de incidencia',
          prefixIcon: const Icon(
            Icons.calendar_today,
            color: Color(0xFF6b7280),
            size: 20,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
              color: Color(0xFFe5e7eb),
              width: 1,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
              color: Color(0xFFe5e7eb),
              width: 1,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
              color: Color(0xFF667eea),
              width: 2,
            ),
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
          labelStyle: const TextStyle(
            color: Color(0xFF6b7280),
            fontSize: 14,
          ),
        ),
        child: Text(
          _fechaIncidencia != null ? _formatDate(_fechaIncidencia!) : 'Selecciona una fecha',
          style: TextStyle(
            fontSize: 16,
            color: _fechaIncidencia != null ? const Color(0xFF1a1a1a) : const Color(0xFF9ca3af),
          ),
        ),
      ),
    );
  }

  /// Método para formatear fecha
  String _formatDate(DateTime date) {
    final meses = [
      'enero', 'febrero', 'marzo', 'abril', 'mayo', 'junio',
      'julio', 'agosto', 'septiembre', 'octubre', 'noviembre', 'diciembre'
    ];
    return '${date.day} de ${meses[date.month - 1]} de ${date.year}';
  }

  /// Widget para construir dropdown de estatus
  Widget _buildEstatusDropdown() {
    // Validar que el valor esté en la lista de items válidos
    // Si no está, usar null para evitar el error del DropdownButton
    final validValue = (_idEstatus == 0 || _idEstatus == 1) ? _idEstatus : null;
    
    return DropdownButtonFormField<int>(
      value: validValue,
      decoration: InputDecoration(
        labelText: 'Estatus',
        prefixIcon: const Icon(
          Icons.check_circle,
          color: Color(0xFF6b7280),
          size: 20,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: Color(0xFFe5e7eb),
            width: 1,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: Color(0xFFe5e7eb),
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: Color(0xFF667eea),
            width: 2,
          ),
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        labelStyle: const TextStyle(
          color: Color(0xFF6b7280),
          fontSize: 14,
        ),
      ),
      items: const [
        DropdownMenuItem<int>(
          value: 1,
          child: Row(
            children: [
              Icon(Icons.check_circle, size: 18, color: Colors.green),
              SizedBox(width: 8),
              Text('Activo'),
            ],
          ),
        ),
        DropdownMenuItem<int>(
          value: 0,
          child: Row(
            children: [
              Icon(Icons.cancel, size: 18, color: Colors.red),
              SizedBox(width: 8),
              Text('Inactivo'),
            ],
          ),
        ),
      ],
      validator: (value) {
        if (value == null) {
          return 'El estatus es requerido';
        }
        return null;
      },
      onChanged: (int? value) {
        if (value != null) {
          setState(() {
            _idEstatus = value;
          });
        }
      },
    );
  }

  /// Método para manejar el envío del formulario
  Future<void> _handleSubmit(BuildContext context, IncidenciaController controller) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_fechaIncidencia == null || _idEstatus == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, completa todos los campos requeridos'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Construir Map con datos de la incidencia
    final habitacionAreaId = int.parse(_habitacionAreaIdController.text.trim());
    final incidencia = _incidenciaController.text.trim();
    final descripcion = _descripcionController.text.trim();
    
    // Formatear fecha a ISO 8601 con timezone Z
    final fechaIso = _fechaIncidencia!.toUtc().toIso8601String();
    
    final incidenciaData = <String, dynamic>{
      'habitacion_area_id': habitacionAreaId,
      'incidencia': incidencia,
      'descripcion': descripcion,
      'fecha_incidencia': fechaIso,
      'id_estatus': _idEstatus!,
    };

    // Actualizar incidencia
    final success = await controller.updateIncidencia(widget.incidenciaId, incidenciaData);

    if (success && context.mounted) {
      // Mostrar mensaje de éxito
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Incidencia actualizada con éxito'),
          backgroundColor: Colors.green,
        ),
      );
      // Navegar de regreso con resultado
      Navigator.pop(context, true);
    } else if (context.mounted && controller.isNotAuthenticated) {
      // Si no está autenticado, redirigir a login
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (context) => const LoginScreen(),
        ),
        (route) => false,
      );
    }
  }

  /// Widget para construir la sección de galería
  Widget _buildGallerySection(IncidenciaController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(
              Icons.photo_library,
              color: Color(0xFF667eea),
              size: 24,
            ),
            const SizedBox(width: 8),
            const Text(
              'Galería de Fotos',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1a1a1a),
                letterSpacing: -0.5,
              ),
            ),
            const Spacer(),
            Consumer<IncidenciaController>(
              builder: (context, ctrl, _) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF667eea),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${ctrl.galeriaImagenes.length}/5',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
        const SizedBox(height: 16),
        // Estado de carga de galería
        if (controller.isLoadingGaleria)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(32.0),
              child: CircularProgressIndicator(
                color: Color(0xFF667eea),
              ),
            ),
          )
        // Grid de fotos
        else if (controller.galeriaImagenes.isNotEmpty)
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.zero,
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
          )
        // Estado vacío
        else
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFFe5e7eb),
                width: 1,
              ),
            ),
            child: const Center(
              child: Column(
                children: [
                  Icon(
                    Icons.photo_library_outlined,
                    size: 48,
                    color: Color(0xFF9ca3af),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'No hay fotos disponibles',
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF6b7280),
                    ),
                  ),
                ],
              ),
            ),
          ),
        const SizedBox(height: 16),
        // Botón para agregar foto
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton.icon(
            onPressed: controller.canAddMorePhotos && 
                      !controller.isUploadingPhoto && 
                      !controller.isDeletingPhoto
                ? () => _takePicture(controller)
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
              controller.isUploadingPhoto ? 'Subiendo...' : 'Agregar Foto',
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
      ],
    );
  }

  /// Widget para construir una card de foto
  Widget _buildPhotoCard(GaleriaImagen imagen, IncidenciaController controller) {
    return Stack(
      children: [
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
                : () => _confirmDeletePhoto(imagen.nombre, imagen.ruta, controller),
          ),
        ),
      ],
    );
  }

  /// Capturar foto con la cámara
  Future<void> _takePicture(IncidenciaController controller) async {
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
              onPressed: () => _takePicture(controller),
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
  void _confirmDeletePhoto(String nombreArchivo, String rutaArchivo, IncidenciaController controller) {
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
                await _deletePhoto(nombreArchivo, rutaArchivo, controller);
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
  Future<void> _deletePhoto(String nombreArchivo, String rutaArchivo, IncidenciaController controller) async {
    print('🗑️ [EDIT SCREEN] Intentando eliminar foto');
    print('   Nombre recibido: "$nombreArchivo"');
    print('   Ruta recibida: "$rutaArchivo"');
    print('   ID Incidencia: ${widget.incidenciaId}');
    
    // Intentar primero con el nombre, luego con la ruta completa si falla
    bool success = await controller.deletePhoto(widget.incidenciaId, nombreArchivo);
    
    // Si falla con el nombre, intentar con la ruta completa
    if (!success && rutaArchivo.isNotEmpty && rutaArchivo != nombreArchivo) {
      print('⚠️ Falló con nombre, intentando con ruta completa...');
      success = await controller.deletePhoto(widget.incidenciaId, rutaArchivo);
    }

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Foto eliminada correctamente'),
            backgroundColor: Colors.green,
          ),
        );
        // La galería se refresca automáticamente en el controller después de eliminar
      } else {
        final errorMessage = controller.uploadPhotoError ?? 'Error desconocido al eliminar la foto';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
              action: SnackBarAction(
              label: 'Reintentar',
              textColor: Colors.white,
              onPressed: () => _deletePhoto(nombreArchivo, rutaArchivo, controller),
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
}


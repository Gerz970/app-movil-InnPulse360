import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../widgets/app_header.dart';
import '../../widgets/app_sidebar.dart';
import 'controllers/hotel_controller.dart';
import 'models/pais_model.dart';
import 'models/estado_model.dart';
import '../login/login_screen.dart';
import 'package:image_picker/image_picker.dart';

/// Pantalla de detalle y edición de hotel
/// Muestra formulario en modo edición con campos precargados
class HotelDetailScreen extends StatefulWidget {
  final int hotelId;

  const HotelDetailScreen({
    super.key,
    required this.hotelId,
  });

  @override
  State<HotelDetailScreen> createState() => _HotelDetailScreenState();
}

class _HotelDetailScreenState extends State<HotelDetailScreen> {
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();
  
  // Controladores de texto
  final _nombreController = TextEditingController();
  final _direccionController = TextEditingController();
  final _codigoPostalController = TextEditingController();
  final _telefonoController = TextEditingController();
  final _emailController = TextEditingController();
  
  // Valores seleccionados
  Pais? _paisSeleccionado;
  Estado? _estadoSeleccionado;
  int? _numeroEstrellas;
  
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    // Cargar detalle del hotel y país/estado específicos al iniciar
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final controller = Provider.of<HotelController>(context, listen: false);
      // Cargar detalle del hotel primero
      controller.loadHotelDetail(widget.hotelId).then((_) {
        // Una vez cargado el detalle, cargar país y estado específicos si existen
        final hotel = controller.hotelDetail;
        if (hotel != null) {
          if (hotel.idPais != null) {
            controller.loadPaisById(hotel.idPais!);
          }
          if (hotel.idEstado != null) {
            controller.loadEstadoById(hotel.idEstado!);
          }
        }
      });
    });
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _direccionController.dispose();
    _codigoPostalController.dispose();
    _telefonoController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  /// Método para precargar valores del hotel en los controladores
  void _preloadHotelData(HotelController controller) {
    if (_isInitialized || controller.hotelDetail == null) return;
    
    final hotel = controller.hotelDetail!;
    
    print('🔍 Precargando datos del hotel: ${hotel.nombre}');
    print('   idPais: ${hotel.idPais}, idEstado: ${hotel.idEstado}');
    
    // Precargar valores en controladores
    _nombreController.text = hotel.nombre;
    _direccionController.text = hotel.direccion;
    _codigoPostalController.text = hotel.codigoPostal ?? '';
    _telefonoController.text = hotel.telefono ?? '';
    _emailController.text = hotel.emailContacto ?? '';
    _numeroEstrellas = hotel.numeroEstrellas;
    
    // Precargar país usando paisDetail (cargado por endpoint específico)
    if (controller.paisDetail != null) {
      _paisSeleccionado = controller.paisDetail;
      print('✅ País cargado: ${controller.paisDetail!.nombre}');
    } else {
      _paisSeleccionado = null;
      print('⚠️ País no cargado aún o no existe');
    }
    
    // Precargar estado usando estadoDetail (cargado por endpoint específico)
    if (controller.estadoDetail != null) {
      _estadoSeleccionado = controller.estadoDetail;
      print('✅ Estado cargado: ${controller.estadoDetail!.nombre}');
    } else {
      _estadoSeleccionado = null;
      print('⚠️ Estado no cargado aún o no existe (es válido no tener estado)');
    }
    
    // Marcar como inicializado
    _isInitialized = true;
    
    print('✅ Datos precargados. País: ${_paisSeleccionado?.nombre ?? "null"}, Estado: ${_estadoSeleccionado?.nombre ?? "null"}');
    
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
              child: Consumer<HotelController>(
                builder: (context, controller, child) {
                  // Estado de carga (detalle)
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
                            'Cargando detalle del hotel...',
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
                    return _buildErrorState(context, controller);
                  }

                  // Si tenemos el detalle, precargar datos (país y estado se cargan de forma asíncrona)
                  if (controller.hotelDetail != null && !_isInitialized) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (mounted) {
                        _preloadHotelData(controller);
                      }
                    });
                  }
                  
                  // Si el país o estado se cargan después, actualizar los dropdowns
                  if (_isInitialized && controller.hotelDetail != null) {
                    // Actualizar país si se carga después
                    if (controller.paisDetail != null && _paisSeleccionado?.idPais != controller.paisDetail!.idPais) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (mounted) {
                          setState(() {
                            _paisSeleccionado = controller.paisDetail;
                          });
                        }
                      });
                    }
                    
                    // Actualizar estado si se carga después
                    if (controller.estadoDetail != null && _estadoSeleccionado?.idEstado != controller.estadoDetail!.idEstado) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (mounted) {
                          setState(() {
                            _estadoSeleccionado = controller.estadoDetail;
                          });
                        }
                      });
                    }
                  }

                  // Formulario - mostrar solo si está inicializado y tenemos el detalle
                  if (controller.hotelDetail != null && _isInitialized) {
                    return _buildForm(context, controller);
                  }

                  // Esperando inicialización
                  return const Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFF667eea),
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
              controller.detailErrorMessage ?? 'Error desconocido',
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
                    controller.loadHotelDetail(widget.hotelId);
                    controller.loadCatalogs();
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

  /// Widget para construir el formulario
  Widget _buildForm(BuildContext context, HotelController controller) {
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
                // Título y menú
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Detalle de hotel',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1a1a1a),
                          letterSpacing: -0.5,
                        ),
                      ),
                    ),
                    // Menú contextual
                    PopupMenuButton<String>(
                      icon: const Icon(
                        Icons.more_vert,
                        color: Color(0xFF6b7280),
                        size: 24,
                      ),
                      onSelected: (value) {
                        if (value == 'delete') {
                          _showDeleteConfirmationDialog(context, controller);
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
                                'Eliminar hotel',
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
                // Subtítulo
                const Text(
                  'Editar información básica',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF6b7280),
                  ),
                ),
                const SizedBox(height: 32),
                // Foto de hotel
                Center(
                  child: _buildFotoHotel(context, controller),
                ),
                const SizedBox(height: 32),
                // Campo: Nombre del hotel (EDITABLE)
                _buildTextField(
                  controller: _nombreController,
                  label: 'Nombre del hotel',
                  hint: 'Ingresa el nombre del hotel',
                  icon: Icons.hotel,
                  enabled: true,
                  validator: (value) {
                    if (value == null || value.isEmpty || value.trim().isEmpty) {
                      return 'El nombre es requerido';
                    }
                    final trimmedValue = value.trim();
                    if (trimmedValue.length < 3) {
                      return 'El nombre debe tener al menos 3 caracteres';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                // Campo: País (READ-ONLY)
                _buildPaisDropdown(controller, enabled: false),
                const SizedBox(height: 20),
                // Campo: Estado (READ-ONLY)
                _buildEstadoDropdown(controller, enabled: false),
                const SizedBox(height: 20),
                // Campo: Dirección (READ-ONLY)
                _buildTextField(
                  controller: _direccionController,
                  label: 'Dirección',
                  hint: 'Ingresa la dirección del hotel',
                  icon: Icons.location_on,
                  enabled: false,
                ),
                const SizedBox(height: 20),
                // Campo: Código postal (READ-ONLY)
                _buildTextField(
                  controller: _codigoPostalController,
                  label: 'Código postal',
                  hint: 'Ingresa el código postal',
                  icon: Icons.markunread_mailbox,
                  keyboardType: TextInputType.number,
                  enabled: false,
                ),
                const SizedBox(height: 20),
                // Campo: Teléfono (EDITABLE)
                _buildTextField(
                  controller: _telefonoController,
                  label: 'Teléfono',
                  hint: 'Ingresa el teléfono',
                  icon: Icons.phone,
                  keyboardType: TextInputType.phone,
                  enabled: true,
                ),
                const SizedBox(height: 20),
                // Campo: Correo de contacto (READ-ONLY)
                _buildTextField(
                  controller: _emailController,
                  label: 'Correo de contacto',
                  hint: 'ejemplo@hotel.com',
                  icon: Icons.email,
                  keyboardType: TextInputType.emailAddress,
                  enabled: false,
                ),
                const SizedBox(height: 20),
                // Campo: Número de estrellas (EDITABLE)
                _buildEstrellasDropdown(enabled: true),
                const SizedBox(height: 32),
                // Botones
                Row(
                  children: [
                    // Botón Cancelar
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF667eea),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          side: const BorderSide(
                            color: Color(0xFF667eea),
                            width: 1,
                          ),
                        ),
                        child: const Text(
                          'Cancelar',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Botón Guardar cambios
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                        onPressed: controller.isUpdating ? null : () => _handleSubmit(context, controller),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF667eea),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          disabledBackgroundColor: const Color(0xFF9ca3af),
                        ),
                        child: const Text(
                          'Guardar cambios',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),
                  ],
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
        // Overlay de guardando
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
                    'Guardando cambios...',
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
    required bool enabled,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      enabled: enabled,
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
        disabledBorder: OutlineInputBorder(
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
        fillColor: enabled ? Colors.white : Colors.grey.shade50,
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

  /// Widget para construir dropdown de países
  /// En modo detalle, solo muestra el país específico (read-only)
  Widget _buildPaisDropdown(HotelController controller, {required bool enabled}) {
    return Consumer<HotelController>(
      builder: (context, controller, child) {
        // En modo detalle, usar paisDetail (país específico cargado por ID)
        final paisValue = controller.paisDetail ?? _paisSeleccionado;
        
        // Crear lista con solo el país específico (si existe)
        final paisesList = paisValue != null ? [paisValue] : <Pais>[];
        
        return DropdownButtonFormField<Pais>(
          value: paisValue,
          decoration: InputDecoration(
            labelText: 'País',
            prefixIcon: const Icon(
              Icons.public,
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
            disabledBorder: OutlineInputBorder(
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
            fillColor: enabled ? Colors.white : Colors.grey.shade50,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
            labelStyle: const TextStyle(
              color: Color(0xFF6b7280),
              fontSize: 14,
            ),
          ),
          items: paisesList.map((pais) {
            return DropdownMenuItem<Pais>(
              value: pais,
              child: Text(pais.nombre),
            );
          }).toList(),
          onChanged: null, // Siempre deshabilitado en modo detalle
        );
      },
    );
  }

  /// Widget para construir dropdown de estados
  /// En modo detalle, solo muestra el estado específico (read-only)
  Widget _buildEstadoDropdown(HotelController controller, {required bool enabled}) {
    return Consumer<HotelController>(
      builder: (context, controller, child) {
        // En modo detalle, usar estadoDetail (estado específico cargado por ID)
        final estadoValue = controller.estadoDetail ?? _estadoSeleccionado;
        
        // Crear lista con solo el estado específico (si existe)
        final estadosList = estadoValue != null ? [estadoValue] : <Estado>[];
        
        return DropdownButtonFormField<Estado>(
          value: estadoValue,
          hint: const Text('Sin estado'), // Mostrar hint cuando no hay estado seleccionado
          decoration: InputDecoration(
            labelText: 'Estado',
            prefixIcon: const Icon(
              Icons.map,
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
            disabledBorder: OutlineInputBorder(
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
            fillColor: enabled ? Colors.white : Colors.grey.shade50,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
            labelStyle: const TextStyle(
              color: Color(0xFF6b7280),
              fontSize: 14,
            ),
          ),
          items: estadosList.map((estado) {
            return DropdownMenuItem<Estado>(
              value: estado,
              child: Text(estado.nombre),
            );
          }).toList(),
          onChanged: null, // Siempre deshabilitado en modo detalle
        );
      },
    );
  }

  /// Widget para construir dropdown de estrellas
  Widget _buildEstrellasDropdown({required bool enabled}) {
    return DropdownButtonFormField<int>(
      value: _numeroEstrellas,
      decoration: InputDecoration(
        labelText: 'Número de estrellas',
        prefixIcon: const Icon(
          Icons.star,
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
        disabledBorder: OutlineInputBorder(
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
        fillColor: enabled ? Colors.white : Colors.grey.shade50,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        labelStyle: const TextStyle(
          color: Color(0xFF6b7280),
          fontSize: 14,
        ),
      ),
      items: List.generate(5, (index) {
        final stars = index + 1;
        return DropdownMenuItem<int>(
          value: stars,
          child: Row(
            children: [
              ...List.generate(stars, (_) => const Icon(Icons.star, size: 16, color: Colors.amber)),
              const SizedBox(width: 8),
              Text('$stars ${stars == 1 ? 'estrella' : 'estrellas'}'),
            ],
          ),
        );
      }),
      onChanged: enabled
          ? (int? value) {
              setState(() {
                _numeroEstrellas = value;
              });
            }
          : null,
    );
  }

  /// Método para manejar el envío del formulario
  Future<void> _handleSubmit(BuildContext context, HotelController controller) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_numeroEstrellas == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, selecciona el número de estrellas'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Construir Map solo con campos editables
    final hotelData = <String, dynamic>{
      'nombre': _nombreController.text.trim(),
      'numero_estrellas': _numeroEstrellas!,
    };

    // Agregar teléfono solo si tiene valor
    final telefonoText = _telefonoController.text;
    if (telefonoText.isNotEmpty) {
      final telefono = telefonoText.trim();
      if (telefono.isNotEmpty) {
        hotelData['telefono'] = telefono;
      }
    }

    // Actualizar hotel
    final success = await controller.updateHotel(widget.hotelId, hotelData);

    if (success && context.mounted) {
      // Refrescar la lista de hoteles antes de regresar
      await controller.fetchHotels();
      
      // Mostrar mensaje de éxito
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cambios guardados'),
          backgroundColor: Colors.green,
        ),
      );
      // Navegar de regreso
      Navigator.pop(context, true); // Pasar true para indicar que se actualizó
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

  /// Método para mostrar el modal de confirmación de eliminación
  void _showDeleteConfirmationDialog(BuildContext context, HotelController controller) {
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
                          _handleDelete(context, controller);
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
  Future<void> _handleDelete(BuildContext context, HotelController controller) async {
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
      final success = await controller.deleteHotel(widget.hotelId);

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
          await controller.fetchHotels();
          // Navegar atrás
          Navigator.pop(context);
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
                  _handleDelete(context, controller);
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

  /// Widget para construir la foto de hotel
  Widget _buildFotoHotel(BuildContext context, HotelController controller) {
    final hotel = controller.hotelDetail;
    if (hotel == null) return const SizedBox.shrink();
    
    String? fotoUrl = hotel.urlFotoPerfil;
    
    return Stack(
      children: [
        // Foto de hotel circular
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
            child: fotoUrl != null && fotoUrl.isNotEmpty
                ? Image.network(
                    fotoUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: const Color(0xFF667eea).withOpacity(0.1),
                        child: const Icon(
                          Icons.hotel,
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
                      Icons.hotel,
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

  /// Método para mostrar opciones de foto
  void _mostrarOpcionesFoto(BuildContext context, HotelController controller) {
    final hotel = controller.hotelDetail;
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
                _pickImageFromGallery(context, controller);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Tomar foto'),
              onTap: () {
                Navigator.pop(context);
                _pickImageFromCamera(context, controller);
              },
            ),
            if (hotel != null &&
                hotel.urlFotoPerfil != null &&
                hotel.urlFotoPerfil!.isNotEmpty)
              ListTile(
                leading: const Icon(Icons.delete_outline, color: Colors.red),
                title: const Text('Restaurar foto por defecto', style: TextStyle(color: Colors.red)),
                onTap: () {
                  Navigator.pop(context);
                  _deleteFoto(context, controller);
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

  /// Seleccionar foto desde galería
  Future<void> _pickImageFromGallery(BuildContext context, HotelController controller) async {
    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
        maxWidth: 800,
        maxHeight: 800,
      );

      if (photo == null) return;

      // Leer los bytes del archivo
      final fileBytes = await photo.readAsBytes();
      final fileName = photo.name;

      final success = await controller.subirFotoHotel(widget.hotelId, fileBytes, fileName);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success
                  ? 'Foto de hotel actualizada correctamente'
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

  /// Seleccionar foto desde cámara
  Future<void> _pickImageFromCamera(BuildContext context, HotelController controller) async {
    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
        maxWidth: 800,
        maxHeight: 800,
      );

      if (photo == null) return;

      // Leer los bytes del archivo
      final fileBytes = await photo.readAsBytes();
      final fileName = photo.name;

      final success = await controller.subirFotoHotel(widget.hotelId, fileBytes, fileName);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success
                  ? 'Foto de hotel actualizada correctamente'
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
            content: Text('Error al tomar foto: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Eliminar foto de hotel
  Future<void> _deleteFoto(BuildContext context, HotelController controller) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Restaurar foto por defecto'),
        content: const Text(
          '¿Estás seguro de que deseas restaurar la foto de hotel por defecto?',
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
      final success = await controller.eliminarFotoHotel(widget.hotelId);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success
                  ? 'Foto de hotel restaurada correctamente'
                  : controller.uploadPhotoError ?? 'Error al eliminar foto',
            ),
            backgroundColor: success ? Colors.green : Colors.red,
          ),
        );
      }
    }
  }
}


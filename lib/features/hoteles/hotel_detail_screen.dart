import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../widgets/app_header.dart';
import '../../widgets/app_sidebar.dart';
import 'controllers/hotel_controller.dart';
import 'models/pais_model.dart';
import 'models/estado_model.dart';
import 'models/galeria_image_model.dart';
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
      // Cargar catálogos de países y estados para habilitar edición
      controller.loadCatalogs();
      
      // Cargar detalle del hotel primero
      controller.loadHotelDetail(widget.hotelId).then((_) {
        // Una vez cargado el detalle, cargar país y estado específicos si existen
        // Estas peticiones son opcionales y no bloquean la UI si fallan
        final hotel = controller.hotelDetail;
        if (hotel != null) {
          if (hotel.idPais != null) {
            controller.loadPaisById(hotel.idPais!).then((_) {
              // Si el país es México, cargar estados
              if (controller.paisDetail != null && _esMexico(controller.paisDetail)) {
                controller.loadEstadosByPais(hotel.idPais!);
              }
            }).catchError((e) {
              // Error silencioso para peticiones secundarias
            });
          }
          if (hotel.idEstado != null) {
            controller.loadEstadoById(hotel.idEstado!).catchError((e) {
              // Error silencioso para peticiones secundarias
            });
          }
        }
        // Cargar galería de imágenes (también opcional)
        controller.cargarGaleria(widget.hotelId).catchError((e) {
          // Error silencioso para galería
        });
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

  /// Verificar si un país es México
  bool _esMexico(Pais? pais) {
    if (pais == null) return false;
    // Comparar sin importar mayúsculas/minúsculas y con/sin acento
    final nombreNormalizado = pais.nombre.toLowerCase().trim();
    // Normalizar acentos: méxico -> mexico
    final nombreSinAcentos = nombreNormalizado
        .replaceAll('é', 'e')
        .replaceAll('É', 'e')
        .replaceAll('ó', 'o')
        .replaceAll('Ó', 'o');
    
    return nombreNormalizado == 'méxico' || 
           nombreNormalizado == 'mexico' ||
           nombreSinAcentos == 'mexico';
  }

  /// Método para precargar valores del hotel en los controladores
  void _preloadHotelData(HotelController controller) {
    if (_isInitialized || controller.hotelDetail == null) return;
    
    final hotel = controller.hotelDetail!;
    
    // Precargar valores en controladores
    _nombreController.text = hotel.nombre;
    _direccionController.text = hotel.direccion;
    _codigoPostalController.text = hotel.codigoPostal ?? '';
    _telefonoController.text = hotel.telefono ?? '';
    _emailController.text = hotel.emailContacto ?? '';
    _numeroEstrellas = hotel.numeroEstrellas;
    
    // Precargar país: buscar en la lista de países cargados por ID
    // IMPORTANTE: Solo usar países que estén en la lista para evitar errores del dropdown
    if (controller.paisDetail != null && controller.paises.isNotEmpty) {
      try {
        _paisSeleccionado = controller.paises.firstWhere(
          (pais) => pais.idPais == controller.paisDetail!.idPais,
        );
        // Solo cargar estados si el país es México
        if (_esMexico(_paisSeleccionado)) {
          controller.loadEstadosByPais(_paisSeleccionado!.idPais);
        }
      } catch (e) {
        // Si no se encuentra en la lista, dejar null (se actualizará cuando se carguen los países)
        _paisSeleccionado = null;
      }
    } else if (controller.paisDetail != null) {
      // Si aún no se han cargado los países, dejar null temporalmente
      // Se actualizará cuando se carguen los catálogos
      _paisSeleccionado = null;
    } else if (hotel.idPais != null && controller.paises.isNotEmpty) {
      // Si no hay paisDetail pero hay idPais, buscar directamente en catálogos
      try {
        _paisSeleccionado = controller.paises.firstWhere(
          (pais) => pais.idPais == hotel.idPais,
        );
        // Solo cargar estados si el país es México
        if (_esMexico(_paisSeleccionado)) {
          controller.loadEstadosByPais(_paisSeleccionado!.idPais);
        }
      } catch (e) {
        _paisSeleccionado = null;
      }
    } else {
      _paisSeleccionado = null;
    }
    
    // Precargar estado: buscar en la lista de estados cargados por ID
    // IMPORTANTE: Solo usar estados que estén en la lista para evitar errores del dropdown
    // Solo si el país es México
    if (_esMexico(_paisSeleccionado ?? controller.paisDetail)) {
      if (controller.estadoDetail != null && controller.estados.isNotEmpty) {
        try {
          _estadoSeleccionado = controller.estados.firstWhere(
            (estado) => estado.idEstado == controller.estadoDetail!.idEstado,
          );
        } catch (e) {
          // Si no se encuentra en la lista, dejar null (se actualizará cuando se carguen los estados)
          _estadoSeleccionado = null;
        }
      } else if (controller.estadoDetail != null) {
        // Si aún no se han cargado los estados, esperar un momento
        // IMPORTANTE: Solo actualizar si el usuario no ha seleccionado un estado diferente
        final idEstadoOriginal = controller.estadoDetail!.idEstado;
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted && controller.estados.isNotEmpty) {
            // Solo actualizar si el usuario no ha cambiado el estado manualmente
            // Verificar que el estado seleccionado actual coincide con el original o es null
            if (_estadoSeleccionado == null || _estadoSeleccionado?.idEstado == idEstadoOriginal) {
              try {
                _estadoSeleccionado = controller.estados.firstWhere(
                  (estado) => estado.idEstado == idEstadoOriginal,
                );
                setState(() {});
              } catch (e) {
                if (_estadoSeleccionado == null) {
                  _estadoSeleccionado = null;
                }
              }
            }
          }
        });
      } else {
        _estadoSeleccionado = null;
      }
    } else {
      _estadoSeleccionado = null;
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
              child: Consumer<HotelController>(
                builder: (context, controller, child) {
                  // Estado de error al cargar detalle
                  if (controller.detailErrorMessage != null) {
                    return _buildErrorState(context, controller);
                  }

                  // Mostrar loader SOLO mientras se carga el detalle del hotel
                  // Los catálogos y otros datos se cargan en segundo plano sin bloquear
                  if (controller.isLoadingDetail || controller.hotelDetail == null) {
                    return const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(
                            color: Color(0xFF667eea),
                          ),
                          SizedBox(height: 16),
                          Text(
                            'Cargando información del hotel...',
                            style: TextStyle(
                              fontSize: 16,
                              color: Color(0xFF6b7280),
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  // Si tenemos el detalle, precargar datos (país y estado se cargan de forma asíncrona)
                  if (controller.hotelDetail != null && !_isInitialized) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (mounted) {
                        _preloadHotelData(controller);
                      }
                    });
                  }
                  
                  // NOTA: La inicialización de país y estado se maneja completamente en _preloadHotelData
                  // No actualizar automáticamente después de la inicialización para evitar sobrescribir cambios del usuario

                  // Formulario - mostrar si tenemos el detalle (inicialización puede estar en progreso)
                  if (controller.hotelDetail != null) {
                    return _buildForm(context, controller);
                  }

                  // Fallback (no debería llegar aquí)
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
                // Galería de fotos
                _buildGaleriaSection(context, controller),
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
                // Campo: País (EDITABLE)
                _buildPaisDropdown(controller, enabled: true),
                const SizedBox(height: 20),
                // Campo: Estado (EDITABLE)
                _buildEstadoDropdown(controller, enabled: true),
                const SizedBox(height: 20),
                // Campo: Dirección (EDITABLE)
                _buildTextField(
                  controller: _direccionController,
                  label: 'Dirección',
                  hint: 'Ingresa la dirección del hotel',
                  icon: Icons.location_on,
                  enabled: true,
                ),
                const SizedBox(height: 20),
                // Campo: Código postal (EDITABLE)
                _buildTextField(
                  controller: _codigoPostalController,
                  label: 'Código postal',
                  hint: 'Ingresa el código postal',
                  icon: Icons.markunread_mailbox,
                  keyboardType: TextInputType.number,
                  enabled: true,
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
  /// Si enabled == true, muestra lista completa y permite edición
  /// Si enabled == false, solo muestra el país específico (read-only)
  Widget _buildPaisDropdown(HotelController controller, {required bool enabled}) {
    return Consumer<HotelController>(
      builder: (context, controller, child) {
        // Si hay un país seleccionado, verificar que esté en la lista
        Pais? paisValue = _paisSeleccionado;
        
        // Si está habilitado, verificar que el país seleccionado esté en la lista de países cargados
        if (enabled && paisValue != null && controller.paises.isNotEmpty) {
          // Verificar si el objeto ya está en la lista (comparación por ID)
          final existeEnLista = controller.paises.any((pais) => pais.idPais == paisValue!.idPais);
          if (!existeEnLista) {
            // Si no está en la lista, usar null para evitar el error
            paisValue = null;
          } else {
            // Si existe, obtener el objeto exacto de la lista (no el de _paisSeleccionado)
            try {
              final idPaisBuscado = paisValue.idPais;
              paisValue = controller.paises.firstWhere(
                (pais) => pais.idPais == idPaisBuscado,
              );
            } catch (e) {
              // Si no se encuentra, usar null para evitar el error
              paisValue = null;
            }
          }
        }
        
        // Si no hay país seleccionado pero hay detalle, buscar en la lista
        if (enabled && paisValue == null && controller.paisDetail != null && controller.paises.isNotEmpty) {
          try {
            paisValue = controller.paises.firstWhere(
              (pais) => pais.idPais == controller.paisDetail!.idPais,
            );
          } catch (e) {
            // Si no se encuentra en la lista, usar null (mostrará el hint)
            paisValue = null;
          }
        }
        
        // Si no está habilitado, usar el valor tal cual (read-only)
        if (!enabled) {
          paisValue = _paisSeleccionado ?? controller.paisDetail;
        }
        
        // Si está habilitado, usar lista completa de catálogos, sino solo el país específico
        final paisesList = enabled
            ? (() {
                try {
                  final paises = controller.paises;
                  return paises.isNotEmpty ? paises : <Pais>[];
                } catch (e) {
                  return <Pais>[];
                }
              }())
            : (paisValue != null ? [paisValue] : <Pais>[]);
        
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
          validator: enabled
              ? (value) {
                  if (value == null) {
                    return 'El país es requerido';
                  }
                  return null;
                }
              : null,
          onChanged: enabled
              ? (Pais? pais) {
                  setState(() {
                    _paisSeleccionado = pais;
                    _estadoSeleccionado = null; // Limpiar estado al cambiar país
                    if (pais != null) {
                      // Solo cargar estados si el país es México
                      if (_esMexico(pais)) {
                        controller.loadEstadosByPais(pais.idPais);
                      }
                    }
                  });
                }
              : null,
        );
      },
    );
  }

  /// Widget para construir dropdown de estados
  /// Si enabled == true, muestra lista completa y permite edición (solo para México)
  /// Si enabled == false, solo muestra el estado específico (read-only)
  Widget _buildEstadoDropdown(HotelController controller, {required bool enabled}) {
    return Consumer<HotelController>(
      builder: (context, controller, child) {
        // Solo mostrar/habilitar el dropdown si el país seleccionado es México
        final esMexico = _esMexico(_paisSeleccionado ?? controller.paisDetail);
        
        // Si hay un estado seleccionado, verificar que esté en la lista
        Estado? estadoValue = _estadoSeleccionado;
        
        // Si está habilitado y es México, verificar que el estado seleccionado esté en la lista
        if (enabled && esMexico && estadoValue != null && controller.estados.isNotEmpty) {
          // Verificar si el objeto ya está en la lista (comparación por ID)
          final existeEnLista = controller.estados.any((estado) => estado.idEstado == estadoValue!.idEstado);
          if (!existeEnLista) {
            // Si no está en la lista, usar null para evitar el error
            estadoValue = null;
          } else {
            // Si existe, obtener el objeto exacto de la lista (no el de _estadoSeleccionado)
            try {
              final idEstadoBuscado = estadoValue.idEstado;
              estadoValue = controller.estados.firstWhere(
                (estado) => estado.idEstado == idEstadoBuscado,
              );
            } catch (e) {
              // Si no se encuentra, usar null para evitar el error
              estadoValue = null;
            }
          }
        }
        
        // Si no hay estado seleccionado pero hay detalle, buscar en la lista
        if (enabled && esMexico && estadoValue == null && controller.estadoDetail != null && controller.estados.isNotEmpty) {
          try {
            estadoValue = controller.estados.firstWhere(
              (estado) => estado.idEstado == controller.estadoDetail!.idEstado,
            );
          } catch (e) {
            // Si no se encuentra en la lista, usar null (mostrará el hint)
            estadoValue = null;
          }
        }
        
        // Si no está habilitado, usar el valor tal cual (read-only)
        if (!enabled) {
          estadoValue = _estadoSeleccionado ?? controller.estadoDetail;
        }
        
        // Si está habilitado y es México, usar lista completa de catálogos, sino solo el estado específico o vacío
        final estadosList = (enabled && esMexico)
            ? (() {
                try {
                  final estados = controller.estados;
                  return estados.isNotEmpty ? estados : <Estado>[];
                } catch (e) {
                  return <Estado>[];
                }
              }())
            : (estadoValue != null && !enabled ? [estadoValue] : <Estado>[]);
        
        // Si no es México o no está habilitado, forzar null (excepto cuando está deshabilitado y hay valor)
        final valorMostrado = (enabled && esMexico) ? estadoValue : (!enabled ? estadoValue : null);
        
        return DropdownButtonFormField<Estado>(
          value: valorMostrado,
          hint: Text(esMexico ? 'Selecciona un estado' : 'Solo disponible para México'),
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
            fillColor: (enabled && esMexico) ? Colors.white : Colors.grey.shade100,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
            labelStyle: TextStyle(
              color: (enabled && esMexico) ? const Color(0xFF6b7280) : Colors.grey.shade400,
              fontSize: 14,
            ),
            hintStyle: TextStyle(
              color: Colors.grey.shade400,
              fontSize: 14,
            ),
          ),
          items: estadosList.map((estado) {
            return DropdownMenuItem<Estado>(
              value: estado,
              child: Text(estado.nombre),
            );
          }).toList(),
          validator: enabled
              ? (value) {
                  // Estado es opcional, no requiere validación
                  return null;
                }
              : null,
          onChanged: (enabled && esMexico && controller.estados.isNotEmpty)
              ? (Estado? estado) {
                  setState(() {
                    _estadoSeleccionado = estado;
                  });
                }
              : null,
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

    // Construir Map con campos editables
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

    // Agregar dirección si tiene valor
    final direccionText = _direccionController.text.trim();
    if (direccionText.isNotEmpty) {
      hotelData['direccion'] = direccionText;
    }

    // Agregar código postal si tiene valor
    final codigoPostalText = _codigoPostalController.text.trim();
    if (codigoPostalText.isNotEmpty) {
      hotelData['codigo_postal'] = codigoPostalText;
    }

    // Agregar país si está seleccionado
    if (_paisSeleccionado != null) {
      hotelData['id_pais'] = _paisSeleccionado!.idPais;
    }

    // Agregar estado si está seleccionado (opcional)
    if (_estadoSeleccionado != null) {
      hotelData['id_estado'] = _estadoSeleccionado!.idEstado;
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
          // Error silencioso al cerrar diálogo
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
          // Error silencioso al cerrar diálogo
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

  /// Widget para construir la sección de galería
  Widget _buildGaleriaSection(BuildContext context, HotelController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Título y contador
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Galería de fotos',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1a1a1a),
              ),
            ),
            Text(
              '${controller.totalImagenesGaleria}/10',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: controller.totalImagenesGaleria >= 10 
                    ? Colors.red 
                    : const Color(0xFF6b7280),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        // Grid de imágenes o mensaje vacío
        if (controller.isLoadingGaleria)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(32.0),
              child: CircularProgressIndicator(
                color: Color(0xFF667eea),
              ),
            ),
          )
        else if (controller.galeriaImagenes.isEmpty)
          _buildEmptyGaleria(context, controller)
        else
          _buildGaleriaGrid(context, controller),
        // Mensaje de error si existe
        if (controller.galeriaErrorMessage != null)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Container(
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
                      controller.galeriaErrorMessage!,
                      style: TextStyle(
                        color: Colors.red.shade700,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  /// Widget para mostrar estado vacío de galería
  Widget _buildEmptyGaleria(BuildContext context, HotelController controller) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Icon(
            Icons.photo_library_outlined,
            size: 48,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'No hay imágenes en la galería',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
          if (controller.puedeAgregarMasImagenes) ...[
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => _mostrarDialogoAgregarImagen(context, controller),
              icon: const Icon(Icons.add, size: 20),
              label: const Text('Agregar primera imagen'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF667eea),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Widget para construir el grid de imágenes de la galería
  Widget _buildGaleriaGrid(BuildContext context, HotelController controller) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 1.0,
      ),
      itemCount: controller.galeriaImagenes.length + (controller.puedeAgregarMasImagenes ? 1 : 0),
      itemBuilder: (context, index) {
        // Si es el último índice y se puede agregar más, mostrar botón de agregar
        if (index == controller.galeriaImagenes.length && controller.puedeAgregarMasImagenes) {
          return _buildAddImageButton(context, controller);
        }
        // Mostrar imagen
        return _buildGaleriaImageItem(context, controller.galeriaImagenes[index], controller);
      },
    );
  }

  /// Widget para construir un item de imagen en la galería
  Widget _buildGaleriaImageItem(BuildContext context, GaleriaImage imagen, HotelController controller) {
    return Stack(
      children: [
        // Imagen
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: imagen.urlPublica != null && imagen.urlPublica!.isNotEmpty
              ? Image.network(
                  imagen.urlPublica!,
                  width: double.infinity,
                  height: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey.shade200,
                      child: const Icon(
                        Icons.broken_image,
                        color: Colors.grey,
                        size: 32,
                      ),
                    );
                  },
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      color: Colors.grey.shade100,
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
                  color: Colors.grey.shade200,
                  child: const Icon(
                    Icons.image,
                    color: Colors.grey,
                    size: 32,
                  ),
                ),
        ),
        // Botón de eliminar
        Positioned(
          top: 4,
          right: 4,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.6),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(
                minWidth: 32,
                minHeight: 32,
              ),
              icon: const Icon(
                Icons.close,
                color: Colors.white,
                size: 18,
              ),
              onPressed: () => _eliminarImagenGaleria(context, imagen, controller),
            ),
          ),
        ),
      ],
    );
  }

  /// Widget para botón de agregar imagen
  Widget _buildAddImageButton(BuildContext context, HotelController controller) {
    return InkWell(
      onTap: controller.isUploadingGaleria 
          ? null 
          : () => _mostrarDialogoAgregarImagen(context, controller),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: Colors.grey.shade300,
            style: BorderStyle.solid,
            width: 2,
          ),
        ),
        child: controller.isUploadingGaleria
            ? const Center(
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Color(0xFF667eea),
                ),
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.add_photo_alternate,
                    size: 32,
                    color: Colors.grey.shade600,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Agregar',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  /// Método para mostrar diálogo de agregar imagen
  void _mostrarDialogoAgregarImagen(BuildContext context, HotelController controller) {
    if (!controller.puedeAgregarMasImagenes) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Se ha alcanzado el límite máximo de 10 imágenes por hotel'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

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
                _pickImageFromGalleryForGaleria(context, controller);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Tomar foto'),
              onTap: () {
                Navigator.pop(context);
                _pickImageFromCameraForGaleria(context, controller);
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

  /// Seleccionar foto desde galería para galería
  Future<void> _pickImageFromGalleryForGaleria(BuildContext context, HotelController controller) async {
    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
        maxWidth: 800,
        maxHeight: 800,
      );

      if (photo == null) return;

      // Validar límite antes de subir
      if (!controller.puedeAgregarMasImagenes) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Se ha alcanzado el límite máximo de 10 imágenes por hotel'),
              backgroundColor: Colors.orange,
            ),
          );
        }
        return;
      }

      // Leer los bytes del archivo
      final fileBytes = await photo.readAsBytes();
      final fileName = photo.name;

      final success = await controller.subirImagenGaleria(widget.hotelId, fileBytes, fileName);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success
                  ? 'Imagen agregada a la galería correctamente'
                  : controller.galeriaErrorMessage ?? 'Error al subir imagen',
            ),
            backgroundColor: success ? Colors.green : Colors.red,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al seleccionar imagen: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Seleccionar foto desde cámara para galería
  Future<void> _pickImageFromCameraForGaleria(BuildContext context, HotelController controller) async {
    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
        maxWidth: 800,
        maxHeight: 800,
      );

      if (photo == null) return;

      // Validar límite antes de subir
      if (!controller.puedeAgregarMasImagenes) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Se ha alcanzado el límite máximo de 10 imágenes por hotel'),
              backgroundColor: Colors.orange,
            ),
          );
        }
        return;
      }

      // Leer los bytes del archivo
      final fileBytes = await photo.readAsBytes();
      final fileName = photo.name;

      final success = await controller.subirImagenGaleria(widget.hotelId, fileBytes, fileName);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success
                  ? 'Imagen agregada a la galería correctamente'
                  : controller.galeriaErrorMessage ?? 'Error al subir imagen',
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

  /// Eliminar imagen de galería
  Future<void> _eliminarImagenGaleria(BuildContext context, GaleriaImage imagen, HotelController controller) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar imagen'),
        content: const Text(
          '¿Estás seguro de que deseas eliminar esta imagen de la galería?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmar == true) {
      final success = await controller.eliminarImagenGaleria(widget.hotelId, imagen.nombre);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success
                  ? 'Imagen eliminada correctamente'
                  : controller.galeriaErrorMessage ?? 'Error al eliminar imagen',
            ),
            backgroundColor: success ? Colors.green : Colors.red,
          ),
        );
      }
    }
  }
}


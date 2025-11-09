import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../widgets/app_header.dart';
import '../../widgets/app_sidebar.dart';
import 'controllers/hotel_controller.dart';
import 'models/pais_model.dart';
import 'models/estado_model.dart';
import '../login/login_screen.dart';

/// Pantalla de formulario para crear un nuevo hotel
/// Incluye carga de catálogos, validaciones y creación de hotel
class HotelCreateScreen extends StatefulWidget {
  const HotelCreateScreen({super.key});

  @override
  State<HotelCreateScreen> createState() => _HotelCreateScreenState();
}

class _HotelCreateScreenState extends State<HotelCreateScreen> {
  final _formKey = GlobalKey<FormState>();
  
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

  @override
  void initState() {
    super.initState();
    // Cargar catálogos al iniciar la pantalla
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final controller = Provider.of<HotelController>(context, listen: false);
      controller.loadCatalogs();
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
                  // Estado de carga de catálogos
                  if (controller.isLoadingCatalogs) {
                    return const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(
                            color: Color(0xFF667eea),
                          ),
                          SizedBox(height: 16),
                          Text(
                            'Cargando catálogos...',
                            style: TextStyle(
                              fontSize: 16,
                              color: Color(0xFF6b7280),
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  // Estado de error al cargar catálogos
                  if (controller.errorMessage != null) {
                    try {
                      final paisesList = controller.paises;
                      if (paisesList.isEmpty || paisesList.length == 0) {
                        return _buildErrorState(context, controller);
                      }
                    } catch (e) {
                      return _buildErrorState(context, controller);
                    }
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

  /// Widget para mostrar estado de error al cargar catálogos
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
            ElevatedButton(
              onPressed: () {
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
                // Título
                const Text(
                  'Registrar nuevo hotel',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1a1a1a),
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 32),
                // Campo: Nombre del hotel
                _buildTextField(
                  controller: _nombreController,
                  label: 'Nombre del hotel',
                  hint: 'Ingresa el nombre del hotel',
                  icon: Icons.hotel,
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
                // Campo: País
                _buildPaisDropdown(controller),
                const SizedBox(height: 20),
                // Campo: Estado
                _buildEstadoDropdown(controller),
                const SizedBox(height: 20),
                // Campo: Dirección
                _buildTextField(
                  controller: _direccionController,
                  label: 'Dirección',
                  hint: 'Ingresa la dirección del hotel',
                  icon: Icons.location_on,
                  validator: (value) {
                    if (value == null || value.isEmpty || value.trim().isEmpty) {
                      return 'La dirección es requerida';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                // Campo: Código postal
                _buildTextField(
                  controller: _codigoPostalController,
                  label: 'Código postal',
                  hint: 'Ingresa el código postal',
                  icon: Icons.markunread_mailbox,
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 20),
                // Campo: Teléfono
                _buildTextField(
                  controller: _telefonoController,
                  label: 'Teléfono',
                  hint: 'Ingresa el teléfono',
                  icon: Icons.phone,
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 20),
                // Campo: Correo de contacto
                _buildTextField(
                  controller: _emailController,
                  label: 'Correo de contacto',
                  hint: 'ejemplo@hotel.com',
                  icon: Icons.email,
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value != null && value.isNotEmpty && value.trim().isNotEmpty) {
                      final trimmedValue = value.trim();
                      final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                      if (!emailRegex.hasMatch(trimmedValue)) {
                        return 'Ingresa un correo válido';
                      }
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                // Campo: Número de estrellas
                _buildEstrellasDropdown(),
                const SizedBox(height: 32),
                // Botón Guardar
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: controller.isCreating ? null : () => _handleSubmit(context, controller),
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
                      'Guardar Hotel',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // Mostrar error de creación si existe
                if (controller.createErrorMessage != null)
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
                            controller.createErrorMessage!,
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
        if (controller.isCreating)
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
                    'Guardando hotel...',
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
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
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

  /// Widget para construir dropdown de países
  Widget _buildPaisDropdown(HotelController controller) {
    return Consumer<HotelController>(
      builder: (context, controller, child) {
        return DropdownButtonFormField<Pais>(
          value: _paisSeleccionado,
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
          items: (() {
            try {
              final paises = controller.paises;
              return paises.isNotEmpty ? paises : <Pais>[];
            } catch (e) {
              return <Pais>[];
            }
          }()).map((pais) {
            return DropdownMenuItem<Pais>(
              value: pais,
              child: Text(pais.nombre),
            );
          }).toList(),
          validator: (value) {
            if (value == null) {
              return 'El país es requerido';
            }
            return null;
          },
          onChanged: (Pais? pais) {
            setState(() {
              _paisSeleccionado = pais;
              _estadoSeleccionado = null; // Limpiar estado al cambiar país
              if (pais != null) {
                controller.loadEstadosByPais(pais.idPais);
              }
            });
          },
        );
      },
    );
  }

  /// Widget para construir dropdown de estados
  Widget _buildEstadoDropdown(HotelController controller) {
    return Consumer<HotelController>(
      builder: (context, controller, child) {
        return DropdownButtonFormField<Estado>(
          value: _estadoSeleccionado,
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
          items: (() {
            try {
              final estados = controller.estados;
              return estados.isNotEmpty ? estados : <Estado>[];
            } catch (e) {
              return <Estado>[];
            }
          }()).map((estado) {
            return DropdownMenuItem<Estado>(
              value: estado,
              child: Text(estado.nombre),
            );
          }).toList(),
          validator: (value) {
            if (value == null) {
              return 'El estado es requerido';
            }
            return null;
          },
          onChanged: _paisSeleccionado == null
              ? null
              : (Estado? estado) {
                  setState(() {
                    _estadoSeleccionado = estado;
                  });
                },
        );
      },
    );
  }

  /// Widget para construir dropdown de estrellas
  Widget _buildEstrellasDropdown() {
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
      validator: (value) {
        if (value == null) {
          return 'El número de estrellas es requerido';
        }
        return null;
      },
      onChanged: (int? value) {
        setState(() {
          _numeroEstrellas = value;
        });
      },
    );
  }

  /// Método para manejar el envío del formulario
  Future<void> _handleSubmit(BuildContext context, HotelController controller) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_paisSeleccionado == null || _estadoSeleccionado == null || _numeroEstrellas == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, completa todos los campos requeridos'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Construir Map con datos del hotel
    final nombre = _nombreController.text;
    final direccion = _direccionController.text;
    
    final hotelData = <String, dynamic>{
      'nombre': nombre.trim(),
      'direccion': direccion.trim(),
      'id_pais': _paisSeleccionado!.idPais,
      'id_estado': _estadoSeleccionado!.idEstado,
      'numero_estrellas': _numeroEstrellas!,
    };

    // Agregar campos opcionales solo si tienen valor
    final codigoPostalText = _codigoPostalController.text;
    if (codigoPostalText.isNotEmpty) {
      final codigoPostal = codigoPostalText.trim();
      if (codigoPostal.isNotEmpty) {
        hotelData['codigo_postal'] = codigoPostal;
      }
    }

    final telefonoText = _telefonoController.text;
    if (telefonoText.isNotEmpty) {
      final telefono = telefonoText.trim();
      if (telefono.isNotEmpty) {
        hotelData['telefono'] = telefono;
      }
    }

    final emailText = _emailController.text;
    if (emailText.isNotEmpty) {
      final email = emailText.trim();
      if (email.isNotEmpty) {
        hotelData['email_contacto'] = email;
      }
    }

    // Crear hotel
    final success = await controller.createHotel(hotelData);

    if (success && context.mounted) {
      // Mostrar mensaje de éxito
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Hotel registrado con éxito'),
          backgroundColor: Colors.green,
        ),
      );
      // Navegar de regreso
      Navigator.pop(context);
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
}


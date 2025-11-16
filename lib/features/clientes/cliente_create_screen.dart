import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../widgets/app_header.dart';
import '../../widgets/app_sidebar.dart';
import 'controllers/cliente_controller.dart';
import '../hoteles/models/pais_model.dart';
import '../hoteles/models/estado_model.dart';
import '../login/login_screen.dart';

/// Pantalla de formulario para crear un nuevo cliente
/// Incluye formulario dinámico según tipo de persona (Física/Moral)
class ClienteCreateScreen extends StatefulWidget {
  const ClienteCreateScreen({super.key});

  @override
  State<ClienteCreateScreen> createState() => _ClienteCreateScreenState();
}

class _ClienteCreateScreenState extends State<ClienteCreateScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Controladores de texto
  final _nombreRazonSocialController = TextEditingController();
  final _apellidoPaternoController = TextEditingController();
  final _apellidoMaternoController = TextEditingController();
  final _rfcController = TextEditingController();
  final _curpController = TextEditingController();
  final _correoController = TextEditingController();
  final _telefonoController = TextEditingController();
  final _direccionController = TextEditingController();
  final _documentoController = TextEditingController();
  final _representanteController = TextEditingController();
  
  // Valores seleccionados
  int _tipoPersona = 1; // 1 = Física, 2 = Moral (default Física)
  Pais? _paisSeleccionado;
  Estado? _estadoSeleccionado;
  int _idEstatus = 1; // 1 = Activo (default)

  @override
  void initState() {
    super.initState();
    // Cargar catálogos al iniciar la pantalla
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final controller = Provider.of<ClienteController>(context, listen: false);
      controller.loadCatalogs();
    });
  }

  @override
  void dispose() {
    _nombreRazonSocialController.dispose();
    _apellidoPaternoController.dispose();
    _apellidoMaternoController.dispose();
    _rfcController.dispose();
    _curpController.dispose();
    _correoController.dispose();
    _telefonoController.dispose();
    _direccionController.dispose();
    _documentoController.dispose();
    _representanteController.dispose();
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
              child: Consumer<ClienteController>(
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
  Widget _buildForm(BuildContext context, ClienteController controller) {
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
                  'Crear cliente',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1a1a1a),
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 8),
                // Subtítulo
                const Text(
                  'Registro de nuevo cliente',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF6b7280),
                  ),
                ),
                const SizedBox(height: 32),
                // Dropdown: Tipo de persona
                _buildTipoPersonaDropdown(),
                const SizedBox(height: 20),
                // Campo: Nombre/Razón social
                _buildTextField(
                  controller: _nombreRazonSocialController,
                  label: _tipoPersona == 1 ? 'Nombre(s)' : 'Razón social',
                  hint: _tipoPersona == 1 ? 'Ingresa el nombre' : 'Ingresa la razón social',
                  icon: Icons.person,
                  validator: (value) {
                    if (value == null || value.isEmpty || value.trim().isEmpty) {
                      return _tipoPersona == 1 ? 'El nombre es requerido' : 'La razón social es requerida';
                    }
                    if (value.trim().length < 3) {
                      return 'Debe tener al menos 3 caracteres';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                // Campos específicos de Persona Física
                if (_tipoPersona == 1) ...[
                  _buildTextField(
                    controller: _apellidoPaternoController,
                    label: 'Apellido paterno',
                    hint: 'Ingresa el apellido paterno',
                    icon: Icons.person_outline,
                    validator: (value) {
                      if (value == null || value.isEmpty || value.trim().isEmpty) {
                        return 'El apellido paterno es requerido';
                      }
                      if (value.trim().length < 3) {
                        return 'Debe tener al menos 3 caracteres';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  _buildTextField(
                    controller: _apellidoMaternoController,
                    label: 'Apellido materno',
                    hint: 'Ingresa el apellido materno',
                    icon: Icons.person_outline,
                  ),
                  const SizedBox(height: 20),
                  _buildTextField(
                    controller: _curpController,
                    label: 'CURP',
                    hint: 'Ingresa el CURP (18 caracteres)',
                    icon: Icons.credit_card,
                    validator: (value) {
                      if (value != null && value.isNotEmpty) {
                        if (value.length != 18) {
                          return 'El CURP debe tener exactamente 18 caracteres';
                        }
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                ],
                // Campo específico de Persona Moral
                if (_tipoPersona == 2) ...[
                  _buildTextField(
                    controller: _representanteController,
                    label: 'Representante',
                    hint: 'Ingresa el nombre del representante',
                    icon: Icons.account_circle,
                    validator: (value) {
                      if (value == null || value.isEmpty || value.trim().isEmpty) {
                        return 'El representante es requerido';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                ],
                // Campo: RFC
                _buildTextField(
                  controller: _rfcController,
                  label: 'RFC',
                  hint: 'Ingresa el RFC (12-13 caracteres)',
                  icon: Icons.assignment_ind,
                  validator: (value) {
                    if (value == null || value.isEmpty || value.trim().isEmpty) {
                      return 'El RFC es requerido';
                    }
                    final rfc = value.trim();
                    if (rfc.length < 12 || rfc.length > 13) {
                      return 'El RFC debe tener 12 o 13 caracteres';
                    }
                    return null;
                  },
                  errorText: controller.rfcDuplicadoError ? 'El RFC ya está registrado' : null,
                ),
                const SizedBox(height: 20),
                // Campo: Correo electrónico
                _buildTextField(
                  controller: _correoController,
                  label: 'Correo electrónico',
                  hint: 'ejemplo@correo.com',
                  icon: Icons.email,
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value != null && value.isNotEmpty) {
                      final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                      if (!emailRegex.hasMatch(value)) {
                        return 'Correo electrónico no válido';
                      }
                    }
                    return null;
                  },
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
                // Campo: Documento de identificación
                _buildTextField(
                  controller: _documentoController,
                  label: 'Documento de identificación',
                  hint: 'Ingresa el número de documento',
                  icon: Icons.badge,
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 20),
                // Campo: Dirección
                _buildTextField(
                  controller: _direccionController,
                  label: 'Dirección',
                  hint: 'Ingresa la dirección completa',
                  icon: Icons.location_on,
                  maxLines: 2,
                ),
                const SizedBox(height: 20),
                // Dropdown: País
                _buildPaisDropdown(controller),
                const SizedBox(height: 20),
                // Dropdown: Estado
                _buildEstadoDropdown(controller),
                const SizedBox(height: 20),
                // Dropdown: Estatus
                _buildEstatusDropdown(),
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
                    // Botón Guardar
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                        onPressed: controller.isCreating ? null : () => _handleSubmit(context, controller),
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
                          'Guardar',
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
                    'Guardando...',
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
    String? errorText,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        errorText: errorText,
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
          borderSide: BorderSide(
            color: errorText != null ? Colors.red : const Color(0xFFe5e7eb),
            width: errorText != null ? 2 : 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: Color(0xFF667eea),
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: Colors.red,
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

  /// Widget para dropdown de tipo de persona
  Widget _buildTipoPersonaDropdown() {
    return DropdownButtonFormField<int>(
      value: _tipoPersona,
      decoration: InputDecoration(
        labelText: 'Tipo de persona',
        prefixIcon: const Icon(
          Icons.category,
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
              Icon(Icons.person, size: 18, color: Color(0xFF667eea)),
              SizedBox(width: 8),
              Text('Física'),
            ],
          ),
        ),
        DropdownMenuItem<int>(
          value: 2,
          child: Row(
            children: [
              Icon(Icons.business, size: 18, color: Color(0xFF667eea)),
              SizedBox(width: 8),
              Text('Moral'),
            ],
          ),
        ),
      ],
      onChanged: (int? value) {
        if (value != null) {
          setState(() {
            _tipoPersona = value;
          });
        }
      },
    );
  }

  /// Widget para dropdown de países
  Widget _buildPaisDropdown(ClienteController controller) {
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
      items: controller.paises.map((pais) {
        return DropdownMenuItem<Pais>(
          value: pais,
          child: Text(pais.nombre),
        );
      }).toList(),
      onChanged: (Pais? pais) {
        setState(() {
          _paisSeleccionado = pais;
          _estadoSeleccionado = null;
          if (pais != null) {
            controller.loadEstadosByPais(pais.idPais);
          }
        });
      },
    );
  }

  /// Widget para dropdown de estados
  Widget _buildEstadoDropdown(ClienteController controller) {
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
      items: controller.estados.map((estado) {
        return DropdownMenuItem<Estado>(
          value: estado,
          child: Text(estado.nombre),
        );
      }).toList(),
      onChanged: (Estado? estado) {
        setState(() {
          _estadoSeleccionado = estado;
        });
      },
    );
  }

  /// Widget para dropdown de estatus
  Widget _buildEstatusDropdown() {
    return DropdownButtonFormField<int>(
      value: _idEstatus,
      decoration: InputDecoration(
        labelText: 'Estatus',
        prefixIcon: const Icon(
          Icons.check_circle,
          color: Color(0xFF6b7280),
          size: 20,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
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
  Future<void> _handleSubmit(BuildContext context, ClienteController controller) async {
    // Validar formulario
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Construir Map con los datos del cliente
    final clienteData = <String, dynamic>{
      'nombre_razon_social': _nombreRazonSocialController.text.trim(),
      'rfc': _rfcController.text.trim().toUpperCase(),
      'id_estatus': _idEstatus,
      'tipo_persona': _tipoPersona,
    };

    // Agregar campos específicos de Persona Física
    if (_tipoPersona == 1) {
      clienteData['apellido_paterno'] = _apellidoPaternoController.text.trim();
      
      final apellidoMaterno = _apellidoMaternoController.text.trim();
      if (apellidoMaterno.isNotEmpty) {
        clienteData['apellido_materno'] = apellidoMaterno;
      }
      
      final curp = _curpController.text.trim();
      if (curp.isNotEmpty) {
        clienteData['curp'] = curp.toUpperCase();
      }
    }

    // Agregar campo específico de Persona Moral
    if (_tipoPersona == 2) {
      clienteData['representante'] = _representanteController.text.trim();
    }

    // Agregar campos opcionales
    final correo = _correoController.text.trim();
    if (correo.isNotEmpty) {
      clienteData['correo_electronico'] = correo;
    }

    final telefono = _telefonoController.text.trim();
    if (telefono.isNotEmpty) {
      clienteData['telefono'] = telefono;
    }

    final direccion = _direccionController.text.trim();
    if (direccion.isNotEmpty) {
      clienteData['direccion'] = direccion;
    }

    final documento = _documentoController.text.trim();
    if (documento.isNotEmpty) {
      clienteData['documento_identificacion'] = documento;
    }

    if (_paisSeleccionado != null) {
      clienteData['pais_id'] = _paisSeleccionado!.idPais;
    }

    if (_estadoSeleccionado != null) {
      clienteData['estado_id'] = _estadoSeleccionado!.idEstado;
    }

    // Crear cliente
    final success = await controller.createCliente(clienteData);

    if (success && context.mounted) {
      // Mostrar mensaje de éxito
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cliente creado'),
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


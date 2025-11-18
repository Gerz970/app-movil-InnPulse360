import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:dio/dio.dart';
import '../../core/auth/controllers/auth_controller.dart';
import '../../features/clientes/services/cliente_service.dart';
import '../../features/clientes/models/cliente_model.dart';
import '../../features/hoteles/models/pais_model.dart';
import '../../features/hoteles/models/estado_model.dart';
import 'register_success_screen.dart';

/// Pantalla de formulario para crear cliente durante el registro
/// Después de crear el cliente, crea automáticamente el usuario
class ClienteRegisterScreen extends StatefulWidget {
  /// Login del usuario a crear
  final String login;
  
  /// Correo electrónico del cliente (prellenado)
  final String correo;

  const ClienteRegisterScreen({
    super.key,
    required this.login,
    required this.correo,
  });

  @override
  State<ClienteRegisterScreen> createState() => _ClienteRegisterScreenState();
}

class _ClienteRegisterScreenState extends State<ClienteRegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final ClienteService _clienteService = ClienteService();
  
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
  
  // Estados de carga
  bool _isLoadingCatalogs = false;
  bool _isCreating = false;
  String? _errorMessage;
  
  // Listas de catálogos
  List<Pais> _paises = [];
  List<Estado> _estados = [];

  @override
  void initState() {
    super.initState();
    // Prellenar correo
    _correoController.text = widget.correo;
    // Cargar catálogos al iniciar
    _loadCatalogs();
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

  /// Cargar catálogos de países y estados
  Future<void> _loadCatalogs() async {
    setState(() {
      _isLoadingCatalogs = true;
    });

    try {
      // Cargar países
      final paisesResponse = await _clienteService.fetchPaisesPublicos();
      if (paisesResponse.data != null && paisesResponse.data is List) {
        _paises = (paisesResponse.data as List)
            .map((json) => Pais.fromJson(json as Map<String, dynamic>))
            .toList();
      }

      setState(() {
        _isLoadingCatalogs = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingCatalogs = false;
        _errorMessage = 'Error al cargar catálogos: ${e.toString()}';
      });
    }
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

  /// Cargar estados por país (solo si el país es México)
  Future<void> _loadEstadosByPais(int idPais, Pais? pais) async {
    // Solo cargar estados si el país es México
    if (!_esMexico(pais)) {
      setState(() {
        _estados = [];
        _estadoSeleccionado = null;
      });
      return;
    }

    // Cuando es México, usar ID = 2 (hardcodeado según requerimiento)
    const int idMexico = 2;
    
    setState(() {
      _estados = [];
      _estadoSeleccionado = null;
    });

    try {
      final estadosResponse = await _clienteService.fetchEstadosPublicos(idPais: idMexico);
      
      if (estadosResponse.data != null && estadosResponse.data is List) {
        _estados = (estadosResponse.data as List)
            .map((json) => Estado.fromJson(json as Map<String, dynamic>))
            .toList();
      }
      setState(() {});
    } catch (e) {
      // Error silencioso - los estados simplemente no se cargarán
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Color(0xFF1a1a1a),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Crear Cliente',
          style: TextStyle(
            color: Color(0xFF1a1a1a),
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SafeArea(
        child: _isLoadingCatalogs
            ? const Center(
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
              )
            : _buildForm(),
      ),
    );
  }

  /// Widget para construir el formulario
  Widget _buildForm() {
    return Stack(
      children: [
        SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Datos del Cliente',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1a1a1a),
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Completa la información para crear tu cuenta',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF6b7280),
                  ),
                ),
                const SizedBox(height: 32),
                _buildTipoPersonaDropdown(),
                const SizedBox(height: 20),
                _buildTextField(
                  controller: _nombreRazonSocialController,
                  label: _tipoPersona == 1 ? 'Nombre(s)' : 'Razón social',
                  hint: _tipoPersona == 1 ? 'Ingresa el nombre' : 'Ingresa la razón social',
                  icon: Icons.person,
                  validator: (value) {
                    if (value == null || value.isEmpty || value.trim().isEmpty) {
                      return _tipoPersona == 1 ? 'El nombre es requerido' : 'La razón social es requerida';
                    }
                    final trimmed = value.trim();
                    if (trimmed.length < 1) {
                      return 'Debe tener al menos 1 carácter';
                    }
                    if (trimmed.length > 250) {
                      return 'No puede tener más de 250 caracteres';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
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
                      final trimmed = value.trim();
                      if (trimmed.length > 250) {
                        return 'No puede tener más de 250 caracteres';
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
                    validator: (value) {
                      if (value != null && value.isNotEmpty) {
                        final trimmed = value.trim();
                        if (trimmed.length > 250) {
                          return 'No puede tener más de 250 caracteres';
                        }
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  _buildTextField(
                    controller: _curpController,
                    label: 'CURP',
                    hint: 'Ingresa el CURP (18 caracteres)',
                    icon: Icons.credit_card,
                    maxLength: 18,
                    validator: (value) {
                      if (value != null && value.isNotEmpty) {
                        final curp = value.trim().toUpperCase();
                        if (curp.length != 18) {
                          return 'El CURP debe tener exactamente 18 caracteres';
                        }
                        // Validar formato CURP: ^[A-Z]{4}\d{6}[HM][A-Z]{5}[A-Z0-9]\d$
                        final curpRegex = RegExp(r'^[A-Z]{4}\d{6}[HM][A-Z]{5}[A-Z0-9]\d$');
                        if (!curpRegex.hasMatch(curp)) {
                          return 'Formato de CURP inválido. Ejemplo: ABCD123456HMABCD1';
                        }
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                ],
                if (_tipoPersona == 2) ...[
                  _buildTextField(
                    controller: _representanteController,
                    label: 'Representante',
                    hint: 'Ingresa el nombre del representante',
                    icon: Icons.account_circle,
                    maxLength: 100,
                    validator: (value) {
                      if (value == null || value.isEmpty || value.trim().isEmpty) {
                        return 'El representante es requerido';
                      }
                      final trimmed = value.trim();
                      if (trimmed.length < 1) {
                        return 'Debe tener al menos 1 carácter';
                      }
                      if (trimmed.length > 100) {
                        return 'No puede tener más de 100 caracteres';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                ],
                _buildTextField(
                  controller: _rfcController,
                  label: 'RFC',
                  hint: 'Ingresa el RFC (12-13 caracteres)',
                  icon: Icons.assignment_ind,
                  maxLength: 13,
                  validator: (value) {
                    if (value != null && value.isNotEmpty) {
                      final rfc = value.trim().toUpperCase();
                      if (rfc.length < 12 || rfc.length > 13) {
                        return 'El RFC debe tener 12 o 13 caracteres';
                      }
                      // Validar formato RFC: ^[A-ZÑ&]{3,4}\d{6}[A-Z0-9]{3}$
                      final rfcRegex = RegExp(r'^[A-ZÑ&]{3,4}\d{6}[A-Z0-9]{3}$');
                      if (!rfcRegex.hasMatch(rfc)) {
                        return 'Formato de RFC inválido. Ejemplo: ABC123456XYZ';
                      }
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                _buildTextField(
                  controller: _correoController,
                  label: 'Correo electrónico',
                  hint: 'ejemplo@correo.com',
                  icon: Icons.email,
                  keyboardType: TextInputType.emailAddress,
                  enabled: false, // Prellenado y deshabilitado
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
                _buildTextField(
                  controller: _telefonoController,
                  label: 'Teléfono',
                  hint: 'Ingresa el teléfono (10 dígitos)',
                  icon: Icons.phone,
                  keyboardType: TextInputType.number,
                  maxLength: 10,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  validator: (value) {
                    if (value != null && value.isNotEmpty) {
                      final telefono = value.trim();
                      if (telefono.length != 10) {
                        return 'El teléfono debe tener exactamente 10 dígitos';
                      }
                      // Validar que solo contenga dígitos
                      if (!RegExp(r'^\d+$').hasMatch(telefono)) {
                        return 'El teléfono debe contener solo dígitos';
                      }
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                _buildTextField(
                  controller: _documentoController,
                  label: 'Documento de identificación',
                  hint: 'Ingresa el número de documento',
                  icon: Icons.badge,
                  keyboardType: TextInputType.number,
                  maxLength: 50,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  validator: (value) {
                    if (value == null || value.isEmpty || value.trim().isEmpty) {
                      return 'El documento de identificación es requerido';
                    }
                    if (value.trim().length > 50) {
                      return 'El documento no puede exceder 50 caracteres';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                _buildTextField(
                  controller: _direccionController,
                  label: 'Dirección',
                  hint: 'Ingresa la dirección completa',
                  icon: Icons.location_on,
                  maxLines: 2,
                  validator: (value) {
                    if (value != null && value.isNotEmpty) {
                      final trimmed = value.trim();
                      if (trimmed.length > 100) {
                        return 'La dirección no puede tener más de 100 caracteres';
                      }
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                _buildPaisDropdown(),
                const SizedBox(height: 20),
                _buildEstadoDropdown(),
                const SizedBox(height: 32),
                if (_errorMessage != null)
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
                            _errorMessage!,
                            style: TextStyle(
                              color: Colors.red.shade700,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                if (_errorMessage != null) const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _isCreating ? null : () => Navigator.pop(context),
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
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                        onPressed: _isCreating ? null : _handleSubmit,
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
                          'Registrarse',
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
              ],
            ),
          ),
        ),
        if (_isCreating)
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
                    'Creando cliente y usuario...',
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
    bool enabled = true,
    int? maxLength,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      maxLength: maxLength,
      inputFormatters: inputFormatters,
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
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: Color(0xFF667eea),
            width: 2,
          ),
        ),
        filled: true,
        fillColor: enabled ? Colors.white : Colors.grey.shade100,
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
        // Ocultar contador de caracteres si maxLength está definido
        counterText: maxLength != null ? '' : null,
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
  Widget _buildPaisDropdown() {
    return DropdownButtonFormField<Pais>(
      value: _paisSeleccionado,
      decoration: InputDecoration(
        labelText: 'País *',
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
      items: _paises.map((pais) {
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
            // Solo cargar estados si el país es México
            _loadEstadosByPais(pais.idPais, pais);
          } else {
            // Limpiar estados si no hay país seleccionado
            _estados = [];
            _estadoSeleccionado = null;
          }
        });
      },
      validator: (value) {
        if (value == null) {
          return 'El país es requerido';
        }
        return null;
      },
    );
  }

  /// Widget para dropdown de estados
  Widget _buildEstadoDropdown() {
    // Solo mostrar/habilitar el dropdown si el país seleccionado es México
    final esMexico = _esMexico(_paisSeleccionado);
    
    return DropdownButtonFormField<Estado>(
      value: _estadoSeleccionado,
      decoration: InputDecoration(
        labelText: 'Estado',
        hintText: esMexico ? 'Selecciona un estado' : 'Solo disponible para México',
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
        fillColor: esMexico ? Colors.white : Colors.grey.shade100,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        labelStyle: TextStyle(
          color: esMexico ? const Color(0xFF6b7280) : Colors.grey.shade400,
          fontSize: 14,
        ),
        hintStyle: TextStyle(
          color: Colors.grey.shade400,
          fontSize: 14,
        ),
      ),
      items: _estados.map((estado) {
        return DropdownMenuItem<Estado>(
          value: estado,
          child: Text(estado.nombre),
        );
      }).toList(),
      onChanged: esMexico && _estados.isNotEmpty
          ? (Estado? estado) {
              setState(() {
                _estadoSeleccionado = estado;
              });
            }
          : null,
      validator: (value) {
        // Estado es opcional, no requiere validación
        return null;
      },
    );
  }

  /// Método para manejar el envío del formulario
  Future<void> _handleSubmit() async {
    // Validar formulario
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Validar país (estado es opcional)
    if (_paisSeleccionado == null) {
      setState(() {
        _errorMessage = 'Por favor selecciona un país';
      });
      return;
    }

    setState(() {
      _isCreating = true;
      _errorMessage = null;
    });

    try {
      // Construir Map con los datos del cliente
      final clienteData = <String, dynamic>{
        'nombre_razon_social': _nombreRazonSocialController.text.trim(),
        'rfc': _rfcController.text.trim().toUpperCase(),
        'id_estatus': _idEstatus,
        'tipo_persona': _tipoPersona,
        'documento_identificacion': _documentoController.text.trim(),
        'correo_electronico': _correoController.text.trim(),
        'pais_id': _paisSeleccionado!.idPais,
        'representante': _tipoPersona == 2
            ? _representanteController.text.trim()
            : _nombreRazonSocialController.text.trim(), // Para persona física usar nombre
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

      // Agregar campos opcionales
      final telefono = _telefonoController.text.trim();
      if (telefono.isNotEmpty) {
        clienteData['telefono'] = telefono;
      }

      final direccion = _direccionController.text.trim();
      if (direccion.isNotEmpty) {
        clienteData['direccion'] = direccion;
      }

      // Agregar estado_id solo si está seleccionado (opcional)
      if (_estadoSeleccionado != null) {
        clienteData['estado_id'] = _estadoSeleccionado!.idEstado;
      }

      // Crear cliente usando método público (sin autenticación)
      final clienteResponse = await _clienteService.createClientePublico(clienteData);
      
      if (clienteResponse.data == null) {
        throw Exception('No se recibió respuesta del servidor');
      }

      // Obtener el ID del cliente creado
      final clienteCreado = Cliente.fromJson(clienteResponse.data as Map<String, dynamic>);
      final clienteId = clienteCreado.idCliente;

      // Ahora crear el usuario usando AuthController
      final authController = Provider.of<AuthController>(context, listen: false);
      final registroSuccess = await authController.registrarCliente(
        widget.login,
        widget.correo,
        clienteId,
      );

      if (registroSuccess && context.mounted) {
        // Navegar a pantalla de éxito
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (context) => RegisterSuccessScreen(
              login: widget.login,
              correo: widget.correo,
              emailEnviado: authController.registroResponse?.emailEnviado ?? false,
            ),
          ),
          (route) => false,
        );
      } else if (context.mounted) {
        setState(() {
          _isCreating = false;
          _errorMessage = authController.registroErrorMessage ?? 'Error al crear usuario';
        });
      }
    } catch (e) {
      setState(() {
        _isCreating = false;
        if (e is DioException) {
          if (e.response != null) {
            final errorData = e.response?.data;
            if (errorData is Map && errorData['detail'] != null) {
              _errorMessage = errorData['detail'] as String;
            } else {
              _errorMessage = 'Error ${e.response?.statusCode}: ${e.response?.data}';
            }
          } else {
            _errorMessage = 'Error de conexión: ${e.message ?? e.toString()}';
          }
        } else {
          _errorMessage = 'Error: ${e.toString()}';
        }
      });
    }
  }
}


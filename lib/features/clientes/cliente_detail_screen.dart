import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../widgets/app_header.dart';
import '../../widgets/app_sidebar.dart';
import 'controllers/cliente_controller.dart';
import '../hoteles/models/pais_model.dart';
import '../hoteles/models/estado_model.dart';
import '../login/login_screen.dart';

/// Pantalla de detalle y edición de cliente
/// Muestra formulario en modo edición con campos precargados
/// Solo permite editar: nombre_razon_social, telefono, direccion, id_estatus
class ClienteDetailScreen extends StatefulWidget {
  final int clienteId;

  const ClienteDetailScreen({
    super.key,
    required this.clienteId,
  });

  @override
  State<ClienteDetailScreen> createState() => _ClienteDetailScreenState();
}

class _ClienteDetailScreenState extends State<ClienteDetailScreen> {
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
  Pais? _paisSeleccionado;
  Estado? _estadoSeleccionado;
  int _idEstatus = 1;
  int _tipoPersona = 1;
  
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    // Cargar detalle del cliente y país/estado específicos al iniciar
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final controller = Provider.of<ClienteController>(context, listen: false);
      // Cargar detalle del cliente primero
      controller.loadClienteDetail(widget.clienteId).then((_) {
        // Una vez cargado el detalle, cargar país y estado específicos si existen
        final cliente = controller.clienteDetail;
        if (cliente != null) {
          if (cliente.paisId != null) {
            controller.loadPaisById(cliente.paisId!);
          }
          if (cliente.estadoId != null) {
            controller.loadEstadoById(cliente.estadoId!);
          }
        }
      });
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

  /// Método para precargar valores del cliente en los controladores
  void _preloadClienteData(ClienteController controller) {
    if (_isInitialized || controller.clienteDetail == null) return;
    
    final cliente = controller.clienteDetail!;
    
    print('🔍 Precargando datos del cliente: ${cliente.nombreRazonSocial}');
    
    // Precargar valores en controladores
    _nombreRazonSocialController.text = cliente.nombreRazonSocial;
    _apellidoPaternoController.text = cliente.apellidoPaterno ?? '';
    _apellidoMaternoController.text = cliente.apellidoMaterno ?? '';
    _rfcController.text = cliente.rfc;
    _curpController.text = cliente.curp ?? '';
    _correoController.text = cliente.correoElectronico ?? '';
    _telefonoController.text = cliente.telefono ?? '';
    _direccionController.text = cliente.direccion ?? '';
    _documentoController.text = cliente.documentoIdentificacion ?? '';
    _representanteController.text = cliente.representante ?? '';
    _idEstatus = cliente.idEstatus;
    _tipoPersona = cliente.tipoPersona;
    
    // Precargar país usando paisDetail (cargado por endpoint específico)
    if (controller.paisDetail != null) {
      _paisSeleccionado = controller.paisDetail;
      print('✅ País cargado: ${controller.paisDetail!.nombre}');
    }
    
    // Precargar estado usando estadoDetail (cargado por endpoint específico)
    if (controller.estadoDetail != null) {
      _estadoSeleccionado = controller.estadoDetail;
      print('✅ Estado cargado: ${controller.estadoDetail!.nombre}');
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
              child: Consumer<ClienteController>(
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
                            'Cargando detalle del cliente...',
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

                  // Si tenemos el detalle, precargar datos
                  if (controller.clienteDetail != null && !_isInitialized) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (mounted) {
                        _preloadClienteData(controller);
                      }
                    });
                  }
                  
                  // Si el país o estado se cargan después, actualizar los dropdowns
                  if (_isInitialized && controller.clienteDetail != null) {
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
                  if (controller.clienteDetail != null && _isInitialized) {
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
  Widget _buildErrorState(BuildContext context, ClienteController controller) {
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
                    controller.loadClienteDetail(widget.clienteId);
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
                // Título y menú
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Detalle de cliente',
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
                                'Eliminar cliente',
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
                // Badge de tipo de persona (informativo)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: _tipoPersona == 1
                        ? Colors.blue.shade50
                        : Colors.purple.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: _tipoPersona == 1
                          ? Colors.blue.shade200
                          : Colors.purple.shade200,
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _tipoPersona == 1 ? Icons.person : Icons.business,
                        size: 16,
                        color: _tipoPersona == 1
                            ? Colors.blue.shade700
                            : Colors.purple.shade700,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        _tipoPersona == 1 ? 'Persona Física' : 'Persona Moral',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: _tipoPersona == 1
                              ? Colors.blue.shade700
                              : Colors.purple.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                // Campo: Nombre/Razón social (EDITABLE)
                _buildTextField(
                  controller: _nombreRazonSocialController,
                  label: _tipoPersona == 1 ? 'Nombre(s)' : 'Razón social',
                  hint: 'Ingresa el nombre',
                  icon: Icons.person,
                  enabled: true,
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
                // Campos específicos de Persona Física (READ-ONLY)
                if (_tipoPersona == 1) ...[
                  _buildTextField(
                    controller: _apellidoPaternoController,
                    label: 'Apellido paterno',
                    hint: 'Apellido paterno',
                    icon: Icons.person_outline,
                    enabled: false,
                  ),
                  const SizedBox(height: 20),
                  _buildTextField(
                    controller: _apellidoMaternoController,
                    label: 'Apellido materno',
                    hint: 'Apellido materno',
                    icon: Icons.person_outline,
                    enabled: false,
                  ),
                  const SizedBox(height: 20),
                  _buildTextField(
                    controller: _curpController,
                    label: 'CURP',
                    hint: 'CURP',
                    icon: Icons.credit_card,
                    enabled: false,
                  ),
                  const SizedBox(height: 20),
                ],
                // Campo específico de Persona Moral (READ-ONLY)
                if (_tipoPersona == 2) ...[
                  _buildTextField(
                    controller: _representanteController,
                    label: 'Representante',
                    hint: 'Representante',
                    icon: Icons.account_circle,
                    enabled: false,
                  ),
                  const SizedBox(height: 20),
                ],
                // Campo: RFC (READ-ONLY)
                _buildTextField(
                  controller: _rfcController,
                  label: 'RFC',
                  hint: 'RFC',
                  icon: Icons.assignment_ind,
                  enabled: false,
                ),
                const SizedBox(height: 20),
                // Campo: Correo electrónico (READ-ONLY)
                _buildTextField(
                  controller: _correoController,
                  label: 'Correo electrónico',
                  hint: 'ejemplo@correo.com',
                  icon: Icons.email,
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
                // Campo: Documento de identificación (READ-ONLY)
                _buildTextField(
                  controller: _documentoController,
                  label: 'Documento de identificación',
                  hint: 'Documento',
                  icon: Icons.badge,
                  enabled: false,
                ),
                const SizedBox(height: 20),
                // Campo: Dirección (EDITABLE)
                _buildTextField(
                  controller: _direccionController,
                  label: 'Dirección',
                  hint: 'Ingresa la dirección completa',
                  icon: Icons.location_on,
                  maxLines: 2,
                  enabled: true,
                ),
                const SizedBox(height: 20),
                // Dropdown: País (READ-ONLY)
                _buildPaisDropdown(controller),
                const SizedBox(height: 20),
                // Dropdown: Estado (READ-ONLY)
                _buildEstadoDropdown(controller),
                const SizedBox(height: 20),
                // Dropdown: Estatus (EDITABLE)
                _buildEstatusDropdown(enabled: true),
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
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
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

  /// Widget para dropdown de países (READ-ONLY en detalle)
  Widget _buildPaisDropdown(ClienteController controller) {
    final paisValue = controller.paisDetail ?? _paisSeleccionado;
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
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
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
      onChanged: null, // Deshabilitado
    );
  }

  /// Widget para dropdown de estados (READ-ONLY en detalle)
  Widget _buildEstadoDropdown(ClienteController controller) {
    final estadoValue = controller.estadoDetail ?? _estadoSeleccionado;
    final estadosList = estadoValue != null ? [estadoValue] : <Estado>[];
    
    return DropdownButtonFormField<Estado>(
      value: estadoValue,
      hint: const Text('Sin estado'),
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
        filled: true,
        fillColor: Colors.grey.shade50,
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
      onChanged: null, // Deshabilitado
    );
  }

  /// Widget para dropdown de estatus
  Widget _buildEstatusDropdown({required bool enabled}) {
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
      onChanged: enabled
          ? (int? value) {
              if (value != null) {
                setState(() {
                  _idEstatus = value;
                });
              }
            }
          : null,
    );
  }

  /// Método para manejar el envío del formulario
  Future<void> _handleSubmit(BuildContext context, ClienteController controller) async {
    // Validar formulario
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Construir Map solo con campos editables
    final clienteData = <String, dynamic>{
      'nombre_razon_social': _nombreRazonSocialController.text.trim(),
      'id_estatus': _idEstatus,
    };

    // Agregar teléfono si tiene valor
    final telefono = _telefonoController.text.trim();
    if (telefono.isNotEmpty) {
      clienteData['telefono'] = telefono;
    }

    // Agregar dirección si tiene valor
    final direccion = _direccionController.text.trim();
    if (direccion.isNotEmpty) {
      clienteData['direccion'] = direccion;
    }

    // Actualizar cliente
    final success = await controller.updateCliente(widget.clienteId, clienteData);

    if (success && context.mounted) {
      // Refrescar la lista de clientes antes de regresar
      await controller.fetchClientes();
      
      // Mostrar mensaje de éxito
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cambios guardados'),
          backgroundColor: Colors.green,
        ),
      );
      // Navegar de regreso
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

  /// Método para mostrar el modal de confirmación de eliminación
  void _showDeleteConfirmationDialog(BuildContext context, ClienteController controller) {
    final TextEditingController confirmController = TextEditingController();
    final String confirmText = 'Eliminar Cliente';
    bool isValid = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text(
                'Eliminar cliente',
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
                    'Esta acción es permanente. Escribe \'Eliminar Cliente\' para confirmar.',
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
                      hintText: 'Escribe: Eliminar Cliente',
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

  /// Método para manejar la eliminación del cliente
  Future<void> _handleDelete(BuildContext context, ClienteController controller) async {
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
      final success = await controller.deleteCliente(widget.clienteId);

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
              content: Text('Cliente eliminado con éxito'),
              backgroundColor: Colors.green,
            ),
          );
          // Refrescar lista
          await controller.fetchClientes();
          // Navegar atrás
          Navigator.pop(context);
        }
      } else {
        // Mostrar mensaje de error
        if (context.mounted) {
          final errorMessage = controller.deleteErrorMessage ?? 'Error al eliminar el cliente';
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
}


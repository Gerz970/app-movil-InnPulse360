import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../widgets/app_header.dart';
import '../../widgets/app_sidebar.dart';
import 'controllers/cliente_controller.dart';
import '../hoteles/models/pais_model.dart';
import '../hoteles/models/estado_model.dart';
import '../login/login_screen.dart';

/// Pantalla de detalle y edición de cliente
/// Muestra formulario en modo edición con campos precargados
/// Permite editar todos los campos excepto correo electrónico
/// El estatus siempre se mantiene como activo (id_estatus = 1)
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
  int _tipoPersona = 1;
  
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    // Cargar detalle del cliente y catálogos completos al iniciar
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final controller = Provider.of<ClienteController>(context, listen: false);
      // Cargar catálogos completos para permitir edición
      controller.loadCatalogs();
      // Cargar detalle del cliente primero
      controller.loadClienteDetail(widget.clienteId).then((_) {
        // Una vez cargado el detalle, precargar país y estado si existen
        final cliente = controller.clienteDetail;
        if (cliente != null) {
          if (cliente.paisId != null) {
            // Cargar país específico para precargar valor
            controller.loadPaisById(cliente.paisId!).then((_) {
              // Si el país es México, cargar estados
              if (controller.paisDetail != null && _esMexico(controller.paisDetail)) {
                controller.loadEstadosByPais(cliente.paisId!);
              }
            });
          }
          if (cliente.estadoId != null) {
            controller.loadEstadoById(cliente.estadoId!);
          }
        }
      });
    });
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
    _tipoPersona = cliente.tipoPersona;
    
    // Precargar país: buscar en la lista de países cargados por ID
    // IMPORTANTE: Solo usar países que estén en la lista para evitar errores del dropdown
    if (controller.paisDetail != null && controller.paises.isNotEmpty) {
      try {
        _paisSeleccionado = controller.paises.firstWhere(
          (pais) => pais.idPais == controller.paisDetail!.idPais,
        );
      } catch (e) {
        // Si no se encuentra en la lista, dejar null (se actualizará cuando se carguen los países)
        _paisSeleccionado = null;
      }
    } else if (controller.paisDetail != null) {
      // Si aún no se han cargado los países, dejar null temporalmente
      // Se actualizará cuando se carguen los catálogos
      _paisSeleccionado = null;
    }
    
    // Precargar estado: buscar en la lista de estados cargados por ID
    // IMPORTANTE: Solo usar estados que estén en la lista para evitar errores del dropdown
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
      // Si aún no se han cargado los estados, dejar null temporalmente
      // Se actualizará cuando se carguen los estados (si el país es México)
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
                  
                  // Si los catálogos se cargan después, actualizar los dropdowns
                  if (_isInitialized && controller.clienteDetail != null) {
                    // Actualizar país si los catálogos se cargan después
                    if (controller.paises.isNotEmpty && controller.paisDetail != null) {
                      try {
                        final paisEncontrado = controller.paises.firstWhere(
                          (pais) => pais.idPais == controller.paisDetail!.idPais,
                        );
                        if (_paisSeleccionado?.idPais != paisEncontrado.idPais) {
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            if (mounted) {
                              setState(() {
                                _paisSeleccionado = paisEncontrado;
                              });
                            }
                          });
                        }
                      } catch (e) {
                        // Si no se encuentra en la lista, dejar null para evitar el error del dropdown
                        // El dropdown mostrará el hint y el usuario podrá seleccionar manualmente
                        if (_paisSeleccionado != null) {
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            if (mounted) {
                              setState(() {
                                _paisSeleccionado = null;
                              });
                            }
                          });
                        }
                      }
                    }
                    
                    // Actualizar estado si se carga después
                    if (controller.estados.isNotEmpty && controller.estadoDetail != null) {
                      try {
                        final estadoEncontrado = controller.estados.firstWhere(
                          (estado) => estado.idEstado == controller.estadoDetail!.idEstado,
                        );
                        if (_estadoSeleccionado?.idEstado != estadoEncontrado.idEstado) {
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            if (mounted) {
                              setState(() {
                                _estadoSeleccionado = estadoEncontrado;
                              });
                            }
                          });
                        }
                      } catch (e) {
                        // Si no se encuentra en la lista, dejar null para evitar el error del dropdown
                        // El dropdown mostrará el hint y el usuario podrá seleccionar manualmente
                        if (_estadoSeleccionado != null) {
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            if (mounted) {
                              setState(() {
                                _estadoSeleccionado = null;
                              });
                            }
                          });
                        }
                      }
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
                  hint: _tipoPersona == 1 ? 'Ingresa el nombre' : 'Ingresa la razón social',
                  icon: Icons.person,
                  enabled: true,
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
                // Campos específicos de Persona Física (EDITABLES)
                if (_tipoPersona == 1) ...[
                  _buildTextField(
                    controller: _apellidoPaternoController,
                    label: 'Apellido paterno',
                    hint: 'Ingresa el apellido paterno',
                    icon: Icons.person_outline,
                    enabled: true,
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
                    enabled: true,
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
                    enabled: true,
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
                // Campo específico de Persona Moral (EDITABLE)
                if (_tipoPersona == 2) ...[
                  _buildTextField(
                    controller: _representanteController,
                    label: 'Representante',
                    hint: 'Ingresa el nombre del representante',
                    icon: Icons.account_circle,
                    enabled: true,
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
                // Campo: RFC (EDITABLE)
                _buildTextField(
                  controller: _rfcController,
                  label: 'RFC',
                  hint: 'Ingresa el RFC (12-13 caracteres)',
                  icon: Icons.assignment_ind,
                  enabled: true,
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
                // Campo: Correo electrónico (READ-ONLY - no se puede editar)
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
                  hint: 'Ingresa el teléfono (10 dígitos)',
                  icon: Icons.phone,
                  keyboardType: TextInputType.number,
                  enabled: true,
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
                // Campo: Documento de identificación (EDITABLE)
                _buildTextField(
                  controller: _documentoController,
                  label: 'Documento de identificación',
                  hint: 'Ingresa el número de documento',
                  icon: Icons.badge,
                  keyboardType: TextInputType.number,
                  enabled: true,
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
                // Campo: Dirección (EDITABLE)
                _buildTextField(
                  controller: _direccionController,
                  label: 'Dirección',
                  hint: 'Ingresa la dirección completa',
                  icon: Icons.location_on,
                  maxLines: 2,
                  enabled: true,
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
                // Dropdown: País (EDITABLE)
                _buildPaisDropdown(controller),
                const SizedBox(height: 20),
                // Dropdown: Estado (EDITABLE - solo disponible para México)
                _buildEstadoDropdown(controller),
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
      textCapitalization: label.contains('CURP') || label.contains('RFC') 
          ? TextCapitalization.characters 
          : TextCapitalization.none,
      onChanged: (value) {
        // Convertir a mayúsculas para RFC y CURP
        if (label.contains('RFC') || label.contains('CURP')) {
          final cursorPosition = controller.selection.start;
          controller.value = TextEditingValue(
            text: value.toUpperCase(),
            selection: TextSelection.collapsed(offset: cursorPosition),
          );
        }
      },
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
        // Ocultar contador de caracteres si maxLength está definido
        counterText: maxLength != null ? '' : null,
      ),
    );
  }

  /// Widget para dropdown de países (EDITABLE)
  Widget _buildPaisDropdown(ClienteController controller) {
    // Si hay un país seleccionado, verificar que esté en la lista
    Pais? paisValue = _paisSeleccionado;
    
    // Verificar que el país seleccionado esté en la lista de países cargados
    if (paisValue != null && controller.paises.isNotEmpty) {
      final existeEnLista = controller.paises.any((pais) => pais.idPais == paisValue!.idPais);
      if (!existeEnLista) {
        // Si el país seleccionado no está en la lista, buscar por ID
        try {
          paisValue = controller.paises.firstWhere(
            (pais) => pais.idPais == paisValue!.idPais,
          );
        } catch (e) {
          // Si no se encuentra, usar null para evitar el error
          paisValue = null;
        }
      }
    }
    
    // Si no hay país seleccionado pero hay detalle, buscar en la lista
    if (paisValue == null && controller.paisDetail != null && controller.paises.isNotEmpty) {
      try {
        paisValue = controller.paises.firstWhere(
          (pais) => pais.idPais == controller.paisDetail!.idPais,
        );
      } catch (e) {
        // Si no se encuentra en la lista, usar null (mostrará el hint)
        paisValue = null;
      }
    }
    
    return DropdownButtonFormField<Pais>(
      value: paisValue,
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
            // Solo cargar estados si el país es México
            if (_esMexico(pais)) {
              controller.loadEstadosByPais(pais.idPais);
            }
            // Si no es México, los estados simplemente no se cargarán
            // y el dropdown se deshabilitará automáticamente
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

  /// Widget para dropdown de estados (EDITABLE)
  Widget _buildEstadoDropdown(ClienteController controller) {
    // Solo mostrar/habilitar el dropdown si el país seleccionado es México
    final esMexico = _esMexico(_paisSeleccionado ?? controller.paisDetail);
    
    // Si no es México o la lista está vacía, el valor debe ser null
    if (!esMexico || controller.estados.isEmpty) {
      return DropdownButtonFormField<Estado>(
        value: null, // Forzar null si no es México o no hay estados
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
        items: controller.estados.map((estado) {
          return DropdownMenuItem<Estado>(
            value: estado,
            child: Text(estado.nombre),
          );
        }).toList(),
        onChanged: esMexico && controller.estados.isNotEmpty
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
    
    // Si hay un estado seleccionado, verificar que esté en la lista
    Estado? estadoValue = _estadoSeleccionado;
    
    // Verificar que el estado seleccionado esté en la lista de estados cargados
    if (estadoValue != null) {
      final existeEnLista = controller.estados.any((estado) => estado.idEstado == estadoValue!.idEstado);
      if (!existeEnLista) {
        // Si el estado seleccionado no está en la lista, buscar por ID
        try {
          estadoValue = controller.estados.firstWhere(
            (estado) => estado.idEstado == estadoValue!.idEstado,
          );
        } catch (e) {
          // Si no se encuentra, usar null para evitar el error
          estadoValue = null;
        }
      } else {
        // Si existe, obtener el objeto exacto de la lista (no el de _estadoSeleccionado)
        estadoValue = controller.estados.firstWhere(
          (estado) => estado.idEstado == estadoValue!.idEstado,
        );
      }
    }
    
    // Si no hay estado seleccionado pero hay detalle, buscar en la lista
    if (estadoValue == null && controller.estadoDetail != null) {
      try {
        estadoValue = controller.estados.firstWhere(
          (estado) => estado.idEstado == controller.estadoDetail!.idEstado,
        );
      } catch (e) {
        // Si no se encuentra en la lista, usar null (mostrará el hint)
        estadoValue = null;
      }
    }
    
    return DropdownButtonFormField<Estado>(
      value: estadoValue, // Este valor ahora está garantizado que está en la lista
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
      items: controller.estados.map((estado) {
        return DropdownMenuItem<Estado>(
          value: estado,
          child: Text(estado.nombre),
        );
      }).toList(),
      onChanged: esMexico && controller.estados.isNotEmpty
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
  Future<void> _handleSubmit(BuildContext context, ClienteController controller) async {
    // Validar formulario
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Validar país (requerido)
    if (_paisSeleccionado == null && controller.paisDetail == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor selecciona un país'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Construir Map con todos los campos editables
    final clienteData = <String, dynamic>{
      'nombre_razon_social': _nombreRazonSocialController.text.trim(),
      'id_estatus': 1, // Siempre activo
      'rfc': _rfcController.text.trim().toUpperCase(),
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
    // Teléfono: solo numérico pero tratado como texto
    final telefono = _telefonoController.text.trim();
    if (telefono.isNotEmpty) {
      clienteData['telefono'] = telefono; // Se envía como String aunque solo contenga dígitos
    }

    final direccion = _direccionController.text.trim();
    if (direccion.isNotEmpty) {
      clienteData['direccion'] = direccion;
    }

    // Documento: solo numérico pero tratado como texto
    final documento = _documentoController.text.trim();
    if (documento.isNotEmpty) {
      clienteData['documento_identificacion'] = documento; // Se envía como String aunque solo contenga dígitos
    }

    // Agregar país (usar seleccionado o el del detalle)
    final paisId = _paisSeleccionado?.idPais ?? controller.paisDetail?.idPais;
    if (paisId != null) {
      clienteData['pais_id'] = paisId;
    }

    // Agregar estado_id solo si está seleccionado (opcional)
    final estadoId = _estadoSeleccionado?.idEstado ?? controller.estadoDetail?.idEstado;
    if (estadoId != null) {
      clienteData['estado_id'] = estadoId;
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
          // Error al cerrar diálogo, ignorar silenciosamente
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
          // Error al cerrar diálogo, ignorar silenciosamente
        }
      }
    }
  }
}


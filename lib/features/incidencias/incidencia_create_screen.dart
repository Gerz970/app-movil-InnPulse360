import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../widgets/app_header.dart';
import '../../widgets/app_sidebar.dart';
import 'controllers/incidencia_controller.dart';
import 'incidencia_galeria_screen.dart';
import '../login/login_screen.dart';

/// Pantalla de formulario para crear una nueva incidencia
/// Incluye validaciones y creación de incidencia
class IncidenciaCreateScreen extends StatefulWidget {
  const IncidenciaCreateScreen({super.key});

  @override
  State<IncidenciaCreateScreen> createState() => _IncidenciaCreateScreenState();
}

class _IncidenciaCreateScreenState extends State<IncidenciaCreateScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Controladores de texto
  final _habitacionAreaIdController = TextEditingController();
  final _incidenciaController = TextEditingController();
  final _descripcionController = TextEditingController();
  
  // Valores seleccionados
  DateTime _fechaIncidencia = DateTime.now();
  int _idEstatus = 1; // 1 = Activo (default)

  @override
  void dispose() {
    _habitacionAreaIdController.dispose();
    _incidenciaController.dispose();
    _descripcionController.dispose();
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
              child: Consumer<IncidenciaController>(
                builder: (context, controller, child) {
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
                  'Registrar nueva incidencia',
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
                      'Guardar Incidencia',
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
                    'Guardando incidencia...',
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
          initialDate: _fechaIncidencia,
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
          _formatDate(_fechaIncidencia),
          style: const TextStyle(
            fontSize: 16,
            color: Color(0xFF1a1a1a),
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

    // Construir Map con datos de la incidencia
    final habitacionAreaId = int.parse(_habitacionAreaIdController.text.trim());
    final incidencia = _incidenciaController.text.trim();
    final descripcion = _descripcionController.text.trim();
    
    // Formatear fecha a ISO 8601 con timezone Z
    final fechaIso = _fechaIncidencia.toUtc().toIso8601String();
    
    final incidenciaData = <String, dynamic>{
      'habitacion_area_id': habitacionAreaId,
      'incidencia': incidencia,
      'descripcion': descripcion,
      'fecha_incidencia': fechaIso,
      'id_estatus': _idEstatus,
    };

    // Crear incidencia
    final success = await controller.createIncidencia(incidenciaData);

    if (success && context.mounted) {
      // Obtener el id de la incidencia creada
      final incidenciaId = controller.incidenciaDetail?.idIncidencia;
      
      if (incidenciaId != null && incidenciaId > 0) {
        // Navegar a pantalla de galería
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => IncidenciaGaleriaScreen(
              incidenciaId: incidenciaId,
            ),
          ),
        );
      } else {
        // Si no se pudo obtener el ID, mostrar error y regresar
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error al obtener el ID de la incidencia creada'),
            backgroundColor: Colors.red,
          ),
        );
        Navigator.pop(context);
      }
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


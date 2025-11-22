import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../widgets/app_header.dart';
import '../../widgets/app_sidebar.dart';
import 'controllers/limpieza_controller.dart';
import 'models/limpieza_model.dart';
import 'models/empleado_simple_model.dart';
import '../../features/hoteles/controllers/hotel_controller.dart';

/// Pantalla para asignar limpieza a camarista
/// Permite seleccionar camarista y editar descripción de limpiezas pendientes
class LimpiezaAsignarScreen extends StatefulWidget {
  final int limpiezaId;
  final int estatusLimpiezaId;

  const LimpiezaAsignarScreen({
    super.key,
    required this.limpiezaId,
    required this.estatusLimpiezaId,
  });

  @override
  State<LimpiezaAsignarScreen> createState() => _LimpiezaAsignarScreenState();
}

class _LimpiezaAsignarScreenState extends State<LimpiezaAsignarScreen> {
  final TextEditingController _descripcionController = TextEditingController();
  EmpleadoSimple? _selectedCamarista;
  Limpieza? _limpiezaActual;

  @override
  void initState() {
    super.initState();
    // Verificar que la limpieza sea editable (estatus == 1)
    if (widget.estatusLimpiezaId != 1) {
      // Si no es pendiente, mostrar error y regresar
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showErrorAndGoBack('Solo se pueden asignar limpiezas en estatus Pendiente');
      });
      return;
    }

    // Buscar la limpieza actual en el controlador
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final limpiezaController = Provider.of<LimpiezaController>(context, listen: false);
      final limpieza = limpiezaController.limpiezas.firstWhere(
        (l) => l.idLimpieza == widget.limpiezaId,
        orElse: () => Limpieza(
          idLimpieza: 0,
          habitacionAreaId: 0,
          fechaProgramada: '',
          tipoLimpiezaId: 0,
          estatusLimpiezaId: 0,
          empleadoId: 0,
          tipoLimpieza: TipoLimpieza(idTipoLimpieza: 0, nombreTipo: '', descripcion: '', idEstatus: 0),
          habitacionArea: HabitacionArea(idHabitacionArea: 0, pisoId: 0, tipoHabitacionId: 0, nombreClave: '', descripcion: '', estatusId: 0),
          empleado: Empleado(claveEmpleado: '', nombre: '', apellidoPaterno: '', apellidoMaterno: '', fechaNacimiento: '', rfc: '', curp: '', domicilio: Domicilio(calle: '', numeroExterior: '', colonia: '', municipio: '', estado: '', codigoPostal: '', paisId: 0)),
        ),
      );

      if (limpieza.idLimpieza != 0) {
        setState(() {
          _limpiezaActual = limpieza;
          _descripcionController.text = limpieza.descripcion ?? '';
        });

        // Cargar empleados del hotel actual
        _loadEmpleados();
      } else {
        _showErrorAndGoBack('Limpieza no encontrada');
      }
    });
  }

  @override
  void dispose() {
    _descripcionController.dispose();
    super.dispose();
  }

  Future<void> _loadEmpleados() async {
    final hotelController = Provider.of<HotelController>(context, listen: false);
    final hotelSeleccionado = hotelController.hotelSeleccionado;

    if (hotelSeleccionado == null) {
      _showErrorAndGoBack('No hay hotel seleccionado');
      return;
    }

    final limpiezaController = Provider.of<LimpiezaController>(context, listen: false);
    await limpiezaController.fetchEmpleadosPorHotel(hotelSeleccionado.idHotel);

    // Si la limpieza ya tiene un empleado asignado, seleccionarlo
    if (_limpiezaActual?.empleadoId != null) {
      final empleadoAsignado = limpiezaController.empleados.firstWhere(
        (e) => e.idEmpleado == _limpiezaActual!.empleadoId,
        orElse: () => EmpleadoSimple(
          idEmpleado: 0,
          claveEmpleado: '',
          nombre: '',
          apellidoPaterno: '',
          apellidoMaterno: '',
          puestos: [],
        ),
      );

      if (empleadoAsignado.idEmpleado != 0) {
        setState(() {
          _selectedCamarista = empleadoAsignado;
        });
      }
    }
  }

  void _showErrorAndGoBack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
    Navigator.of(context).pop();
  }

  Future<void> _saveAsignacion() async {
    if (_selectedCamarista == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor selecciona un camarista'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final limpiezaController = Provider.of<LimpiezaController>(context, listen: false);
    final success = await limpiezaController.updateLimpieza(
      widget.limpiezaId,
      _selectedCamarista!.idEmpleado,
      _descripcionController.text.trim().isEmpty ? null : _descripcionController.text.trim(),
    );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Limpieza asignada correctamente'),
          backgroundColor: Colors.green,
        ),
      );
      // Regresar al listado y refrescar
      Navigator.of(context).pop(true); // true indica que se actualizó
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(limpiezaController.updateErrorMessage ?? 'Error al guardar asignación'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_limpiezaActual == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

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
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Botón de regreso
                    _buildBackButton(),
                    
                    const SizedBox(height: 16),
                    
                    // Título
                    const Text(
                      'Asignar Limpieza',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1a1a1a),
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Información de la limpieza
                    _buildLimpiezaInfo(),

                    const SizedBox(height: 24),

                    // Campo de descripción
                    _buildDescripcionField(),

                    const SizedBox(height: 24),

                    // Selector de camarista
                    _buildCamaristaSelector(),

                    const SizedBox(height: 32),

                    // Botón de guardar
                    _buildSaveButton(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBackButton() {
    return InkWell(
      onTap: () {
        Navigator.of(context).pop();
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.grey.shade200,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.arrow_back_rounded,
              color: Colors.grey.shade700,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              'Regresar al listado',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLimpiezaInfo() {
    final estatusColor = Color(_limpiezaActual!.estatusLimpiezaColor);
    
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            estatusColor.withOpacity(0.1),
            Colors.white,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: estatusColor.withOpacity(0.2),
          width: 1.5,
        ),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header con icono y título
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: estatusColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.cleaning_services_rounded,
                  color: estatusColor,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Información de Limpieza',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _limpiezaActual!.habitacionArea.nombreClave,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1a1a1a),
                        letterSpacing: -0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // Información detallada en grid
          Row(
            children: [
              Expanded(
                child: _buildInfoCard(
                  Icons.category_rounded,
                  'Tipo',
                  _limpiezaActual!.tipoLimpieza.nombreTipo,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildInfoCard(
                  Icons.schedule_rounded,
                  'Fecha',
                  _limpiezaActual!.fechaProgramadaFormateada,
                ),
              ),
            ],
          ),
          
          if (_limpiezaActual!.habitacionArea.descripcion.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    size: 18,
                    color: Colors.grey.shade600,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _limpiezaActual!.habitacionArea.descripcion,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoCard(IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey.shade200,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: 16,
                color: Colors.grey.shade600,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1a1a1a),
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildDescripcionField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Descripción',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1a1a1a),
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _descripcionController,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: 'Ingrese una descripción para la limpieza...',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(
                color: Color(0xFF667eea),
                width: 2,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCamaristaSelector() {
    return Consumer<LimpiezaController>(
      builder: (context, controller, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF667eea).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.person_search_rounded,
                    color: Color(0xFF667eea),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Seleccionar Camarista',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1a1a1a),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            if (controller.isLoadingEmpleados)
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(
                  child: CircularProgressIndicator(
                    color: Color(0xFF667eea),
                  ),
                ),
              )
            else if (controller.empleadosErrorMessage != null)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline, color: Colors.red),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        controller.empleadosErrorMessage!,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              )
            else
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _selectedCamarista != null 
                        ? const Color(0xFF667eea) 
                        : Colors.grey.shade300,
                    width: _selectedCamarista != null ? 2 : 1,
                  ),
                  boxShadow: _selectedCamarista != null
                      ? [
                          BoxShadow(
                            color: const Color(0xFF667eea).withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<EmpleadoSimple>(
                    value: _selectedCamarista,
                    hint: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text(
                        'Selecciona un camarista',
                        style: TextStyle(
                          color: Colors.grey.shade500,
                          fontSize: 15,
                        ),
                      ),
                    ),
                    isExpanded: true,
                    icon: Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    items: controller.empleados.map((camarista) {
                      return DropdownMenuItem<EmpleadoSimple>(
                        value: camarista,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          child: Row(
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF667eea).withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Text(
                                    camarista.nombre.isNotEmpty 
                                        ? camarista.nombre[0].toUpperCase() 
                                        : '?',
                                    style: const TextStyle(
                                      color: Color(0xFF667eea),
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  '${camarista.claveEmpleado} - ${camarista.nombreCompleto}',
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF1a1a1a),
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                    onChanged: (EmpleadoSimple? value) {
                      setState(() {
                        _selectedCamarista = value;
                      });
                    },
                  ),
                ),
              ),
            
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.people_outline_rounded,
                    size: 16,
                    color: Colors.grey.shade600,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${controller.empleados.length} camaristas disponibles',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSaveButton() {
    return Consumer<LimpiezaController>(
      builder: (context, controller, child) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            boxShadow: controller.isUpdating
                ? null
                : [
                    BoxShadow(
                      color: const Color(0xFF4CAF50).withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
          ),
          child: ElevatedButton(
            onPressed: controller.isUpdating ? null : _saveAsignacion,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4CAF50),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 18),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
              disabledBackgroundColor: Colors.grey.shade300,
            ),
            child: controller.isUpdating
                ? const SizedBox(
                    height: 24,
                    width: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.check_circle_outline_rounded, size: 22),
                      const SizedBox(width: 8),
                      const Text(
                        'Guardar Asignación',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
          ),
        );
      },
    );
  }
}

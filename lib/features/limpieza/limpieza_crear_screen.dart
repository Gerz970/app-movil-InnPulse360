import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../widgets/app_header.dart';
import '../../widgets/app_sidebar.dart';
import '../../core/auth/services/session_storage.dart';
import 'controllers/limpieza_controller.dart';
import 'models/tipo_limpieza_model.dart';
import '../../features/hoteles/models/hotel_model.dart';
import '../../features/pisos/models/piso_model.dart';
import 'widgets/habitacion_grid_card.dart';

/// Pantalla para crear nuevas limpiezas
/// Flujo mejorado: Hotel → Piso → Selección Múltiple de Habitaciones → Datos Comunes → Creación Masiva
class LimpiezaCrearScreen extends StatefulWidget {
  const LimpiezaCrearScreen({super.key});

  @override
  State<LimpiezaCrearScreen> createState() => _LimpiezaCrearScreenState();
}

class _LimpiezaCrearScreenState extends State<LimpiezaCrearScreen> {
  int _currentStep = 0;
  
  // Selecciones del usuario
  Hotel? _selectedHotel;
  Piso? _selectedPiso;
  Set<int> _selectedHabitacionesIds = {}; // IDs de habitaciones seleccionadas
  TipoLimpieza? _selectedTipoLimpieza;
  
  // Controllers
  final TextEditingController _descripcionController = TextEditingController();
  DateTime? _fechaProgramada;
  TimeOfDay? _horaProgramada;
  
  int? _empleadoIdLogueado;

  @override
  void initState() {
    super.initState();
    print('🎬 [LimpiezaCrearScreen] initState() ejecutado');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      print('⏰ [LimpiezaCrearScreen] PostFrameCallback en initState ejecutado');
      if (mounted) {
        print('✅ [LimpiezaCrearScreen] Widget montado, llamando _obtenerEmpleadoIdLogueado()');
        _obtenerEmpleadoIdLogueado();
      } else {
        print('⚠️ [LimpiezaCrearScreen] Widget NO montado en initState');
      }
    });
  }

  @override
  void dispose() {
    _descripcionController.dispose();
    super.dispose();
  }

  Future<void> _obtenerEmpleadoIdLogueado() async {
    print('👤 [LimpiezaCrearScreen] _obtenerEmpleadoIdLogueado() iniciado');
    if (!mounted) {
      print('⚠️ [LimpiezaCrearScreen] Widget no montado, cancelando');
      return;
    }
    
    try {
      print('🔍 [LimpiezaCrearScreen] Obteniendo sesión...');
      final session = await SessionStorage.getSession();
      if (session == null) {
        print('⚠️ [LimpiezaCrearScreen] No hay sesión disponible');
        return;
      }
      
      print('✅ [LimpiezaCrearScreen] Sesión obtenida');
      print('🔍 [LimpiezaCrearScreen] Contenido de session: ${session.keys}');
      
      final usuario = session['usuario'];
      print('👤 [LimpiezaCrearScreen] Usuario: $usuario');
      
      if (usuario is Map<String, dynamic>) {
        print('🔍 [LimpiezaCrearScreen] Keys del usuario: ${usuario.keys}');
        // Intentar con diferentes nombres de campo
        _empleadoIdLogueado = usuario['empleado_id'] as int? ?? 
                             usuario['id_empleado'] as int? ??
                             usuario['empleadoId'] as int?;
        print('👤 [LimpiezaCrearScreen] empleado_id desde usuario: $_empleadoIdLogueado');
      }
      
      if (_empleadoIdLogueado == null) {
        // Intentar desde el nivel de session directamente
        _empleadoIdLogueado = session['empleado_id'] as int? ?? 
                              session['id_empleado'] as int? ??
                              session['empleadoId'] as int?;
        print('👤 [LimpiezaCrearScreen] empleado_id desde session: $_empleadoIdLogueado');
      }
      
      if (_empleadoIdLogueado != null && mounted) {
        print('🏨 [LimpiezaCrearScreen] Cargando hoteles para empleado $_empleadoIdLogueado');
        final controller = Provider.of<LimpiezaController>(context, listen: false);
        await controller.fetchHotelesPorEmpleado(_empleadoIdLogueado!);
        print('✅ [LimpiezaCrearScreen] Hoteles cargados: ${controller.hotelesEmpleado.length}');
        
        // Lógica de auto-selección de hotel
        if (controller.hotelesEmpleado.length == 1) {
          // Solo hay un hotel: seleccionarlo automáticamente y avanzar al paso de pisos
          print('🏨 [LimpiezaCrearScreen] Solo hay 1 hotel, seleccionando automáticamente');
          setState(() {
            _selectedHotel = controller.hotelesEmpleado.first;
            _currentStep = 1; // Saltar al paso de pisos
          });
          // Cargar pisos automáticamente
          await controller.fetchPisosPorHotel(_selectedHotel!.idHotel);
          
          // Lógica de auto-selección de piso
          if (controller.pisos.length == 1) {
            // Solo hay un piso: seleccionarlo automáticamente y avanzar al paso de habitaciones
            print('🏢 [LimpiezaCrearScreen] Solo hay 1 piso, seleccionando automáticamente');
            setState(() {
              _selectedPiso = controller.pisos.first;
              _currentStep = 2; // Saltar al paso de habitaciones
            });
            // Cargar habitaciones automáticamente
            await controller.fetchHabitacionesConEstadoPorPiso(_selectedPiso!.idPiso);
          } else if (controller.pisos.length > 1) {
            // Hay más de un piso: preseleccionar el primero
            print('🏢 [LimpiezaCrearScreen] Hay ${controller.pisos.length} pisos, preseleccionando el primero');
            setState(() {
              _selectedPiso = controller.pisos.first;
            });
            // Cargar habitaciones del primer piso
            await controller.fetchHabitacionesConEstadoPorPiso(_selectedPiso!.idPiso);
          }
        } else if (controller.hotelesEmpleado.length > 1) {
          // Hay más de un hotel: preseleccionar el primero
          print('🏨 [LimpiezaCrearScreen] Hay ${controller.hotelesEmpleado.length} hoteles, preseleccionando el primero');
          setState(() {
            _selectedHotel = controller.hotelesEmpleado.first;
          });
          // Cargar pisos del primer hotel
          await controller.fetchPisosPorHotel(_selectedHotel!.idHotel);
          
          // Lógica de auto-selección de piso
          if (controller.pisos.length == 1) {
            // Solo hay un piso: seleccionarlo automáticamente
            print('🏢 [LimpiezaCrearScreen] Solo hay 1 piso, seleccionando automáticamente');
            setState(() {
              _selectedPiso = controller.pisos.first;
            });
            // Cargar habitaciones automáticamente
            await controller.fetchHabitacionesConEstadoPorPiso(_selectedPiso!.idPiso);
          } else if (controller.pisos.length > 1) {
            // Hay más de un piso: preseleccionar el primero
            print('🏢 [LimpiezaCrearScreen] Hay ${controller.pisos.length} pisos, preseleccionando el primero');
            setState(() {
              _selectedPiso = controller.pisos.first;
            });
            // Cargar habitaciones del primer piso
            await controller.fetchHabitacionesConEstadoPorPiso(_selectedPiso!.idPiso);
          }
        }
        // Si no hay hoteles, se mostrará el mensaje en _buildStepHotel()
      } else {
        print('⚠️ [LimpiezaCrearScreen] No se pudo obtener empleado_id o widget no montado');
      }
    } catch (e) {
      print('❌ [LimpiezaCrearScreen] Error al obtener empleado_id: $e');
      print('   Stack trace: ${StackTrace.current}');
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
            const AppHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Título
                    const Text(
                      'Crear Limpiezas',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1a1a1a),
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    
                    // Indicador de pasos
                    _buildStepIndicator(),
                    
                    const SizedBox(height: 24),
                    
                    // Contenido según el paso actual
                    _buildStepContent(),
                    
                    const SizedBox(height: 24),
                    
                    // Botones de navegación
                    _buildNavigationButtons(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepIndicator() {
    final steps = ['Hotel', 'Piso', 'Habitaciones', 'Datos'];
    return Row(
      children: steps.asMap().entries.map((entry) {
        final index = entry.key;
        final stepName = entry.value;
        final isActive = index == _currentStep;
        final isCompleted = index < _currentStep;
        
        return Expanded(
          child: Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: isActive || isCompleted
                            ? const Color(0xFF4CAF50)
                            : Colors.grey.shade300,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: isCompleted
                            ? const Icon(Icons.check, color: Colors.white, size: 18)
                            : Text(
                                '${index + 1}',
                                style: TextStyle(
                                  color: isActive || isCompleted
                                      ? Colors.white
                                      : Colors.grey.shade700,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      stepName,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                        color: isActive || isCompleted
                            ? const Color(0xFF4CAF50)
                            : Colors.grey.shade600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              if (index < steps.length - 1)
                Container(
                  width: 20,
                  height: 2,
                  color: isCompleted
                      ? const Color(0xFF4CAF50)
                      : Colors.grey.shade300,
                ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildStepContent() {
    print('📄 [LimpiezaCrearScreen] _buildStepContent() - Paso actual: $_currentStep');
    switch (_currentStep) {
      case 0:
        print('🏨 [LimpiezaCrearScreen] Construyendo paso 0: Hotel');
        return _buildStepHotel();
      case 1:
        print('🏢 [LimpiezaCrearScreen] Construyendo paso 1: Piso');
        return _buildStepPiso();
      case 2:
        print('🚪 [LimpiezaCrearScreen] Construyendo paso 2: Habitaciones');
        return _buildStepHabitaciones();
      case 3:
        print('📝 [LimpiezaCrearScreen] Construyendo paso 3: Datos');
        return _buildStepDatos();
      default:
        print('⚠️ [LimpiezaCrearScreen] Paso desconocido: $_currentStep');
        return const SizedBox();
    }
  }

  Widget _buildStepHotel() {
    return Consumer<LimpiezaController>(
      builder: (context, controller, child) {
        if (controller.isLoadingHotelesEmpleado) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: CircularProgressIndicator(color: Color(0xFF4CAF50)),
            ),
          );
        }
        
        if (controller.hotelesEmpleadoErrorMessage != null) {
          return Container(
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
                    controller.hotelesEmpleadoErrorMessage!,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              ],
            ),
          );
        }
        
        if (controller.hotelesEmpleado.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.orange.shade200),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.hotel_outlined,
                  size: 64,
                  color: Colors.orange.shade700,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Sin Hoteles Asignados',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1a1a1a),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'El empleado administrador no tiene ningún hotel asignado.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade700,
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('Regresar'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4CAF50),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                ),
              ],
            ),
          );
        }
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4CAF50).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.hotel,
                    color: Color(0xFF4CAF50),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Seleccionar Hotel',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1a1a1a),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _selectedHotel != null
                      ? const Color(0xFF4CAF50)
                      : Colors.grey.shade300,
                  width: _selectedHotel != null ? 2 : 1,
                ),
                boxShadow: _selectedHotel != null
                    ? [
                        BoxShadow(
                          color: const Color(0xFF4CAF50).withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<Hotel>(
                  value: _selectedHotel,
                  hint: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      'Selecciona un hotel',
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
                  items: controller.hotelesEmpleado.map((hotel) {
                    return DropdownMenuItem<Hotel>(
                      value: hotel,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        child: Text(
                          hotel.nombre,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1a1a1a),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                  onChanged: (hotel) async {
                    setState(() {
                      _selectedHotel = hotel;
                      _selectedPiso = null;
                      _selectedHabitacionesIds.clear();
                    });
                    if (hotel != null) {
                      final controller = Provider.of<LimpiezaController>(context, listen: false);
                      await controller.fetchPisosPorHotel(hotel.idHotel);
                      
                      // Lógica de auto-selección de piso
                      if (controller.pisos.length == 1) {
                        // Solo hay un piso: seleccionarlo automáticamente
                        setState(() {
                          _selectedPiso = controller.pisos.first;
                        });
                        // Cargar habitaciones automáticamente
                        await controller.fetchHabitacionesConEstadoPorPiso(_selectedPiso!.idPiso);
                      } else if (controller.pisos.length > 1) {
                        // Hay más de un piso: preseleccionar el primero
                        setState(() {
                          _selectedPiso = controller.pisos.first;
                        });
                        // Cargar habitaciones del primer piso
                        await controller.fetchHabitacionesConEstadoPorPiso(_selectedPiso!.idPiso);
                      }
                    }
                  },
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStepPiso() {
    if (_selectedHotel == null) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.orange.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.orange.shade200),
        ),
        child: Row(
          children: [
            Icon(Icons.info_outline, color: Colors.orange.shade700),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Primero debe seleccionar un hotel',
                style: TextStyle(color: Colors.orange),
              ),
            ),
          ],
        ),
      );
    }

    return Consumer<LimpiezaController>(
      builder: (context, controller, child) {
        if (controller.isLoadingPisos) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: CircularProgressIndicator(color: Color(0xFF4CAF50)),
            ),
          );
        }
        
        if (controller.pisosErrorMessage != null) {
          return Container(
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
                    controller.pisosErrorMessage!,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              ],
            ),
          );
        }
        
        if (controller.pisos.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.orange.shade200),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.layers_outlined,
                  size: 64,
                  color: Colors.orange.shade700,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Sin Pisos Asignados',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1a1a1a),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Al hotel seleccionado le hace falta asignarle pisos de habitaciones.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade700,
                  ),
                ),
                const SizedBox(height: 24),
                OutlinedButton.icon(
                  onPressed: () {
                    setState(() {
                      _currentStep = 0; // Regresar al paso de hoteles
                      _selectedHotel = null;
                      _selectedPiso = null;
                    });
                  },
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('Regresar'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF4CAF50),
                    side: const BorderSide(color: Color(0xFF4CAF50)),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                ),
              ],
            ),
          );
        }
        
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
                    Icons.layers,
                    color: Color(0xFF667eea),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Seleccionar Piso',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1a1a1a),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _selectedPiso != null
                      ? const Color(0xFF667eea)
                      : Colors.grey.shade300,
                  width: _selectedPiso != null ? 2 : 1,
                ),
                boxShadow: _selectedPiso != null
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
                child: DropdownButton<Piso>(
                  value: _selectedPiso,
                  hint: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      'Selecciona un piso',
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
                  items: controller.pisos.map((piso) {
                    return DropdownMenuItem<Piso>(
                      value: piso,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        child: Text(
                          '${piso.nombre} - Nivel ${piso.nivel}',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1a1a1a),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                  onChanged: (piso) async {
                    setState(() {
                      _selectedPiso = piso;
                      _selectedHabitacionesIds.clear();
                    });
                    if (piso != null) {
                      final controller = Provider.of<LimpiezaController>(context, listen: false);
                      await controller.fetchHabitacionesConEstadoPorPiso(piso.idPiso);
                    }
                  },
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStepHabitaciones() {
    if (_selectedPiso == null) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.orange.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.orange.shade200),
        ),
        child: Row(
          children: [
            Icon(Icons.info_outline, color: Colors.orange.shade700),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Primero debe seleccionar un piso',
                style: TextStyle(color: Colors.orange),
              ),
            ),
          ],
        ),
      );
    }

    return Consumer<LimpiezaController>(
      builder: (context, controller, child) {
        if (controller.isLoadingHabitacionesConEstado) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: CircularProgressIndicator(color: Color(0xFF4CAF50)),
            ),
          );
        }
        
        if (controller.habitacionesConEstadoErrorMessage != null) {
          return Container(
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
                    controller.habitacionesConEstadoErrorMessage!,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              ],
            ),
          );
        }
        
        if (controller.habitacionesConEstado.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: Text(
                'No hay habitaciones disponibles para este piso',
                style: TextStyle(color: Colors.grey),
              ),
            ),
          );
        }

        final habitacionesSeleccionables = controller.habitacionesConEstado
            .where((h) => h.puedeSeleccionarse)
            .length;
        final habitacionesSeleccionadas = controller.habitacionesConEstado
            .where((h) => _selectedHabitacionesIds.contains(h.idHabitacionArea))
            .length;

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
                    Icons.room,
                    color: Color(0xFF667eea),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Seleccionar Habitaciones',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1a1a1a),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Botón de seleccionar todas
            if (habitacionesSeleccionables > 0)
              OutlinedButton.icon(
                onPressed: () {
                  setState(() {
                    final todasSeleccionadas = habitacionesSeleccionables == habitacionesSeleccionadas;
                    if (todasSeleccionadas) {
                      // Deseleccionar todas
                      _selectedHabitacionesIds.clear();
                    } else {
                      // Seleccionar todas las seleccionables
                      _selectedHabitacionesIds = controller.habitacionesConEstado
                          .where((h) => h.puedeSeleccionarse)
                          .map((h) => h.idHabitacionArea)
                          .toSet();
                    }
                  });
                },
                icon: Icon(
                  habitacionesSeleccionables == habitacionesSeleccionadas
                      ? Icons.check_box_outlined
                      : Icons.check_box,
                  size: 18,
                ),
                label: Text(
                  habitacionesSeleccionables == habitacionesSeleccionadas
                      ? 'Deseleccionar Todas'
                      : 'Seleccionar Todas ($habitacionesSeleccionables)',
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF667eea),
                  side: const BorderSide(color: Color(0xFF667eea)),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, size: 16, color: Colors.grey.shade600),
                  const SizedBox(width: 8),
                  Text(
                    '$habitacionesSeleccionadas de $habitacionesSeleccionables habitaciones seleccionadas',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.85,
              ),
              itemCount: controller.habitacionesConEstado.length,
              itemBuilder: (context, index) {
                final habitacion = controller.habitacionesConEstado[index];
                final isSelected = _selectedHabitacionesIds.contains(habitacion.idHabitacionArea);
                
                return HabitacionGridCard(
                  habitacion: habitacion,
                  isSelected: isSelected,
                  enabled: habitacion.puedeSeleccionarse,
                  onTap: () {
                    setState(() {
                      if (isSelected) {
                        _selectedHabitacionesIds.remove(habitacion.idHabitacionArea);
                      } else {
                        _selectedHabitacionesIds.add(habitacion.idHabitacionArea);
                      }
                    });
                  },
                );
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildStepDatos() {
    print('📝 [LimpiezaCrearScreen] _buildStepDatos() ejecutado - Paso 3');
    return Consumer<LimpiezaController>(
      builder: (context, controller, child) {
        print('👁️ [LimpiezaCrearScreen] Consumer de _buildStepDatos ejecutado');
        print('   Estado actual: tiposLimpieza=${controller.tiposLimpieza.length}, isLoading=${controller.isLoadingTiposLimpieza}, error=${controller.tiposLimpiezaErrorMessage}');
        
        // Cargar tipos de limpieza si aún no se han cargado
        if (controller.tiposLimpieza.isEmpty && 
            !controller.isLoadingTiposLimpieza && 
            controller.tiposLimpiezaErrorMessage == null) {
          print('📥 [LimpiezaCrearScreen] Programando carga de tipos desde _buildStepDatos...');
          WidgetsBinding.instance.addPostFrameCallback((_) {
            print('⏰ [LimpiezaCrearScreen] PostFrameCallback desde _buildStepDatos ejecutado');
            if (mounted) {
              print('✅ [LimpiezaCrearScreen] Widget montado, llamando fetchTiposLimpieza() desde _buildStepDatos');
              controller.fetchTiposLimpieza();
            } else {
              print('⚠️ [LimpiezaCrearScreen] Widget NO montado en _buildStepDatos');
            }
          });
        }
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Descripción
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF667eea).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.description,
                    color: Color(0xFF667eea),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Datos Comunes',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1a1a1a),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Campo de descripción
            TextFormField(
              controller: _descripcionController,
              decoration: InputDecoration(
                labelText: 'Descripción (opcional)',
                hintText: 'Ingrese una descripción para las limpiezas...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: Color(0xFF667eea),
                    width: 2,
                  ),
                ),
              ),
              maxLines: 3,
            ),
            
            const SizedBox(height: 24),
            
            // Fecha y hora programada
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () async {
                      final fecha = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (fecha != null) {
                        setState(() {
                          _fechaProgramada = fecha;
                        });
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _fechaProgramada != null
                              ? const Color(0xFF4CAF50)
                              : Colors.grey.shade300,
                          width: _fechaProgramada != null ? 2 : 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.calendar_today,
                            color: _fechaProgramada != null
                                ? const Color(0xFF4CAF50)
                                : Colors.grey.shade600,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Fecha Programada',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _fechaProgramada == null
                                      ? 'Seleccionar fecha'
                                      : '${_fechaProgramada!.day.toString().padLeft(2, '0')}/${_fechaProgramada!.month.toString().padLeft(2, '0')}/${_fechaProgramada!.year}',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: _fechaProgramada != null
                                        ? const Color(0xFF1a1a1a)
                                        : Colors.grey.shade400,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: InkWell(
                    onTap: () async {
                      final hora = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.now(),
                      );
                      if (hora != null) {
                        setState(() {
                          _horaProgramada = hora;
                        });
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _horaProgramada != null
                              ? const Color(0xFF4CAF50)
                              : Colors.grey.shade300,
                          width: _horaProgramada != null ? 2 : 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.access_time,
                            color: _horaProgramada != null
                                ? const Color(0xFF4CAF50)
                                : Colors.grey.shade600,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Hora Programada',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _horaProgramada == null
                                      ? 'Seleccionar hora'
                                      : _horaProgramada!.format(context),
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: _horaProgramada != null
                                        ? const Color(0xFF1a1a1a)
                                        : Colors.grey.shade400,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Selector de tipo de limpieza
            Builder(
              builder: (context) {
                print('🔍 [LimpiezaCrearScreen] Builder ejecutado para tipos de limpieza');
                print('   tiposLimpieza.isEmpty: ${controller.tiposLimpieza.isEmpty}');
                print('   isLoadingTiposLimpieza: ${controller.isLoadingTiposLimpieza}');
                print('   tiposLimpiezaErrorMessage: ${controller.tiposLimpiezaErrorMessage}');
                
                // Cargar tipos de limpieza si aún no se han cargado
                if (controller.tiposLimpieza.isEmpty && 
                    !controller.isLoadingTiposLimpieza && 
                    controller.tiposLimpiezaErrorMessage == null) {
                  print('📥 [LimpiezaCrearScreen] Programando carga de tipos de limpieza...');
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    print('⏰ [LimpiezaCrearScreen] PostFrameCallback ejecutado');
                    if (mounted) {
                      print('✅ [LimpiezaCrearScreen] Widget montado, llamando fetchTiposLimpieza()');
                      controller.fetchTiposLimpieza();
                    } else {
                      print('⚠️ [LimpiezaCrearScreen] Widget NO montado, cancelando carga');
                    }
                  });
                }
                
                if (controller.isLoadingTiposLimpieza) {
                  print('⏳ [LimpiezaCrearScreen] Mostrando indicador de carga');
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: CircularProgressIndicator(color: Color(0xFF667eea)),
                    ),
                  );
                }
                
                if (controller.tiposLimpiezaErrorMessage != null) {
                  print('❌ [LimpiezaCrearScreen] Mostrando error: ${controller.tiposLimpiezaErrorMessage}');
                  return Container(
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
                            controller.tiposLimpiezaErrorMessage!,
                            style: const TextStyle(color: Colors.red),
                          ),
                        ),
                      ],
                    ),
                  );
                }
                
                print('📋 [LimpiezaCrearScreen] Mostrando selector con ${controller.tiposLimpieza.length} tipos');
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
                            Icons.cleaning_services,
                            color: Color(0xFF667eea),
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'Tipo de Limpieza',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1a1a1a),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _selectedTipoLimpieza != null
                              ? const Color(0xFF667eea)
                              : Colors.grey.shade300,
                          width: _selectedTipoLimpieza != null ? 2 : 1,
                        ),
                        boxShadow: _selectedTipoLimpieza != null
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
                        child: DropdownButton<TipoLimpieza>(
                          value: _selectedTipoLimpieza,
                          hint: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: Text(
                              'Selecciona un tipo de limpieza',
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
                          items: controller.tiposLimpieza.map((tipo) {
                            return DropdownMenuItem<TipoLimpieza>(
                              value: tipo,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                child: Text(
                                  tipo.nombreTipo,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF1a1a1a),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                          onChanged: (tipo) {
                            setState(() {
                              _selectedTipoLimpieza = tipo;
                            });
                          },
                        ),
                      ),
                    ),
                    // Mostrar descripción del tipo seleccionado debajo
                    if (_selectedTipoLimpieza != null && _selectedTipoLimpieza!.descripcion.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.info_outline,
                              size: 16,
                              color: Colors.grey.shade600,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _selectedTipoLimpieza!.descripcion,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey.shade700,
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                );
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildNavigationButtons() {
    return Row(
      children: [
        if (_currentStep > 0)
          Expanded(
            child: OutlinedButton(
              onPressed: () {
                setState(() {
                  _currentStep--;
                  // Si regresamos al paso 0 y solo hay 1 hotel, no permitir regresar más
                  if (_currentStep == 0) {
                    final controller = Provider.of<LimpiezaController>(context, listen: false);
                    if (controller.hotelesEmpleado.length == 1) {
                      // Si solo hay 1 hotel, volver al paso 1 automáticamente
                      _currentStep = 1;
                    }
                  }
                });
              },
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                side: const BorderSide(
                  color: Color(0xFF667eea),
                  width: 1.5,
                ),
              ),
              child: const Text(
                'Anterior',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF667eea),
                ),
              ),
            ),
          ),
        if (_currentStep > 0) const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton(
            onPressed: _canContinue() ? _onContinue : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4CAF50),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
              disabledBackgroundColor: Colors.grey.shade300,
            ),
            child: Text(
              _currentStep == 3 ? 'Crear Limpiezas' : 'Siguiente',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }

  bool _canContinue() {
    switch (_currentStep) {
      case 0:
        return _selectedHotel != null;
      case 1:
        return _selectedPiso != null;
      case 2:
        return _selectedHabitacionesIds.isNotEmpty;
      case 3:
        return _fechaProgramada != null &&
            _horaProgramada != null &&
            _selectedTipoLimpieza != null;
      default:
        return false;
    }
  }

  void _onContinue() {
    print('➡️ [LimpiezaCrearScreen] _onContinue() llamado - Paso actual: $_currentStep');
    if (_currentStep < 3) {
      setState(() {
        _currentStep++;
        print('✅ [LimpiezaCrearScreen] Avanzando al paso $_currentStep');
      });
    } else {
      print('🚀 [LimpiezaCrearScreen] Último paso, creando limpiezas masivamente');
      _crearLimpiezasMasivo();
    }
  }

  Future<void> _crearLimpiezasMasivo() async {
    // Validaciones finales
    if (_selectedHabitacionesIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Debe seleccionar al menos una habitación'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (_fechaProgramada == null || _horaProgramada == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Debe seleccionar fecha y hora programada'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (_selectedTipoLimpieza == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Debe seleccionar un tipo de limpieza'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Combinar fecha y hora
    final fechaHoraCompleta = DateTime(
      _fechaProgramada!.year,
      _fechaProgramada!.month,
      _fechaProgramada!.day,
      _horaProgramada!.hour,
      _horaProgramada!.minute,
    );

    // Obtener habitaciones seleccionadas
    final controller = Provider.of<LimpiezaController>(context, listen: false);
    final habitacionesSeleccionadas = controller.habitacionesConEstado
        .where((h) => _selectedHabitacionesIds.contains(h.idHabitacionArea))
        .toList();

    // Preparar array de limpiezas
    final limpiezasData = habitacionesSeleccionadas.map((habitacion) {
      final data = <String, dynamic>{
        'habitacion_area_id': habitacion.idHabitacionArea,
        'descripcion': _descripcionController.text.trim().isEmpty
            ? null
            : _descripcionController.text.trim(),
        'fecha_programada': fechaHoraCompleta.toIso8601String(),
        'tipo_limpieza_id': _selectedTipoLimpieza!.idTipoLimpieza,
        'estatus_limpieza_id': 1, // Pendiente
        // No incluir empleado_id si es null (se asignará después)
      };
      // Solo agregar empleado_id si tiene un valor válido (no 0 ni null)
      // Por ahora no lo incluimos, se asignará después en el proceso de asignación
      return data;
    }).toList();

    // Mostrar diálogo de confirmación
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Creación'),
        content: Text(
          '¿Desea crear ${limpiezasData.length} limpieza${limpiezasData.length > 1 ? 's' : ''}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4CAF50),
            ),
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );

    if (confirmar != true) return;

    // Mostrar loading
    if (mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(color: Color(0xFF4CAF50)),
        ),
      );
    }

    final success = await controller.crearLimpiezasMasivo(limpiezasData);

    if (mounted) {
      Navigator.of(context).pop(); // Cerrar loading
      
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${limpiezasData.length} limpieza${limpiezasData.length > 1 ? 's creadas' : ' creada'} exitosamente',
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );
        Navigator.of(context).pop(true); // Regresar con éxito
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              controller.createMasivoErrorMessage ?? 'Error al crear limpiezas',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

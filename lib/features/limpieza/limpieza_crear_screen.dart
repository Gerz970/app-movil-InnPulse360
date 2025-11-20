import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../widgets/app_sidebar.dart';
import '../../core/auth/services/session_storage.dart';
import 'controllers/limpieza_controller.dart';
import 'models/habitacion_area_model.dart';
import 'models/empleado_simple_model.dart';
import '../../features/hoteles/models/hotel_model.dart';
import '../../features/pisos/models/piso_model.dart';

/// Pantalla para crear nueva limpieza
/// Flujo multi-paso: Hotel → Piso → Habitación → Datos → Camarista
class LimpiezaCrearScreen extends StatefulWidget {
  const LimpiezaCrearScreen({super.key});

  @override
  State<LimpiezaCrearScreen> createState() => _LimpiezaCrearScreenState();
}

class _LimpiezaCrearScreenState extends State<LimpiezaCrearScreen> {
  int _currentStep = 0;
  final _formKey = GlobalKey<FormState>();
  
  // Selecciones del usuario
  Hotel? _selectedHotel;
  Piso? _selectedPiso;
  HabitacionArea? _selectedHabitacion;
  EmpleadoSimple? _selectedCamarista;
  
  // Controllers
  final TextEditingController _descripcionController = TextEditingController();
  DateTime? _fechaProgramada;
  TimeOfDay? _horaProgramada;
  
  int? _empleadoIdLogueado;

  @override
  void initState() {
    super.initState();
    _obtenerEmpleadoIdLogueado();
  }

  @override
  void dispose() {
    _descripcionController.dispose();
    super.dispose();
  }

  Future<void> _obtenerEmpleadoIdLogueado() async {
    try {
      final session = await SessionStorage.getSession();
      if (session == null) return;
      
      // Intentar obtener desde diferentes ubicaciones posibles
      final usuario = session['usuario'];
      if (usuario is Map<String, dynamic>) {
        _empleadoIdLogueado = usuario['id_empleado'] as int?;
      }
      
      if (_empleadoIdLogueado == null) {
        _empleadoIdLogueado = session['id_empleado'] as int?;
      }
      
      if (_empleadoIdLogueado != null && mounted) {
        final controller = Provider.of<LimpiezaController>(context, listen: false);
        await controller.fetchHotelesPorEmpleado(_empleadoIdLogueado!);
      }
    } catch (e) {
      print('Error al obtener empleado_id: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      drawer: const AppSidebar(),
      appBar: AppBar(
        title: const Text('Crear Nueva Limpieza'),
        backgroundColor: const Color(0xFF4CAF50),
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: Stepper(
            currentStep: _currentStep,
            onStepContinue: _onStepContinue,
            onStepCancel: _onStepCancel,
            onStepTapped: (step) {
              setState(() {
                _currentStep = step;
              });
            },
            steps: [
              _buildStepHotel(),
              _buildStepPiso(),
              _buildStepHabitacion(),
              _buildStepDatos(),
              _buildStepCamarista(),
            ],
          ),
        ),
      ),
    );
  }

  Step _buildStepHotel() {
    return Step(
      title: const Text('Seleccionar Hotel'),
      content: Consumer<LimpiezaController>(
        builder: (context, controller, child) {
          if (controller.isLoadingHotelesEmpleado) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (controller.hotelesEmpleadoErrorMessage != null) {
            return Text(
              controller.hotelesEmpleadoErrorMessage!,
              style: const TextStyle(color: Colors.red),
            );
          }
          
          if (controller.hotelesEmpleado.isEmpty) {
            return const Text('No hay hoteles disponibles');
          }
          
          return DropdownButtonFormField<Hotel>(
            value: _selectedHotel,
            decoration: const InputDecoration(
              labelText: 'Hotel',
              border: OutlineInputBorder(),
            ),
            items: controller.hotelesEmpleado.map((hotel) {
              return DropdownMenuItem<Hotel>(
                value: hotel,
                child: Text(hotel.nombre),
              );
            }).toList(),
            onChanged: (hotel) {
              setState(() {
                _selectedHotel = hotel;
                _selectedPiso = null;
                _selectedHabitacion = null;
              });
            },
            validator: (value) {
              if (value == null) {
                return 'Debe seleccionar un hotel';
              }
              return null;
            },
          );
        },
      ),
      isActive: _currentStep >= 0,
      state: _currentStep > 0 ? StepState.complete : StepState.indexed,
    );
  }

  Step _buildStepPiso() {
    return Step(
      title: const Text('Seleccionar Piso'),
      content: Consumer<LimpiezaController>(
        builder: (context, controller, child) {
          if (_selectedHotel == null) {
            return const Text('Primero debe seleccionar un hotel');
          }
          
          if (controller.isLoadingPisos) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (controller.pisosErrorMessage != null) {
            return Text(
              controller.pisosErrorMessage!,
              style: const TextStyle(color: Colors.red),
            );
          }
          
          if (controller.pisos.isEmpty) {
            return const Text('No hay pisos disponibles para este hotel');
          }
          
          return DropdownButtonFormField<Piso>(
            value: _selectedPiso,
            decoration: const InputDecoration(
              labelText: 'Piso',
              border: OutlineInputBorder(),
            ),
            items: controller.pisos.map((piso) {
              return DropdownMenuItem<Piso>(
                value: piso,
                child: Text('${piso.nombre} - Nivel ${piso.nivel}'),
              );
            }).toList(),
            onChanged: (piso) {
              setState(() {
                _selectedPiso = piso;
                _selectedHabitacion = null;
              });
            },
            validator: (value) {
              if (value == null) {
                return 'Debe seleccionar un piso';
              }
              return null;
            },
          );
        },
      ),
      isActive: _currentStep >= 1,
      state: _currentStep > 1 ? StepState.complete : StepState.indexed,
    );
  }

  Step _buildStepHabitacion() {
    return Step(
      title: const Text('Seleccionar Habitación'),
      content: Consumer<LimpiezaController>(
        builder: (context, controller, child) {
          if (_selectedPiso == null) {
            return const Text('Primero debe seleccionar un piso');
          }
          
          if (controller.isLoadingHabitaciones) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (controller.habitacionesErrorMessage != null) {
            return Text(
              controller.habitacionesErrorMessage!,
              style: const TextStyle(color: Colors.red),
            );
          }
          
          if (controller.habitacionesDisponibles.isEmpty) {
            return const Text('No hay habitaciones disponibles para este piso');
          }
          
          return DropdownButtonFormField<HabitacionArea>(
            value: _selectedHabitacion,
            decoration: const InputDecoration(
              labelText: 'Habitación',
              border: OutlineInputBorder(),
            ),
            items: controller.habitacionesDisponibles.map((habitacion) {
              return DropdownMenuItem<HabitacionArea>(
                value: habitacion,
                child: Text('${habitacion.nombreClave} - ${habitacion.descripcion}'),
              );
            }).toList(),
            onChanged: (habitacion) {
              setState(() {
                _selectedHabitacion = habitacion;
              });
            },
            validator: (value) {
              if (value == null) {
                return 'Debe seleccionar una habitación';
              }
              return null;
            },
          );
        },
      ),
      isActive: _currentStep >= 2,
      state: _currentStep > 2 ? StepState.complete : StepState.indexed,
    );
  }

  Step _buildStepDatos() {
    return Step(
      title: const Text('Datos de la Limpieza'),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
            controller: _descripcionController,
            decoration: const InputDecoration(
              labelText: 'Descripción',
              border: OutlineInputBorder(),
              hintText: 'Ingrese una descripción de la limpieza',
            ),
            maxLines: 3,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Debe ingresar una descripción';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          ListTile(
            title: const Text('Fecha Programada'),
            subtitle: Text(
              _fechaProgramada == null
                  ? 'No seleccionada'
                  : '${_fechaProgramada!.day.toString().padLeft(2, '0')}/${_fechaProgramada!.month.toString().padLeft(2, '0')}/${_fechaProgramada!.year}',
            ),
            trailing: const Icon(Icons.calendar_today),
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
          ),
          ListTile(
            title: const Text('Hora Programada'),
            subtitle: Text(
              _horaProgramada == null
                  ? 'No seleccionada'
                  : _horaProgramada!.format(context),
            ),
            trailing: const Icon(Icons.access_time),
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
          ),
        ],
      ),
      isActive: _currentStep >= 3,
      state: _currentStep > 3 ? StepState.complete : StepState.indexed,
    );
  }

  Step _buildStepCamarista() {
    return Step(
      title: const Text('Asignar Camarista'),
      content: Consumer<LimpiezaController>(
        builder: (context, controller, child) {
          if (_selectedHotel == null) {
            return const Text('Primero debe seleccionar un hotel');
          }
          
          if (controller.isLoadingEmpleados) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (controller.empleadosErrorMessage != null) {
            return Text(
              controller.empleadosErrorMessage!,
              style: const TextStyle(color: Colors.red),
            );
          }
          
          if (controller.empleados.isEmpty) {
            return const Text('No hay camaristas disponibles para este hotel');
          }
          
          return DropdownButtonFormField<EmpleadoSimple>(
            value: _selectedCamarista,
            decoration: const InputDecoration(
              labelText: 'Camarista',
              border: OutlineInputBorder(),
            ),
            items: controller.empleados.map((empleado) {
              return DropdownMenuItem<EmpleadoSimple>(
                value: empleado,
                child: Text(empleado.nombreCompleto),
              );
            }).toList(),
            onChanged: (empleado) {
              setState(() {
                _selectedCamarista = empleado;
              });
            },
            validator: (value) {
              if (value == null) {
                return 'Debe seleccionar un camarista';
              }
              return null;
            },
          );
        },
      ),
      isActive: _currentStep >= 4,
      state: _currentStep > 4 ? StepState.complete : StepState.indexed,
    );
  }

  void _onStepContinue() {
    if (_currentStep == 0) {
      // Validar hotel
      if (_formKey.currentState!.validate()) {
        if (_selectedHotel != null) {
          final controller = Provider.of<LimpiezaController>(context, listen: false);
          controller.fetchPisosPorHotel(_selectedHotel!.idHotel);
          setState(() {
            _currentStep++;
          });
        }
      }
    } else if (_currentStep == 1) {
      // Validar piso
      if (_formKey.currentState!.validate()) {
        if (_selectedPiso != null) {
          final controller = Provider.of<LimpiezaController>(context, listen: false);
          controller.fetchHabitacionesDisponiblesPorPiso(_selectedPiso!.idPiso);
          setState(() {
            _currentStep++;
          });
        }
      }
    } else if (_currentStep == 2) {
      // Validar habitación
      if (_formKey.currentState!.validate()) {
        setState(() {
          _currentStep++;
        });
      }
    } else if (_currentStep == 3) {
      // Validar datos
      if (_formKey.currentState!.validate()) {
        if (_fechaProgramada == null || _horaProgramada == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Debe seleccionar fecha y hora programada'),
              backgroundColor: Colors.orange,
            ),
          );
          return;
        }
        
        // Cargar camaristas del hotel seleccionado
        if (_selectedHotel != null) {
          final controller = Provider.of<LimpiezaController>(context, listen: false);
          controller.fetchEmpleadosPorHotel(_selectedHotel!.idHotel);
        }
        
        setState(() {
          _currentStep++;
        });
      }
    } else if (_currentStep == 4) {
      // Validar camarista y crear limpieza
      if (_formKey.currentState!.validate()) {
        _crearLimpieza();
      }
    }
  }

  void _onStepCancel() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
    } else {
      Navigator.of(context).pop();
    }
  }

  Future<void> _crearLimpieza() async {
    if (_selectedHabitacion == null || 
        _fechaProgramada == null || 
        _horaProgramada == null ||
        _selectedCamarista == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Debe completar todos los campos'),
          backgroundColor: Colors.red,
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

    // Preparar datos para crear limpieza
    final limpiezaData = {
      'habitacion_area_id': _selectedHabitacion!.idHabitacionArea,
      'descripcion': _descripcionController.text.trim(),
      'fecha_programada': fechaHoraCompleta.toIso8601String(),
      'tipo_limpieza_id': 1, // Valor por defecto, ajustar según necesidad
      'estatus_limpieza_id': 1, // Pendiente
      'empleado_id': _selectedCamarista!.idEmpleado,
    };

    final controller = Provider.of<LimpiezaController>(context, listen: false);
    
    if (mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );
    }

    final success = await controller.crearLimpieza(limpiezaData);

    if (mounted) {
      Navigator.of(context).pop(); // Cerrar loading
      
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Limpieza creada exitosamente'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop(true); // Regresar con éxito
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(controller.createErrorMessage ?? 'Error al crear limpieza'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}


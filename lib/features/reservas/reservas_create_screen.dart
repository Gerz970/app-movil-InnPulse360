import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import './controllers/reservas_controller.dart';
import './reservas_tipos_disponibles_screen.dart';
import '../../../features/hoteles/controllers/hotel_controller.dart';

class NuevaReservaScreen extends StatefulWidget {
  const NuevaReservaScreen({super.key});

  @override
  State<NuevaReservaScreen> createState() => _NuevaReservaScreenState();
}

class _NuevaReservaScreenState extends State<NuevaReservaScreen> {
  DateTime? fechaInicio;
  DateTime? fechaFin;

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<ReservacionController>(
      context,
      listen: false,
    );
    controller.clearHabitaciones();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Nueva Reserva"),
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      ),
      body: Consumer<ReservacionController>(
        builder: (context, reservaController, _) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header con nombre del paso
                _buildStepHeader(),
                const SizedBox(height: 16),
                
                // Indicador de pasos
                _buildStepIndicator(),
                const SizedBox(height: 24),
                
                // Contenido según el paso actual
                _buildStepContent(reservaController),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStepHeader() {
    return const Text(
      'Seleccionar Fechas',
      style: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: Color(0xFF1a1a1a),
        letterSpacing: -0.5,
      ),
    );
  }

  Widget _buildStepIndicator() {
    final steps = ['Fechas', 'Disponibilidades', 'Confirmación'];
    return Row(
      children: steps.asMap().entries.map((entry) {
        final index = entry.key;
        final stepName = entry.value;
        // Paso 1 (Fechas) siempre está activo en esta pantalla
        final isActive = index == 0;
        final isCompleted = false; // No hay pasos completados en esta pantalla
        
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
                            ? const Color(0xFF667eea)
                            : Colors.grey.shade300,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
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
                            ? const Color(0xFF667eea)
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
                  color: Colors.grey.shade300,
                ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildStepContent(ReservacionController controller) {
    // Siempre mostrar el paso de fechas en esta pantalla
    return _buildStepFechas(controller);
  }

  Widget _buildStepFechas(ReservacionController controller) {
    return Consumer<HotelController>(
      builder: (context, hotelController, _) {
        // Asegurar que se preseleccione el primer hotel si no hay uno seleccionado
        if (controller.hotelSeleccionado == null && hotelController.hotels.isNotEmpty) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted && controller.hotelSeleccionado == null) {
              controller.seleccionarHotel(hotelController.hotels.first);
            }
          });
        }

        // Cargar hoteles si no están cargados
        if (hotelController.hotels.isEmpty && !hotelController.isLoading) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            hotelController.fetchHotels();
          });
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Input de Hotel (tipo Label)
            _buildLabelInput(
              label: "Hotel",
              value: controller.hotelSeleccionado?.nombre ?? 
                     (hotelController.hotels.isNotEmpty 
                      ? hotelController.hotels.first.nombre 
                      : hotelController.isLoading ? "Cargando..." : "No seleccionado"),
              icon: Icons.hotel,
              onTap: () {
                // Mostrar diálogo o navegar a selección de hotel si es necesario
                // Por ahora solo muestra el hotel seleccionado
              },
            ),
            const SizedBox(height: 16),
            
            // Input de Fecha Inicio (tipo Label)
            _buildLabelInput(
              label: "Fecha Inicio",
              value: fechaInicio != null
                  ? "${fechaInicio!.day}/${fechaInicio!.month}/${fechaInicio!.year}"
                  : null,
              icon: Icons.calendar_today,
              onTap: () => _selectDate(true),
            ),
            const SizedBox(height: 16),
            
            // Input de Fecha Fin (tipo Label)
            _buildLabelInput(
              label: "Fecha Fin",
              value: fechaFin != null
                  ? "${fechaFin!.day}/${fechaFin!.month}/${fechaFin!.year}"
                  : null,
              icon: Icons.calendar_today,
              onTap: () => _selectDate(false),
            ),
            const SizedBox(height: 24),
            
            // Área de espera cuando no hay fechas
            if (fechaInicio == null || fechaFin == null)
              _buildWaitingForDates(),
            
            // Botón para ver tipos disponibles cuando hay fechas
            if (fechaInicio != null && fechaFin != null)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ReservasTiposDisponiblesScreen(
                          fechaInicio: fechaInicio!,
                          fechaFin: fechaFin!,
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF667eea),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    "Ver Tipos Disponibles",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildLabelInput({
    required String label,
    required String? value,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
          color: Colors.white,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Colors.grey.shade600, size: 20),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value ?? "Seleccionar",
              style: TextStyle(
                fontSize: 16,
                color: value != null ? Colors.black87 : Colors.grey.shade400,
                fontWeight: value != null ? FontWeight.w500 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWaitingForDates() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.calendar_today_outlined,
            size: 64,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            "Seleccionar fechas",
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Selecciona las fechas de inicio y fin para continuar",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _selectDate(bool isInicio) async {
    final picked = await showDatePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
      initialDate: isInicio 
          ? (fechaInicio ?? DateTime.now())
          : (fechaFin ?? fechaInicio ?? DateTime.now()),
    );
    
    if (picked != null) {
      setState(() {
        if (isInicio) {
          fechaInicio = picked;
        } else {
          fechaFin = picked;
        }
      });
      
      // Validar fechas después de seleccionar
      if (fechaInicio != null && fechaFin != null) {
        _tryLoadDisponibles();
      }
    }
  }

  void _tryLoadDisponibles() {
    if (fechaInicio == null || fechaFin == null) return;

    // VALIDACIÓN: fecha inicio < fecha fin
    if (fechaInicio!.isAfter(fechaFin!) ||
        fechaInicio!.isAtSameMomentAs(fechaFin!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("La fecha de inicio debe ser menor a la fecha de fin"),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );

      // Limpia habitaciones para evitar mostrar resultados inválidos
      Provider.of<ReservacionController>(
        context,
        listen: false,
      ).clearHabitaciones();
      return;
    }
    // La navegación ahora se hace desde el botón "Ver Tipos Disponibles"
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import './controllers/reservas_controller.dart';
import './reservas_tipo_detail_screen.dart';
import './models/tipo_habitacion_disponible_model.dart';
import './widgets/reservas_bottom_nav_bar.dart';

class ReservasTiposDisponiblesScreen extends StatefulWidget {
  final DateTime fechaInicio;
  final DateTime fechaFin;

  const ReservasTiposDisponiblesScreen({
    super.key,
    required this.fechaInicio,
    required this.fechaFin,
  });

  @override
  State<ReservasTiposDisponiblesScreen> createState() =>
      _ReservasTiposDisponiblesScreenState();
}

class _ReservasTiposDisponiblesScreenState
    extends State<ReservasTiposDisponiblesScreen> {
  bool _hasLoaded = false;

  @override
  void initState() {
    super.initState();
    _hasLoaded = false;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_hasLoaded) {
      _hasLoaded = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          final controller = Provider.of<ReservacionController>(context, listen: false);
          controller.fetchTiposHabitacionDisponibles(
            widget.fechaInicio.toIso8601String(),
            widget.fechaFin.toIso8601String(),
            idHotel: controller.hotelSeleccionado?.idHotel,
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final duracionDias = widget.fechaFin.difference(widget.fechaInicio).inDays;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Tipos de Habitación Disponibles"),
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      ),
      body: Column(
        children: [
          // Header y indicador de pasos
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header con nombre del paso
                const Text(
                  'Verificar Disponibilidades',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1a1a1a),
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 16),
                
                // Indicador de pasos
                _buildStepIndicator(),
              ],
            ),
          ),
          
            // Información de reservación elegante
            Consumer<ReservacionController>(
              builder: (context, reservaController, _) {
                return Container(
                  width: double.infinity,
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        const Color(0xFF667eea).withOpacity(0.15),
                        const Color(0xFF667eea).withOpacity(0.05),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color(0xFF667eea).withOpacity(0.2),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF667eea).withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Título de la sección
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: const Color(0xFF667eea).withOpacity(0.2),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(
                                Icons.info_outline,
                                color: Color(0xFF667eea),
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Text(
                              "Detalles de la reservación",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF1a1a1a),
                                letterSpacing: -0.3,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        
                        // Hotel seleccionado
                        if (reservaController.hotelSeleccionado != null) ...[
                          _buildDetailRow(
                            icon: Icons.hotel,
                            iconColor: const Color(0xFF667eea),
                            label: "Hotel",
                            value: reservaController.hotelSeleccionado!.nombre,
                            isLast: false,
                          ),
                        ],
                        
                        // Período de reservación
                        _buildDetailRow(
                          icon: Icons.calendar_today,
                          iconColor: Colors.orange[600]!,
                          label: "Período",
                          value: "${_formatDate(widget.fechaInicio)} - ${_formatDate(widget.fechaFin)}",
                          isLast: false,
                        ),
                        
                        // Cantidad de noches
                        _buildDetailRow(
                          icon: Icons.bedtime,
                          iconColor: Colors.purple[600]!,
                          label: "Estadía",
                          value: "$duracionDias ${duracionDias == 1 ? 'noche' : 'noches'}",
                          isLast: true,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          const SizedBox(height: 16),
          
          // Lista de tipos disponibles
          Expanded(
            child: Consumer<ReservacionController>(
              builder: (context, controller, _) {
                if (controller.isLoadingTiposDisponibles) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFF667eea),
                    ),
                  );
                }

                if (controller.tiposDisponiblesErrorMessage != null) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Text(
                            'Error: ${controller.tiposDisponiblesErrorMessage}',
                            style: const TextStyle(color: Colors.red),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            controller.fetchTiposHabitacionDisponibles(
                              widget.fechaInicio.toIso8601String(),
                              widget.fechaFin.toIso8601String(),
                            );
                          },
                          child: const Text('Reintentar'),
                        ),
                      ],
                    ),
                  );
                }

                if (controller.tiposDisponibles.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Text("No hay tipos de habitación disponibles"),
                    ),
                  );
                }

                return GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.7, // Aumentado de 0.65 a 0.7 para dar más espacio vertical
                  ),
                  itemCount: controller.tiposDisponibles.length,
                  itemBuilder: (context, index) {
                    final tipo = controller.tiposDisponibles[index];
                    return _buildTipoCard(tipo, duracionDias);
                  },
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: ReservasBottomNavBar(
        currentIndex: 1, // Generar Reservación está activo
        onTap: (index) {
          // Regresar a la pantalla principal primero
          Navigator.of(context).popUntil((route) {
            // Buscar la pantalla principal de reservas
            return route.settings.name == '/reservas' || route.isFirst;
          });
          
          // Si necesitamos cambiar de índice, esto se manejará en la pantalla principal
          // Por ahora solo regresamos
          if (index != 1) {
            // Si se necesita cambiar de pantalla, se puede hacer aquí
            // pero por ahora solo regresamos
          }
        },
      ),
    );
  }

  Widget _buildStepIndicator() {
    final steps = ['Fechas', 'Disponibilidades', 'Confirmación'];
    return Row(
      children: steps.asMap().entries.map((entry) {
        final index = entry.key;
        final stepName = entry.value;
        // Paso 2 (Disponibilidades) está activo en esta pantalla
        final isActive = index == 1;
        final isCompleted = index < 1; // Paso 1 (Fechas) está completado
        
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
                  color: isCompleted
                      ? const Color(0xFF667eea)
                      : Colors.grey.shade300,
                ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTipoCard(TipoHabitacionDisponible tipo, int duracionDias) {
    final controller = Provider.of<ReservacionController>(context, listen: false);
    final precioTotal = controller.calcularPrecioTotal(
      tipo.tipoHabitacion.precioUnitario,
      tipo.tipoHabitacion.periodicidadId,
      duracionDias,
    );

    // Usar primera imagen de galería o foto de perfil
    final imagenUrl = tipo.tipoHabitacion.galeriaTipoHabitacion?.isNotEmpty == true
        ? tipo.tipoHabitacion.galeriaTipoHabitacion!.first
        : tipo.tipoHabitacion.urlFotoPerfil;

    // Formatear precio con formato de moneda
    final precioFormateado = _formatCurrency(precioTotal);

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ReservasTipoDetailScreen(
                tipoHabitacionId: tipo.tipoHabitacion.idTipoHabitacion,
                fechaInicio: widget.fechaInicio,
                fechaFin: widget.fechaFin,
              ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Imagen con overlay
            Expanded(
              flex: 3,
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                    child: imagenUrl != null && imagenUrl.isNotEmpty
                        ? Image.network(
                            imagenUrl,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: Colors.grey[300],
                                child: const Icon(
                                  Icons.bed,
                                  size: 48,
                                  color: Color(0xFF667eea),
                                ),
                              );
                            },
                          )
                        : Container(
                            color: Colors.grey[300],
                            child: const Icon(
                              Icons.bed,
                              size: 48,
                              color: Color(0xFF667eea),
                            ),
                          ),
                  ),
                  // Badge de cantidad disponible
                  Positioned(
                    top: 6,
                    right: 6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.95),
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 3,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.hotel,
                            size: 12,
                            color: Colors.grey[700],
                          ),
                          const SizedBox(width: 3),
                          Text(
                            '${tipo.cantidadDisponible}',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[800],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Información
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Nombre del tipo
                    Flexible(
                      child: Text(
                        tipo.tipoHabitacion.tipoHabitacion,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1a1a1a),
                          letterSpacing: -0.2,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(height: 6),
                    
                    // Cantidad disponible
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.check_circle,
                          size: 12,
                          color: Colors.green[600],
                        ),
                        const SizedBox(width: 3),
                        Flexible(
                          child: Text(
                            "${tipo.cantidadDisponible} ${tipo.cantidadDisponible == 1 ? 'disponible' : 'disponibles'}",
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey[700],
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    
                    // Precio destacado
                    Flexible(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFF667eea).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Costo por $duracionDias ${duracionDias == 1 ? 'día' : 'días'}",
                              style: TextStyle(
                                fontSize: 9,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: Alignment.centerLeft,
                              child: Text(
                                precioFormateado,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF667eea),
                                  letterSpacing: -0.5,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatCurrency(double amount) {
    // Formatear con separadores de miles
    final parts = amount.toStringAsFixed(2).split('.');
    final integerPart = parts[0];
    final decimalPart = parts[1];
    
    String formatted = '';
    int count = 0;
    for (int i = integerPart.length - 1; i >= 0; i--) {
      if (count == 3) {
        formatted = ',' + formatted;
        count = 0;
      }
      formatted = integerPart[i] + formatted;
      count++;
    }
    
    return '\$$formatted.$decimalPart';
  }

  String _formatDate(DateTime date) {
    // Formatear fecha como "DD MMM" (ej: "15 Nov")
    final months = [
      'Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun',
      'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'
    ];
    return '${date.day} ${months[date.month - 1]}';
  }

  Widget _buildDetailRow({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
    required bool isLast,
  }) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icono con fondo
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: iconColor,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            // Información
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1a1a1a),
                      letterSpacing: -0.2,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        if (!isLast) ...[
          const SizedBox(height: 16),
          Divider(
            height: 1,
            thickness: 1,
            color: Colors.grey[200],
            indent: 52,
          ),
          const SizedBox(height: 16),
        ],
      ],
    );
  }
}


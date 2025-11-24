import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import './controllers/reservas_controller.dart';
import './reservas_confirmacion_screen.dart';
import './widgets/reservas_bottom_nav_bar.dart';
import './models/tipo_habitacion_model.dart';
import '../../../core/auth/services/session_storage.dart';
import '../clientes/models/cliente_model.dart';
import '../clientes/services/cliente_service.dart';

class ReservasTipoDetailScreen extends StatefulWidget {
  final int tipoHabitacionId;
  final DateTime fechaInicio;
  final DateTime fechaFin;

  const ReservasTipoDetailScreen({
    super.key,
    required this.tipoHabitacionId,
    required this.fechaInicio,
    required this.fechaFin,
  });

  @override
  State<ReservasTipoDetailScreen> createState() =>
      _ReservasTipoDetailScreenState();
}

class _ReservasTipoDetailScreenState extends State<ReservasTipoDetailScreen> {
  final PageController _pageController = PageController();
  Cliente? _clienteData;
  bool _isLoadingCliente = false;
  String? _clienteErrorMessage;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final controller = Provider.of<ReservacionController>(context, listen: false);
      controller.fetchTipoHabitacionDetail(widget.tipoHabitacionId);
      _loadClienteData();
    });
  }

  Future<void> _loadClienteData() async {
    try {
      setState(() {
        _isLoadingCliente = true;
        _clienteErrorMessage = null;
      });

      final session = await SessionStorage.getSession();
      if (session == null || session['usuario'] == null) {
        throw Exception('No hay sesión activa');
      }

      final usuario = session['usuario'] as Map<String, dynamic>;
      final clienteId = usuario['cliente_id'] as int?;
      
      if (clienteId == null) {
        throw Exception('No se encontró el ID del cliente en la sesión');
      }

      final clienteService = ClienteService();
      final response = await clienteService.fetchClienteDetail(clienteId);
      
      if (response.data == null) {
        throw Exception('No se recibieron datos del cliente');
      }

      final clienteJson = response.data as Map<String, dynamic>;
      setState(() {
        _clienteData = Cliente.fromJson(clienteJson);
        _isLoadingCliente = false;
      });
    } catch (e) {
      print("🔴 Error al cargar datos del cliente: $e");
      setState(() {
        _clienteErrorMessage = e.toString();
        _isLoadingCliente = false;
      });
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final duracionDias = widget.fechaFin.difference(widget.fechaInicio).inDays;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Detalle de Habitación"),
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
                  'Confirmar Reservación',
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
          
          // Contenido scrollable
          Expanded(
            child: Consumer<ReservacionController>(
        builder: (context, controller, _) {
          if (controller.isLoadingTipoDetail || controller.tipoHabitacionDetail == null) {
            return const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF667eea),
              ),
            );
          }

          if (controller.tipoDetailErrorMessage != null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: Colors.red,
                      size: 64,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Error al cargar detalles',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      controller.tipoDetailErrorMessage!,
                      style: const TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () {
                        controller.fetchTipoHabitacionDetail(widget.tipoHabitacionId);
                      },
                      child: const Text('Reintentar'),
                    ),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text('Volver'),
                    ),
                  ],
                ),
              ),
            );
          }

          // Validar que tipoHabitacionDetail no sea null antes de usar
          final tipo = controller.tipoHabitacionDetail;
          if (tipo == null) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    color: Color(0xFF667eea),
                  ),
                  SizedBox(height: 16),
                  Text('Cargando detalles...'),
                ],
              ),
            );
          }
          
          // Validar valores críticos
          if (tipo.precioUnitario.isNaN || tipo.precioUnitario.isInfinite) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: Colors.red,
                      size: 64,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Error: Precio inválido',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () {
                        controller.fetchTipoHabitacionDetail(widget.tipoHabitacionId);
                      },
                      child: const Text('Reintentar'),
                    ),
                  ],
                ),
              ),
            );
          }
          
          final precioTotal = controller.calcularPrecioTotal(
            tipo.precioUnitario,
            tipo.periodicidadId,
            duracionDias,
          );

          // Envolver el contenido en un try-catch para capturar errores de renderizado
          try {
            return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Galería de imágenes
                _buildGaleria(controller),
                const SizedBox(height: 20),
                
                // Nombre del tipo de habitación
                Text(
                  tipo.tipoHabitacion,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1a1a1a),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Clave: ${tipo.clave}",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 24),
                
                // Sección de Fechas y Duración
                _buildFechasSection(tipo, duracionDias),
                const SizedBox(height: 20),
                
                // Sección de Información del Hotel
                _buildHotelSection(controller),
                const SizedBox(height: 20),
                
                // Sección de Información del Cliente
                _buildClienteSection(),
                const SizedBox(height: 20),
                
                // Sección de Cálculo de Precio Total
                _buildPrecioTotalSection(tipo, duracionDias, precioTotal),
                const SizedBox(height: 32),
                
                // Botón de Confirmación
                _buildConfirmButton(precioTotal),
                const SizedBox(height: 16),
              ],
            ),
          );
          } catch (e, stackTrace) {
            print("🔴 [ReservasTipoDetail] Error al construir UI: $e");
            print("🔴 Stack trace: $stackTrace");
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: Colors.red,
                      size: 64,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Error al mostrar detalles',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      e.toString(),
                      style: const TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () {
                        controller.fetchTipoHabitacionDetail(widget.tipoHabitacionId);
                      },
                      child: const Text('Reintentar'),
                    ),
                  ],
                ),
              ),
            );
          }
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
            return route.settings.name == '/reservas' || route.isFirst;
          });
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
        // Paso 3 (Confirmación) está activo en esta pantalla
        final isActive = index == 2;
        final isCompleted = index < 2; // Pasos 1 y 2 están completados
        
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

  Widget _buildFechasSection(TipoHabitacion tipo, int duracionDias) {
    // Usar colores seguros sin el operador !
    final orange50 = Colors.orange.shade50;
    final orange25 = Colors.orange.shade50.withOpacity(0.5);
    final orange200 = Colors.orange.shade200;
    final orange100 = Colors.orange.shade100;
    final orange700 = Colors.orange.shade700;
    final orange600 = Colors.orange.shade600;
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            orange50,
            orange25,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: orange200,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: orange100,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.calendar_today,
                  color: orange700,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                "Fechas y Duración",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1a1a1a),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildDetailRow(
            icon: Icons.door_front_door,
            iconColor: orange600,
            label: "Fecha de entrada",
            value: _formatDateFull(widget.fechaInicio),
            isLast: false,
          ),
          _buildDetailRow(
            icon: Icons.exit_to_app,
            iconColor: orange600,
            label: "Fecha de salida",
            value: _formatDateFull(widget.fechaFin),
            isLast: false,
          ),
          _buildDetailRow(
            icon: Icons.bedtime,
            iconColor: orange600,
            label: "Cantidad de noches",
            value: "$duracionDias ${duracionDias == 1 ? 'noche' : 'noches'}",
            isLast: false,
          ),
          if (tipo.periodicidadId == 1)
            _buildDetailRow(
              icon: Icons.attach_money,
              iconColor: orange600,
              label: "Costo por noche",
              value: "\$${tipo.precioUnitario.toStringAsFixed(2)}",
              isLast: true,
            ),
        ],
      ),
    );
  }

  Widget _buildHotelSection(ReservacionController controller) {
    final hotel = controller.hotelSeleccionado;
    
    if (hotel == null) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF667eea).withOpacity(0.1),
            const Color(0xFF667eea).withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF667eea).withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF667eea).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.hotel,
                  color: Color(0xFF667eea),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                "Hotel",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1a1a1a),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildDetailRow(
            icon: Icons.business,
            iconColor: const Color(0xFF667eea),
            label: "Nombre",
            value: hotel.nombre,
            isLast: false,
          ),
          _buildDetailRow(
            icon: Icons.location_on,
            iconColor: const Color(0xFF667eea),
            label: "Dirección",
            value: hotel.direccion,
            isLast: hotel.numeroEstrellas == 0,
          ),
          if (hotel.numeroEstrellas > 0)
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Row(
                children: [
                  Icon(
                    Icons.star,
                    color: Colors.amber.shade600,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Categoría",
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: List.generate(
                            hotel.numeroEstrellas,
                            (index) => Icon(
                              Icons.star,
                              color: Colors.amber.shade600,
                              size: 18,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildClienteSection() {
    // Usar colores seguros sin el operador !
    final purple50 = Colors.purple.shade50;
    final purple25 = Colors.purple.shade50.withOpacity(0.5);
    final purple200 = Colors.purple.shade200;
    final purple100 = Colors.purple.shade100;
    final purple700 = Colors.purple.shade700;
    final purple600 = Colors.purple.shade600;

    if (_isLoadingCliente) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              purple50,
              purple25,
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: purple200,
            width: 1,
          ),
        ),
        child: const Center(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: CircularProgressIndicator(
              color: Color(0xFF667eea),
            ),
          ),
        ),
      );
    }

    if (_clienteErrorMessage != null || _clienteData == null) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              purple50,
              purple25,
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: purple200,
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: purple100,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.person,
                    color: purple700,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  "Cliente",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1a1a1a),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              _clienteErrorMessage ?? 'No se pudieron cargar los datos del cliente',
              style: const TextStyle(color: Colors.red),
            ),
          ],
        ),
      );
    }

    final cliente = _clienteData!;
    final nombreCompleto = cliente.nombreCompleto;
    final rfc = cliente.rfc.isNotEmpty ? cliente.rfc : null;
    final documentoIdentificacion = cliente.documentoIdentificacion;
    final email = cliente.correoElectronico;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            purple50,
            purple25,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: purple200,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: purple100,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.person,
                  color: purple700,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                "Cliente",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1a1a1a),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildDetailRow(
            icon: Icons.badge,
            iconColor: purple600,
            label: "Nombre completo",
            value: nombreCompleto.isNotEmpty ? nombreCompleto : 'No disponible',
            isLast: rfc == null && documentoIdentificacion == null && email == null,
          ),
          if (rfc != null)
            _buildDetailRow(
              icon: Icons.description,
              iconColor: purple600,
              label: "RFC",
              value: rfc,
              isLast: documentoIdentificacion == null && email == null,
            ),
          if (documentoIdentificacion != null && documentoIdentificacion.isNotEmpty)
            _buildDetailRow(
              icon: Icons.credit_card,
              iconColor: purple600,
              label: "Identificación",
              value: documentoIdentificacion,
              isLast: email == null,
            ),
          if (email != null)
            _buildDetailRow(
              icon: Icons.email,
              iconColor: purple600,
              label: "Correo electrónico",
              value: email,
              isLast: true,
            ),
        ],
      ),
    );
  }

  Widget _buildPrecioTotalSection(TipoHabitacion tipo, int duracionDias, double precioTotal) {
    final precioFormateado = _formatCurrency(precioTotal);
    final precioUnitarioFormateado = _formatCurrency(tipo.precioUnitario);
    final subtotal = tipo.periodicidadId == 1 
        ? tipo.precioUnitario * duracionDias 
        : tipo.precioUnitario;
    final subtotalFormateado = _formatCurrency(subtotal);

    // Usar colores seguros sin el operador !
    final green50 = Colors.green.shade50;
    final green25 = Colors.green.shade50.withOpacity(0.5);
    final green200 = Colors.green.shade200;
    final green100 = Colors.green.shade100;
    final green700 = Colors.green.shade700;
    final green300 = Colors.green.shade300;
    final green900 = Colors.green.shade900;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            green50,
            green25,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: green200,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: green100,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: green100,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.receipt_long,
                  color: green700,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                "Resumen de Precio",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1a1a1a),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (tipo.periodicidadId == 1) ...[
            _buildPriceRow(
              "Precio por noche",
              precioUnitarioFormateado,
              isTotal: false,
            ),
            _buildPriceRow(
              "Cantidad de noches",
              "$duracionDias",
              isTotal: false,
            ),
            _buildPriceRow(
              "Subtotal",
              subtotalFormateado,
              isTotal: false,
            ),
            const SizedBox(height: 12),
            Divider(
              height: 1,
              thickness: 2,
              color: green300,
            ),
            const SizedBox(height: 12),
          ],
          _buildPriceRow(
            "TOTAL",
            precioFormateado,
            isTotal: true,
            green900: green900,
            green700: green700,
          ),
        ],
      ),
    );
  }

  Widget _buildPriceRow(String label, String value, {required bool isTotal, Color? green900, Color? green700}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isTotal ? 18 : 14,
              fontWeight: isTotal ? FontWeight.w800 : FontWeight.w600,
              color: isTotal ? (green900 ?? Colors.green.shade900) : Colors.grey.shade700,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: isTotal ? 24 : 16,
              fontWeight: FontWeight.w800,
              color: isTotal ? (green700 ?? Colors.green.shade700) : Colors.grey.shade800,
              letterSpacing: -0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConfirmButton(double precioTotal) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () {
          // Validar todos los valores antes de navegar
          try {
            print("🔵 [ReservasTipoDetail] Navegando a Confirmación");
            print("  - tipoHabitacionId: ${widget.tipoHabitacionId}");
            print("  - fechaInicio: ${widget.fechaInicio}");
            print("  - fechaFin: ${widget.fechaFin}");
            print("  - precioTotal: $precioTotal");
            
            if (widget.tipoHabitacionId == 0) {
              throw Exception("tipoHabitacionId inválido: ${widget.tipoHabitacionId}");
            }
            
            if (precioTotal.isNaN || precioTotal.isInfinite) {
              throw Exception("precioTotal inválido: $precioTotal");
            }
            
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ReservasConfirmacionScreen(
                  tipoHabitacionId: widget.tipoHabitacionId,
                  fechaInicio: widget.fechaInicio,
                  fechaFin: widget.fechaFin,
                  precioTotal: precioTotal,
                ),
              ),
            );
          } catch (e, stackTrace) {
            print("🔴 Error al navegar a Confirmación: $e");
            print("🔴 Stack trace: $stackTrace");
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("Error: ${e.toString()}"),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        icon: const Icon(
          Icons.check_circle,
          size: 24,
        ),
        label: const Text(
          "Confirmar Reservación",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF667eea),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 4,
          shadowColor: const Color(0xFF667eea).withOpacity(0.4),
        ),
      ),
    );
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

  String _formatDateFull(DateTime date) {
    final months = [
      'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
      'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'
    ];
    return '${date.day} de ${months[date.month - 1]} de ${date.year}';
  }

  String _formatCurrency(double amount) {
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

  Widget _buildGaleria(ReservacionController controller) {
    final tipo = controller.tipoHabitacionDetail;
    
    // Validar que tipo no sea null
    if (tipo == null) {
      return Container(
        height: 250,
        color: Colors.grey[300],
        child: const Center(
          child: Icon(
            Icons.bed,
            size: 64,
            color: Color(0xFF667eea),
          ),
        ),
      );
    }
    
    // Usar galería del tipo si está disponible
    final imagenes = tipo.galeriaTipoHabitacion ?? [];

    if (imagenes.isEmpty && (tipo.urlFotoPerfil == null || tipo.urlFotoPerfil!.isEmpty)) {
      return Container(
        height: 250,
        color: Colors.grey[300],
        child: const Center(
          child: Icon(
            Icons.bed,
            size: 64,
            color: Color(0xFF667eea),
          ),
        ),
      );
    }

    final todasLasImagenes = <String>[];
    // Agregar foto de perfil si existe y no está vacía
    if (tipo.urlFotoPerfil != null && tipo.urlFotoPerfil!.isNotEmpty) {
      todasLasImagenes.add(tipo.urlFotoPerfil!);
    }
    // Agregar imágenes de la galería que no estén vacías
    todasLasImagenes.addAll(imagenes.where((url) => url.isNotEmpty));

    if (todasLasImagenes.isEmpty) {
      return Container(
        height: 250,
        color: Colors.grey[300],
        child: const Center(
          child: Icon(
            Icons.bed,
            size: 64,
            color: Color(0xFF667eea),
          ),
        ),
      );
    }

    return SizedBox(
      height: 300,
      child: PageView.builder(
        controller: _pageController,
        itemCount: todasLasImagenes.length,
        itemBuilder: (context, index) {
          return Image.network(
            todasLasImagenes[index],
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                color: Colors.grey[300],
                child: const Icon(
                  Icons.bed,
                  size: 64,
                  color: Color(0xFF667eea),
                ),
              );
            },
          );
        },
      ),
    );
  }

}


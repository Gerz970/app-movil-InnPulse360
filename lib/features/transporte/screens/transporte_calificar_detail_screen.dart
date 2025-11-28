import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../controllers/transporte_controller.dart';
import '../models/servicio_transporte_model.dart';

class TransporteCalificarDetailScreen extends StatefulWidget {
  final ServicioTransporteModel servicio;

  const TransporteCalificarDetailScreen({super.key, required this.servicio});

  @override
  State<TransporteCalificarDetailScreen> createState() => _TransporteCalificarDetailScreenState();
}

class _TransporteCalificarDetailScreenState extends State<TransporteCalificarDetailScreen> {
  int _calificacionSeleccionada = 0;
  final _comentarioController = TextEditingController();
  bool _isCalificando = false;

  @override
  void dispose() {
    _comentarioController.dispose();
    super.dispose();
  }

  void _calificarViaje() async {
    if (_calificacionSeleccionada == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor selecciona una calificación')),
      );
      return;
    }

    setState(() {
      _isCalificando = true;
    });

    final controller = Provider.of<TransporteController>(context, listen: false);
    final exito = await controller.calificarViaje(
      widget.servicio.idServicioTransporte!,
      _calificacionSeleccionada,
      _comentarioController.text.trim().isEmpty ? null : _comentarioController.text.trim(),
    );

    if (mounted) {
      setState(() {
        _isCalificando = false;
      });

      if (exito) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Viaje calificado correctamente'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true); // Regresar indicando que se calificó
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${controller.error ?? "Error desconocido"}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildEstrellasCalificacion() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) {
        final estrellaNum = index + 1;
        final estaSeleccionada = estrellaNum <= _calificacionSeleccionada;
        
        return IconButton(
          onPressed: () {
            setState(() {
              _calificacionSeleccionada = estrellaNum;
            });
          },
          icon: Icon(
            estaSeleccionada ? Icons.star : Icons.star_border,
            color: estaSeleccionada ? Colors.amber : Colors.grey,
            size: 48,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 4),
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tieneOrigen = widget.servicio.latitudOrigen != null && widget.servicio.longitudOrigen != null;
    final tieneDestino = widget.servicio.latitudDestino != null && widget.servicio.longitudDestino != null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Calificar Viaje'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Mapa
          if (tieneOrigen || tieneDestino)
            SizedBox(
              height: 250,
              child: FlutterMap(
                options: MapOptions(
                  initialCenter: tieneOrigen 
                    ? LatLng(widget.servicio.latitudOrigen!, widget.servicio.longitudOrigen!)
                    : (tieneDestino 
                        ? LatLng(widget.servicio.latitudDestino!, widget.servicio.longitudDestino!)
                        : const LatLng(0, 0)),
                  initialZoom: 13,
                ),
                children: [
                  TileLayer(
                    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.innpulse.app',
                  ),
                  MarkerLayer(
                    markers: [
                      if (tieneOrigen)
                        Marker(
                          point: LatLng(widget.servicio.latitudOrigen!, widget.servicio.longitudOrigen!),
                          width: 40,
                          height: 40,
                          child: const Icon(Icons.location_on, color: Colors.green, size: 40),
                        ),
                      if (tieneDestino)
                        Marker(
                          point: LatLng(widget.servicio.latitudDestino!, widget.servicio.longitudDestino!),
                          width: 40,
                          height: 40,
                          child: const Icon(Icons.location_on, color: Colors.red, size: 40),
                        ),
                    ],
                  ),
                  if (tieneOrigen && tieneDestino)
                    PolylineLayer(
                      polylines: [
                        Polyline(
                          points: [
                            LatLng(widget.servicio.latitudOrigen!, widget.servicio.longitudOrigen!),
                            LatLng(widget.servicio.latitudDestino!, widget.servicio.longitudDestino!),
                          ],
                          color: Colors.blue,
                          strokeWidth: 4.0,
                        ),
                      ],
                    ),
                ],
              ),
            ),
          
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Información del viaje
                  _buildInfoRow(Icons.calendar_today, 'Fecha', widget.servicio.fechaServicio.toString().split(' ')[0]),
                  _buildInfoRow(Icons.access_time, 'Hora', widget.servicio.horaServicio),
                  const Divider(),
                  _buildInfoRow(Icons.my_location, 'Origen', 
                    widget.servicio.direccionOrigen ?? 'Coordenadas: ${widget.servicio.latitudOrigen ?? "?"}, ${widget.servicio.longitudOrigen ?? "?"}'),
                  _buildInfoRow(Icons.place, 'Destino', widget.servicio.destino),
                  const Divider(),
                  if (widget.servicio.distanciaKm != null)
                    _buildInfoRow(Icons.directions_car, 'Distancia', '${widget.servicio.distanciaKm!.toStringAsFixed(1)} km'),
                  _buildInfoRow(Icons.attach_money, 'Costo', '\$${widget.servicio.costoViaje.toStringAsFixed(2)}'),
                  
                  const SizedBox(height: 24),
                  const Divider(),
                  const SizedBox(height: 24),
                  
                  // Sección de calificación
                  const Text(
                    'Califica tu viaje',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1a1a1a),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Selecciona de 1 a 5 estrellas',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Estrellas de calificación
                  _buildEstrellasCalificacion(),
                  
                  if (_calificacionSeleccionada > 0) ...[
                    const SizedBox(height: 8),
                    Center(
                      child: Text(
                        '${_calificacionSeleccionada} ${_calificacionSeleccionada == 1 ? 'estrella' : 'estrellas'}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.amber[700],
                        ),
                      ),
                    ),
                  ],
                  
                  const SizedBox(height: 32),
                  
                  // Campo de comentarios opcional
                  TextField(
                    controller: _comentarioController,
                    decoration: InputDecoration(
                      labelText: 'Comentarios (opcional)',
                      hintText: 'Comparte tu experiencia...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: const Icon(Icons.comment_outlined),
                    ),
                    maxLines: 4,
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Botón de calificar
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isCalificando ? null : _calificarViaje,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF667eea),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isCalificando
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.star, size: 20),
                                SizedBox(width: 8),
                                Text(
                                  'Calificar Viaje',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
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
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.grey.shade600, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


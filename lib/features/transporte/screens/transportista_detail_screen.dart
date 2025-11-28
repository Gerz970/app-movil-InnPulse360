import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../controllers/transporte_controller.dart';
import '../models/servicio_transporte_model.dart';

class TransportistaDetailScreen extends StatefulWidget {
  final ServicioTransporteModel servicio;

  const TransportistaDetailScreen({super.key, required this.servicio});

  @override
  State<TransportistaDetailScreen> createState() => _TransportistaDetailScreenState();
}

class _TransportistaDetailScreenState extends State<TransportistaDetailScreen> {
  final _comentarioController = TextEditingController();
  final MapController _mapController = MapController();
  late ServicioTransporteModel _servicio;

  @override
  void initState() {
    super.initState();
    _servicio = widget.servicio;
  }

  Color _getStatusColor(int? status) {
    switch (status) {
      case 1: return Colors.orange;
      case 2: return Colors.blue;
      case 4: return Colors.green;
      case 3: return Colors.grey;
      case 0: return Colors.red;
      default: return Colors.grey;
    }
  }

  String _getStatusText(int? status) {
    switch (status) {
      case 1: return "Pendiente";
      case 2: return "Aceptado";
      case 4: return "En curso";
      case 3: return "Terminado";
      case 0: return "Cancelado";
      default: return "Desconocido";
    }
  }

  void _mostrarDialogoComentario(String accion, Function(String) onConfirm) {
    _comentarioController.clear();
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => AlertDialog(
        title: Text('$accion Viaje'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Puedes agregar un comentario opcional sobre el viaje.'),
            const SizedBox(height: 16),
            TextField(
              controller: _comentarioController,
              decoration: const InputDecoration(
                labelText: 'Comentario (opcional)',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              onConfirm(_comentarioController.text.trim());
            },
            child: Text(accion),
          ),
        ],
      ),
    );
  }

  void _iniciarViaje() {
    _mostrarDialogoComentario('Iniciar', (comentario) async {
      final controller = Provider.of<TransporteController>(context, listen: false);
      final exito = await controller.iniciarViaje(_servicio.idServicioTransporte!, comentario);
      
      if (mounted) {
        if (exito) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Viaje iniciado correctamente')),
          );
          // Recargar el detalle del servicio para reflejar el cambio
          final servicioActualizado = await controller.obtenerDetalleServicio(_servicio.idServicioTransporte!);
          if (servicioActualizado != null && mounted) {
            setState(() {
              _servicio = servicioActualizado;
            });
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${controller.error ?? "Error desconocido"}')),
          );
        }
      }
    });
  }

  void _terminarViaje() {
    _mostrarDialogoComentario('Terminar', (comentario) async {
      final controller = Provider.of<TransporteController>(context, listen: false);
      final exito = await controller.terminarViaje(_servicio.idServicioTransporte!, comentario);
      
      if (mounted) {
        if (exito) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Viaje terminado correctamente')),
          );
          // Recargar el detalle del servicio para reflejar el cambio
          final servicioActualizado = await controller.obtenerDetalleServicio(_servicio.idServicioTransporte!);
          if (servicioActualizado != null && mounted) {
            setState(() {
              _servicio = servicioActualizado;
            });
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${controller.error ?? "Error desconocido"}')),
          );
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Coordenadas por defecto (CDMX) si no hay datos
    final latOrigen = _servicio.latitudOrigen?.toDouble() ?? 19.4326;
    final lngOrigen = _servicio.longitudOrigen?.toDouble() ?? -99.1332;
    final latDestino = _servicio.latitudDestino?.toDouble();
    final lngDestino = _servicio.longitudDestino?.toDouble();

    final tieneDestino = latDestino != null && lngDestino != null;
    final center = LatLng(latOrigen, lngOrigen);

    return Scaffold(
      appBar: AppBar(
        title: Text('Servicio #${_servicio.idServicioTransporte}'),
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _getStatusText(_servicio.idEstatus),
                  style: TextStyle(
                    color: _getStatusColor(_servicio.idEstatus),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          )
        ],
      ),
      body: Column(
        children: [
          // Mapa (Solo lectura)
          Expanded(
            flex: 5,
            child: FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: center,
                initialZoom: 13,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.innpulse.app',
                ),
                MarkerLayer(
                  markers: [
                    // Origen
                    Marker(
                      point: LatLng(latOrigen, lngOrigen),
                      width: 60,
                      height: 60,
                      child: const Icon(Icons.location_on, color: Colors.green, size: 40),
                    ),
                    // Destino
                    if (tieneDestino)
                      Marker(
                        point: LatLng(latDestino, lngDestino),
                        width: 60,
                        height: 60,
                        child: const Icon(Icons.location_on, color: Colors.red, size: 40),
                      ),
                  ],
                ),
                if (tieneDestino)
                  PolylineLayer(
                    polylines: [
                      Polyline(
                        points: [LatLng(latOrigen, lngOrigen), LatLng(latDestino, lngDestino)],
                        color: Colors.blue,
                        strokeWidth: 4.0,
                      ),
                    ],
                  ),
              ],
            ),
          ),
          
          // Detalles
          Expanded(
            flex: 4,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Colors.white,
                boxShadow: [BoxShadow(blurRadius: 5, color: Colors.black12, offset: Offset(0, -2))],
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInfoRow(Icons.calendar_today, 'Fecha', _servicio.fechaServicio.toIso8601String().split('T')[0]),
                    const SizedBox(height: 12),
                    _buildInfoRow(Icons.access_time, 'Hora', _servicio.horaServicio),
                    const SizedBox(height: 12),
                    _buildInfoRow(Icons.map, 'Origen', _servicio.direccionOrigen ?? "N/A"),
                    const SizedBox(height: 12),
                    _buildInfoRow(Icons.flag, 'Destino', _servicio.destino), // Destino es string en el modelo base
                    if (_servicio.observacionesCliente != null) ...[
                       const SizedBox(height: 12),
                       const Text('Observaciones Cliente:', style: TextStyle(fontWeight: FontWeight.bold)),
                       Text(_servicio.observacionesCliente!),
                    ],
                    const SizedBox(height: 24),
                    
                    // Acciones
                    if (_servicio.idEstatus == 1 || _servicio.idEstatus == 2)
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _iniciarViaje,
                          icon: const Icon(Icons.play_arrow),
                          label: const Text('INICIAR VIAJE'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                      
                    if (_servicio.idEstatus == 4)
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _terminarViaje,
                          icon: const Icon(Icons.stop),
                          label: const Text('TERMINAR VIAJE'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Colors.grey),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
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
    );
  }
}


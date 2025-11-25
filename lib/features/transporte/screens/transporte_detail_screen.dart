import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../models/servicio_transporte_model.dart';

class TransporteDetailScreen extends StatelessWidget {
  final ServicioTransporteModel servicio;

  const TransporteDetailScreen({super.key, required this.servicio});

  @override
  Widget build(BuildContext context) {
    final tieneOrigen = servicio.latitudOrigen != null && servicio.longitudOrigen != null;
    final tieneDestino = servicio.latitudDestino != null && servicio.longitudDestino != null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle del Viaje'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Mapa
          if (tieneOrigen || tieneDestino)
            SizedBox(
              height: 300,
              child: FlutterMap(
                options: MapOptions(
                  initialCenter: tieneOrigen 
                    ? LatLng(servicio.latitudOrigen!, servicio.longitudOrigen!)
                    : (tieneDestino 
                        ? LatLng(servicio.latitudDestino!, servicio.longitudDestino!)
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
                          point: LatLng(servicio.latitudOrigen!, servicio.longitudOrigen!),
                          width: 40,
                          height: 40,
                          child: const Icon(Icons.location_on, color: Colors.green, size: 40),
                        ),
                      if (tieneDestino)
                        Marker(
                          point: LatLng(servicio.latitudDestino!, servicio.longitudDestino!),
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
                            LatLng(servicio.latitudOrigen!, servicio.longitudOrigen!),
                            LatLng(servicio.latitudDestino!, servicio.longitudDestino!),
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
                  _buildInfoRow(Icons.calendar_today, 'Fecha', servicio.fechaServicio.toString().split(' ')[0]),
                  _buildInfoRow(Icons.access_time, 'Hora', servicio.horaServicio),
                  const Divider(),
                  _buildInfoRow(Icons.my_location, 'Origen', 
                    servicio.direccionOrigen ?? 'Coordenadas: ${servicio.latitudOrigen ?? "?"}, ${servicio.longitudOrigen ?? "?"}'),
                  _buildInfoRow(Icons.place, 'Destino', 
                    servicio.destino),
                  const Divider(),
                  if (servicio.distanciaKm != null)
                    _buildInfoRow(Icons.directions_car, 'Distancia', '${servicio.distanciaKm} km'),
                  _buildInfoRow(Icons.attach_money, 'Costo', '\$${servicio.costoViaje.toStringAsFixed(2)}'),
                  const Divider(),
                  if (servicio.observacionesCliente != null && servicio.observacionesCliente!.isNotEmpty) ...[
                    const Text('Observaciones:', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(servicio.observacionesCliente!),
                  ],
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
        children: [
          Icon(icon, color: Colors.grey.shade600, size: 20),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
              Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
            ],
          ),
        ],
      ),
    );
  }
}


import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import '../controllers/transporte_controller.dart';
import '../models/servicio_transporte_model.dart';

class TransporteCreateScreen extends StatefulWidget {
  const TransporteCreateScreen({super.key});

  @override
  State<TransporteCreateScreen> createState() => _TransporteCreateScreenState();
}

class _TransporteCreateScreenState extends State<TransporteCreateScreen> {
  final _observacionesController = TextEditingController();
  final MapController _mapController = MapController();
  
  LatLng? _ubicacionOrigen;
  LatLng? _ubicacionDestino;
  LatLng? _miUbicacionActual;
  double? _distanciaKm;
  bool _cargandoUbicacion = true;

  @override
  void initState() {
    super.initState();
    _inicializarUbicacion();
  }

  Future<void> _inicializarUbicacion() async {
    // Obtener ubicación actual al iniciar
    final controller = Provider.of<TransporteController>(context, listen: false);
    final pos = await controller.obtenerUbicacionActual();
    
    if (mounted && pos != null && pos is Position) {
      setState(() {
        _miUbicacionActual = LatLng(pos.latitude, pos.longitude);
        // Por defecto, el origen es la ubicación actual
        _ubicacionOrigen = _miUbicacionActual;
        _cargandoUbicacion = false;
      });
    } else {
       if (mounted) setState(() => _cargandoUbicacion = false);
    }
  }

  void _onMapTap(TapPosition tapPosition, LatLng point) {
    setState(() {
      // Si ya tengo origen, el tap define el destino
      _ubicacionDestino = point;
      _calcularDistancia();
    });
  }

  void _calcularDistancia() {
    if (_ubicacionOrigen != null && _ubicacionDestino != null) {
      final distanciaMetros = Geolocator.distanceBetween(
        _ubicacionOrigen!.latitude,
        _ubicacionOrigen!.longitude,
        _ubicacionDestino!.latitude,
        _ubicacionDestino!.longitude,
      );
      _distanciaKm = distanciaMetros / 1000;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Centro inicial: ubicación actual o CDMX por defecto
    final initialCenter = _miUbicacionActual ?? const LatLng(19.4326, -99.1332);

    return Scaffold(
      body: Stack(
        children: [
          // 1. Mapa (Ocupa toda la pantalla detrás del panel)
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: initialCenter,
              initialZoom: 15,
              onTap: _onMapTap,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.innpulse.app',
              ),
              
              // Línea de ruta
              if (_ubicacionOrigen != null && _ubicacionDestino != null)
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: [_ubicacionOrigen!, _ubicacionDestino!],
                      color: Colors.blue,
                      strokeWidth: 4.0,
                      borderColor: Colors.blue.shade800,
                      borderStrokeWidth: 1.0,
                    ),
                  ],
                ),

              // Marcadores
              MarkerLayer(
                markers: [
                  // Origen (Mi ubicación)
                  if (_ubicacionOrigen != null)
                    Marker(
                      point: _ubicacionOrigen!,
                      width: 60,
                      height: 60,
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(4),
                              boxShadow: [BoxShadow(blurRadius: 2, color: Colors.black26)],
                            ),
                            child: const Text('Origen', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                          ),
                          const Icon(Icons.location_on, color: Colors.green, size: 40),
                        ],
                      ),
                    ),
                  
                  // Destino
                  if (_ubicacionDestino != null)
                    Marker(
                      point: _ubicacionDestino!,
                      width: 60,
                      height: 60,
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(4),
                              boxShadow: [BoxShadow(blurRadius: 2, color: Colors.black26)],
                            ),
                            child: const Text('Destino', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                          ),
                          const Icon(Icons.location_on, color: Colors.red, size: 40),
                        ],
                      ),
                    ),
                ],
              ),
            ],
          ),

          // Botón para centrar en mi ubicación
          Positioned(
            top: 40,
            right: 16,
            child: FloatingActionButton.small(
              heroTag: 'btn_center_location',
              backgroundColor: Colors.white,
              child: const Icon(Icons.my_location, color: Colors.black87),
              onPressed: () {
                if (_miUbicacionActual != null) {
                  _mapController.move(_miUbicacionActual!, 15);
                } else {
                  _inicializarUbicacion();
                }
              },
            ),
          ),

          // Indicador de carga inicial
          if (_cargandoUbicacion)
            const Center(
              child: Card(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text('Obteniendo ubicación...'),
                    ],
                  ),
                ),
              ),
            ),

          // Instrucción flotante si no hay destino
          if (!_cargandoUbicacion && _ubicacionDestino == null)
            Positioned(
              top: 100,
              left: 16,
              right: 16,
              child: Card(
                color: Colors.white.withOpacity(0.9),
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    children: const [
                      Icon(Icons.touch_app, color: Colors.blue),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Toca en el mapa para seleccionar tu destino',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // 2. Panel Inferior (Información y Confirmación)
          if (_ubicacionDestino != null)
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Detalles del Viaje', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    
                    // Origen
                    Row(
                      children: [
                        const Icon(Icons.circle, color: Colors.green, size: 12),
                        const SizedBox(width: 8),
                        const Text('Origen: ', style: TextStyle(color: Colors.grey)),
                        Expanded(
                          child: Text(
                            _formatearCoordenadas(_ubicacionOrigen),
                            style: const TextStyle(fontWeight: FontWeight.w500),
                            maxLines: 1, overflow: TextOverflow.ellipsis
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    
                    // Destino
                    Row(
                      children: [
                        const Icon(Icons.circle, color: Colors.red, size: 12),
                        const SizedBox(width: 8),
                        const Text('Destino: ', style: TextStyle(color: Colors.grey)),
                        Expanded(
                          child: Text(
                            _formatearCoordenadas(_ubicacionDestino),
                            style: const TextStyle(fontWeight: FontWeight.w500),
                            maxLines: 1, overflow: TextOverflow.ellipsis
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 24),
                    
                    // Distancia y Costo Estimado
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Distancia', style: TextStyle(fontSize: 12, color: Colors.grey)),
                            Text('${_distanciaKm?.toStringAsFixed(2) ?? "0.0"} km', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            const Text('Costo Estimado', style: TextStyle(fontSize: 12, color: Colors.grey)),
                            Text('\$${((_distanciaKm ?? 0) * 15.0).toStringAsFixed(2)}', 
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF667eea))
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    // Campo Observaciones
                    TextField(
                      controller: _observacionesController,
                      decoration: InputDecoration(
                        hintText: 'Observaciones para el conductor...',
                        filled: true,
                        fillColor: Colors.grey.shade100,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      ),
                      maxLines: 2,
                      minLines: 1,
                    ),
                    const SizedBox(height: 16),
                    
                    // Botón Solicitar
                    SizedBox(
                      width: double.infinity,
                      child: Consumer<TransporteController>(
                        builder: (context, controller, _) {
                          return ElevatedButton(
                            onPressed: controller.isLoading ? null : () => _solicitarViaje(controller),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF667eea),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child: Text(
                              controller.isLoading ? 'Procesando...' : 'Confirmar Solicitud',
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                          );
                        },
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

  String _formatearCoordenadas(LatLng? pos) {
    if (pos == null) return "Seleccionar...";
    return "${pos.latitude.toStringAsFixed(5)}, ${pos.longitude.toStringAsFixed(5)}";
  }

  void _solicitarViaje(TransporteController controller) async {
    if (_ubicacionOrigen == null || _ubicacionDestino == null) return;

    final nuevoServicio = ServicioTransporteModel(
      destino: "Destino seleccionado en mapa",
      fechaServicio: DateTime.now(),
      horaServicio: "${DateTime.now().hour.toString().padLeft(2, '0')}:${DateTime.now().minute.toString().padLeft(2, '0')}",
      empleadoId: 1,
      costoViaje: double.parse(((_distanciaKm ?? 0) * 15.0).toStringAsFixed(2)),
      observacionesCliente: _observacionesController.text,
      latitudOrigen: _ubicacionOrigen!.latitude,
      longitudOrigen: _ubicacionOrigen!.longitude,
      latitudDestino: _ubicacionDestino!.latitude,
      longitudDestino: _ubicacionDestino!.longitude,
      direccionOrigen: _formatearCoordenadas(_ubicacionOrigen),
      direccionDestino: _formatearCoordenadas(_ubicacionDestino),
      distanciaKm: double.parse((_distanciaKm ?? 0).toStringAsFixed(2)),
    );

    final exito = await controller.crearServicio(nuevoServicio);

    if (mounted) {
      if (exito) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Viaje solicitado exitosamente')),
        );
        // Limpiar estado
        setState(() {
          _ubicacionDestino = null;
          _distanciaKm = null;
          _observacionesController.clear();
        });
        
        // Opcional: Navegar a la pestaña de "Solicitados" (index 0)
        // Esto requeriría acceso al estado de TransporteMainScreen o un bus de eventos
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${controller.error}')),
        );
      }
    }
  }
}

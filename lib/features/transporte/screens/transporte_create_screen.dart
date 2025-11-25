import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import '../../../core/services/geolocalizacion_service.dart';
import '../controllers/transporte_controller.dart';
import '../models/servicio_transporte_model.dart';

class TransporteCreateScreen extends StatefulWidget {
  final int? reservacionId; // Nuevo parámetro opcional
  
  const TransporteCreateScreen({
    super.key,
    this.reservacionId, // Opcional
  });

  @override
  State<TransporteCreateScreen> createState() => _TransporteCreateScreenState();
}

class _TransporteCreateScreenState extends State<TransporteCreateScreen> {
  final _observacionesController = TextEditingController();
  final MapController _mapController = MapController();
  final GeolocalizacionService _geoService = GeolocalizacionService();
  
  LatLng? _ubicacionOrigen;
  LatLng? _ubicacionDestino;
  LatLng? _miUbicacionActual;
  double? _distanciaKm;
  bool _cargandoUbicacion = true;
  
  // Direcciones legibles
  String? _direccionOrigenTexto;
  String? _direccionDestinoTexto;
  bool _cargandoDireccionOrigen = false;
  bool _cargandoDireccionDestino = false;

  @override
  void initState() {
    super.initState();
    _inicializarUbicacion();
  }

  Future<void> _inicializarUbicacion() async {
    try {
      // Obtener ubicación actual al iniciar con timeout
      final controller = Provider.of<TransporteController>(context, listen: false);
      
      // Intentar obtener ubicación con timeout de 15 segundos
      dynamic pos;
      try {
        pos = await controller.obtenerUbicacionActual()
            .timeout(const Duration(seconds: 15));
      } catch (e) {
        print('⚠️ Timeout o error al obtener ubicación: $e');
        pos = null;
      }
      
      if (mounted && pos != null && pos is Position) {
        final ubicacion = LatLng(pos.latitude, pos.longitude);
        setState(() {
          _miUbicacionActual = ubicacion;
          _ubicacionOrigen = ubicacion;
          _cargandoUbicacion = false;
          _cargandoDireccionOrigen = true;
        });
        
        // Obtener dirección del origen
        try {
          print('📍 Iniciando obtención de dirección para origen: ${pos.latitude}, ${pos.longitude}');
          final direccion = await _geoService.obtenerDireccionDesdeCoordenadas(
            pos.latitude,
            pos.longitude,
          ).timeout(const Duration(seconds: 10), onTimeout: () {
            return "${pos.latitude.toStringAsFixed(5)}, ${pos.longitude.toStringAsFixed(5)}";
          });
          
          print('✅ Dirección obtenida para origen: $direccion');
          
          if (mounted) {
            setState(() {
              _direccionOrigenTexto = direccion;
              _cargandoDireccionOrigen = false;
            });
          }
        } catch (e) {
          print('❌ Error al obtener dirección de origen: $e');
          if (mounted) {
            setState(() {
              _direccionOrigenTexto = "${pos.latitude.toStringAsFixed(5)}, ${pos.longitude.toStringAsFixed(5)}";
              _cargandoDireccionOrigen = false;
            });
          }
        }
      } else {
        // Si no se pudo obtener ubicación, usar ubicación por defecto (CDMX)
        if (mounted) {
          setState(() {
            _miUbicacionActual = const LatLng(19.4326, -99.1332);
            _ubicacionOrigen = const LatLng(19.4326, -99.1332);
            _cargandoUbicacion = false;
            _direccionOrigenTexto = "Ciudad de México, México";
            _cargandoDireccionOrigen = false;
          });
        }
      }
    } catch (e) {
      print('❌ Error al inicializar ubicación: $e');
      // En caso de error, usar ubicación por defecto
      if (mounted) {
        setState(() {
          _miUbicacionActual = const LatLng(19.4326, -99.1332);
          _ubicacionOrigen = const LatLng(19.4326, -99.1332);
          _cargandoUbicacion = false;
          _direccionOrigenTexto = "Ciudad de México, México";
          _cargandoDireccionOrigen = false;
        });
      }
    }
  }

  void _onMapTap(TapPosition tapPosition, LatLng point) async {
    setState(() {
      // Si ya tengo origen, el tap define el destino
      _ubicacionDestino = point;
      _cargandoDireccionDestino = true;
      _direccionDestinoTexto = "Cargando dirección...";
      _calcularDistancia();
    });
    
    // Obtener dirección del destino
    try {
      print('📍 Iniciando obtención de dirección para destino: ${point.latitude}, ${point.longitude}');
      final direccion = await _geoService.obtenerDireccionDesdeCoordenadas(
        point.latitude,
        point.longitude,
      );
      
      print('✅ Dirección obtenida para destino: $direccion');
      
      if (mounted) {
        setState(() {
          _direccionDestinoTexto = direccion;
          _cargandoDireccionDestino = false;
        });
      }
    } catch (e) {
      print('❌ Error al obtener dirección de destino: $e');
      if (mounted) {
        setState(() {
          _direccionDestinoTexto = "${point.latitude.toStringAsFixed(5)}, ${point.longitude.toStringAsFixed(5)}";
          _cargandoDireccionDestino = false;
        });
      }
    }
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
                          child: _cargandoDireccionOrigen
                              ? Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: const [
                                    SizedBox(
                                      width: 12,
                                      height: 12,
                                      child: CircularProgressIndicator(strokeWidth: 2),
                                    ),
                                    SizedBox(width: 8),
                                    Text('Cargando dirección...', style: TextStyle(fontStyle: FontStyle.italic)),
                                  ],
                                )
                              : Text(
                                  _direccionOrigenTexto ?? "Ubicación actual",
                                  style: const TextStyle(fontWeight: FontWeight.w500),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
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
                          child: _cargandoDireccionDestino
                              ? Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: const [
                                    SizedBox(
                                      width: 12,
                                      height: 12,
                                      child: CircularProgressIndicator(strokeWidth: 2),
                                    ),
                                    SizedBox(width: 8),
                                    Text('Cargando dirección...', style: TextStyle(fontStyle: FontStyle.italic)),
                                  ],
                                )
                              : Text(
                                  _direccionDestinoTexto ?? "Seleccionar destino",
                                  style: const TextStyle(fontWeight: FontWeight.w500),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
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

  void _solicitarViaje(TransporteController controller) async {
    if (_ubicacionOrigen == null || _ubicacionDestino == null) return;

    final nuevoServicio = ServicioTransporteModel(
      destino: _direccionDestinoTexto ?? "Destino seleccionado en mapa",
      fechaServicio: DateTime.now(),
      horaServicio: "${DateTime.now().hour.toString().padLeft(2, '0')}:${DateTime.now().minute.toString().padLeft(2, '0')}",
      empleadoId: null, // No asignar empleado - se hará en proceso aparte
      costoViaje: double.parse(((_distanciaKm ?? 0) * 15.0).toStringAsFixed(2)),
      observacionesCliente: _observacionesController.text.isEmpty ? null : _observacionesController.text,
      // No incluir observacionesEmpleado ni calificacionViaje - se harán en proceso aparte
      latitudOrigen: _ubicacionOrigen!.latitude,
      longitudOrigen: _ubicacionOrigen!.longitude,
      latitudDestino: _ubicacionDestino!.latitude,
      longitudDestino: _ubicacionDestino!.longitude,
      direccionOrigen: _direccionOrigenTexto,
      direccionDestino: _direccionDestinoTexto,
      distanciaKm: double.parse((_distanciaKm ?? 0).toStringAsFixed(2)),
    );

    // Si hay reservacionId, usar el método que incluye reservación
    final exito = widget.reservacionId != null
        ? await controller.crearServicioDesdeReservacion(nuevoServicio, widget.reservacionId!)
        : await controller.crearServicio(nuevoServicio);

    if (mounted) {
      if (exito) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Viaje solicitado exitosamente')),
        );
        // Limpiar estado
        setState(() {
          _ubicacionDestino = null;
          _distanciaKm = null;
          _direccionDestinoTexto = null;
          _cargandoDireccionDestino = false;
          _observacionesController.clear();
        });
        
        // Si venimos de una reservación, regresar a los detalles
        if (widget.reservacionId != null) {
          Navigator.pop(context);
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${controller.error}')),
        );
      }
    }
  }
}

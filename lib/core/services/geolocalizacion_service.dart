import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:dio/dio.dart';

class GeolocalizacionService {
  /// Verifica y solicita permisos de ubicación
  Future<bool> solicitarPermisos() async {
    // Verificar si los servicios de ubicación están habilitados
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Los servicios de ubicación están deshabilitados');
    }

    // Verificar permisos
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Permisos de ubicación denegados');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception('Los permisos de ubicación están denegados permanentemente');
    }

    return true;
  }

  /// Obtiene la ubicación actual del dispositivo
  Future<Position> obtenerUbicacionActual() async {
    await solicitarPermisos();
    
    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
      timeLimit: const Duration(seconds: 10),
    );
  }

  /// Calcula la distancia entre dos puntos en kilómetros
  double calcularDistancia(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    return Geolocator.distanceBetween(lat1, lon1, lat2, lon2) / 1000;
  }

  /// Obtiene una dirección legible a partir de coordenadas
  Future<String> obtenerDireccionDesdeCoordenadas(double lat, double lon) async {
    try {
      print('🔍 [Nativo] Obteniendo dirección para: $lat, $lon');
      
      // Intentar con geocoding nativo primero
      try {
        List<Placemark> placemarks = await placemarkFromCoordinates(lat, lon)
            .timeout(const Duration(seconds: 5)); // Timeout corto para nativo
        
        if (placemarks.isNotEmpty) {
          Placemark place = placemarks[0];
          final partes = <String>[];
          if (place.street != null && place.street!.isNotEmpty) partes.add(place.street!);
          if (place.subThoroughfare != null && place.subThoroughfare!.isNotEmpty) partes.add(place.subThoroughfare!);
          if (place.subLocality != null && place.subLocality!.isNotEmpty) partes.add(place.subLocality!);
          if (place.locality != null && place.locality!.isNotEmpty) partes.add(place.locality!);
          if (place.administrativeArea != null && place.administrativeArea!.isNotEmpty) partes.add(place.administrativeArea!);
          if (place.country != null && place.country!.isNotEmpty) partes.add(place.country!);
          
          if (partes.isNotEmpty) {
            final dir = partes.join(', ');
            print('✅ [Nativo] Dirección obtenida: $dir');
            return dir;
          }
        }
      } catch (e) {
        print('⚠️ [Nativo] Falló geocoding nativo: $e');
      }

      // Fallback: OpenStreetMap (Nominatim)
      print('🔍 [OSM] Intentando con Nominatim...');
      return await _obtenerDireccionOSM(lat, lon);

    } catch (e, stackTrace) {
      print('❌ Error obteniendo dirección: $e');
      print('Stack trace: $stackTrace');
      return "$lat, $lon";
    }
  }

  Future<String> _obtenerDireccionOSM(double lat, double lon) async {
    try {
      final dio = Dio();
      // Nominatim requiere User-Agent
      dio.options.headers['User-Agent'] = 'InnPulseApp/1.0';
      
      final response = await dio.get(
        'https://nominatim.openstreetmap.org/reverse',
        queryParameters: {
          'format': 'json',
          'lat': lat,
          'lon': lon,
          'zoom': 18,
          'addressdetails': 1,
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data;
        // Nominatim devuelve 'display_name' que es la dirección completa
        if (data['display_name'] != null) {
          print('✅ [OSM] Dirección obtenida: ${data['display_name']}');
          return data['display_name'];
        }
      }
    } catch (e) {
      print('❌ [OSM] Error en Nominatim: $e');
    }
    return "$lat, $lon";
  }
}

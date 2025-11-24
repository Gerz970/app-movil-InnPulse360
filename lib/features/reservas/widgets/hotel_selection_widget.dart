import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../features/hoteles/controllers/hotel_controller.dart';
import '../../../features/hoteles/models/hotel_model.dart';

class HotelSelectionWidget extends StatefulWidget {
  final Function(Hotel) onHotelSelected;

  const HotelSelectionWidget({
    super.key,
    required this.onHotelSelected,
  });

  @override
  State<HotelSelectionWidget> createState() => _HotelSelectionWidgetState();
}

class _HotelSelectionWidgetState extends State<HotelSelectionWidget> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final hotelController = Provider.of<HotelController>(context, listen: false);
      if (hotelController.hotels.isEmpty) {
        hotelController.fetchHotels().then((_) {
          // Después de cargar, preseleccionar el primero
          if (hotelController.hotels.isNotEmpty) {
            widget.onHotelSelected(hotelController.hotels.first);
          }
        });
      } else {
        // Si ya hay hoteles cargados, preseleccionar el primero si no hay selección previa
        if (hotelController.hotels.isNotEmpty) {
          widget.onHotelSelected(hotelController.hotels.first);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<HotelController>(
      builder: (context, hotelController, _) {
        if (hotelController.isLoading) {
          return const Center(
            child: CircularProgressIndicator(
              color: Color(0xFF667eea),
            ),
          );
        }

        if (hotelController.errorMessage != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Error: ${hotelController.errorMessage}',
                  style: const TextStyle(color: Colors.red),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => hotelController.fetchHotels(),
                  child: const Text('Reintentar'),
                ),
              ],
            ),
          );
        }

        if (hotelController.hotels.isEmpty) {
          return const Center(
            child: Text('No hay hoteles disponibles'),
          );
        }

        // Preseleccionar el primer hotel automáticamente
        if (hotelController.hotels.isNotEmpty) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            widget.onHotelSelected(hotelController.hotels.first);
          });
        }

        // Mostrar lista de hoteles
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: hotelController.hotels.length,
          itemBuilder: (context, index) {
            final hotel = hotelController.hotels[index];
            return _buildHotelCard(hotel);
          },
        );
      },
    );
  }

  Widget _buildHotelCard(Hotel hotel) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () => widget.onHotelSelected(hotel),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Imagen del hotel
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: hotel.urlFotoPerfil != null &&
                        hotel.urlFotoPerfil!.isNotEmpty
                    ? Image.network(
                        hotel.urlFotoPerfil!,
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 80,
                            height: 80,
                            color: Colors.grey[300],
                            child: const Icon(
                              Icons.hotel,
                              size: 40,
                              color: Color(0xFF667eea),
                            ),
                          );
                        },
                      )
                    : Container(
                        width: 80,
                        height: 80,
                        color: Colors.grey[300],
                        child: const Icon(
                          Icons.hotel,
                          size: 40,
                          color: Color(0xFF667eea),
                        ),
                      ),
              ),
              const SizedBox(width: 16),
              // Información del hotel
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      hotel.nombre,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      hotel.direccion,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (hotel.numeroEstrellas > 0) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: List.generate(
                          hotel.numeroEstrellas,
                          (index) => const Icon(
                            Icons.star,
                            size: 16,
                            color: Colors.amber,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios,
                size: 20,
                color: Color(0xFF667eea),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


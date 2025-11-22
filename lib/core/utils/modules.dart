import 'package:flutter/material.dart';
import '../../features/incidencias/incidencias_list_screen.dart';
import '../../features/clientes/clientes_list_screen.dart';
import '../../features/hoteles/hotels_list_screen.dart';
import '../../features/limpieza/limpieza_administracion_screen.dart';
import '../../features/limpieza/limpieza_camarista_screen.dart';
import '../../features/reservas/reservas_list_screen.dart';

final Map<String, Widget Function()> moduleScreens = {
  // Rutas exactas del backend según MODULOS.md
  'clientes_administracion_screen': () => const ClientesListScreen(),
  'hotel_administracion_screen': () => const HotelsListScreen(),
  'incidencias_cliente_screen': () => const IncidenciasListScreen(),
  'reservaciones_cliente_screen': () => const ReservacionesListScreen(),
  'limpieza_administracion_screen': () => const LimpiezaAdministracionScreen(),
  'limpieza_camarista_screen': () => const LimpiezaCamaristaScreen(),
};
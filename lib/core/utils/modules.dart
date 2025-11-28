import 'package:app_movil_innpulse/features/mantenimiento/mantenimiento_list_screen.dart';
import 'package:flutter/material.dart';
import '../../features/incidencias/incidencias_list_screen.dart';
import '../../features/clientes/clientes_list_screen.dart';
import '../../features/hoteles/hotels_list_screen.dart';
import '../../features/limpieza/limpieza_administracion_screen.dart';
import '../../features/limpieza/limpieza_camarista_screen.dart';
import '../../features/reservas/reservas_main_screen.dart';
import '../../features/transporte/screens/transporte_main_screen.dart';

final Map<String, Widget Function()> moduleScreens = {
  // Rutas exactas del backend según MODULOS.md
  'clientes_administracion_screen': () => const ClientesListScreen(),
  'hotel_administracion_screen': () => const HotelsListScreen(),
  'incidencias_cliente_screen': () => const IncidenciasListScreen(),
  'reservaciones_cliente_screen': () => const ReservasMainScreen(),
  'limpieza_administracion_screen': () => const LimpiezaAdministracionScreen(),
  'limpieza_camarista_screen': () => const LimpiezaCamaristaScreen(),
  // Módulo de transporte
  'transporte_cliente_screen': () => const TransporteMainScreen(),
  'mantenimiento_screen': () => const MantenimientosListScreen()
};
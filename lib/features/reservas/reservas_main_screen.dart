import 'package:flutter/material.dart';
import 'reservas_list_screen.dart';
import 'reservas_create_screen.dart';
import 'reservas_history_screen.dart';
import 'widgets/reservas_bottom_nav_bar.dart';

/// Pantalla principal del módulo de Reservaciones
/// Maneja la navegación entre las tres secciones mediante barra inferior
class ReservasMainScreen extends StatefulWidget {
  const ReservasMainScreen({super.key});

  @override
  State<ReservasMainScreen> createState() => _ReservasMainScreenState();
}

class _ReservasMainScreenState extends State<ReservasMainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const ReservacionesListScreen(),
    const NuevaReservaScreen(),
    const ReservasHistoryScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: ReservasBottomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}


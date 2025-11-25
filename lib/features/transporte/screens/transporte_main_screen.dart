import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/transporte_controller.dart';
import 'transporte_list_screen.dart';
import 'transporte_create_screen.dart';

class TransporteMainScreen extends StatefulWidget {
  const TransporteMainScreen({super.key});

  @override
  State<TransporteMainScreen> createState() => _TransporteMainScreenState();
}

class _TransporteMainScreenState extends State<TransporteMainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const TransporteListScreen(mostrarActivos: true), // Viajes solicitados
    const TransporteCreateScreen(), // Solicitar viaje
    const TransporteListScreen(mostrarActivos: false), // Historial
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => TransporteController(),
      child: Scaffold(
        body: IndexedStack(
          index: _selectedIndex,
          children: _screens,
        ),
        bottomNavigationBar: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.list_alt),
              label: 'Solicitados',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.add_location_alt),
              label: 'Solicitar',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.history),
              label: 'Historial',
            ),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: const Color(0xFF667eea),
          onTap: _onItemTapped,
        ),
      ),
    );
  }
}


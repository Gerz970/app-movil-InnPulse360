import 'package:flutter/material.dart';
import 'transporte_list_screen.dart';
import 'transporte_create_screen.dart';
import '../../../widgets/app_header.dart';
import '../../../widgets/app_sidebar.dart';

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
    // El TransporteController ahora está disponible globalmente desde main.dart
    return Scaffold(
      drawer: const AppSidebar(),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Header global de la app que siempre será visible
            const AppHeader(),
            // Botón de regreso (si hay una ruta anterior)
            if (Navigator.canPop(context)) _buildBackButton(),
            // Contenido principal con las 3 secciones
            Expanded(
              child: IndexedStack(
                index: _selectedIndex,
                children: _screens,
              ),
            ),
          ],
        ),
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
    );
  }

  // Widget para construir el botón de regreso
  Widget _buildBackButton() {
    return InkWell(
      onTap: () => Navigator.pop(context),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.grey.shade200,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.arrow_back_ios,
              size: 18,
              color: Colors.grey.shade700,
            ),
            const SizedBox(width: 8),
            Text(
              'Regresar',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}


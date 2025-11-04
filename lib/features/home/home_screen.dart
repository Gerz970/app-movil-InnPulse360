import 'package:flutter/material.dart';

/// Clase HomeScreen, se encarga de la pantalla de inicio de la aplicación
class HomeScreen extends StatefulWidget {
  /// Constructor de la clase HomeScreen
  const HomeScreen({super.key}); // super.key es el constructor de la clase padre

  @override
  /// Metodo para crear el estado de la clase HomeScreen
  State<HomeScreen> createState() => _HomeScreenState();
  /// cuando () significa que el metodo no recibe parametros
  /// cuando {} significa que el metodo recibe parametros
  /// cuando @override significa que el metodo es un override de la clase padre
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Text('Pantalla de inicio')
        )
      )
    );
  }
}
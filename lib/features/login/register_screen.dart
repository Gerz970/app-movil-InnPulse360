import 'package:flutter/material.dart';

/// Clase RegisterScreen, se encarga de la pantalla de registro de usuario
class RegisterScreen extends StatefulWidget {
  /// Constructor de la clase RegisterScreen
  const RegisterScreen({super.key}); // super.key es el constructor de la clase padre

  /// Metodo para crear el estado de la clase RegisterScreen
  @override
  /// Metodo para crear el estado de la clase RegisterScreen
  State<RegisterScreen> createState() => _RegisterScreenState();
  /// cuando () significa que el metodo no recibe parametros
  /// cuando {} significa que el metodo recibe parametros
  /// cuando @override significa que el metodo es un override de la clase padre

}

class _RegisterScreenState extends State<RegisterScreen> {
  /// Metodo para construir la pantalla de registro de usuario
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:SafeArea(
        child: Center(
          child: Text('RegisterScreen')
        )
      )
    );
  }
}
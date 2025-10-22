import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'aplicacion/inyeccion_dependencias/localizador_servicios.dart';
import 'modulos/autenticacion/presentacion/paginas/pagina_login.dart';

void main() async {
  /// Asegurar que Flutter esté inicializado
  WidgetsFlutterBinding.ensureInitialized();
  
  /// Inicializar todas las dependencias
  await inicializarDependencias();
  
  runApp(
    /// ProviderScope es necesario para usar Riverpod
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'InnPulse App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF667eea)),
        useMaterial3: true,
      ),
      home: const PaginaLogin(),
      debugShowCheckedModeBanner: false,
    );
  }
}

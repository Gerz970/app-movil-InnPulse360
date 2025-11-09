import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'features/login/login_screen.dart';
import 'core/auth/controllers/auth_controller.dart';
import 'core/sidebar/sidebar_controller.dart';
import 'features/hoteles/controllers/hotel_controller.dart';
import 'features/clientes/controllers/cliente_controller.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthController()),
        ChangeNotifierProvider(create: (_) => SidebarController()),
        ChangeNotifierProvider(create: (_) => HotelController()),
        ChangeNotifierProvider(create: (_) => ClienteController()),
      ],
      child: MaterialApp(
        title: 'InnPulse App',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF667eea)),
          useMaterial3: true,
        ),
        home: const LoginScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
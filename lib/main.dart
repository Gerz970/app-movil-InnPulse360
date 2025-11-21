import 'package:app_movil_innpulse/features/pisos/controllers/piso_controller.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'features/login/login_screen.dart';
import 'core/auth/controllers/auth_controller.dart';
import 'core/sidebar/sidebar_controller.dart';
import 'core/notifications/fcm_service.dart';
import 'features/hoteles/controllers/hotel_controller.dart';
import 'features/clientes/controllers/cliente_controller.dart';
import 'features/incidencias/controllers/incidencia_controller.dart';
import 'features/perfil/controllers/perfil_controller.dart';
import 'features/limpieza/controllers/limpieza_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inicializar Firebase
  try {
    await Firebase.initializeApp();
    print('✅ Firebase inicializado correctamente');
    
    // Inicializar FCMService (solo configuración, no registra token aún)
    final fcmService = FCMService();
    await fcmService.initialize();
    
    // Configurar callback para navegación desde notificaciones
    fcmService.setOnNotificationTapped((data) {
      print('📱 Callback de notificación ejecutado: $data');
      // La navegación real se manejará desde MyApp usando un GlobalKey<NavigatorState>
      // o desde el widget que tenga acceso al contexto de navegación
    });
    
    print('✅ FCMService inicializado');
  } catch (e) {
    print('⚠️ Error inicializando Firebase: $e');
    // Continuar aunque falle Firebase (para desarrollo sin Firebase configurado)
  }
  
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
        ChangeNotifierProvider(create: (_) => IncidenciaController()),
        ChangeNotifierProvider(create: (_) => PisoController()),
        ChangeNotifierProvider(create: (_) => PerfilController()),
        ChangeNotifierProvider(create: (_) => LimpiezaController()),

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
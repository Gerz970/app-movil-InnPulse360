import 'package:flutter/material.dart';
import '../../../autenticacion/presentacion/paginas/pagina_login.dart';

/// Pantalla principal de la aplicación
/// Se muestra después de un login exitoso
class PaginaInicio extends StatelessWidget {
  const PaginaInicio({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF667eea),
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'InnPulse360 Movil',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              /// Navegar de vuelta al login
              /// Se usa pushReplacement para limpiar el historial
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const PaginaLogin(),
                ),
              );
            },
            tooltip: 'Cerrar sesión',
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            /// Icono de bienvenida
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: const Color(0xFF667eea).withOpacity(0.1),
                borderRadius: BorderRadius.circular(60),
              ),
              child: const Icon(
                Icons.check_circle_outline,
                size: 60,
                color: Color(0xFF667eea),
              ),
            ),
            const SizedBox(height: 32),
            
            /// Mensaje de bienvenida
            const Text(
              'Bienvenido',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1a1a1a),
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 16),
            
            /// Mensaje secundario
            Text(
              'Has iniciado sesión correctamente',
              style: TextStyle(
                fontSize: 16,
                color: const Color(0xFF6b7280),
                fontWeight: FontWeight.w400,
              ),
            ),
            const SizedBox(height: 48),
            
            /// Tarjeta informativa
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: const Color(0xFF667eea).withOpacity(0.05),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color(0xFF667eea).withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: Column(
                  children: [
                    const Icon(
                      Icons.info_outline,
                      color: Color(0xFF667eea),
                      size: 32,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Esta es la pantalla principal de la aplicación',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: const Color(0xFF6b7280),
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Aquí se agregarán las funcionalidades principales',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: const Color(0xFF6b7280),
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


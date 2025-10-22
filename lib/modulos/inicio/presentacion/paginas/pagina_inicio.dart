import 'package:flutter/material.dart';
import '../../../autenticacion/presentacion/paginas/pagina_login.dart';
import '../../../autenticacion/dominio/entidades/respuesta_autenticacion.dart';
import '../widgets/header_notificaciones.dart';

/// Pantalla principal de la aplicación
/// Se muestra después de un login exitoso
class PaginaInicio extends StatelessWidget {
  /// Datos de autenticación del usuario
  /// En una implementación real, esto vendría de un provider o servicio
  static RespuestaAutenticacion? _respuestaAutenticacion;
  
  const PaginaInicio({super.key});

  /// Método estático para establecer los datos de autenticación
  /// Esto se llamaría desde el login exitoso
  static void establecerDatosAutenticacion(RespuestaAutenticacion respuesta) {
    _respuestaAutenticacion = respuesta;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          /// Header con notificaciones
          if (_respuestaAutenticacion != null)
            HeaderNotificaciones(
              respuestaAutenticacion: _respuestaAutenticacion!,
              onLogout: () {
                _respuestaAutenticacion = null;
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const PaginaLogin(),
                  ),
                );
              },
              onCambiarPassword: () {
                /// TODO: Implementar navegación a cambio de contraseña
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Funcionalidad de cambio de contraseña pendiente'),
                    backgroundColor: Colors.blue,
                  ),
                );
              },
            )
          else
            /// Header básico si no hay datos de autenticación
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color(0xFF667eea),
                    const Color(0xFF667eea).withOpacity(0.8),
                  ],
                ),
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.notifications_outlined,
                        color: Colors.white,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'InnPulse360 Movil',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.logout),
                        color: Colors.white,
                        onPressed: () {
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
                ),
              ),
            ),
          /// Contenido principal
          Expanded(
            child: Center(
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
          ),
        ],
      ),
    );
  }
}


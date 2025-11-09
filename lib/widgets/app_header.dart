import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/auth/controllers/auth_controller.dart';

/// Widget de header global reutilizable para toda la aplicación
/// Muestra información del usuario, foto de perfil y botones de acción
class AppHeader extends StatelessWidget {
  const AppHeader({super.key});

  /// Función auxiliar para extraer un String de forma segura del loginResponse
  /// Maneja casos donde el valor podría ser un Map o null
  String _extractString(Map<String, dynamic>? data, String key) {
    if (data == null) return 'Usuario';
    final value = data[key];
    if (value is String) {
      return value;
    }
    return 'Usuario';
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthController>(
      builder: (context, authController, child) {
        // Obtener datos del usuario del loginResponse
        final loginResponse = authController.loginResponse;
        
        // Extraer el campo "login" del usuario (prioridad al campo login)
        String userLogin = 'Usuario';
        if (loginResponse != null) {
          // Priorizar el campo "login" de la sesión
          userLogin = _extractString(loginResponse, 'login');
          
          // Si no encontramos "login", intentar otros campos como fallback
          if (userLogin == 'Usuario') {
            userLogin = _extractString(loginResponse, 'username');
          }
          if (userLogin == 'Usuario') {
            userLogin = _extractString(loginResponse, 'usuario');
          }
          if (userLogin == 'Usuario') {
            userLogin = _extractString(loginResponse, 'nombre');
          }
          if (userLogin == 'Usuario') {
            userLogin = _extractString(loginResponse, 'name');
          }
          
          // Si aún no encontramos un login válido, intentar obtenerlo de un objeto anidado
          if (userLogin == 'Usuario' && loginResponse['usuario'] != null) {
            final usuarioObj = loginResponse['usuario'];
            if (usuarioObj is Map<String, dynamic>) {
              userLogin = _extractString(usuarioObj, 'login');
              if (userLogin == 'Usuario') {
                userLogin = _extractString(usuarioObj, 'username');
              }
            }
          }
        }

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              // Botón circular hamburguesa (☰) para abrir sidebar
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF667eea).withOpacity(0.1),
                ),
                child: IconButton(
                  padding: EdgeInsets.zero,
                  icon: const Icon(
                    Icons.menu,
                    color: Color(0xFF667eea),
                    size: 22,
                  ),
                  onPressed: () {
                    // Abrir el drawer del Scaffold
                    Scaffold.of(context).openDrawer();
                  },
                ),
              ),
              const SizedBox(width: 12),
              // Foto de perfil circular con icono temporal
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF667eea).withOpacity(0.1),
                  border: Border.all(
                    color: const Color(0xFF667eea).withOpacity(0.2),
                    width: 2,
                  ),
                ),
                child: const Icon(
                  Icons.person,
                  color: Color(0xFF667eea),
                  size: 28,
                ),
              ),
              const SizedBox(width: 12),
              // Nombre del usuario y texto secundario
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      userLogin,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1a1a1a),
                        letterSpacing: -0.3,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Bienvenido de nuevo',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFF6b7280),
                        letterSpacing: -0.2,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // Botón circular "+"
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF667eea).withOpacity(0.1),
                ),
                child: IconButton(
                  padding: EdgeInsets.zero,
                  icon: const Icon(
                    Icons.add,
                    color: Color(0xFF667eea),
                    size: 22,
                  ),
                  onPressed: () {
                    // Sin funcionalidad por ahora
                  },
                ),
              ),
              const SizedBox(width: 8),
              // Botón circular menú "⋮"
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF667eea).withOpacity(0.1),
                ),
                child: PopupMenuButton<String>(
                  padding: EdgeInsets.zero,
                  icon: const Icon(
                    Icons.more_vert,
                    color: Color(0xFF667eea),
                    size: 22,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  itemBuilder: (BuildContext context) => [
                    const PopupMenuItem<String>(
                      value: 'perfil',
                      child: Row(
                        children: [
                          Icon(Icons.person_outline, size: 20, color: Color(0xFF6b7280)),
                          SizedBox(width: 12),
                          Text('Perfil'),
                        ],
                      ),
                    ),
                    const PopupMenuItem<String>(
                      value: 'configuracion',
                      child: Row(
                        children: [
                          Icon(Icons.settings_outlined, size: 20, color: Color(0xFF6b7280)),
                          SizedBox(width: 12),
                          Text('Configuración'),
                        ],
                      ),
                    ),
                    const PopupMenuItem<String>(
                      value: 'ayuda',
                      child: Row(
                        children: [
                          Icon(Icons.help_outline, size: 20, color: Color(0xFF6b7280)),
                          SizedBox(width: 12),
                          Text('Ayuda'),
                        ],
                      ),
                    ),
                    const PopupMenuDivider(),
                    const PopupMenuItem<String>(
                      value: 'cerrar_sesion',
                      child: Row(
                        children: [
                          Icon(Icons.logout, size: 20, color: Colors.red),
                          SizedBox(width: 12),
                          Text(
                            'Cerrar sesión',
                            style: TextStyle(color: Colors.red),
                          ),
                        ],
                      ),
                    ),
                  ],
                  onSelected: (String value) {
                    // Sin funcionalidad por ahora, solo muestra opciones de ejemplo
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Opción seleccionada: $value'),
                        backgroundColor: const Color(0xFF667eea),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}


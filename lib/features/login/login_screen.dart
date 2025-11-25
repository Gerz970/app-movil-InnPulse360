import 'package:flutter/material.dart'; //Es para uso de componentes visuales
import 'package:provider/provider.dart'; // es para escuchar cambios y actualizar UI
import '../../../core/auth/controllers/auth_controller.dart'; //controller de esta interfaz
import '../home/home_screen.dart'; // pantalla de inicio
import 'register_screen.dart'; // pantalla de registro
import 'forgot_password_screen.dart'; // pantalla de recuperar contraseña
import '../../../core/utils/modules.dart'; // mapeo de rutas a pantallas
import '../common/under_construction_screen.dart'; // pantalla para módulos no implementados

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  /// Controladores para los campos de texto
  final _loginController = TextEditingController();
  final _passwordController = TextEditingController();
  
  /// Estado para mostrar/ocultar contraseña
  bool _ocultarPassword = true;
  
  @override
  void dispose() {
    _loginController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildHeader(),
                const SizedBox(height: 64),
                _buildLoginForm(),
                const SizedBox(height: 16),
                _buildErrorMessage(),
                const SizedBox(height: 16),
                _buildLoginButton(),
                const SizedBox(height: 24),
                _buildRegisterOption(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            color: const Color.fromARGB(255, 255, 255, 255).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20)
          ),
          child: SizedBox(
            width: 280,
            height: 140,
            child:
              Image(
                image: AssetImage('lib/assets/splash_logo.png')
              )
          )
        ),
        const SizedBox(height: 32),
        const Text(
          'InnPulse360 Móvil',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1a1a1a),
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Inicia sesión para continuar',
          style: TextStyle(
            fontSize: 16,
            color: const Color(0xFF6b7280),
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }

  Widget _buildLoginForm() {
    return Column(
      children: [
        _buildEmailField(),
        const SizedBox(height: 20),
        _buildPasswordField(),
        const SizedBox(height: 12),
        _buildForgotPassword(),
      ],
    );
  }

  Widget _buildEmailField() {
    return TextFormField(
      controller: _loginController,
      decoration: InputDecoration(
        labelText: 'Usuario',
        hintText: 'Ingresa tu usuario',
        prefixIcon: const Icon(
          Icons.person_outline,
          color: Color(0xFF6b7280),
          size: 20,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: Color(0xFFe5e7eb),
            width: 1,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: Color(0xFFe5e7eb),
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: Color(0xFF667eea),
            width: 2,
          ),
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        labelStyle: const TextStyle(
          color: Color(0xFF6b7280),
          fontSize: 14,
        ),
        hintStyle: const TextStyle(
          color: Color(0xFF9ca3af),
          fontSize: 14,
        ),
      ),
      keyboardType: TextInputType.text,
      textInputAction: TextInputAction.next,
    );
  }

  Widget _buildPasswordField() {
    return TextFormField(
      controller: _passwordController,
      decoration: InputDecoration(
        labelText: 'Contraseña',
        hintText: '••••••••',
        prefixIcon: const Icon(
          Icons.lock_outline,
          color: Color(0xFF6b7280),
          size: 20,
        ),
        suffixIcon: IconButton(
          icon: Icon(
            _ocultarPassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
            color: Color(0xFF6b7280),
            size: 20,
          ),
          onPressed: () {
            setState(() {
              _ocultarPassword = !_ocultarPassword;
            });
          },
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: Color(0xFFe5e7eb),
            width: 1,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: Color(0xFFe5e7eb),
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: Color(0xFF667eea),
            width: 2,
          ),
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        labelStyle: const TextStyle(
          color: Color(0xFF6b7280),
          fontSize: 14,
        ),
        hintStyle: const TextStyle(
          color: Color(0xFF9ca3af),
          fontSize: 14,
        ),
      ),
      obscureText: _ocultarPassword,
      textInputAction: TextInputAction.done,
    );
  }

  Widget _buildForgotPassword() {
    return Align(
      alignment: Alignment.centerRight,
      child: TextButton(
        onPressed: _navigateToForgotPassword,
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          minimumSize: Size.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        child: const Text(
          '¿Olvidaste tu contraseña?',
          style: TextStyle(
            color: Color(0xFF667eea),
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildLoginButton() {
    return Consumer<AuthController>(
      builder: (context, authController, child) {
        return SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: authController.isLoading ? null : _handleLogin,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF667eea),
              foregroundColor: Colors.white,
              elevation: 0,
              shadowColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              disabledBackgroundColor: const Color(0xFF9ca3af),
            ),
            child: authController.isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Text(
                    'Iniciar Sesión',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
          ),
        );
      },
    );
  }

  Widget _buildRegisterOption() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          '¿No tienes una cuenta?',
          style: TextStyle(
            color: Color(0xFF6b7280),
            fontSize: 14,
            fontWeight: FontWeight.w400,
          ),
        ),
        TextButton(
          onPressed: _navigateToRegister,
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: const Text(
            'Regístrate',
            style: TextStyle(
              color: Color(0xFF667eea),
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorMessage() {
    return Consumer<AuthController>(
      builder: (context, authController, child) {
        if (authController.errorMessage != null && authController.errorMessage!.isNotEmpty) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFFEF2F2).withOpacity(0.6),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: const Color(0xFFFCA5A5).withOpacity(0.4),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: const Color(0xFFDC2626).withOpacity(0.7),
                  size: 16,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    authController.errorMessage!,
                    style: TextStyle(
                      color: const Color(0xFF991B1B).withOpacity(0.8),
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                      letterSpacing: 0.2,
                    ),
                  ),
                ),
              ],
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
  
  Future<void> _handleLogin() async {
    final login = _loginController.text.trim();
    final password = _passwordController.text.trim();
    
    // Validación de campos vacíos
    if (login.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, completa todos los campos'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Obtener el AuthController del Provider
    final authController = Provider.of<AuthController>(context, listen: false);
    
    // Realizar petición de login al API
    final success = await authController.login(login, password, context);
    
    if (success) {
      // Login exitoso - navegar al primer módulo asignado
      if (context.mounted) {
        _navigateToFirstModule(context, authController.loginResponse);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Bienvenido $login'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } else {
      // El error ya está manejado en el AuthController y se mostrará en _buildErrorMessage
      // No necesitamos hacer nada más aquí
    }
  }

  /// Navega al primer módulo asignado al usuario
  void _navigateToFirstModule(BuildContext context, Map<String, dynamic>? loginResponse) {
    // Obtener módulos del loginResponse
    List<dynamic> modulos = [];
    if (loginResponse != null && loginResponse['modulos'] is List) {
      modulos = loginResponse['modulos'] as List;
    }

    print('🔍 [Login] Total módulos recibidos: ${modulos.length}');

    // Filtrar solo los módulos que son móvil (movil == 1)
    // Reutilizando la misma lógica que app_sidebar.dart
    final modulosMovil = modulos.where((modulo) {
      final moduloMap = modulo as Map<String, dynamic>;
      final movil = moduloMap['movil'];
      final nombre = moduloMap['nombre'] as String? ?? 'Sin nombre';
      final ruta = moduloMap['ruta'] as String? ?? 'Sin ruta';
      
      // Verificar si movil es 1 (puede ser int, num, String '1', o bool true)
      if (movil == null) {
        print('❌ [Login] Módulo "$nombre" (ruta: "$ruta") - movil es null, descartado');
        return false; // Si es null, no es móvil
      }
      
      bool esMovil = false;
      // Manejar diferentes tipos de datos
      if (movil is int || movil is num) {
        esMovil = movil == 1;
      } else if (movil is String) {
        esMovil = movil == '1' || movil.toLowerCase() == 'true';
      } else if (movil is bool) {
        esMovil = movil == true;
      }
      
      if (esMovil) {
        print('✅ [Login] Módulo móvil encontrado: "$nombre" (ruta: "$ruta", movil: $movil)');
      } else {
        print('❌ [Login] Módulo "$nombre" (ruta: "$ruta") - movil=$movil (tipo: ${movil.runtimeType}), descartado');
      }
      
      return esMovil;
    }).toList();

    print('📱 [Login] Total módulos móviles filtrados: ${modulosMovil.length}');

    // Si no hay módulos móviles, navegar a HomeScreen por defecto
    if (modulosMovil.isEmpty) {
      print('⚠️ [Login] No hay módulos móviles disponibles, navegando a HomeScreen');
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => const HomeScreen(),
        ),
      );
      return;
    }

    // Obtener el primer módulo
    final primerModulo = modulosMovil.first as Map<String, dynamic>;
    final rutaModulo = (primerModulo['ruta'] as String? ?? '').trim();
    final nombreModulo = primerModulo['nombre'] as String? ?? 'Módulo';

    print('🎯 [Login] Navegando al primer módulo móvil: "$nombreModulo" (ruta: "$rutaModulo")');
    print('📋 [Login] Rutas disponibles en moduleScreens: ${moduleScreens.keys.toList()}');

    // Buscar la pantalla correspondiente en moduleScreens
    final entry = moduleScreens.entries.firstWhere(
      (e) => rutaModulo == e.key,
      orElse: () {
        print('⚠️ [Login] Ruta "$rutaModulo" no encontrada en moduleScreens, usando UnderConstructionScreen');
        return MapEntry(
          'default',
          () => UnderConstructionScreen(title: nombreModulo),
        );
      },
    );

    print('✅ [Login] Pantalla encontrada para ruta "$rutaModulo", navegando...');

    // Navegar a la pantalla del primer módulo
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => entry.value()),
    );
  }

  void _navigateToRegister() {
    // Navegar a la pantalla de registro de usuario
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const RegisterScreen(),
      ),
    );
  }

  void _navigateToForgotPassword() {
    // Navegar a la pantalla de recuperar contraseña
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const ForgotPasswordScreen(),
      ),
    );
  }
}
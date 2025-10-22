import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../inicio/presentacion/paginas/pagina_inicio.dart';
import '../estado/login_provider.dart';
import '../estado/login_estado.dart';

class PaginaLogin extends ConsumerStatefulWidget {
  const PaginaLogin({super.key});
  
  @override
  ConsumerState<PaginaLogin> createState() => _PaginaLoginState();
}

class _PaginaLoginState extends ConsumerState<PaginaLogin> {
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
    /// Escuchar cambios en el estado del login
    ref.listen<LoginEstado>(loginNotificadorProvider, (previous, next) {
      if (next is LoginExitoso) {
        /// Login exitoso - Mostrar mensaje y navegar
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Bienvenido ${next.respuesta.usuario.login}'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
        
        /// Navegar a la pantalla principal
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const PaginaInicio(),
          ),
        );
        
      } else if (next is LoginError) {
        /// Login fallido - Mostrar error
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.mensaje),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    });
    
    /// Obtener el estado actual
    final estadoLogin = ref.watch(loginNotificadorProvider);
    
    return Scaffold(
      backgroundColor: Colors.white,
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
                const SizedBox(height: 32),
                _buildLoginButton(estadoLogin),
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
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            color: const Color(0xFF667eea).withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: const Color(0xFF667eea).withOpacity(0.2),
              width: 1,
            ),
          ),
          child: const Icon(
            Icons.lock_outline,
            size: 36,
            color: Color(0xFF667eea),
          ),
        ),
        const SizedBox(height: 32),
        const Text(
          'InnPulse360 Movil',
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
        const SizedBox(height: 20),
        _buildRememberMe(),
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

  Widget _buildRememberMe() {
    return Row(
      children: [
        Checkbox(
          value: false,
          onChanged: (value) {
            /// TODO: Implementar lógica de recordar
          },
          activeColor: const Color(0xFF667eea),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const Text(
          'Recordar contraseña',
          style: TextStyle(
            color: Color(0xFF6b7280),
            fontSize: 14,
            fontWeight: FontWeight.w400,
          ),
        ),
        const Spacer(),
        TextButton(
          onPressed: () {
            /// TODO: Implementar navegación a recuperar contraseña
          },
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
      ],
    );
  }

  Widget _buildLoginButton(LoginEstado estado) {
    final estaCargando = estado is LoginCargando;
    
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: estaCargando ? null : _handleLogin,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF667eea),
          foregroundColor: Colors.white,
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: estaCargando
            ? const SizedBox(
                width: 20,
                height: 20,
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
  }
  
  void _handleLogin() {
    final login = _loginController.text.trim();
    final password = _passwordController.text.trim();
    
    ref.read(loginNotificadorProvider.notifier).iniciarSesion(
          login: login,
          password: password,
        );
  }
}


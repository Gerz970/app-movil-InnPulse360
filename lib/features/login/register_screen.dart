import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/auth/controllers/auth_controller.dart';
import 'cliente_register_screen.dart';
import 'register_success_screen.dart';
import 'login_screen.dart';

/// Pantalla de registro de usuario
/// Flujo automático: el usuario ingresa login y correo, hace clic en "Registrarse"
/// y la app maneja automáticamente la verificación y registro
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  /// Controladores para los campos de texto
  final _loginController = TextEditingController();
  final _correoController = TextEditingController();
  
  /// Clave del formulario para validación
  final _formKey = GlobalKey<FormState>();
  
  /// Estado de procesamiento general
  bool _isProcessing = false;
  
  /// Mensaje de estado actual (para mostrar en el overlay de carga)
  String _currentStatusMessage = '';

  @override
  void dispose() {
    _loginController.dispose();
    _correoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Color(0xFF1a1a1a),
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(32.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildHeader(),
                      const SizedBox(height: 64),
                      _buildForm(),
                      const SizedBox(height: 16),
                      _buildErrorMessage(),
                      const SizedBox(height: 16),
                      _buildRegistrarButton(),
                    ],
                  ),
                ),
              ),
            ),
          ),
          // Overlay de carga durante el procesamiento
          if (_isProcessing)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 250,
                        child: Column(
                          children: [
                            LinearProgressIndicator(
                              backgroundColor: Colors.grey.shade200,
                              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF667eea)),
                              minHeight: 4,
                              borderRadius: BorderRadius.circular(2),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _currentStatusMessage,
                              style: const TextStyle(
                                fontSize: 16,
                                color: Color(0xFF1a1a1a),
                                fontWeight: FontWeight.w500,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// Widget para construir el encabezado
  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            color: const Color.fromARGB(255, 255, 255, 255).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const SizedBox(
            width: 200,
            height: 100,
            child: Image(
              image: AssetImage('lib/assets/img/logo.jpg'),
            ),
          ),
        ),
        const SizedBox(height: 32),
        const Text(
          'Registro de Usuario',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1a1a1a),
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Ingresa tu correo y login para crear tu cuenta',
          style: TextStyle(
            fontSize: 16,
            color: Color(0xFF6b7280),
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }

  /// Widget para construir el formulario
  Widget _buildForm() {
    return Column(
      children: [
        _buildLoginField(),
        const SizedBox(height: 20),
        _buildCorreoField(),
      ],
    );
  }

  /// Widget para campo de login
  Widget _buildLoginField() {
    return TextFormField(
      controller: _loginController,
      enabled: !_isProcessing,
      decoration: InputDecoration(
        labelText: 'Login',
        hintText: 'Ingresa tu login',
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
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'El login es requerido';
        }
        if (value.trim().length < 3) {
          return 'El login debe tener al menos 3 caracteres';
        }
        if (value.trim().length > 25) {
          return 'El login no puede tener más de 25 caracteres';
        }
        return null;
      },
    );
  }

  /// Widget para campo de correo
  Widget _buildCorreoField() {
    return TextFormField(
      controller: _correoController,
      enabled: !_isProcessing,
      decoration: InputDecoration(
        labelText: 'Correo electrónico',
        hintText: 'ejemplo@correo.com',
        prefixIcon: const Icon(
          Icons.email_outlined,
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
      keyboardType: TextInputType.emailAddress,
      textInputAction: TextInputAction.done,
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'El correo electrónico es requerido';
        }
        final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
        if (!emailRegex.hasMatch(value.trim())) {
          return 'Correo electrónico no válido';
        }
        return null;
      },
    );
  }

  /// Widget para mostrar mensajes de error
  Widget _buildErrorMessage() {
    return Consumer<AuthController>(
      builder: (context, authController, child) {
        // Mostrar error de verificación o registro
        final errorMessage = authController.verificacionErrorMessage ?? 
                            authController.registroErrorMessage;
        
        if (errorMessage != null && errorMessage.isNotEmpty && !_isProcessing) {
          return Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.red.shade200),
            ),
            child: Row(
              children: [
                Icon(Icons.error_outline, color: Colors.red.shade700, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    errorMessage,
                    style: TextStyle(
                      color: Colors.red.shade700,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
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

  /// Widget para botón de registro (único botón)
  Widget _buildRegistrarButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: _isProcessing ? null : _handleRegistroCompleto,
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
        child: const Text(
          'Registrarse',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }

  /// Método principal que maneja todo el flujo de registro automáticamente
  Future<void> _handleRegistroCompleto() async {
    // 1. Validar formulario
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final login = _loginController.text.trim();
    final correo = _correoController.text.trim();

    // Obtener el AuthController del Provider
    final authController = Provider.of<AuthController>(context, listen: false);
    
    // Limpiar errores anteriores
    authController.clearVerificacionYRegistro();

    // 2. Iniciar procesamiento
    setState(() {
      _isProcessing = true;
      _currentStatusMessage = 'Verificando disponibilidad...';
    });

    try {
      // 3. Verificar disponibilidad
      final verificacionSuccess = await authController.verificarDisponibilidad(login, correo);

      if (!verificacionSuccess) {
        // Error en la verificación
        setState(() {
          _isProcessing = false;
        });
        _mostrarMensajeError(
          authController.verificacionErrorMessage ?? 
          'Error al verificar disponibilidad. Por favor, intenta nuevamente.'
        );
        return;
      }

      final verificacion = authController.verificacionResponse;
      if (verificacion == null) {
        setState(() {
          _isProcessing = false;
        });
        _mostrarMensajeError('Error al obtener respuesta del servidor. Por favor, intenta nuevamente.');
        return;
      }

      // 4. Manejar escenarios según el resultado
      
      // ESCENARIO 1: Login no disponible
      if (!verificacion.loginDisponible) {
        setState(() {
          _isProcessing = false;
        });
        _mostrarDialogoLoginOcupado(
          verificacion.mensaje.isNotEmpty 
            ? verificacion.mensaje 
            : 'El login ya está en uso. Por favor, elige otro.'
        );
        return;
      }

      // ESCENARIO 2: Cliente no existe → Navegar a crear cliente
      if (!verificacion.correoEnClientes) {
        setState(() {
          _isProcessing = false;
        });
        _navegarACrearCliente(login, correo);
        return;
      }

      // ESCENARIO 3: Cliente existe pero usuario ya existe
      if (verificacion.usuarioYaExiste) {
        setState(() {
          _isProcessing = false;
        });
        _mostrarDialogoUsuarioExistente();
        return;
      }

      // ESCENARIO 4: Cliente existe y puede registrar → Registrar automáticamente
      if (verificacion.puedeRegistrar && verificacion.cliente != null) {
        final clienteId = verificacion.cliente!.idCliente;
        
        if (clienteId <= 0) {
          setState(() {
            _isProcessing = false;
          });
          _mostrarMensajeError('Error: No se pudo obtener el ID del cliente. Por favor, intenta nuevamente.');
          return;
        }

        // Actualizar mensaje de estado
        setState(() {
          _currentStatusMessage = 'Creando tu cuenta...';
        });

        // Registrar usuario automáticamente
        final registroSuccess = await authController.registrarCliente(login, correo, clienteId);

        setState(() {
          _isProcessing = false;
        });

        if (registroSuccess && context.mounted) {
          // Navegar a pantalla de éxito
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => RegisterSuccessScreen(
                login: login,
                correo: correo,
                emailEnviado: authController.registroResponse?.emailEnviado ?? false,
              ),
            ),
          );
        } else if (context.mounted) {
          // Mostrar error de registro
          _mostrarMensajeError(
            authController.registroErrorMessage ?? 
            'Error al crear tu cuenta. Por favor, intenta nuevamente.'
          );
        }
        return;
      }

      // Caso no esperado
      setState(() {
        _isProcessing = false;
      });
      _mostrarMensajeError('No se pudo procesar tu solicitud. Por favor, intenta nuevamente.');
    } catch (e) {
      setState(() {
        _isProcessing = false;
      });
      _mostrarMensajeError('Error inesperado: ${e.toString()}');
      print('Error en _handleRegistroCompleto: $e');
    }
  }

  /// Método para mostrar mensajes de error específicos
  void _mostrarMensajeError(String mensaje) {
    if (!context.mounted) return;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                mensaje,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// Método para mostrar diálogo cuando el login está ocupado
  void _mostrarDialogoLoginOcupado(String mensaje) {
    if (!context.mounted) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        title: Row(
          children: [
            Icon(Icons.error_outline, color: Colors.red.shade700, size: 24),
            const SizedBox(width: 8),
            const Expanded(
              child: Text(
                'Login no disponible',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        content: Text(
          mensaje,
          style: const TextStyle(
            fontSize: 14,
            color: Color(0xFF6b7280),
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF667eea),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Entendido'),
          ),
        ],
      ),
    );
  }

  /// Método para mostrar diálogo cuando el usuario ya existe
  void _mostrarDialogoUsuarioExistente() {
    if (!context.mounted) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        title: Row(
          children: [
            Icon(Icons.info_outline, color: Colors.blue.shade700, size: 24),
            const SizedBox(width: 8),
            const Expanded(
              child: Text(
                'Cuenta existente',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        content: const Text(
          'Ya tienes una cuenta registrada con este correo electrónico. Por favor, inicia sesión con tus credenciales.',
          style: TextStyle(
            fontSize: 14,
            color: Color(0xFF6b7280),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _navegarALogin();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF667eea),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Ir a inicio de sesión'),
          ),
        ],
      ),
    );
  }

  /// Método para navegar a la pantalla de creación de cliente
  void _navegarACrearCliente(String login, String correo) {
    if (!context.mounted) return;

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ClienteRegisterScreen(
          login: login,
          correo: correo,
        ),
      ),
    );
  }

  /// Método para navegar a la pantalla de login
  void _navegarALogin() {
    if (!context.mounted) return;

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (context) => const LoginScreen(),
      ),
      (route) => false,
    );
  }
}

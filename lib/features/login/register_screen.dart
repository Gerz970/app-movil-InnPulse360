import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/auth/controllers/auth_controller.dart';
import '../../core/theme/app_theme.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/app_button.dart';
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

class _RegisterScreenState extends State<RegisterScreen> 
    with SingleTickerProviderStateMixin {
  /// Controladores para los campos de texto
  final _loginController = TextEditingController();
  final _correoController = TextEditingController();
  
  /// Clave del formulario para validación
  final _formKey = GlobalKey<FormState>();
  
  /// Estado de procesamiento general
  bool _isProcessing = false;
  
  /// Mensaje de estado actual (para mostrar en el overlay de carga)
  String _currentStatusMessage = '';
  
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  
  @override
  void initState() {
    super.initState();
    // Animación de entrada
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));
    
    _animationController.forward();
  }
  
  @override
  void dispose() {
    _loginController.dispose();
    _correoController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.primary,
              AppColors.primaryLight,
              AppColors.primary.withOpacity(0.8),
            ],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // Círculos decorativos de fondo
              Positioned(
                top: -100,
                right: -100,
                child: Container(
                  width: 300,
                  height: 300,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.1),
                  ),
                ),
              ),
              Positioned(
                bottom: -150,
                left: -150,
                child: Container(
                  width: 400,
                  height: 400,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.1),
                  ),
                ),
              ),
              
              // Botón de regresar
              Positioned(
                top: 0,
                left: 0,
                child: IconButton(
                  icon: Icon(
                    Icons.arrow_back,
                    color: Colors.white,
                    size: 28,
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              
              // Contenido principal
              Center(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSpacing.xxxl,
                    vertical: AppSpacing.xxxl,
                  ),
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: Container(
                        constraints: BoxConstraints(
                          maxWidth: 420,
                          minHeight: screenHeight * 0.7,
                        ),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _buildHeader(),
                              SizedBox(height: AppSpacing.xxxl),
                              _buildRegisterCard(),
                            ],
                          ),
                        ),
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
                      padding: EdgeInsets.all(AppSpacing.xxl),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: AppRadius.mdBorder,
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
                                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                                  minHeight: 4,
                                  borderRadius: BorderRadius.circular(2),
                                ),
                                SizedBox(height: AppSpacing.lg),
                                Text(
                                  _currentStatusMessage,
                                  style: AppTextStyles.bodyLarge.copyWith(
                                    color: AppColors.textPrimary,
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
        ),
      ),
    );
  }

  /// Widget para construir el encabezado
  Widget _buildHeader() {
    return Column(
      children: [
        // Logo con efecto de elevación
        Container(
          padding: EdgeInsets.all(AppSpacing.xxl),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: ClipOval(
              child: Image.asset(
                'lib/assets/splash_logo.png',
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return Icon(
                    Icons.hotel,
                    size: 60,
                    color: AppColors.primary,
                  );
                },
              ),
            ),
          ),
        ),
        SizedBox(height: AppSpacing.xxxl),
        // Título con mejor estilo
        Text(
          'Crear Cuenta',
          style: AppTextStyles.h1.copyWith(
            color: Colors.white,
            fontSize: 32,
            fontWeight: FontWeight.bold,
            letterSpacing: -0.5,
            shadows: [
              Shadow(
                color: Colors.black.withOpacity(0.2),
                offset: const Offset(0, 2),
                blurRadius: 4,
              ),
            ],
          ),
        ),
        SizedBox(height: AppSpacing.sm),
        Text(
          'Comienza tu gestión hotelera',
          style: AppTextStyles.bodyLarge.copyWith(
            color: Colors.white.withOpacity(0.9),
            fontSize: 16,
            fontWeight: FontWeight.w400,
            shadows: [
              Shadow(
                color: Colors.black.withOpacity(0.1),
                offset: const Offset(0, 1),
                blurRadius: 2,
              ),
            ],
          ),
        ),
      ],
    );
  }
  
  /// Widget para construir la card de registro
  Widget _buildRegisterCard() {
    return Container(
      padding: EdgeInsets.all(AppSpacing.xxxl),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 30,
            offset: const Offset(0, 15),
            spreadRadius: 5,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Título del formulario
          Text(
            'Registro de Usuario',
            style: AppTextStyles.h2.copyWith(
              color: AppColors.textPrimary,
              fontSize: 24,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: AppSpacing.md),
          Text(
            'Ingresa tu correo y login para crear tu cuenta',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: AppSpacing.xxxl),
          
          // Formulario
          _buildForm(),
          SizedBox(height: AppSpacing.lg),
          _buildErrorMessage(),
          SizedBox(height: AppSpacing.lg),
          _buildRegistrarButton(),
          SizedBox(height: AppSpacing.xxl),
          _buildDivider(),
          SizedBox(height: AppSpacing.xxl),
          _buildFooterOption(),
        ],
      ),
    );
  }
  
  Widget _buildDivider() {
    return Row(
      children: [
        Expanded(
          child: Divider(
            color: AppColors.border,
            thickness: 1,
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: Text(
            'o',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textTertiary,
            ),
          ),
        ),
        Expanded(
          child: Divider(
            color: AppColors.border,
            thickness: 1,
          ),
        ),
      ],
    );
  }
  
  Widget _buildFooterOption() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          '¿Ya tienes una cuenta?',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        SizedBox(width: AppSpacing.xs),
        TextButton(
          onPressed: _navegarALogin,
          style: TextButton.styleFrom(
            padding: EdgeInsets.symmetric(
              horizontal: AppSpacing.xs,
              vertical: AppSpacing.xs,
            ),
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Text(
            'Inicia sesión',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  /// Widget para construir el formulario
  Widget _buildForm() {
    return Column(
      children: [
        AppTextField(
          controller: _loginController,
          label: 'Login',
          hint: 'Ingresa tu login',
          prefixIcon: Icons.person_outline,
          keyboardType: TextInputType.text,
          textInputAction: TextInputAction.next,
          enabled: !_isProcessing,
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
        ),
        SizedBox(height: AppSpacing.xl),
        AppTextField(
          controller: _correoController,
          label: 'Correo electrónico',
          hint: 'ejemplo@correo.com',
          prefixIcon: Icons.email_outlined,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.done,
          enabled: !_isProcessing,
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
        ),
      ],
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
            padding: EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.md,
            ),
            decoration: BoxDecoration(
              color: AppColors.errorLight,
              borderRadius: AppRadius.mdBorder,
              border: Border.all(
                color: AppColors.error.withOpacity(0.4),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.error_outline,
                  color: AppColors.error.withOpacity(0.7),
                  size: 20,
                ),
                SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    errorMessage,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.error.withOpacity(0.8),
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
    return Container(
      decoration: BoxDecoration(
        borderRadius: AppRadius.mdBorder,
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
            spreadRadius: 0,
          ),
        ],
      ),
      child: AppButton(
        text: 'Registrarse',
        onPressed: _isProcessing ? null : _handleRegistroCompleto,
        isLoading: _isProcessing,
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
        backgroundColor: AppColors.error,
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

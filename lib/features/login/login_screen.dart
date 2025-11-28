import 'package:flutter/material.dart'; //Es para uso de componentes visuales
import 'package:provider/provider.dart'; // es para escuchar cambios y actualizar UI
import '../../../core/auth/controllers/auth_controller.dart'; //controller de esta interfaz
import '../../../core/theme/app_theme.dart'; // sistema de diseño centralizado
import '../../../widgets/app_text_field.dart'; // campo de texto reutilizable
import '../../../widgets/app_button.dart'; // botón reutilizable
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

class _LoginScreenState extends State<LoginScreen> 
    with SingleTickerProviderStateMixin {
  /// Controladores para los campos de texto
  final _loginController = TextEditingController();
  final _passwordController = TextEditingController();
  
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
    _passwordController.dispose();
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
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildHeader(),
                            SizedBox(height: AppSpacing.xxxl),
                            _buildLoginCard(),
                          ],
                        ),
                      ),
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
          'InnPulse360',
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
          'Sistema de gestión hotelera',
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
  
  Widget _buildLoginCard() {
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
            'Iniciar Sesión',
            style: AppTextStyles.h2.copyWith(
              color: AppColors.textPrimary,
              fontSize: 24,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: AppSpacing.md),
          Text(
            'Ingresa tus credenciales para continuar',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: AppSpacing.xxxl),
          
          // Formulario
          _buildLoginForm(),
          SizedBox(height: AppSpacing.lg),
          _buildErrorMessage(),
          SizedBox(height: AppSpacing.lg),
          _buildLoginButton(),
          SizedBox(height: AppSpacing.xxl),
          _buildDivider(),
          SizedBox(height: AppSpacing.xxl),
          _buildFooterOptions(),
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
  
  Widget _buildFooterOptions() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '¿No tienes una cuenta?',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            SizedBox(width: AppSpacing.xs),
            TextButton(
              onPressed: _navigateToRegister,
              style: TextButton.styleFrom(
                padding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.xs,
                  vertical: AppSpacing.xs,
                ),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                'Regístrate',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLoginForm() {
    return Column(
      children: [
        AppTextField(
          controller: _loginController,
          label: 'Usuario',
          hint: 'Ingresa tu usuario',
          prefixIcon: Icons.person_outline,
          keyboardType: TextInputType.text,
          textInputAction: TextInputAction.next,
        ),
        SizedBox(height: AppSpacing.xl),
        AppTextField(
          controller: _passwordController,
          label: 'Contraseña',
          hint: '••••••••',
          prefixIcon: Icons.lock_outline,
          obscureText: true,
          textInputAction: TextInputAction.done,
        ),
        SizedBox(height: AppSpacing.md),
        _buildForgotPassword(),
      ],
    );
  }

  Widget _buildForgotPassword() {
    return Align(
      alignment: Alignment.centerRight,
      child: TextButton(
        onPressed: _navigateToForgotPassword,
        style: AppButtonStyles.text(context),
        child: const Text('¿Olvidaste tu contraseña?'),
      ),
    );
  }

  Widget _buildLoginButton() {
    return Consumer<AuthController>(
      builder: (context, authController, child) {
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
            text: 'Iniciar Sesión',
            onPressed: authController.isLoading ? null : _handleLogin,
            isLoading: authController.isLoading,
          ),
        );
      },
    );
  }


  Widget _buildErrorMessage() {
    return Consumer<AuthController>(
      builder: (context, authController, child) {
        if (authController.errorMessage != null && authController.errorMessage!.isNotEmpty) {
          return Container(
            padding: EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm + 2,
            ),
            decoration: BoxDecoration(
              color: AppColors.errorLight,
              borderRadius: AppRadius.smBorder,
              border: Border.all(
                color: AppColors.error.withOpacity(0.4),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: AppColors.error.withOpacity(0.7),
                  size: 16,
                ),
                SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    authController.errorMessage!,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.error.withOpacity(0.8),
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
        SnackBar(
          content: const Text('Por favor, completa todos los campos'),
          backgroundColor: AppColors.error,
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
            backgroundColor: AppColors.success,
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
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../../../core/auth/services/auth_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../../widgets/app_text_field.dart';
import '../../../widgets/app_button.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> 
    with SingleTickerProviderStateMixin {
  /// Controlador para el campo de correo electrónico
  final _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  String? _errorMessage;
  bool _emailSent = false;
  
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
    _emailController.dispose();
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
                  onPressed: () => Navigator.of(context).pop(),
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
                              if (_emailSent)
                                _buildSuccessCard()
                              else
                                _buildPasswordCard(),
                            ],
                          ),
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
        // Ícono de candado con efecto de elevación
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
            child: Icon(
              Icons.lock_reset,
              size: 60,
              color: AppColors.primary,
            ),
          ),
        ),
        SizedBox(height: AppSpacing.xxxl),
        // Título con mejor estilo
        Text(
          'Recuperar Contraseña',
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
          'Te ayudaremos a recuperar tu acceso',
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
  
  Widget _buildPasswordCard() {
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
            '¿Olvidaste tu contraseña?',
            style: AppTextStyles.h2.copyWith(
              color: AppColors.textPrimary,
              fontSize: 24,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: AppSpacing.md),
          Text(
            'Ingresa tu correo electrónico y te enviaremos una contraseña temporal',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: AppSpacing.xxxl),
          
          // Formulario
          _buildForm(),
          SizedBox(height: AppSpacing.lg),
          _buildSubmitButton(),
        ],
      ),
    );
  }
  
  Widget _buildSuccessCard() {
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
          _buildSuccessMessage(),
          SizedBox(height: AppSpacing.xxl),
          _buildBackToLoginButton(),
        ],
      ),
    );
  }

  Widget _buildForm() {
    return Column(
      children: [
        AppTextField(
          controller: _emailController,
          label: 'Correo Electrónico',
          hint: 'usuario@ejemplo.com',
          prefixIcon: Icons.email_outlined,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.done,
          enabled: !_isLoading,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Por favor, ingresa tu correo electrónico';
            }
            final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
            if (!emailRegex.hasMatch(value.trim())) {
              return 'Por favor, ingresa un correo electrónico válido';
            }
            return null;
          },
        ),
        SizedBox(height: AppSpacing.lg),
        if (_errorMessage != null) _buildErrorMessage(),
      ],
    );
  }

  Widget _buildErrorMessage() {
    if (_errorMessage == null) return const SizedBox.shrink();

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
            Icons.error_outline,
            color: AppColors.error.withOpacity(0.7),
            size: 16,
          ),
          SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              _errorMessage!,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.error.withOpacity(0.8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessMessage() {
    return Column(
      children: [
        Icon(
          Icons.check_circle_outline,
          color: AppColors.success,
          size: 64,
        ),
        SizedBox(height: AppSpacing.lg),
        Text(
          'Correo Enviado',
          style: AppTextStyles.h2.copyWith(
            color: AppColors.success,
            fontSize: 24,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: AppSpacing.md),
        Text(
          'Si el correo existe en nuestro sistema, se ha enviado una contraseña temporal.',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: AppSpacing.xxl),
        Container(
          padding: EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.warningLight,
            borderRadius: AppRadius.mdBorder,
            border: Border.all(
              color: AppColors.warning.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.info_outline,
                color: AppColors.warning,
                size: 20,
              ),
              SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  'La contraseña temporal expira en 7 días. Debes cambiarla al ingresar al sistema.',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.warning.withOpacity(0.9),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
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
        text: 'Enviar Contraseña Temporal',
        onPressed: _isLoading ? null : _handleRecoverPassword,
        isLoading: _isLoading,
      ),
    );
  }

  Widget _buildBackToLoginButton() {
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
        text: 'Volver al Inicio de Sesión',
        onPressed: () {
          Navigator.of(context).pop();
        },
      ),
    );
  }

  Future<void> _handleRecoverPassword() async {
    // Limpiar mensaje de error anterior
    setState(() {
      _errorMessage = null;
    });

    // Validar formulario
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final correo = _emailController.text.trim();

    setState(() {
      _isLoading = true;
    });

    try {
      final authService = AuthService();
      final response = await authService.recuperarPassword(correo);

      if (response.statusCode == 200) {
        // Mostrar mensaje de éxito
        setState(() {
          _isLoading = false;
          _emailSent = true;
          _errorMessage = null;
        });
      } else {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Error al procesar la solicitud. Por favor, intenta nuevamente.';
        });
      }
    } on DioException catch (e) {
      setState(() {
        _isLoading = false;
      });

      if (e.response != null) {
        // Error con respuesta del servidor
        final statusCode = e.response?.statusCode;
        final errorData = e.response?.data;

        if (statusCode == 400 || statusCode == 422) {
          // Error de validación
          if (errorData is Map && errorData.containsKey('detail')) {
            _errorMessage = errorData['detail'].toString();
          } else {
            _errorMessage = 'Por favor, verifica que el correo electrónico sea válido.';
          }
        } else {
          // Otro error del servidor
          _errorMessage = 'Error del servidor. Por favor, intenta nuevamente más tarde.';
        }
      } else {
        // Error de conexión
        _errorMessage = 'Error de conexión. Por favor, verifica tu conexión a internet.';
      }

      setState(() {
        _errorMessage = _errorMessage;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Error inesperado. Por favor, intenta nuevamente.';
      });
    }
  }
}


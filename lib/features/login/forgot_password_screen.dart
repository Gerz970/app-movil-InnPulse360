import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../../../core/auth/services/auth_service.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  /// Controlador para el campo de correo electrónico
  final _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  String? _errorMessage;
  bool _emailSent = false;

  @override
  void dispose() {
    _emailController.dispose();
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
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Recuperar Contraseña',
          style: TextStyle(
            color: Color(0xFF1a1a1a),
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(32.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 48),
                  if (_emailSent)
                    _buildSuccessMessage()
                  else
                    _buildForm(),
                  const SizedBox(height: 24),
                  if (!_emailSent) _buildSubmitButton(),
                  if (_emailSent) _buildBackToLoginButton(),
                ],
              ),
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
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: const Color(0xFF667eea).withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.lock_reset,
            size: 40,
            color: Color(0xFF667eea),
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          '¿Olvidaste tu contraseña?',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1a1a1a),
            letterSpacing: -0.5,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        Text(
          _emailSent
              ? 'Revisa tu correo electrónico para obtener tu contraseña temporal'
              : 'Ingresa tu correo electrónico y te enviaremos una contraseña temporal',
          style: const TextStyle(
            fontSize: 14,
            color: Color(0xFF6b7280),
            fontWeight: FontWeight.w400,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildForm() {
    return Column(
      children: [
        _buildEmailField(),
        const SizedBox(height: 16),
        if (_errorMessage != null) _buildErrorMessage(),
      ],
    );
  }

  Widget _buildEmailField() {
    return TextFormField(
      controller: _emailController,
      keyboardType: TextInputType.emailAddress,
      textInputAction: TextInputAction.done,
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Por favor, ingresa tu correo electrónico';
        }
        if (!value.contains('@') || !value.contains('.')) {
          return 'Por favor, ingresa un correo electrónico válido';
        }
        return null;
      },
      decoration: InputDecoration(
        labelText: 'Correo Electrónico',
        hintText: 'usuario@ejemplo.com',
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
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: Color(0xFFDC2626),
            width: 1,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: Color(0xFFDC2626),
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
    );
  }

  Widget _buildErrorMessage() {
    if (_errorMessage == null) return const SizedBox.shrink();

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
            Icons.error_outline,
            color: const Color(0xFFDC2626).withOpacity(0.7),
            size: 16,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _errorMessage!,
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

  Widget _buildSuccessMessage() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFF0FDF4).withOpacity(0.6),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF86EFAC).withOpacity(0.4),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.check_circle_outline,
            color: const Color(0xFF16A34A),
            size: 48,
          ),
          const SizedBox(height: 16),
          const Text(
            'Correo Enviado',
            style: TextStyle(
              color: Color(0xFF16A34A),
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Si el correo existe en nuestro sistema, se ha enviado una contraseña temporal.',
            style: TextStyle(
              color: const Color(0xFF166534).withOpacity(0.8),
              fontSize: 14,
              fontWeight: FontWeight.w400,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFFEF3C7).withOpacity(0.5),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: const Color(0xFFD97706),
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'La contraseña temporal expira en 7 días. Debes cambiarla al ingresar al sistema.',
                    style: TextStyle(
                      color: const Color(0xFF92400E).withOpacity(0.8),
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _handleRecoverPassword,
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
        child: _isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Text(
                'Enviar Contraseña Temporal',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
      ),
    );
  }

  Widget _buildBackToLoginButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: () {
          Navigator.of(context).pop();
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF667eea),
          foregroundColor: Colors.white,
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: const Text(
          'Volver al Inicio de Sesión',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
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


import 'package:flutter/material.dart';
import 'login_screen.dart';

/// Pantalla de éxito de registro
/// Muestra mensaje de confirmación y opción para ir a login
class RegisterSuccessScreen extends StatelessWidget {
  /// Login del usuario registrado
  final String login;
  
  /// Correo electrónico del usuario registrado
  final String correo;
  
  /// Indica si se envió el email con las credenciales
  final bool emailEnviado;

  const RegisterSuccessScreen({
    super.key,
    required this.login,
    required this.correo,
    required this.emailEnviado,
  });

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
                _buildSuccessIcon(),
                const SizedBox(height: 32),
                _buildTitle(),
                const SizedBox(height: 16),
                _buildMessage(),
                const SizedBox(height: 32),
                _buildInfoCard(),
                const SizedBox(height: 48),
                _buildLoginButton(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Widget para el ícono de éxito
  Widget _buildSuccessIcon() {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        shape: BoxShape.circle,
      ),
      child: Icon(
        Icons.check_circle,
        size: 80,
        color: Colors.green.shade600,
      ),
    );
  }

  /// Widget para el título
  Widget _buildTitle() {
    return const Text(
      '¡Registro exitoso!',
      style: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        color: Color(0xFF1a1a1a),
        letterSpacing: -0.5,
      ),
      textAlign: TextAlign.center,
    );
  }

  /// Widget para el mensaje principal
  Widget _buildMessage() {
    return Text(
      'Tu cuenta ha sido creada exitosamente.',
      style: TextStyle(
        fontSize: 16,
        color: const Color(0xFF6b7280),
        fontWeight: FontWeight.w400,
      ),
      textAlign: TextAlign.center,
    );
  }

  /// Widget para la tarjeta de información
  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.email_outlined,
                color: Colors.blue.shade700,
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  emailEnviado
                      ? 'Credenciales enviadas'
                      : 'Credenciales pendientes',
                  style: TextStyle(
                    color: Colors.blue.shade700,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            emailEnviado
                ? 'Se han enviado tus credenciales de acceso al correo electrónico:'
                : 'Las credenciales de acceso se enviarán al correo electrónico:',
            style: TextStyle(
              color: const Color(0xFF1a1a1a),
              fontSize: 14,
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.email,
                  color: Colors.blue.shade700,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    correo,
                    style: const TextStyle(
                      color: Color(0xFF1a1a1a),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (emailEnviado) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green.shade200),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: Colors.green.shade700,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Revisa tu bandeja de entrada y spam para encontrar tus credenciales.',
                      style: TextStyle(
                        color: Colors.green.shade700,
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Widget para el botón de ir a login
  Widget _buildLoginButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: () {
          // Limpiar el stack de navegación y ir a login
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (context) => const LoginScreen(),
            ),
            (route) => false,
          );
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
          'Ir a inicio de sesión',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }
}


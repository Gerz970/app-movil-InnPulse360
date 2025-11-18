import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/perfil_controller.dart';
import '../models/cambiar_password_model.dart';

/// Pantalla para cambiar la contraseña del usuario
/// Incluye validaciones de coincidencia y fortaleza
class CambiarPasswordScreen extends StatefulWidget {
  const CambiarPasswordScreen({super.key});

  @override
  State<CambiarPasswordScreen> createState() => _CambiarPasswordScreenState();
}

class _CambiarPasswordScreenState extends State<CambiarPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _passwordActualController = TextEditingController();
  final _passwordNuevaController = TextEditingController();
  final _passwordConfirmacionController = TextEditingController();
  
  bool _ocultarPasswordActual = true;
  bool _ocultarPasswordNueva = true;
  bool _ocultarPasswordConfirmacion = true;

  @override
  void dispose() {
    _passwordActualController.dispose();
    _passwordNuevaController.dispose();
    _passwordConfirmacionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      appBar: AppBar(
        title: const Text('Cambiar contraseña'),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1a1a1a),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 16),
              // Información
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF667eea).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFF667eea).withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.info_outline,
                      color: Color(0xFF667eea),
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'La contraseña debe tener al menos 6 caracteres',
                        style: TextStyle(
                          fontSize: 14,
                          color: const Color(0xFF667eea).withOpacity(0.9),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              // Campo Contraseña actual
              TextFormField(
                controller: _passwordActualController,
                obscureText: _ocultarPasswordActual,
                decoration: InputDecoration(
                  labelText: 'Contraseña actual',
                  hintText: 'Ingresa tu contraseña actual',
                  prefixIcon: const Icon(Icons.lock_outlined),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _ocultarPasswordActual
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                    ),
                    onPressed: () {
                      setState(() {
                        _ocultarPasswordActual = !_ocultarPasswordActual;
                      });
                    },
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: const Color(0xFFf9fafb),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'La contraseña actual es requerida';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              // Campo Nueva contraseña
              TextFormField(
                controller: _passwordNuevaController,
                obscureText: _ocultarPasswordNueva,
                decoration: InputDecoration(
                  labelText: 'Nueva contraseña',
                  hintText: 'Ingresa tu nueva contraseña',
                  prefixIcon: const Icon(Icons.lock_outlined),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _ocultarPasswordNueva
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                    ),
                    onPressed: () {
                      setState(() {
                        _ocultarPasswordNueva = !_ocultarPasswordNueva;
                      });
                    },
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: const Color(0xFFf9fafb),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'La nueva contraseña es requerida';
                  }
                  if (value.length < 6) {
                    return 'La contraseña debe tener al menos 6 caracteres';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              // Campo Confirmar nueva contraseña
              TextFormField(
                controller: _passwordConfirmacionController,
                obscureText: _ocultarPasswordConfirmacion,
                decoration: InputDecoration(
                  labelText: 'Confirmar nueva contraseña',
                  hintText: 'Confirma tu nueva contraseña',
                  prefixIcon: const Icon(Icons.lock_outlined),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _ocultarPasswordConfirmacion
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                    ),
                    onPressed: () {
                      setState(() {
                        _ocultarPasswordConfirmacion = !_ocultarPasswordConfirmacion;
                      });
                    },
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: const Color(0xFFf9fafb),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'La confirmación es requerida';
                  }
                  if (value != _passwordNuevaController.text) {
                    return 'Las contraseñas no coinciden';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),
              // Botón Cambiar contraseña
              Consumer<PerfilController>(
                builder: (context, controller, child) {
                  return ElevatedButton(
                    onPressed: controller.isChangingPassword
                        ? null
                        : () => _cambiarPassword(controller),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF667eea),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: controller.isChangingPassword
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Text(
                            'Cambiar contraseña',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  );
                },
              ),
              // Mostrar error si existe
              Consumer<PerfilController>(
                builder: (context, controller, child) {
                  if (controller.changePasswordError != null) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.red.withOpacity(0.3)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.error_outline, color: Colors.red, size: 20),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                controller.changePasswordError!,
                                style: const TextStyle(color: Colors.red, fontSize: 14),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _cambiarPassword(PerfilController controller) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Obtener login del usuario actual
    final usuario = controller.usuarioPerfil;
    if (usuario == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No se pudo obtener la información del usuario'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final datos = CambiarPasswordModel(
      login: usuario.login,
      passwordActual: _passwordActualController.text,
      passwordNueva: _passwordNuevaController.text,
      passwordConfirmacion: _passwordConfirmacionController.text,
    );

    // Validar que las contraseñas coincidan
    if (!datos.passwordsCoinciden) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Las contraseñas no coinciden'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Validar fortaleza mínima
    if (!datos.passwordValida) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('La contraseña debe tener al menos 6 caracteres'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final success = await controller.cambiarPassword(datos);

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Contraseña cambiada correctamente. Por favor, inicia sesión nuevamente.'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 4),
          ),
        );
        // Limpiar campos
        _passwordActualController.clear();
        _passwordNuevaController.clear();
        _passwordConfirmacionController.clear();
        // Regresar a la pantalla anterior después de un breve delay
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            Navigator.pop(context);
          }
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              controller.changePasswordError ?? 'Error al cambiar contraseña',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}


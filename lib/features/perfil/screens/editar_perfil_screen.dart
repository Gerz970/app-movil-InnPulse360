import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/perfil_controller.dart';
import '../models/perfil_update_model.dart';

/// Pantalla para editar el perfil del usuario
/// Permite modificar login y correo electrónico
class EditarPerfilScreen extends StatefulWidget {
  const EditarPerfilScreen({super.key});

  @override
  State<EditarPerfilScreen> createState() => _EditarPerfilScreenState();
}

class _EditarPerfilScreenState extends State<EditarPerfilScreen> {
  final _formKey = GlobalKey<FormState>();
  final _loginController = TextEditingController();
  final _correoController = TextEditingController();
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    // Cargar datos del perfil al iniciar
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _cargarDatosPerfil();
    });
  }

  @override
  void dispose() {
    _loginController.dispose();
    _correoController.dispose();
    super.dispose();
  }

  void _cargarDatosPerfil() {
    final controller = context.read<PerfilController>();
    final usuario = controller.usuarioPerfil;
    
    if (usuario != null) {
      _loginController.text = usuario.login;
      _correoController.text = usuario.correoElectronico;
      setState(() {
        _isInitialized = true;
      });
    } else {
      // Si no hay perfil cargado, intentar cargarlo
      controller.cargarPerfil().then((success) {
        if (success && mounted) {
          final usuario = controller.usuarioPerfil;
          if (usuario != null) {
            _loginController.text = usuario.login;
            _correoController.text = usuario.correoElectronico;
            setState(() {
              _isInitialized = true;
            });
          }
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      appBar: AppBar(
        title: const Text('Editar perfil'),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1a1a1a),
      ),
      body: Consumer<PerfilController>(
        builder: (context, controller, child) {
          if (!_isInitialized && controller.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (controller.usuarioPerfil == null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Colors.red.withOpacity(0.5),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'No se pudo cargar el perfil',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () {
                        controller.cargarPerfil().then((success) {
                          if (success) {
                            _cargarDatosPerfil();
                          }
                        });
                      },
                      child: const Text('Reintentar'),
                    ),
                  ],
                ),
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 16),
                  // Campo Login
                  TextFormField(
                    controller: _loginController,
                    decoration: InputDecoration(
                      labelText: 'Login',
                      hintText: 'Ingresa tu login',
                      prefixIcon: const Icon(Icons.person_outline),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: const Color(0xFFf9fafb),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'El login es requerido';
                      }
                      if (value.length > 25) {
                        return 'El login no puede tener más de 25 caracteres';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  // Campo Correo electrónico
                  TextFormField(
                    controller: _correoController,
                    decoration: InputDecoration(
                      labelText: 'Correo electrónico',
                      hintText: 'Ingresa tu correo electrónico',
                      prefixIcon: const Icon(Icons.email_outlined),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: const Color(0xFFf9fafb),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'El correo electrónico es requerido';
                      }
                      if (value.length > 50) {
                        return 'El correo no puede tener más de 50 caracteres';
                      }
                      // Validación básica de email
                      final emailRegex = RegExp(
                        r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
                      );
                      if (!emailRegex.hasMatch(value)) {
                        return 'Ingresa un correo electrónico válido';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 32),
                  // Botón Guardar
                  ElevatedButton(
                    onPressed: controller.isUpdatingProfile
                        ? null
                        : () => _guardarPerfil(controller),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF667eea),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: controller.isUpdatingProfile
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Text(
                            'Guardar cambios',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                  // Mostrar error si existe
                  if (controller.updateProfileError != null) ...[
                    const SizedBox(height: 16),
                    Container(
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
                              controller.updateProfileError!,
                              style: const TextStyle(color: Colors.red, fontSize: 14),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _guardarPerfil(PerfilController controller) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final datos = PerfilUpdate(
      login: _loginController.text.trim(),
      correoElectronico: _correoController.text.trim(),
    );

    final success = await controller.actualizarPerfil(datos);

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Perfil actualizado correctamente'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              controller.updateProfileError ?? 'Error al actualizar perfil',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}


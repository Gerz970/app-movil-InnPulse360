import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../widgets/app_header.dart';
import '../../widgets/app_sidebar.dart';
import 'controllers/piso_controller.dart';
import 'models/piso_model.dart';

class PisoEditScreen extends StatefulWidget {
  final Piso piso;

  const PisoEditScreen({
    super.key,
    required this.piso,
  });

  @override
  State<PisoEditScreen> createState() => _PisoEditScreenState();
}

class _PisoEditScreenState extends State<PisoEditScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nivelController;
  late TextEditingController _nombreController;
  late TextEditingController _descripcionController;

  @override
  void initState() {
    super.initState();

    _nivelController = TextEditingController(text: widget.piso.nivel.toString());
    _nombreController = TextEditingController(text: widget.piso.nombre);
    _descripcionController = TextEditingController(text: widget.piso.descripcion);
  }

  @override
  void dispose() {
    _nivelController.dispose();
    _nombreController.dispose();
    _descripcionController.dispose();
    super.dispose();
  }

  Future<void> _guardarCambios(BuildContext context, PisoController controller) async {
    if (!_formKey.currentState!.validate()) return;

    final pisoEditado = Piso(
      idPiso: widget.piso.idPiso,
      idHotel: widget.piso.idHotel,
      nivel: int.parse(_nivelController.text),
      nombre: _nombreController.text.trim(),
      descripcion: _descripcionController.text.trim(),
      idEstatus: widget.piso.idEstatus,
    );

    await controller.actualizarPiso(pisoEditado);
    final pisoController = Provider.of<PisoController>(context, listen: false);
    await pisoController.cargarPisosPorHotel(context);
    if (!mounted) return;

    if (controller.error == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Piso actualizado correctamente")),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: ${controller.error}")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      drawer: const AppSidebar(),
      body: SafeArea(
        child: Column(
          children: [
            const AppHeader(),
            Expanded(
              child: Consumer<PisoController>(
                builder: (context, controller, child) {
                  return Stack(
                    children: [
                      _buildForm(context, controller),

                      if (controller.isLoading)
                        Container(
                          color: Colors.black.withOpacity(0.35),
                          child: const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CircularProgressIndicator(color: Color(0xFF667eea)),
                                SizedBox(height: 16),
                                Text(
                                  'Guardando cambios...',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildForm(BuildContext context, PisoController controller) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Título + menú contextual
            Row(
              children: [
                const Expanded(
                  child: Text(
                    "Editar piso",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1a1a1a),
                    ),
                  ),
                ),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert, color: Color(0xFF6b7280)),
                  onSelected: (value) {
                    if (value == "delete") _showDeleteDialog(context, controller);
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: "delete",
                      child: Row(
                        children: [
                          Icon(Icons.delete, color: Colors.red),
                          SizedBox(width: 8),
                          Text("Eliminar piso", style: TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                  ],
                )
              ],
            ),

            const SizedBox(height: 8),
            const Text(
              "Editar información del piso",
              style: TextStyle(fontSize: 14, color: Color(0xFF6b7280)),
            ),
            const SizedBox(height: 32),

            // Campo: Nivel
            _buildTextField(
              controller: _nivelController,
              label: "Nivel del piso",
              hint: "Ingresa el nivel",
              icon: Icons.stairs,
              keyboardType: TextInputType.number,
              validator: (v) => v == null || v.isEmpty ? "Ingresa el nivel" : null,
            ),
            const SizedBox(height: 20),

            // Campo: Nombre
            _buildTextField(
              controller: _nombreController,
              label: "Nombre",
              hint: "Ingresa el nombre del piso",
              icon: Icons.title,
              validator: (v) => v == null || v.isEmpty ? "Ingresa un nombre" : null,
            ),
            const SizedBox(height: 20),

            // Campo: Descripción
            _buildTextField(
              controller: _descripcionController,
              label: "Descripción",
              hint: "Descripción opcional",
              icon: Icons.description,
            ),
            const SizedBox(height: 32),

            // Botones
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF667eea),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      side: const BorderSide(color: Color(0xFF667eea)),
                    ),
                    child: const Text("Cancelar",
                        style: TextStyle(fontWeight: FontWeight.w600)),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: controller.isLoading
                        ? null
                        : () => _guardarCambios(context, controller),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF667eea),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      disabledBackgroundColor: const Color(0xFF9ca3af),
                    ),
                    child: const Text(
                      "Guardar cambios",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, PisoController controller) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("¿Eliminar piso?"),
          content: const Text("Esta acción no se puede deshacer."),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancelar"),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);
                if (!mounted) return;

                if (controller.error == null) {
                  Navigator.pop(context);
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text("Eliminar"),
            )
          ],
        );
      },
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: const Color(0xFF6b7280)),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFe5e7eb)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF667eea), width: 2),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../../widgets/app_header.dart';
import '../../widgets/app_sidebar.dart';
import 'models/piso_model.dart';
import 'services/piso_service.dart';

class PisoCreateScreen extends StatefulWidget {
  const PisoCreateScreen({Key? key}) : super(key: key);

  @override
  State<PisoCreateScreen> createState() => _PisoCreateScreenState();
}

class _PisoCreateScreenState extends State<PisoCreateScreen> {
  final _formKey = GlobalKey<FormState>();

  final _idHotelController = TextEditingController();
  final _nivelController = TextEditingController();
  final _nombreController = TextEditingController();
  final _descripcionController = TextEditingController();
  final PisoService _pisoService = PisoService();

  bool _isSaving = false;

  @override
  void dispose() {
    _idHotelController.dispose();
    _nivelController.dispose();
    _nombreController.dispose();
    _descripcionController.dispose();
    super.dispose();
  }

  Future<void> _guardarPiso() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final piso = PisoCreateModel(
      idHotel: int.parse(_idHotelController.text),
      nivel: int.parse(_nivelController.text),
      nombre: _nombreController.text.trim(),
      descripcion: _descripcionController.text.trim(),
      idEstatus: 1,
    );

    final result = await _pisoService.createPiso(piso);

    setState(() => _isSaving = false);

    if (!mounted) return;

    if (result != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Piso registrado correctamente')),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al registrar el piso')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppSidebar(),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: const [
                AppHeader(),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(top: 80),
              child: _buildForm(),
            ),
            if (_isSaving)
              Container(
                color: Colors.black.withOpacity(0.3),
                child: const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(color: Color(0xFF667eea)),
                      SizedBox(height: 16),
                      Text(
                        "Guardando piso...",
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ],
                  ),
                ),
              )
          ],
        ),
      ),
    );
  }

  Widget _buildForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Registrar piso',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1a1a1a),
              ),
            ),
            
            const SizedBox(height: 20),

            _buildTextField(
              controller: _nivelController,
              label: "Nivel del piso",
              hint: "Ejemplo: 1, 2, 3...",
              icon: Icons.layers,
              keyboardType: TextInputType.number,
              validator: (value) =>
                  value!.isEmpty ? "Ingresa el nivel del piso" : null,
            ),
            const SizedBox(height: 20),

            _buildTextField(
              controller: _nombreController,
              label: "Nombre",
              hint: "Ejemplo: Piso Ejecutivo",
              icon: Icons.text_fields,
              validator: (value) =>
                  value!.isEmpty ? "Ingresa un nombre" : null,
            ),
            const SizedBox(height: 20),

            _buildTextField(
              controller: _descripcionController,
              label: "Descripción",
              hint: "Describe el piso",
              icon: Icons.description,
              validator: (value) =>
                  value!.isEmpty ? "Ingresa una descripción" : null,
            ),
            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _guardarPiso,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF667eea),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  disabledBackgroundColor: const Color(0xFF9ca3af),
                ),
                child: const Text(
                  "Guardar Piso",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            )
          ],
        ),
      ),
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
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: Color(0xFF6b7280)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFe5e7eb)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF667eea), width: 2),
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
    );
  }
}

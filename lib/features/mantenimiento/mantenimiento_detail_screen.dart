import 'dart:typed_data';
import 'package:app_movil_innpulse/features/mantenimiento/controllers/mantenimiento_controller.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'models/mantenimiento_model.dart';
import '../../widgets/app_sidebar.dart';
import '../../widgets/app_header.dart';
import 'package:provider/provider.dart';

class MantenimientoDetailScreen extends StatefulWidget {
  final Mantenimiento mantenimiento;

  const MantenimientoDetailScreen({
    super.key,
    required this.mantenimiento,
  });

  @override
  State<MantenimientoDetailScreen> createState() =>
      _MantenimientoDetailScreenState();
}

class _MantenimientoDetailScreenState extends State<MantenimientoDetailScreen> {
  List<XFile> _fotosSeleccionadas = [];
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final controller =
          Provider.of<MantenimientoController>(context, listen: false);

      controller.fetchGaleria(widget.mantenimiento.idMantenimiento);
    });
  }

  Future<void> _elegirFoto(BuildContext context) async {
    final controller =
        Provider.of<MantenimientoController>(context, listen: false);

    final XFile? foto = await _picker.pickImage(source: ImageSource.camera);

    if (foto == null) return;

    final success = await controller.uploadPhoto(
      widget.mantenimiento.idMantenimiento,
      foto,
      'despues'
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(success ? "Foto subida con éxito" : "Error al subir foto")),
    );
  }

  // ------------------------------------------------------------
  // Abrir formulario para TERMINAR mantenimiento
  // ------------------------------------------------------------
  void _mostrarFormularioTerminar() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return _FormularioTerminarMantenimiento(
          mantenimientoId: widget.mantenimiento.idMantenimiento,
          fotosSeleccionadas: _fotosSeleccionadas,
          picker: _picker,
          onTerminar: _terminarMantenimiento,
        );
      },
    );
  }

  // Recibir fotos y enviarlas al backend
  Future<void> _terminarMantenimiento(List<XFile> fotos) async {
    if (fotos.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Debes subir al menos una foto')),
      );
      return;
    }

    final controller = Provider.of<MantenimientoController>(context, listen: false);
    
    // Subir todas las fotos
    bool todasSubidas = true;
    for (var foto in fotos) {
      final success = await controller.uploadPhoto(
        widget.mantenimiento.idMantenimiento,
        foto,
        'despues',
      );
      if (!success) {
        todasSubidas = false;
      }
    }

    if (!todasSubidas) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error al subir algunas fotos'),
            backgroundColor: Colors.orange,
          ),
        );
      }
      return;
    }

    final success = await controller.cambiarEstatusMantenimiento(widget.mantenimiento.idMantenimiento);

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Limpieza terminada correctamente'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(controller.errorMessage ?? 'Error al terminar limpieza'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final estatusColor = const Color(0xFF22c55e);

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      drawer: const AppSidebar(),
      body: SafeArea(
        child: Column(
          children: [
            const AppHeader(),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildBackButton(context),
                    const SizedBox(height: 16),

                    const Text(
                      'Detalle del Mantenimiento',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1a1a1a),
                      ),
                    ),

                    const SizedBox(height: 20),

                    _buildDetalleMantenimientoCard(
                      context,
                      widget.mantenimiento,
                      estatusColor,
                    ),

                    const SizedBox(height: 30),

                    // ---------------------------------------------------
                    // BOTÓN FINALIZAR — corregido el error
                    // ---------------------------------------------------
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF2196F3).withOpacity(0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ElevatedButton.icon(
                        onPressed: _mostrarFormularioTerminar,
                        icon: const Icon(Icons.check_circle_rounded, size: 22),
                        label: const Text(
                          'Terminar Mantenimiento',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF22c55e),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                      ),
                    ),

                    const SizedBox(height: 40),

                    _buildGaleria(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ------------------------------ UI ------------------------------

  Widget _buildDetalleMantenimientoCard(
    BuildContext context,
    Mantenimiento mantenimiento,
    Color estatusColor,
  ) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [estatusColor.withOpacity(0.1), Colors.white],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: estatusColor.withOpacity(0.2), width: 1.5),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: estatusColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.build_rounded,
                    color: estatusColor, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  mantenimiento.descripcion,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          Row(
            children: [
              Expanded(
                child: _buildInfoCard(
                  Icons.calendar_today_rounded,
                  'Fecha',
                  mantenimiento.fechaFormateada,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildInfoCard(
                  Icons.build_circle_rounded,
                  'Tipo',
                  'No especificado',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBackButton(BuildContext context) {
    return InkWell(
      onTap: () => Navigator.pop(context),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.arrow_back_rounded, color: Colors.grey.shade700),
            const SizedBox(width: 8),
            Text(
              'Regresar al listado',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        color: Colors.white,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: Colors.grey.shade600),
              const SizedBox(width: 6),
              Text(label,
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 11)),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGaleria() {
    return Consumer<MantenimientoController>(
      builder: (context, controller, child) {
        if (controller.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.galeriaImagenes.isEmpty) {
          return const SizedBox.shrink();
        }

        return GridView.builder(
          shrinkWrap: true,
          itemCount: controller.galeriaImagenes.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemBuilder: (context, index) {
            final foto = controller.galeriaImagenes[index];
            return ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(foto.ruta, fit: BoxFit.cover),
            );
          },
        );
      },
    );
  }
}

class _FormularioTerminarMantenimiento extends StatefulWidget {
  final int mantenimientoId;
  final List<XFile> fotosSeleccionadas;
  final ImagePicker picker;
  final Future<void> Function(List<XFile> fotos) onTerminar;

  const _FormularioTerminarMantenimiento({
    required this.mantenimientoId,
    required this.fotosSeleccionadas,
    required this.picker,
    required this.onTerminar,
  });

  @override
  State<_FormularioTerminarMantenimiento> createState() =>
      _FormularioTerminarMantenimientoState();
}

class _FormularioTerminarMantenimientoState
    extends State<_FormularioTerminarMantenimiento> {
  bool _isSubiendo = false;
  Map<int, Uint8List> _fotoBytes = {};

  Future<void> _seleccionarFotos() async {
    if (widget.fotosSeleccionadas.length >= 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Máximo 5 fotos')),
      );
      return;
    }

    final fotos = await widget.picker.pickMultiImage(
      maxHeight: 1800,
      maxWidth: 1800,
      imageQuality: 85,
    );

    if (fotos == null) return;

    final disponibles = 5 - widget.fotosSeleccionadas.length;
    final agregar = fotos.take(disponibles).toList();

    for (var x in agregar) {
      _fotoBytes[widget.fotosSeleccionadas.length + agregar.indexOf(x)] =
          await x.readAsBytes();
    }

    setState(() {
      widget.fotosSeleccionadas.addAll(agregar);
    });
  }

  Future<void> _finalizar() async {
    if (widget.fotosSeleccionadas.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Debes subir mínimo 1 foto')),
      );
      return;
    }

    setState(() => _isSubiendo = true);

    await widget.onTerminar(widget.fotosSeleccionadas);

    if (!mounted) return;

    setState(() => _isSubiendo = false);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            "Terminar Mantenimiento",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
          ),

          const SizedBox(height: 16),

          OutlinedButton.icon(
            icon: const Icon(Icons.add_photo_alternate),
            onPressed: widget.fotosSeleccionadas.length >= 5
                ? null
                : _seleccionarFotos,
            label: Text(
                "Agregar Fotos (${widget.fotosSeleccionadas.length}/5)"),
          ),

          if (widget.fotosSeleccionadas.isNotEmpty)
            SizedBox(
              height: 110,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: widget.fotosSeleccionadas.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.memory(
                            _fotoBytes[index]!,
                            width: 100,
                            height: 100,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Positioned(
                          right: 4,
                          top: 4,
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                widget.fotosSeleccionadas.removeAt(index);
                                _fotoBytes.clear();
                              });
                            },
                            child: const CircleAvatar(
                              radius: 12,
                              backgroundColor: Colors.red,
                              child: Icon(Icons.close,
                                  color: Colors.white, size: 16),
                            ),
                          ),
                        )
                      ],
                    ),
                  );
                },
              ),
            ),

          const SizedBox(height: 16),

          ElevatedButton(
            onPressed: _isSubiendo ? null : _finalizar,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF22c55e),
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: _isSubiendo
                ? const CircularProgressIndicator(color: Colors.white)
                : const Text("Finalizar"),
          ),

          const SizedBox(height: 12),
        ],
      ),
    );
  }
}

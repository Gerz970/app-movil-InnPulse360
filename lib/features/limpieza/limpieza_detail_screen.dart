import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../../widgets/app_header.dart';
import '../../widgets/app_sidebar.dart';
import 'controllers/limpieza_controller.dart';
import 'models/limpieza_model.dart';

class LimpiezaDetailScreen extends StatefulWidget {
  final Limpieza limpieza;

  const LimpiezaDetailScreen({
    required this.limpieza,
    super.key,
  });

  @override
  State<LimpiezaDetailScreen> createState() => _LimpiezaDetailScreenState();
}

class _LimpiezaDetailScreenState extends State<LimpiezaDetailScreen> {
  final ImagePicker _picker = ImagePicker();
  final TextEditingController _comentarioController = TextEditingController();
  List<XFile> _fotosSeleccionadas = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _cargarGaleria();
    });
  }

  @override
  void dispose() {
    _comentarioController.dispose();
    super.dispose();
  }

  Future<void> _cargarGaleria() async {
    final controller = Provider.of<LimpiezaController>(context, listen: false);
    await controller.fetchGaleria(widget.limpieza.idLimpieza, null);
  }

  @override
  Widget build(BuildContext context) {
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
                    _buildBackButton(),
                    const SizedBox(height: 16),
                    const Text(
                      'Detalle de Limpieza',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1a1a1a),
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 24),
                    _buildInformacionLimpieza(),
                    const SizedBox(height: 24),
                    _buildAcciones(),
                    const SizedBox(height: 24),
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

  Widget _buildBackButton() {
    return InkWell(
      onTap: () => Navigator.pop(context),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.grey.shade200,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.arrow_back_rounded,
              color: Colors.grey.shade700,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              'Regresar al listado',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInformacionLimpieza() {
    final estatusColor = Color(widget.limpieza.estatusLimpiezaColor);
    
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            estatusColor.withOpacity(0.1),
            Colors.white,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: estatusColor.withOpacity(0.2),
          width: 1.5,
        ),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header con icono y título
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: estatusColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.cleaning_services_rounded,
                  color: estatusColor,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Información de Limpieza',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.limpieza.habitacionArea.nombreClave,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1a1a1a),
                        letterSpacing: -0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // Información detallada en grid
          Row(
            children: [
              Expanded(
                child: _buildInfoCard(
                  Icons.category_rounded,
                  'Tipo',
                  widget.limpieza.tipoLimpieza.nombreTipo,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildInfoCard(
                  Icons.schedule_rounded,
                  'Fecha Programada',
                  widget.limpieza.fechaProgramadaFormateada,
                ),
              ),
            ],
          ),
          
          if (widget.limpieza.fechaInicioLimpieza != null || widget.limpieza.fechaTermino != null) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                if (widget.limpieza.fechaInicioLimpieza != null)
                  Expanded(
                    child: _buildInfoCard(
                      Icons.play_circle_rounded,
                      'Iniciada',
                      widget.limpieza.fechaInicioLimpiezaFormateada ?? '',
                    ),
                  ),
                if (widget.limpieza.fechaInicioLimpieza != null && widget.limpieza.fechaTermino != null)
                  const SizedBox(width: 12),
                if (widget.limpieza.fechaTermino != null)
                  Expanded(
                    child: _buildInfoCard(
                      Icons.check_circle_rounded,
                      'Terminada',
                      widget.limpieza.fechaTerminoFormateada ?? '',
                    ),
                  ),
              ],
            ),
          ],
          
          if (widget.limpieza.habitacionArea.descripcion.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    size: 18,
                    color: Colors.grey.shade600,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      widget.limpieza.habitacionArea.descripcion,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          
          if (widget.limpieza.descripcion != null && widget.limpieza.descripcion!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.description_rounded,
                    size: 18,
                    color: Colors.grey.shade600,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      widget.limpieza.descripcion!,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          
          if (widget.limpieza.comentariosObservaciones != null && widget.limpieza.comentariosObservaciones!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.comment_rounded,
                    size: 18,
                    color: Colors.grey.shade600,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      widget.limpieza.comentariosObservaciones!,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade700,
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

  Widget _buildInfoCard(IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey.shade200,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: 16,
                color: Colors.grey.shade600,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1a1a1a),
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildAcciones() {
    final estatus = widget.limpieza.estatusLimpiezaId;

    if (estatus == 1) {
      // Pendiente: Iniciar y Cancelar
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF4CAF50).withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ElevatedButton.icon(
              onPressed: _mostrarDialogoIniciar,
              icon: const Icon(Icons.play_arrow_rounded, size: 22),
              label: const Text(
                'Iniciar Limpieza',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4CAF50),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
            ),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: _mostrarDialogoCancelar,
            icon: const Icon(Icons.cancel_rounded, size: 22),
            label: const Text(
              'Cancelar Limpieza',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.red,
              padding: const EdgeInsets.symmetric(vertical: 18),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              side: const BorderSide(color: Colors.red, width: 2),
            ),
          ),
        ],
      );
    } else if (estatus == 2) {
      // En Progreso: Terminar
      return Container(
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
            'Terminar Limpieza',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF2196F3),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 18),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 0,
          ),
        ),
      );
    } else {
      // Completada o Cancelada: Sin acciones
      return const SizedBox.shrink();
    }
  }

  Future<void> _mostrarDialogoIniciar() async {
    final confirmado = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Iniciar Limpieza'),
        content: const Text('¿Estás seguro de que deseas iniciar esta limpieza?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4CAF50)),
            child: const Text('Iniciar'),
          ),
        ],
      ),
    );

    if (confirmado == true && mounted) {
      await _iniciarLimpieza();
    }
  }

  Future<void> _iniciarLimpieza() async {
    final controller = Provider.of<LimpiezaController>(context, listen: false);
    final fechaInicio = DateTime.now();

    final success = await controller.iniciarLimpieza(widget.limpieza.idLimpieza, fechaInicio);

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Limpieza iniciada correctamente'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(controller.actionErrorMessage ?? 'Error al iniciar limpieza'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _mostrarDialogoCancelar() async {
    final comentarioController = TextEditingController();

    final confirmado = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancelar Limpieza'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Por favor, indica el motivo de la cancelación:'),
            const SizedBox(height: 16),
            TextField(
              controller: comentarioController,
              decoration: const InputDecoration(
                hintText: 'Motivo de cancelación...',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
              autofocus: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              if (comentarioController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Por favor ingresa un motivo')),
                );
                return;
              }
              Navigator.pop(context, comentarioController.text.trim());
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Cancelar Limpieza'),
          ),
        ],
      ),
    );

    if (confirmado != null && confirmado != false && mounted) {
      await _cancelarLimpieza(confirmado as String);
    }
  }

  Future<void> _cancelarLimpieza(String comentario) async {
    final controller = Provider.of<LimpiezaController>(context, listen: false);

    final success = await controller.cancelarLimpieza(widget.limpieza.idLimpieza, comentario);

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Limpieza cancelada correctamente'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(controller.actionErrorMessage ?? 'Error al cancelar limpieza'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _mostrarFormularioTerminar() async {
    _comentarioController.clear();
    _fotosSeleccionadas.clear();

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _FormularioTerminarLimpieza(
        limpiezaId: widget.limpieza.idLimpieza,
        comentarioController: _comentarioController,
        fotosSeleccionadas: _fotosSeleccionadas,
        picker: _picker,
        onTerminar: _terminarLimpieza,
      ),
    );
  }

  Future<void> _terminarLimpieza(String comentario, List<XFile> fotos) async {
    if (fotos.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Debes subir al menos una foto')),
      );
      return;
    }

    final controller = Provider.of<LimpiezaController>(context, listen: false);

    // Subir todas las fotos
    bool todasSubidas = true;
    for (var foto in fotos) {
      final success = await controller.uploadFoto(
        widget.limpieza.idLimpieza,
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

    // Terminar limpieza
    final fechaTermino = DateTime.now();
    final success = await controller.terminarLimpieza(
      widget.limpieza.idLimpieza,
      fechaTermino,
      comentario,
    );

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
          content: Text(controller.actionErrorMessage ?? 'Error al terminar limpieza'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _buildGaleria() {
    return Consumer<LimpiezaController>(
      builder: (context, controller, child) {
        if (controller.isLoadingGaleria) {
          return Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF667eea),
              ),
            ),
          );
        }

        if (controller.galeriaFotos.isEmpty) {
          return const SizedBox.shrink();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF667eea).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.photo_library_rounded,
                    color: Color(0xFF667eea),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Galería de Fotos',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1a1a1a),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: controller.galeriaFotos.length,
              itemBuilder: (context, index) {
                final foto = controller.galeriaFotos[index];
                final url = foto['public_url'] as String?;
                if (url == null) return const SizedBox.shrink();

                return ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.grey.shade200,
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Image.network(
                      url,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: Colors.grey.shade100,
                        child: Icon(
                          Icons.error_outline,
                          color: Colors.grey.shade400,
                        ),
                      ),
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          color: Colors.grey.shade100,
                          child: Center(
                            child: CircularProgressIndicator(
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                      loadingProgress.expectedTotalBytes!
                                  : null,
                              strokeWidth: 2,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }
}

class _FormularioTerminarLimpieza extends StatefulWidget {
  final int limpiezaId;
  final TextEditingController comentarioController;
  final List<XFile> fotosSeleccionadas;
  final ImagePicker picker;
  final Future<void> Function(String comentario, List<XFile> fotos) onTerminar;

  const _FormularioTerminarLimpieza({
    required this.limpiezaId,
    required this.comentarioController,
    required this.fotosSeleccionadas,
    required this.picker,
    required this.onTerminar,
  });

  @override
  State<_FormularioTerminarLimpieza> createState() => _FormularioTerminarLimpiezaState();
}

class _FormularioTerminarLimpiezaState extends State<_FormularioTerminarLimpieza> {
  bool _isSubiendo = false;
  Map<int, Uint8List> _fotoBytes = {}; // Cache de bytes de las fotos para mostrar

  Future<void> _seleccionarFotos() async {
    if (widget.fotosSeleccionadas.length >= 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Máximo 5 fotos permitidas')),
      );
      return;
    }

    final List<XFile>? fotos = await widget.picker.pickMultiImage(
      maxWidth: 1800,
      maxHeight: 1800,
      imageQuality: 85,
    );

    if (fotos != null) {
      final fotosRestantes = 5 - widget.fotosSeleccionadas.length;
      final fotosAAgregar = fotos.take(fotosRestantes).toList();
      
      // Cargar bytes de las fotos para mostrar preview
      for (var foto in fotosAAgregar) {
        final bytes = await foto.readAsBytes();
        final index = widget.fotosSeleccionadas.length + fotosAAgregar.indexOf(foto);
        _fotoBytes[index] = bytes;
      }
      
      setState(() {
        widget.fotosSeleccionadas.addAll(fotosAAgregar);
      });
    }
  }

  void _eliminarFoto(int index) {
    setState(() {
      widget.fotosSeleccionadas.removeAt(index);
      // Limpiar cache y recargar bytes para las fotos restantes
      _fotoBytes.clear();
      for (var i = 0; i < widget.fotosSeleccionadas.length; i++) {
        widget.fotosSeleccionadas[i].readAsBytes().then((bytes) {
          if (mounted) {
            setState(() {
              _fotoBytes[i] = bytes;
            });
          }
        });
      }
    });
  }

  Future<void> _finalizar() async {
    if (widget.comentarioController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor ingresa un comentario')),
      );
      return;
    }

    if (widget.fotosSeleccionadas.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Debes subir al menos una foto')),
      );
      return;
    }

    setState(() => _isSubiendo = true);

    await widget.onTerminar(
      widget.comentarioController.text.trim(),
      widget.fotosSeleccionadas,
    );

    if (mounted) {
      setState(() => _isSubiendo = false);
      Navigator.pop(context);
    }
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
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Terminar Limpieza',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: widget.comentarioController,
            decoration: const InputDecoration(
              labelText: 'Comentario final *',
              hintText: 'Ingresa comentarios sobre la limpieza...',
              border: OutlineInputBorder(),
            ),
            maxLines: 4,
          ),
          const SizedBox(height: 16),
          const Text(
            'Fotos (mínimo 1, máximo 5) *',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: widget.fotosSeleccionadas.length >= 5 ? null : _seleccionarFotos,
            icon: const Icon(Icons.add_photo_alternate),
            label: Text('Agregar Fotos (${widget.fotosSeleccionadas.length}/5)'),
          ),
          if (widget.fotosSeleccionadas.isNotEmpty) ...[
            const SizedBox(height: 12),
            SizedBox(
              height: 100,
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
                          child: _fotoBytes.containsKey(index)
                              ? Image.memory(
                                  _fotoBytes[index]!,
                                  width: 100,
                                  height: 100,
                                  fit: BoxFit.cover,
                                )
                              : FutureBuilder<Uint8List>(
                                  future: widget.fotosSeleccionadas[index].readAsBytes(),
                                  builder: (context, snapshot) {
                                    if (snapshot.hasData) {
                                      _fotoBytes[index] = snapshot.data!;
                                      return Image.memory(
                                        snapshot.data!,
                                        width: 100,
                                        height: 100,
                                        fit: BoxFit.cover,
                                      );
                                    }
                                    return Container(
                                      width: 100,
                                      height: 100,
                                      color: Colors.grey[300],
                                      child: const Center(child: CircularProgressIndicator()),
                                    );
                                  },
                                ),
                        ),
                        Positioned(
                          top: 4,
                          right: 4,
                          child: CircleAvatar(
                            radius: 12,
                            backgroundColor: Colors.red,
                            child: IconButton(
                              icon: const Icon(Icons.close, size: 16, color: Colors.white),
                              onPressed: () => _eliminarFoto(index),
                              padding: EdgeInsets.zero,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _isSubiendo ? null : _finalizar,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2196F3),
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: _isSubiendo
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : const Text('Finalizar Limpieza'),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}


import 'package:flutter/material.dart';
import '../models/habitacion_area_con_estado_model.dart';

/// Widget reutilizable para mostrar una habitación en el grid de selección
/// Muestra el estado visual (reservación activa, limpieza pendiente, etc.)
/// y permite selección mediante checkbox
class HabitacionGridCard extends StatelessWidget {
  final HabitacionAreaConEstado habitacion;
  final bool isSelected;
  final VoidCallback? onTap;
  final bool enabled;

  const HabitacionGridCard({
    super.key,
    required this.habitacion,
    required this.isSelected,
    this.onTap,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    // Determinar color de fondo según el estado
    Color backgroundColor;
    Color borderColor;
    Color textColor = const Color(0xFF1a1a1a);
    
    if (!habitacion.puedeSeleccionarse) {
      // No seleccionable (limpieza pendiente o en proceso)
      backgroundColor = Colors.grey.shade200;
      borderColor = Colors.grey.shade400;
      textColor = Colors.grey.shade600;
    } else if (habitacion.tieneReservacionActiva) {
      // Con reservación activa (seleccionable pero marcada)
      backgroundColor = const Color(0xFFFFF3E0); // Naranja claro
      borderColor = const Color(0xFFFFA726);
      textColor = const Color(0xFFE65100);
    } else if (isSelected) {
      // Seleccionada
      backgroundColor = const Color(0xFFE8F5E9); // Verde claro
      borderColor = const Color(0xFF4CAF50);
      textColor = const Color(0xFF1a1a1a);
    } else {
      // Disponible normal
      backgroundColor = Colors.white;
      borderColor = Colors.grey.shade300;
      textColor = const Color(0xFF1a1a1a);
    }

    return GestureDetector(
      onTap: enabled && habitacion.puedeSeleccionarse ? onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? borderColor : borderColor.withOpacity(0.5),
            width: isSelected ? 2.5 : 1.5,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: borderColor.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ],
        ),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Checkbox en la esquina superior derecha
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      if (habitacion.puedeSeleccionarse)
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: isSelected ? const Color(0xFF4CAF50) : Colors.white,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isSelected ? const Color(0xFF4CAF50) : Colors.grey.shade400,
                              width: 2,
                            ),
                          ),
                          child: isSelected
                              ? const Icon(
                                  Icons.check,
                                  size: 16,
                                  color: Colors.white,
                                )
                              : null,
                        )
                      else
                        Icon(
                          Icons.block,
                          size: 20,
                          color: Colors.grey.shade500,
                        ),
                    ],
                  ),
                  
                  const Spacer(),
                  
                  // Nombre de la habitación
                  Text(
                    habitacion.nombreClave,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: textColor,
                      letterSpacing: -0.5,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  
                  const SizedBox(height: 4),
                  
                  // Descripción (si cabe)
                  if (habitacion.descripcion.isNotEmpty)
                    Text(
                      habitacion.descripcion,
                      style: TextStyle(
                        fontSize: 11,
                        color: textColor.withOpacity(0.7),
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  
                  const Spacer(),
                  
                  // Indicadores de estado
                  if (habitacion.tieneReservacionActiva)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFA726).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.event_busy,
                            size: 12,
                            color: const Color(0xFFE65100),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Reservada',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFFE65100),
                            ),
                          ),
                        ],
                      ),
                    )
                  else if (habitacion.tieneLimpiezaPendiente)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.cleaning_services,
                            size: 12,
                            color: Colors.orange.shade700,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Pendiente',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: Colors.orange.shade700,
                            ),
                          ),
                        ],
                      ),
                    )
                  else if (habitacion.tieneLimpiezaEnProceso)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.cleaning_services,
                            size: 12,
                            color: Colors.blue.shade700,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'En proceso',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: Colors.blue.shade700,
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF4CAF50).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.check_circle_outline,
                            size: 12,
                            color: const Color(0xFF4CAF50),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Disponible',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF4CAF50),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}


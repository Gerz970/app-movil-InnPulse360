import 'package:flutter/foundation.dart';

/// Controlador para manejar el estado del sidebar lateral
/// Usa ChangeNotifier para notificar cambios de estado
class SidebarController extends ChangeNotifier {
  // Estado privado del sidebar
  bool _isOpen = false;

  /// Getter para obtener el estado actual del sidebar
  bool get isOpen => _isOpen;

  /// Abrir el sidebar
  void openSidebar() {
    if (!_isOpen) {
      _isOpen = true;
      notifyListeners();
    }
  }

  /// Cerrar el sidebar
  void closeSidebar() {
    if (_isOpen) {
      _isOpen = false;
      notifyListeners();
    }
  }

  /// Alternar el estado del sidebar (abrir/cerrar)
  void toggleSidebar() {
    _isOpen = !_isOpen;
    notifyListeners();
  }
}


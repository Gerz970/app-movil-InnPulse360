import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'login_estado.dart';
import 'login_notificador.dart';

/// Provider del notificador de login
/// Gestiona el estado de la pantalla de login
final loginNotificadorProvider = NotifierProvider<LoginNotificador, LoginEstado>(
  () => LoginNotificador(),
);


// Endpoints para notificaciones push
// Rutas relativas para peticiones a los endpoints específicos

class EndpointsNotifications {
  // Endpoints de notificaciones
  
  // [POST]: Registrar token de dispositivo
  static const String registerToken = "notifications/register-token";
  
  // [POST]: Desregistrar tokens de dispositivo (logout)
  static const String unregisterToken = "notifications/unregister-token";
}


/*
  Modelo para cambiar la contraseña del usuario
  Incluye validación de coincidencia de contraseñas
*/

class CambiarPasswordModel {
  final String login;
  final String passwordActual;
  final String passwordNueva;
  final String passwordConfirmacion;

  CambiarPasswordModel({
    required this.login,
    required this.passwordActual,
    required this.passwordNueva,
    required this.passwordConfirmacion,
  });

  Map<String, dynamic> toJson() {
    return {
      'login': login,
      'password_actual': passwordActual,
      'password_nueva': passwordNueva,
      'password_confirmacion': passwordConfirmacion,
    };
  }

  // Validar que las contraseñas coincidan
  bool get passwordsCoinciden => passwordNueva == passwordConfirmacion;

  // Validar fortaleza mínima (6 caracteres)
  bool get passwordValida => passwordNueva.length >= 6;

  // Validar que todos los campos estén completos
  bool get camposCompletos => 
      login.isNotEmpty && 
      passwordActual.isNotEmpty && 
      passwordNueva.isNotEmpty && 
      passwordConfirmacion.isNotEmpty;
}


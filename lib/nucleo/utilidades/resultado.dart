import '../errores/fallas.dart';

/// Clase genérica para representar el resultado de una operación
/// Puede ser Éxito (con datos) o Error (con falla)
/// Basado en el patrón Either/Result
abstract class Resultado<T> {
  const Resultado();
  
  /// Ejecutar una función si el resultado es exitoso
  R when<R>({
    required R Function(T datos) exito,
    required R Function(Falla falla) error,
  });
  
  /// Verificar si el resultado es exitoso
  bool get esExitoso => this is Exito<T>;
  
  /// Verificar si el resultado es un error
  bool get esError => this is Error<T>;
  
  /// Obtener los datos si es exitoso, null si es error
  T? get datosONull => esExitoso ? (this as Exito<T>).datos : null;
  
  /// Obtener la falla si es error, null si es exitoso
  Falla? get fallaONull => esError ? (this as Error<T>).falla : null;
}

/// Resultado exitoso
/// Contiene los datos retornados por la operación
class Exito<T> extends Resultado<T> {
  final T datos;
  
  const Exito(this.datos);
  
  @override
  R when<R>({
    required R Function(T datos) exito,
    required R Function(Falla falla) error,
  }) {
    return exito(datos);
  }
}

/// Resultado de error
/// Contiene la falla que ocurrió durante la operación
class Error<T> extends Resultado<T> {
  final Falla falla;
  
  const Error(this.falla);
  
  @override
  R when<R>({
    required R Function(T datos) exito,
    required R Function(Falla falla) error,
  }) {
    return error(falla);
  }
}


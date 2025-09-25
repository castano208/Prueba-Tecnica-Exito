/// Interfaz para operaciones relacionadas con el tiempo
/// Define los métodos para verificar horarios y disponibilidad del modo express
abstract class ITimeService {
  /// Verifica si el modo express está disponible actualmente
  Future<bool> isExpressTimeAvailable();
  
  /// Obtiene la hora actual en una zona horaria específica
  Future<DateTime> getCurrentTime();
  
  /// Verifica si la hora actual está dentro del horario express
  bool isWithinExpressHours(DateTime time);
}

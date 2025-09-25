/// Interfaz para operaciones de notificaciones
/// Define los métodos para enviar notificaciones al usuario
abstract class INotificationService {
  /// Envía un mensaje de notificación
  Future<void> sendNotification(String message);
  
  /// Envía notificación de que el modo express está disponible
  Future<void> notifyExpressModeAvailable();
  
  /// Envía notificación de que el modo express está terminando
  Future<void> notifyExpressModeEnding();
}

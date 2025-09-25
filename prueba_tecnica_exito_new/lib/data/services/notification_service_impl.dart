import 'package:flutter/foundation.dart';
import '../../core/interfaces/i_notification_service.dart';

/// Implementación del servicio de notificaciones
/// Se encarga de enviar notificaciones al usuario sobre el estado del modo express
class NotificationServiceImpl extends ChangeNotifier implements INotificationService {
  /// Envía una notificación con el mensaje especificado
  @override
  Future<void> sendNotification(String message) async {
    // TODO: Implementar lógica real de notificaciones
    // Esto podría ser Firebase Cloud Messaging, notificaciones locales, etc.
    print('Notificación: $message');
  }

  /// Notifica que el modo express está disponible
  @override
  Future<void> notifyExpressModeAvailable() async {
    await sendNotification('¡El modo express está disponible!');
  }

  /// Notifica que el modo express está terminando
  @override
  Future<void> notifyExpressModeEnding() async {
    await sendNotification('¡El modo express terminará pronto!');
  }
}

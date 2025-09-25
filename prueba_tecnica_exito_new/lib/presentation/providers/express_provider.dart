import 'package:flutter/foundation.dart';
import '../../data/services/time_service_impl.dart';
import '../../data/services/notification_service_impl.dart';

/// Provider para la funcionalidad del modo express
/// Gestiona el estado del modo express y la vista personalizada
class ExpressProvider extends ChangeNotifier {
  final TimeServiceImpl _timeService;
  final NotificationServiceImpl _notificationService;
  
  bool _isExpressModeActive = false;
  bool _showSwitch = false;
  bool _customViewActive = false;

  ExpressProvider(this._timeService, this._notificationService);

  // Getters para acceder al estado
  bool get isExpressModeActive => _isExpressModeActive;
  bool get showSwitch => _showSwitch;
  bool get customViewActive => _customViewActive;

  /// Alterna entre vista normal y vista personalizada
  void toggleCustomView() {
    _customViewActive = !_customViewActive;
    notifyListeners();
  }

  /// Verifica si el horario express está disponible
  Future<void> checkExpressTime() async {
    try {
      final isAvailable = await _timeService.isExpressTimeAvailable();
      _showSwitch = isAvailable;
      
      if (!isAvailable) {
        _isExpressModeActive = false;
      }
      
      notifyListeners();
    } catch (e) {
      print('Error al verificar el tiempo express: $e');
      _showSwitch = false;
      _isExpressModeActive = false;
      notifyListeners();
    }
  }

  /// Cambia el estado del modo express
  void changeExpressMode(bool value) {
    _isExpressModeActive = value;
    notifyListeners();
    
    if (value) {
      _notificationService.notifyExpressModeAvailable();
    }
  }
}

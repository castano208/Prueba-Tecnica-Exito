import 'package:flutter/foundation.dart';
import '../../data/services/time_service_impl.dart';
import '../../data/services/notification_service_impl.dart';

/// Provider para la funcionalidad del modo express
/// Gestiona el estado del modo express y la vista personalizada
/// Optimizado para usar el sistema de tiempo inteligente
class ExpressProvider extends ChangeNotifier {
  final TimeServiceImpl _timeService;
  final NotificationServiceImpl _notificationService;
  
  bool _isExpressModeActive = false;
  bool _showSwitch = false;
  bool _customViewActive = false;
  bool _isInitialized = false;

  ExpressProvider(this._timeService, this._notificationService) {
    _initialize();
  }

  // Getters para acceder al estado
  bool get isExpressModeActive => _isExpressModeActive;
  bool get showSwitch => _showSwitch;
  bool get customViewActive => _customViewActive;
  bool get isInitialized => _isInitialized;

  /// Inicializa el provider y configura el sistema de tiempo
  Future<void> _initialize() async {
    try {
      print('🚀 [ExpressProvider] Inicializando...');
      await _timeService.initialize();
      _timeService.addListener(_onTimeServiceUpdate);
      await _checkExpressTime();
      _isInitialized = true;
      notifyListeners();
      print('✅ [ExpressProvider] Inicializado correctamente');
      print('   - Modo express activo: $_isExpressModeActive');
      print('   - Switch visible: $_showSwitch');
      print('   - Vista personalizada: $_customViewActive');
    } catch (e) {
      print('❌ [ExpressProvider] Error al inicializar: $e');
      _isInitialized = false;
    }
  }

  /// Escucha los cambios del TimeService
  void _onTimeServiceUpdate() {
    print('📡 [ExpressProvider] Recibida actualización del TimeService');
    _checkExpressTime();
  }

  /// Verifica si el horario express está disponible (optimizado)
  Future<void> _checkExpressTime() async {
    try {
      final isAvailable = await _timeService.isExpressTimeAvailable();
      final wasShowSwitch = _showSwitch;
      final wasExpressModeActive = _isExpressModeActive;
      
      _showSwitch = isAvailable;
      
      if (!isAvailable) {
        _isExpressModeActive = false;
      }
      
      // Log solo si hay cambios
      if (wasShowSwitch != _showSwitch || wasExpressModeActive != _isExpressModeActive) {
        print('🔄 [ExpressProvider] Estado actualizado:');
        print('   - Modo express disponible: $_showSwitch');
        print('   - Modo express activo: $_isExpressModeActive');
        print('   - Vista personalizada: $_customViewActive');
      }
      
      notifyListeners();
    } catch (e) {
      print('❌ [ExpressProvider] Error al verificar tiempo express: $e');
      _showSwitch = false;
      _isExpressModeActive = false;
      notifyListeners();
    }
  }

  /// Alterna entre vista normal y vista personalizada
  void toggleCustomView() {
    _customViewActive = !_customViewActive;
    notifyListeners();
  }

  /// Verifica si el horario express está disponible (método público para compatibilidad)
  Future<void> checkExpressTime() async {
    await _checkExpressTime();
  }

  /// Cambia el estado del modo express
  void changeExpressMode(bool value) {
    _isExpressModeActive = value;
    notifyListeners();
    
    if (value) {
      _notificationService.notifyExpressModeAvailable();
    }
  }

  /// Fuerza una actualización del tiempo (útil para sincronización)
  Future<void> forceTimeRefresh() async {
    try {
      await _timeService.forceRefresh();
      await _checkExpressTime();
    } catch (e) {
      print('Error al forzar actualización del tiempo: $e');
    }
  }

  /// Limpia recursos y listeners
  @override
  void dispose() {
    _timeService.removeListener(_onTimeServiceUpdate);
    super.dispose();
  }
}

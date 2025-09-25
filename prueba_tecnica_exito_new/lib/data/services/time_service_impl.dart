import 'dart:convert';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../../core/interfaces/i_time_service.dart';

/// Implementación del servicio de tiempo para el modo express
/// Se encarga de verificar horarios y disponibilidad del modo express
/// Optimizado para evitar consultas innecesarias a la API
class TimeServiceImpl extends ChangeNotifier implements ITimeService {
  static const String _timezone = "America/Bogota";
  static const String _apiUrl = "https://worldtimeapi.org/api/timezone/$_timezone";
  
  // Horario del modo express: 10:00 AM a 4:00 PM
  static const int _expressStartHour = 10;
  static const int _expressEndHour = 16;
  
  // Rangos críticos para verificación minuto a minuto
  static const int _activationStartHour = 9;
  static const int _activationStartMinute = 58;
  static const int _activationEndHour = 10;
  static const int _activationEndMinute = 2;
  
  static const int _deactivationStartHour = 15;
  static const int _deactivationStartMinute = 58;
  static const int _deactivationEndHour = 16;
  static const int _deactivationEndMinute = 2;
  
  // Variables de estado
  DateTime? _lastKnownTime;
  Timer? _smartTimer;
  bool _isInCriticalRange = false;

  /// Inicializa el servicio de tiempo con consulta inicial
  Future<void> initialize() async {
    try {
      print('🕐 [TimeService] Iniciando consulta a la API...');
      _lastKnownTime = await getCurrentTime();
      print('✅ [TimeService] Consulta exitosa. Hora actual: $_lastKnownTime');
      _setupSmartTimer();
    } catch (e) {
      print('❌ [TimeService] Error al inicializar: $e');
    }
  }

  /// Configura el timer inteligente basado en rangos críticos
  void _setupSmartTimer() {
    _smartTimer?.cancel();
    
    if (_lastKnownTime == null) return;
    
    final now = _lastKnownTime!;
    final isInActivationRange = _isInActivationRange(now);
    final isInDeactivationRange = _isInDeactivationRange(now);
    
    _isInCriticalRange = isInActivationRange || isInDeactivationRange;
    
    print('📊 [TimeService] Estado actual:');
    print('   - Hora actual: ${now.hour}:${now.minute.toString().padLeft(2, '0')}');
    print('   - En rango de activación (9:58-10:02): $isInActivationRange');
    print('   - En rango de desactivación (15:58-16:02): $isInDeactivationRange');
    print('   - En rango crítico: $_isInCriticalRange');
    
    if (_isInCriticalRange) {
      // Estamos en rango crítico, verificar cada minuto
      _startMinuteTimer();
      print('🚨 [TimeService] Timer activado: En rango crítico');
    } else {
      // No estamos en rango crítico, calcular cuándo activar el timer
      _scheduleNextCheck();
    }
  }

  /// Verifica si estamos en el rango de activación (9:58 - 10:02)
  bool _isInActivationRange(DateTime time) {
    final hour = time.hour;
    final minute = time.minute;
    
    if (hour == _activationStartHour && minute >= _activationStartMinute) return true;
    if (hour == _activationEndHour && minute <= _activationEndMinute) return true;
    
    return false;
  }

  /// Verifica si estamos en el rango de desactivación (15:58 - 16:02)
  bool _isInDeactivationRange(DateTime time) {
    final hour = time.hour;
    final minute = time.minute;
    
    if (hour == _deactivationStartHour && minute >= _deactivationStartMinute) return true;
    if (hour == _deactivationEndHour && minute <= _deactivationEndMinute) return true;
    
    return false;
  }

  /// Programa la próxima verificación basada en el tiempo actual
  void _scheduleNextCheck() {
    if (_lastKnownTime == null) return;
    
    final now = _lastKnownTime!;
    DateTime nextCheck;
    
    // Calcular cuándo será el próximo rango crítico
    final today = DateTime(now.year, now.month, now.day);
    final activationStart = DateTime(today.year, today.month, today.day, _activationStartHour, _activationStartMinute);
    final deactivationStart = DateTime(today.year, today.month, today.day, _deactivationStartHour, _deactivationStartMinute);
    
    if (now.isBefore(activationStart)) {
      nextCheck = activationStart;
      print('⏰ [TimeService] Próximo rango: Activación (9:58)');
    } else if (now.isAfter(DateTime(today.year, today.month, today.day, _activationEndHour, _activationEndMinute)) &&
               now.isBefore(deactivationStart)) {
      nextCheck = deactivationStart;
      print('⏰ [TimeService] Próximo rango: Desactivación (15:58)');
    } else {
      // Si ya pasaron ambos rangos, programar para mañana
      nextCheck = activationStart.add(const Duration(days: 1));
      print('⏰ [TimeService] Próximo rango: Mañana a las 9:58');
    }
    
    final duration = nextCheck.difference(now);
    _smartTimer = Timer(duration, () {
      _setupSmartTimer();
    });
    
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    print('⏳ [TimeService] Próxima verificación programada para: ${nextCheck.hour}:${nextCheck.minute.toString().padLeft(2, '0')}');
    print('   - Tiempo restante: ${hours}h ${minutes}m (${duration.inMinutes} minutos)');
    print('   - Timer inactivo hasta entonces');
  }

  /// Inicia el timer de verificación minuto a minuto
  void _startMinuteTimer() {
    _smartTimer?.cancel();
    _smartTimer = Timer.periodic(const Duration(minutes: 1), (timer) {
      _checkTimeAndUpdate();
    });
    print('🔄 [TimeService] Timer minuto a minuto activado');
  }

  /// Verifica el tiempo y actualiza el estado
  void _checkTimeAndUpdate() {
    if (_lastKnownTime == null) return;
    
    // Actualizar tiempo local (sin consultar API)
    _lastKnownTime = _lastKnownTime!.add(const Duration(minutes: 1));
    
    final wasInCriticalRange = _isInCriticalRange;
    final isInActivationRange = _isInActivationRange(_lastKnownTime!);
    final isInDeactivationRange = _isInDeactivationRange(_lastKnownTime!);
    
    _isInCriticalRange = isInActivationRange || isInDeactivationRange;
    
    print('⏱️ [TimeService] Verificación minuto a minuto:');
    print('   - Hora actualizada: ${_lastKnownTime!.hour}:${_lastKnownTime!.minute.toString().padLeft(2, '0')}');
    print('   - En rango crítico: $_isInCriticalRange');
    
    // Si salimos del rango crítico, programar próxima verificación
    if (wasInCriticalRange && !_isInCriticalRange) {
      _smartTimer?.cancel();
      _scheduleNextCheck();
      print('🚪 [TimeService] Salimos del rango crítico, programando próxima verificación');
    }
    
    // Notificar cambios
    notifyListeners();
  }

  /// Obtiene el tiempo actual (optimizado)
  DateTime? get currentTime => _lastKnownTime;

  /// Verifica si el modo express está disponible actualmente
  @override
  Future<bool> isExpressTimeAvailable() async {
    if (_lastKnownTime == null) {
      await initialize();
    }
    
    return _lastKnownTime != null ? isWithinExpressHours(_lastKnownTime!) : false;
  }

  /// Obtiene la hora actual desde la API de tiempo
  @override
  Future<DateTime> getCurrentTime() async {
    const int maxAttempts = 5;
    const Duration cooldown = Duration(seconds: 2);
    
    for (int attempt = 0; attempt < maxAttempts; attempt++) {
      try {
        final response = await http
            .get(Uri.parse(_apiUrl))
            .timeout(const Duration(seconds: 5));

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          final utcDateTime = DateTime.parse(data["utc_datetime"]);
          final offset = data["utc_offset"];

          final offsetDuration = Duration(
            hours: int.parse(offset.substring(1, 3)),
            minutes: int.parse(offset.substring(4, 6)),
          );

          final localTime = offset.startsWith("+")
              ? utcDateTime.add(offsetDuration)
              : utcDateTime.subtract(offsetDuration);

          return localTime;
        }
      } catch (e) {
        print('Intento ${attempt + 1} falló: $e');
        if (attempt < maxAttempts - 1) {
          await Future.delayed(cooldown);
        }
      }
    }
    
    throw Exception('Error al obtener la hora actual después de $maxAttempts intentos');
  }

  /// Verifica si la hora especificada está dentro del horario express
  @override
  bool isWithinExpressHours(DateTime time) {
    final hour = time.hour;
    final minute = time.minute;
    
    // El modo express está disponible de 10:00 AM a 4:00 PM
    if (hour == _expressStartHour && minute >= 0) return true;
    if (hour > _expressStartHour && hour < _expressEndHour) return true;
    if (hour == _expressEndHour && minute == 0) return true;
    
    return false;
  }

  /// Limpia recursos y cancela timers
  @override
  void dispose() {
    _smartTimer?.cancel();
    super.dispose();
  }

  /// Fuerza una nueva consulta a la API (útil para sincronización)
  Future<void> forceRefresh() async {
    try {
      _lastKnownTime = await getCurrentTime();
      _setupSmartTimer();
      notifyListeners();
      print('TimeService actualizado forzadamente. Nueva hora: $_lastKnownTime');
    } catch (e) {
      print('Error al forzar actualización: $e');
    }
  }
}

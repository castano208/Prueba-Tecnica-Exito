import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../../core/interfaces/i_time_service.dart';

/// Implementación del servicio de tiempo para el modo express
/// Se encarga de verificar horarios y disponibilidad del modo express
class TimeServiceImpl extends ChangeNotifier implements ITimeService {
  static const String _timezone = "America/Bogota";
  static const String _apiUrl = "https://worldtimeapi.org/api/timezone/$_timezone";
  
  // Horario del modo express: 10:00 AM a 4:00 PM
  static const int _expressStartHour = 10;
  static const int _expressEndHour = 16;

  /// Verifica si el modo express está disponible actualmente
  @override
  Future<bool> isExpressTimeAvailable() async {
    try {
      final currentTime = await getCurrentTime();
      return isWithinExpressHours(currentTime);
    } catch (e) {
      print('Error al verificar la disponibilidad del tiempo express: $e');
      return false;
    }
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
}

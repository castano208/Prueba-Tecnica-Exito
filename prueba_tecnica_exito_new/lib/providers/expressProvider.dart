import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ExpressProvider extends ChangeNotifier {
  //Datos y funcion para vista personalizada
  bool _vistaPersonalizadaActiva = false;
  bool get vistaPersonalizadaActiva => _vistaPersonalizadaActiva;

  void  triggerVistaPersonalizada() {
    _vistaPersonalizadaActiva ? _vistaPersonalizadaActiva = false : _vistaPersonalizadaActiva = true;
    notifyListeners();
  }

  bool _modoExpressActivo = false;
  bool _mostrarSwitch = false;


  bool get modoExpressActivo => _modoExpressActivo;
  bool get mostrarSwitch => _mostrarSwitch;

  Future<void> verificarHorario({int intentosMaximos = 5, Duration cooldown = const Duration(seconds: 2)}) async {

  final String zona = "America/Bogota";
  int intento = 0;

  while (intento < intentosMaximos) {
    intento++;
    try {
      final resp = await http
          .get(Uri.parse("https://worldtimeapi.org/api/timezone/$zona"))
          .timeout(const Duration(seconds: 5));

      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body);
        final fechaUtc = DateTime.parse(data["utc_datetime"]);
        final offset = data["utc_offset"];

        final duracionOffset = Duration(
          hours: int.parse(offset.substring(1, 3)),
          minutes: int.parse(offset.substring(4, 6)),
        );

        final horaLocal = offset.startsWith("+")
            ? fechaUtc.add(duracionOffset)
            : fechaUtc.subtract(duracionOffset);

        final hora = horaLocal.hour;
        final minuto = horaLocal.minute;

        // Mostrar switch entre 10:00 AM y 4:00 PM exactas
        if ((hora == 10 && minuto >= 0) || (hora > 10 && hora < 16) || (hora == 16 && minuto == 0)) {
          _mostrarSwitch = true;
        } else {
          _mostrarSwitch = false;
          _modoExpressActivo = false;
        }

        notifyListeners();
        print("Hora obtenida con éxito: $horaLocal");
        return;
      } else {
        print("Error en respuesta: ${resp.statusCode}");
      }
    } catch (e) {
      print("Error en intento $intento: $e");
    }

    await Future.delayed(cooldown);
  }

    _mostrarSwitch = false;
    _modoExpressActivo = false;
    notifyListeners();
  }


  void cambiarModoExpress(bool valor) {
    _modoExpressActivo = valor;
    notifyListeners();
  }
}

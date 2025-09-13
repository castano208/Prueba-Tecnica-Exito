import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/expressProvider.dart';

class BotonExperienciaExpress extends StatelessWidget {
  const BotonExperienciaExpress({super.key});

  @override
  Widget build(BuildContext context) {
    final express = Provider.of<ExpressProvider>(context);

    if (!express.mostrarSwitch) {
      return const SizedBox.shrink();
    }

    return SwitchListTile(
      title: const Text(
        "Activar la experiencia express",
        style: TextStyle(fontWeight: FontWeight.w600),
      ),
      value: express.modoExpressActivo,
      activeThumbColor: Colors.blue,
      inactiveThumbColor: Colors.deepOrange,
      inactiveTrackColor: Colors.deepOrange.shade200,
      onChanged: (val) {
        express.cambiarModoExpress(val);
      },
    );
  }
}

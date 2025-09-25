import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/express_provider.dart';

/// Widget para el switch del modo express
/// Permite al usuario activar/desactivar el modo express cuando está disponible
class ExpressModeSwitch extends StatelessWidget {
  const ExpressModeSwitch({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ExpressProvider>(
      builder: (context, expressProvider, child) {
        if (!expressProvider.showSwitch) {
          return const SizedBox.shrink();
        }

        return SwitchListTile(
          title: const Text(
            "Activa experencia express ",
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          value: expressProvider.isExpressModeActive,
          activeThumbColor: Colors.blue,
          inactiveThumbColor: Colors.deepOrange,
          inactiveTrackColor: Colors.deepOrange.shade200,
          onChanged: (value) {
            expressProvider.changeExpressMode(value);
          },
        );
      },
    );
  }
}

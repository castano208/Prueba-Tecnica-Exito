import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:prueba_tecnica_exito_new/providers/i_carrito.dart';
import '../../../providers/carritoProvider.dart';
import '../../../providers/expressProvider.dart';
import '../../../providers/carrito_express_provider.dart';

class PantallaCarrito extends StatefulWidget {
  const PantallaCarrito({super.key});

  @override
  State<PantallaCarrito> createState() => _PantallaCarritoState();
}

class _PantallaCarritoState extends State<PantallaCarrito> {
  final Map<ICarrito, Map<dynamic, TextEditingController>> _controllers = {};
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _iniciarVerificacion();
  }

  void _iniciarVerificacion() {
    final express = Provider.of<ExpressProvider>(context, listen: false);
    var inicial = express.modoExpressActivo;
    // Ejecuta inmediatamente
    express.verificarHorario();

    // Timer cada 1 minuto
    _timer = Timer.periodic(const Duration(minutes: 1), (timer) async {
      final now = DateTime.now();

      // Si estamos en la franja de hora punta (9:59 AM)
      if (now.hour == 9 && now.minute == 59) {
        final waitSeconds = 61 - now.second;
        await Future.delayed(Duration(seconds: waitSeconds));
      }

      // Si estamos llegando al final de la franja express (4 PM)
      if (now.hour == 16 && now.minute == 0) {
        final waitSeconds = 62 - now.second;
        await Future.delayed(Duration(seconds: waitSeconds));
      }

      await express.verificarHorario();

      if (inicial != express.modoExpressActivo && mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    // Limpiar todos los controladores
    for (var carritoMap in _controllers.values) {
      carritoMap.values.forEach((c) => c.dispose());
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final express = Provider.of<ExpressProvider>(context);
    final carritoNormal = Provider.of<CarritoProvider>(context);
    final carritoExpress = Provider.of<CarritoExpressProvider>(context);

    final ICarrito carritoActivo =
        express.modoExpressActivo ? carritoExpress : carritoNormal;

    final colorTema = express.modoExpressActivo ? Colors.blue : Colors.orange;

    // Inicializar mapa de controladores si no existe
    _controllers.putIfAbsent(carritoActivo, () => {});

    double total = 0;
    carritoActivo.items.forEach((producto, cantidad) {
      total += (producto.price * cantidad);

      // Inicializar controller por producto si no existe
      _controllers[carritoActivo]!.putIfAbsent(
        producto,
        () => TextEditingController(text: cantidad.toString()),
      );
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text("Carrito de compras"),
        backgroundColor: colorTema,
      ),
      body: carritoActivo.items.isEmpty
          ? const Center(child: Text("El carrito está vacío"))
          : Column(
              children: [
                // Lista de productos
                Expanded(
                  child: ListView(
                    children: carritoActivo.items.entries.map((entry) {
                      final producto = entry.key;
                      final controller = _controllers[carritoActivo]![producto]!;

                      bool _actualizandoDesdeBoton = false;

                      return ListTile(
                        leading: Image.network(producto.image, width: 50),
                        title: Text(producto.title),
                        subtitle: Text(
                          "\$${producto.price.toStringAsFixed(2)}",
                          style: TextStyle(color: colorTema),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Botón de restar
                            IconButton(
                              icon: const Icon(Icons.remove),
                              onPressed: () {
                                carritoActivo.removeItem(producto);
                                final nuevaCantidad =
                                    carritoActivo.getQuantity(producto);
                                _actualizandoDesdeBoton = true;
                                controller.text = nuevaCantidad.toString();
                                controller.selection = TextSelection.fromPosition(
                                  TextPosition(offset: controller.text.length),
                                );
                                _actualizandoDesdeBoton = false;
                                setState(() {});
                              },
                            ),
                            // Input editable limitado en ancho
                            SizedBox(
                              width: 50,
                              child: TextField(
                                controller: controller,
                                textAlign: TextAlign.center,
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                ],
                                onChanged: (value) {
                                  if (_actualizandoDesdeBoton) return;
                                  int valorInput = int.tryParse(value) ?? 0;
                                  if (valorInput < 0) return;

                                  final cantidadActual =
                                      carritoActivo.getQuantity(producto);
                                  final diferencia = valorInput - cantidadActual;
                                  if (diferencia != 0) {
                                    carritoActivo.addItem(producto, diferencia);
                                    setState(() {});
                                  }
                                },
                                decoration: const InputDecoration(
                                  border: OutlineInputBorder(),
                                  isDense: true,
                                  contentPadding:
                                      EdgeInsets.symmetric(vertical: 8),
                                ),
                                style: const TextStyle(fontSize: 14),
                              ),
                            ),
                            // Botón de sumar
                            IconButton(
                              icon: const Icon(Icons.add),
                              onPressed: () {
                                carritoActivo.addItem(producto);
                                final nuevaCantidad =
                                    carritoActivo.getQuantity(producto);
                                _actualizandoDesdeBoton = true;
                                controller.text = nuevaCantidad.toString();
                                controller.selection = TextSelection.fromPosition(
                                  TextPosition(offset: controller.text.length),
                                );
                                _actualizandoDesdeBoton = false;
                                setState(() {});
                              },
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
                // Barra de total
                Container(
                  padding: const EdgeInsets.all(16),
                  color: colorTema.withOpacity(0.1),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Total:",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      Text(
                        "\$${total.toStringAsFixed(2)}",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}

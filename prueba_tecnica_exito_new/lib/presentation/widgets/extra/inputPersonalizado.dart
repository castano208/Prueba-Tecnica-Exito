import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../data/models/producto.dart';
import '../../../../providers/i_carrito.dart';

class InputPersonalizado extends StatefulWidget {
  final Producto producto;
  final ICarrito carritoActivo;
  final bool modoExpressActivo;

  const InputPersonalizado({
    super.key,
    required this.producto,
    required this.carritoActivo,
    required this.modoExpressActivo,
  });

  @override
  State<InputPersonalizado> createState() => _CantidadInputState();
}

class _CantidadInputState extends State<InputPersonalizado> {
  late TextEditingController controller;
  bool _actualizandoDesdeBoton = false;

  @override
  void initState() {
    super.initState();
    final cantidadInicial = widget.carritoActivo.getQuantity(widget.producto);
    controller = TextEditingController(text: cantidadInicial > 0 ? cantidadInicial.toString() : "1");
  }

  void _actualizarCantidadDesdeBoton(int cantidadNueva) {
    _actualizandoDesdeBoton = true;
    controller.text = cantidadNueva.toString();
    controller.selection = TextSelection.fromPosition(
      TextPosition(offset: controller.text.length),
    );
    setState(() {});
    _actualizandoDesdeBoton = false;
  }

  @override
  Widget build(BuildContext context) {
    final Color fillColor = widget.modoExpressActivo
        ? const Color.fromARGB(255, 174, 204, 255)
        : const Color.fromARGB(255, 255, 223, 175);

    final int cantidadActual = widget.carritoActivo.getQuantity(widget.producto);

    return cantidadActual == 0
        ? SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                widget.carritoActivo.addItem(widget.producto, 1);
                _actualizarCantidadDesdeBoton(1);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: widget.modoExpressActivo ? Colors.blueAccent : Colors.orange,
              ),
              child: const Text("Agregar"),
            ),
          )
        : Column(
            children: [
              TextField(
                controller: controller,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: InputDecoration(
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  labelText: "Cantidad",
                  fillColor: fillColor,
                  filled: true,
                  labelStyle: const TextStyle(color: Colors.black),
                ),
                style: const TextStyle(color: Colors.black),
                onChanged: (value) {
                  if (_actualizandoDesdeBoton) return;
                  final int valorInput = int.tryParse(value) ?? 0;
                  if (valorInput < 0) return;

                  final int cantidadActual = widget.carritoActivo.getQuantity(widget.producto);
                  final int diferencia = valorInput - cantidadActual;
                  if (diferencia != 0) {
                    widget.carritoActivo.addItem(widget.producto, diferencia);
                  }
                },
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove),
                    onPressed: () {
                      widget.carritoActivo.removeItem(widget.producto);
                      final nuevaCantidad = widget.carritoActivo.getQuantity(widget.producto);
                      _actualizarCantidadDesdeBoton(nuevaCantidad);
                    },
                  ),
                  Text(
                    widget.carritoActivo.getQuantity(widget.producto) > 999999
                        ? "999999+"
                        : widget.carritoActivo.getQuantity(widget.producto).toString(),
                    style: const TextStyle(fontSize: 14),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () {
                      widget.carritoActivo.addItem(widget.producto, 1);
                      final nuevaCantidad = widget.carritoActivo.getQuantity(widget.producto);
                      _actualizarCantidadDesdeBoton(nuevaCantidad);
                    },
                  ),
                ],
              ),
            ],
          );
  }
}

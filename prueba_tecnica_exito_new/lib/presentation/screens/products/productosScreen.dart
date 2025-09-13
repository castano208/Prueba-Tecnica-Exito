import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../data/models/producto.dart';
import '../../../data/services/api_service.dart';
import '../../../providers/carritoProvider.dart';
import '../../../providers/carrito_express_provider.dart';
import '../../../providers/expressProvider.dart';
import '../../../providers/i_carrito.dart';
import 'package:go_router/go_router.dart';

class PantallaProductos extends StatefulWidget {
  final String categoria;
  const PantallaProductos({super.key, required this.categoria});

  @override
  State<PantallaProductos> createState() => _PantallaProductosEstado();
}

class _PantallaProductosEstado extends State<PantallaProductos> {
  final ApiService _api = ApiService();
  late Future<List<Producto>> _productosFuturo;

  final Map<int, TextEditingController> _controllers = {};
  late Timer _timer;

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
  void initState() {
    super.initState();
    _productosFuturo = _cargarProductos();
    _iniciarVerificacion();
  }

  @override
  void dispose() {
    _timer.cancel();
    // Limpiar todos los controladores
    _controllers.values.forEach((c) => c.dispose());
    super.dispose();
  }

  Future<List<Producto>> _cargarProductos() async {
    final productos = await _api.getProductsByCategory(widget.categoria);
    for (final producto in productos) {
      if (!mounted) break;
      await precacheImage(NetworkImage(producto.image), context);
    }
    return productos;
  }

  int obtenerCantidadActual(ICarrito carrito, Producto producto) {
    return carrito.getQuantity(producto);
  }

  @override
  Widget build(BuildContext context) {
    final express = Provider.of<ExpressProvider>(context);
    final carritoNormal = Provider.of<CarritoProvider>(context);
    final carritoExpress = Provider.of<CarritoExpressProvider>(context);

    final ICarrito carritoActivo =
        express.modoExpressActivo ? carritoExpress : carritoNormal;

    final Color colorPrecio =
        express.modoExpressActivo ? Colors.blue.shade600 : const Color.fromARGB(255, 255, 10, 10);
    final Color colorBoton =
      express.modoExpressActivo ? Colors.blue : Colors.orange;

    final Icon tipoIcono = Icon(
      express.modoExpressActivo ? Icons.restore_from_trash_outlined : Icons.remove_circle_outline,
    );
        
    final int columnas =
        (MediaQuery.of(context).size.width ~/ 180).clamp(2, 4);

    return Scaffold(
      appBar: AppBar(
          title: Text(
            widget.categoria.toUpperCase(),
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
        backgroundColor: const Color.fromARGB(255, 255, 234, 0),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 11),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                IconButton(
                  icon: const Icon(Icons.shopping_cart, color: Colors.black),
                  onPressed: () => context.push('/carrito'),
                ),
                if (carritoActivo.totalItems > 0)
                  Positioned(
                    left: 25,
                    bottom: 26,
                    child: Container(
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: colorBoton,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        carritoActivo.totalItems < 99 ? carritoActivo.totalItems.toString() : "99+" ,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color.fromARGB(255, 0, 0, 0),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
      body: FutureBuilder<List<Producto>>(
        future: _productosFuturo,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          final productos = snapshot.data ?? [];
          if (productos.isEmpty) {
            return const Center(child: Text("No hay productos disponibles"));
          }

          return GridView.builder(
            padding: const EdgeInsets.all(12),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: columnas,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.65,
            ),
            itemCount: productos.length,
            itemBuilder: (context, index) {
              final producto = productos[index];
              final int cantidadActual = obtenerCantidadActual(carritoActivo, producto);

              final TextEditingController controller = TextEditingController(
                text: cantidadActual > 0 ? cantidadActual.toString() : "1",
              );

              return Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 3,
                clipBehavior: Clip.antiAlias,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: Image.network(
                        producto.image,
                        fit: BoxFit.contain,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            producto.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "\$${producto.price.toStringAsFixed(2)}",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: colorPrecio,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.star, color: Colors.amber, size: 16),
                              const SizedBox(width: 4),
                              Text("${producto.rate} (${producto.count})"),
                            ],
                          ),
                          const SizedBox(height: 8),
                          cantidadActual == 0
                          ? SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () {
                                  carritoActivo.addItem(producto, 1);
                                  setState(() {
                                    controller.text = "1";
                                  });
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: express.modoExpressActivo ? Colors.blueAccent : Colors.orange ,
                                ),
                                child: const Text("Agregar"),
                              ),
                            )
                          :Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              IconButton(
                                icon: tipoIcono,
                                onPressed: () {
                                  carritoActivo.removeItem(producto);
                                },
                                color: express.modoExpressActivo ? const Color.fromARGB(255, 0, 0, 0) : Colors.orange,
                              ),
                              Text(
                                (cantidadActual > 999 ? "999+ " : cantidadActual.toString()) + "und",
                                style: TextStyle(fontSize: (cantidadActual > 999 ? 12 : 16 )),
                              ),
                              IconButton(
                                icon: const Icon(Icons.add_circle_outline),
                                onPressed: () {
                                  carritoActivo.addItem(producto);
                                },
                                color: colorBoton,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

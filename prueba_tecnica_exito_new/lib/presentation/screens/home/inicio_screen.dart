import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:prueba_tecnica_exito_new/providers/carritoProvider.dart';
import 'package:prueba_tecnica_exito_new/providers/carrito_express_provider.dart';
import 'package:prueba_tecnica_exito_new/providers/i_carrito.dart';
import '../../../data/services/api_service.dart';
import 'package:go_router/go_router.dart';
import '../../../presentation/widgets/experienciaSwitch.dart';
import '../../../providers/expressProvider.dart';

final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with RouteAware {
  final ApiService _api = ApiService();
  late Timer _timer;

  late Future<List<String>> _categoriasFuturo;

  @override
  void initState() {
    super.initState();

    _categoriasFuturo = _cargarCategorias();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _iniciarVerificacion();
    });
  }

  void _iniciarVerificacion() {
    final express = Provider.of<ExpressProvider>(context, listen: false);

    // Ejecuta inmediatamente
    express.verificarHorario();

    // Timer cada 1 minutos
    _timer = Timer.periodic(const Duration(minutes: 1), (timer) async {
      final now = DateTime.now();

      // Si estamos en la franja de hora punta (9:59 AM), espera hasta las 10:00
      if (now.hour == 9 && now.minute == 59) {
        final waitSeconds = 61 - now.second;
        await Future.delayed(Duration(seconds: waitSeconds));
      }

      // Si estamos llegando al final de la franja express (4 PM), espera hasta las 4:00
      if (now.hour == 16 && now.minute == 0) {
        final waitSeconds = 62 - now.second;
        await Future.delayed(Duration(seconds: waitSeconds));
      }

      // Verifica horario en cada ejecución
      express.verificarHorario();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context)! as PageRoute);
  }

  // Esta función se llama cada vez que la pantalla vuelve a aparecer
  @override
  void didPopNext() {
    final express = Provider.of<ExpressProvider>(context, listen: false);
    express.verificarHorario();
  }

  @override
  void dispose() {
    _timer.cancel();
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  Future<List<String>> _cargarCategorias() async {
    final List<String> productos = await _api.getCategorias();
    final Set<String> categoriasSet = {};
    categoriasSet.addAll(productos);
    return categoriasSet.toList();
  }

  @override
  Widget build(BuildContext context) {
    final express = Provider.of<ExpressProvider>(context);
    final carritoNormal = Provider.of<CarritoProvider>(context);
    final carritoExpress = Provider.of<CarritoExpressProvider>(context);

    final ICarrito carritoActivo =
        express.modoExpressActivo ? carritoExpress : carritoNormal;

    final crossAxisCount =
        (MediaQuery.of(context).size.width ~/ 180).clamp(2, 4);

    final Color colorBoton =
        express.modoExpressActivo ? Colors.blue : Colors.orange;

    return Scaffold(
      appBar: AppBar(
      leading: IconButton(
        icon: Icon(
          express.vistaPersonalizadaActiva ? Icons.remove_red_eye : Icons.visibility_off,
          color: Colors.black,
        ),
        onPressed: () => express.triggerVistaPersonalizada(),
      ),
      title: Text(
        "Categorías" +
            (express.vistaPersonalizadaActiva ? " Personalizado" : ""),
        style: const TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.bold,
        ),
      ),
      centerTitle: true,
      backgroundColor: const Color.fromARGB(255, 255, 238, 0),
      actions: [
        // Carrito
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
                      carritoActivo.totalItems < 99
                          ? carritoActivo.totalItems.toString()
                          : "99+",
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    ),
    body: Column(
        children: [
          if (express.mostrarSwitch) ...[
            const Padding(
              padding: EdgeInsets.all(20),
              child: BotonExperienciaExpress(),
            ),
          ],
          Expanded(
            child: FutureBuilder<List<String>>(
              future: _categoriasFuturo,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No hay categorías disponibles'));
                }

                final categorias = snapshot.data!;

                return GridView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: categorias.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.1,
                  ),
                  itemBuilder: (context, index) {
                    final categoria = categorias[index];
                    return GestureDetector(
                      onTap: () {
                        if (express.vistaPersonalizadaActiva) {
                          context.push('/productosPersonalizado/$categoria');
                        }else{
                          context.push('/productos/$categoria');
                        }
                      },
                      child: Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 3,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.category,
                              size: 48,
                              color: Colors.blueAccent,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              categoria.toUpperCase(),
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

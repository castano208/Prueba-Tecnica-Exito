import 'package:go_router/go_router.dart';
import '../presentation/screens/home/inicio_screen.dart';
import '../presentation/screens/products/productosScreen.dart';
import '../presentation/screens/cart/pantalla_carrito.dart';

//importas vista personalizada
import '../presentation/screens/products/extra/productosScreenModificado.dart';

final GoRouter router = GoRouter(
  observers: [routeObserver],
  routes: [
    // Routas para acceder a las vistas unicamente de lo solitado en la prueba tecnica
    GoRoute(
      path: '/',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/productos/:category',
      builder: (context, state) {
        final categoria = state.pathParameters['category']!;
        return PantallaProductos(categoria: categoria);
      },
    ),
    GoRoute(
      path: '/carrito',
      builder: (context, state) => const PantallaCarrito(),
    ),
    
    // Routa para acceder a las visuales personalizada de productos
    GoRoute(
      path: '/productosPersonalizado/:category',
      builder: (context, state) {
        final categoria = state.pathParameters['category']!;
        return PantallaProductosModificada(categoria: categoria);
      },
    ),
  ],
);

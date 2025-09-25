import 'package:go_router/go_router.dart';
import 'package:prueba_tecnica_exito_new/main.dart';
import '../presentation/screens/home/home_screen.dart';
import '../presentation/screens/products/products_screen.dart';
import '../presentation/screens/cart/cart_screen.dart';
import '../presentation/screens/products/custom_products_screen.dart';

final GoRouter router = GoRouter(
  observers: [routeObserver],
  routes: [
    // Routa para la pantalla principal
    GoRoute(
      path: '/',
      builder: (context, state) => const HomeScreen(),
    ),
    // Route para la vista de productos por categoria
    GoRoute(
      path: '/products/:category',
      builder: (context, state) {
        final category = state.pathParameters['category']!;
        return ProductsScreen(category: category);
      },
    ),
    // Route para la vista de carrito
    GoRoute(
      path: '/cart',
      builder: (context, state) => const CartScreen(),
    ),
    
    // Route para la vista de productos personalizados
    GoRoute(
      path: '/products-custom/:category',
      builder: (context, state) {
        final category = state.pathParameters['category']!;
        return CustomProductsScreen(category: category);
      },
    ),
  ],
);

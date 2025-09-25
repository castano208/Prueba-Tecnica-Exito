import 'package:provider/provider.dart';
import '../../data/services/api_service_impl.dart';
import '../../data/services/time_service_impl.dart';
import '../../data/services/notification_service_impl.dart';
import '../../data/repositories/product_repository_impl.dart';
import '../../data/repositories/cart_repository_impl.dart';
import '../../presentation/providers/express_provider.dart';
import '../../presentation/providers/product_provider.dart';
import '../../presentation/providers/carrito_provider.dart';
import '../../presentation/providers/carrito_express_provider.dart';
import '../../presentation/providers/search_provider.dart';

/// Configuración de inyección de dependencias
/// Registra todos los providers y servicios de la aplicación
class DependencyInjection {
  static List<ChangeNotifierProvider> get providers => [
    // Servicios - Implementaciones concretas que extienden ChangeNotifier
    ChangeNotifierProvider<ApiServiceImpl>(
      create: (_) => ApiServiceImpl(),
    ),
    ChangeNotifierProvider<TimeServiceImpl>(
      create: (_) => TimeServiceImpl(),
    ),
    ChangeNotifierProvider<NotificationServiceImpl>(
      create: (_) => NotificationServiceImpl(),
    ),
    
    // Repositorios - Implementaciones concretas que extienden ChangeNotifier
    ChangeNotifierProvider<ProductRepositoryImpl>(
      create: (context) => ProductRepositoryImpl(
        context.read<ApiServiceImpl>(),
      ),
    ),
    
    // Providers de Carrito - Carritos separados para modo normal y express
    ChangeNotifierProvider<CarritoProvider>(
      create: (context) => CarritoProvider(
        CartRepositoryImpl(),
      ),
    ),
    ChangeNotifierProvider<CarritoExpressProvider>(
      create: (context) => CarritoExpressProvider(
        CartRepositoryImpl(),
      ),
    ),
    
    // Providers de Lógica de Negocio - Estos extienden ChangeNotifier
    ChangeNotifierProvider<ExpressProvider>(
      create: (context) => ExpressProvider(
        context.read<TimeServiceImpl>(),
        context.read<NotificationServiceImpl>(),
      ),
    ),
    ChangeNotifierProvider<SearchProvider>(
      create: (context) => SearchProvider(
        context.read<ProductRepositoryImpl>(),
      ),
    ),
    ChangeNotifierProvider<ProductProvider>(
      create: (context) => ProductProvider(
        context.read<ProductRepositoryImpl>(),
        context.read<CarritoProvider>(),
        context.read<CarritoExpressProvider>(),
        context.read<ExpressProvider>(),
      ),
    ),
  ];
}

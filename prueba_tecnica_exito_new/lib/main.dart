import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'config/router.dart';
import 'config/tema.dart';
import '../../../providers/carritoProvider.dart';
import '../../../providers/carrito_express_provider.dart';
import '../../../providers/expressProvider.dart';

final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();

void main() {
  tz.initializeTimeZones();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<CarritoProvider>(create: (_) => CarritoProvider()),
        ChangeNotifierProvider<CarritoExpressProvider>(create: (_) => CarritoExpressProvider()),
        ChangeNotifierProvider<ExpressProvider>(create: (_) => ExpressProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      routerConfig: router,
    );
  }
}

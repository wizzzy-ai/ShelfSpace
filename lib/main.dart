import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/theme/app_theme.dart';
import 'profile_orders/data/profile_orders_repository.dart';
import 'profile_orders/data/profile_orders_repository_impl.dart';
import 'profile_orders/providers/orders_provider.dart';
import 'profile_orders/providers/profile_provider.dart';
import 'core/theme/app_theme_controller.dart';
import 'screens/splash/splash_screen.dart';
import 'services/google_auth_service.dart';

void main() async {
  await GoogleAuthService.instance.init();
  runApp(const ShelfSpaceApp());
}

class ShelfSpaceApp extends StatelessWidget {
  const ShelfSpaceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<ProfileOrdersRepository>(
          create: (_) => ProfileOrdersRepositoryImpl(),
        ),
        ChangeNotifierProvider(
          create: (c) =>
              ProfileProvider(c.read<ProfileOrdersRepository>()),
        ),
        ChangeNotifierProvider(
          create: (c) =>
              OrdersProvider(c.read<ProfileOrdersRepository>()),
        ),
      ],
      child: AnimatedBuilder(
        animation: AppThemeController.instance,
        builder: (context, _) => MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'ShelfSpace',
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: AppThemeController.instance.themeMode,
          home: const SplashScreen(),
        ),
      ),
    );
  }
}

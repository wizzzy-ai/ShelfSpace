import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/theme/app_theme.dart';
import 'profile_orders/data/mock_profile_orders_repository.dart';
import 'profile_orders/data/profile_orders_repository.dart';
import 'profile_orders/providers/orders_provider.dart';
import 'profile_orders/providers/profile_provider.dart';
import 'screens/splash/splash_screen.dart';

void main() {
  runApp(const ShelfSpaceApp());
}

class ShelfSpaceApp extends StatelessWidget {
  const ShelfSpaceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<ProfileOrdersRepository>(
          create: (_) => MockProfileOrdersRepository(),
        ),
        ChangeNotifierProvider(
          create: (c) =>
              ProfileProvider(c.read<ProfileOrdersRepository>())..load(),
        ),
        ChangeNotifierProvider(
          create: (c) =>
              OrdersProvider(c.read<ProfileOrdersRepository>())..load(),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'ShelfSpace',
        theme: AppTheme.lightTheme,
        home: const SplashScreen(),
      ),
    );
  }
}
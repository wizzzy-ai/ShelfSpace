import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';
import 'core/theme/app_theme_controller.dart';
import 'screens/splash/splash_screen.dart';

void main() {
  runApp(const ShelfSpaceApp());
}

class ShelfSpaceApp extends StatelessWidget {
  const ShelfSpaceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: AppThemeController.instance,
      builder: (context, _) => MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'ShelfSpace',
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: AppThemeController.instance.themeMode,
        home: const SplashScreen(),
      ),
    );
  }
}

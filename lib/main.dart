import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';
import 'screens/splash/splash_screen.dart';

void main() {
  runApp(const ShelfSpaceApp());
}

class ShelfSpaceApp extends StatelessWidget {
  const ShelfSpaceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ShelfSpace',
      theme: AppTheme.lightTheme,
      home: const SplashScreen(),
    );
  }
}
import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';
import 'screens/splash/splash_screen.dart';

void main() {
  runApp(const BibliraApp());
}

class BibliraApp extends StatelessWidget {
  const BibliraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Biblira',
      theme: AppTheme.lightTheme,
      home: const SplashScreen(),
    );
  }
}
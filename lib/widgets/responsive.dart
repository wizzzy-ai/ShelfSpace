import 'package:flutter/material.dart';

class ShelfSpaceResponsive {
  ShelfSpaceResponsive._();

  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < 600;
  }

  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return width >= 600 && width < 1024;
  }

  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= 1024;
  }

  static double horizontalPadding(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    if (width >= 1200) {
      return 80;
    }

    if (width >= 1024) {
      return 48;
    }

    if (width >= 600) {
      return 32;
    }

    return 20;
  }

  static int gridColumns(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    if (width >= 1400) {
      return 5;
    }

    if (width >= 1100) {
      return 4;
    }

    if (width >= 700) {
      return 3;
    }

    return 2;
  }

  static double contentMaxWidth(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    if (width >= 1400) {
      return 1280;
    }

    if (width >= 1000) {
      return 960;
    }

    return double.infinity;
  }
}

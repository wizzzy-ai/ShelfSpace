import 'package:flutter/material.dart';

class ResponsiveContent extends StatelessWidget {
  final Widget child;

  const ResponsiveContent({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    double maxWidth;

    if (width >= 1400) {
      maxWidth = 1280;
    } else if (width >= 1100) {
      maxWidth = 1000;
    } else if (width >= 800) {
      maxWidth = 760;
    } else {
      maxWidth = double.infinity;
    }

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: maxWidth,
        ),
        child: child,
      ),
    );
  }
}
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../core/constants/app_colors.dart';

/// Flutter version of the ldrs Trefoil loader used on the splash screen.
class ShelfSpaceLoader extends StatefulWidget {
  final double size;
  final double stroke;
  final Color color;
  final Duration duration;

  const ShelfSpaceLoader({
    super.key,
    this.size = 40,
    this.stroke = 4,
    this.color = AppColors.burgundy,
    this.duration = const Duration(milliseconds: 1400),
  });

  @override
  State<ShelfSpaceLoader> createState() => _ShelfSpaceLoaderState();
}

class _ShelfSpaceLoaderState extends State<ShelfSpaceLoader>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration)
      ..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: widget.size,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) => CustomPaint(
          painter: _TrefoilPainter(
            progress: _controller.value,
            color: widget.color,
            stroke: widget.stroke,
          ),
        ),
      ),
    );
  }
}

class _TrefoilPainter extends CustomPainter {
  final double progress;
  final double stroke;
  final Color color;

  const _TrefoilPainter({
    required this.progress,
    required this.color,
    required this.stroke,
  });

  Path _createPath(Size size) {
    final path = Path();
    final center = Offset(size.width / 2, size.height / 2);
    final scale = size.shortestSide / 6.2;

    // Three-lobed trefoil curve, sampled smoothly for the compact loader.
    const samples = 240;
    for (var i = 0; i <= samples; i++) {
      final t = 2 * math.pi * i / samples;
      final x = math.sin(t) + 2 * math.sin(2 * t);
      final y = math.cos(t) - 2 * math.cos(2 * t);
      final point = Offset(center.dx + x * scale, center.dy + y * scale);
      if (i == 0) {
        path.moveTo(point.dx, point.dy);
      } else {
        path.lineTo(point.dx, point.dy);
      }
    }
    path.close();
    return path;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final path = _createPath(size);
    final trackPaint = Paint()
      ..color = color.withValues(alpha: 0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(path, trackPaint);

    final movingPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;

    final metric = path.computeMetrics().first;
    final start = progress * metric.length;
    final end = start + metric.length * 0.15;
    if (end <= metric.length) {
      canvas.drawPath(metric.extractPath(start, end), movingPaint);
    } else {
      canvas.drawPath(metric.extractPath(start, metric.length), movingPaint);
      canvas.drawPath(metric.extractPath(0, end - metric.length), movingPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _TrefoilPainter oldDelegate) =>
      oldDelegate.progress != progress ||
      oldDelegate.color != color ||
      oldDelegate.stroke != stroke;
}

import 'dart:io';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

class ProfileAvatar extends StatelessWidget {
  const ProfileAvatar({
    super.key,
    required this.name,
    this.imagePath,
    this.radius = 48,
  });

  final String name;
  final String? imagePath;
  final double radius;

  String get _initials {
    final parts = name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty);
    if (parts.isEmpty) return '?';
    return parts.take(2).map((p) => p[0].toUpperCase()).join();
  }

  @override
  Widget build(BuildContext context) {
    final path = imagePath;
    final hasImage = path != null && path.isNotEmpty;

    ImageProvider? image;
    if (hasImage) {
      image = kIsWeb ? NetworkImage(path) : FileImage(File(path));
    }

    return CircleAvatar(
      radius: radius,
      backgroundImage: image,
      child: hasImage
          ? null
          : Text(_initials, style: TextStyle(fontSize: radius * 0.7)),
    );
  }
}
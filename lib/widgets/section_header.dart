import 'package:flutter/material.dart';

import '../core/constants/app_colors.dart';

class SectionHeader extends StatelessWidget {
  final String title;
  final String? actionText;
  final VoidCallback? onAction;
  final VoidCallback? onSeeAll;

  const SectionHeader({
    super.key,
    required this.title,
    this.actionText,
    this.onAction,
    this.onSeeAll,
  });

  @override
  Widget build(BuildContext context) {
    final callback = onSeeAll ?? onAction;
    final label = actionText ?? 'See all';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.dark,
                  ),
            ),
          ),
          if (callback != null)
            TextButton(
              onPressed: callback,
              child: Text(
                label,
                style: const TextStyle(
                  color: AppColors.burgundy,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
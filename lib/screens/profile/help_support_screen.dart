import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  void _showComingSoon(
    BuildContext context,
    String feature,
  ) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature will be connected later.'),
      ),
    );
  }

  void _showContactDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: Theme.of(context).colorScheme.surface,
          title: const Text('Contact Support'),
          content: Text(
            'Need help? Our support team will be available through email, phone, and in-app support.',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              height: 1.5,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text(
                'Close',
                style: TextStyle(
                  color: AppColors.burgundy,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showFaq(
    BuildContext context,
    String question,
    String answer,
  ) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              20,
              18,
              20,
              24,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 45,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.outlineVariant,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  question,
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 12),
                Text(
                  answer,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    height: 1.6,
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(sheetContext);
                    },
                    child: const Text('Close'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Help & Support'),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          16,
          8,
          16,
          30,
        ),
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.burgundy,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.white.withValues(
                      alpha: 0.12,
                    ),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.support_agent_rounded,
                    color: AppColors.white,
                    size: 26,
                  ),
                ),
                const SizedBox(height: 18),
                const Text(
                  'How can we help?',
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 7),
                const Text(
                  'Find answers to common questions or contact the ShelfSpace support team.',
                  style: TextStyle(
                    color: AppColors.white,
                    height: 1.5,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 18),
                SizedBox(
                  height: 46,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      _showContactDialog(context);
                    },
                    icon: const Icon(
                      Icons.headset_mic_outlined,
                      size: 19,
                    ),
                    label: const Text('Contact Support'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.surface,
                      foregroundColor: AppColors.burgundy,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 26),

          const Text(
            'Frequently Asked Questions',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 12),

          _FaqCard(
            icon: Icons.shopping_bag_outlined,
            question: 'How do I place an order?',
            onTap: () {
              _showFaq(
                context,
                'How do I place an order?',
                'Browse the ShelfSpace catalog, open a book, add it to your cart, and continue to checkout. Enter your delivery details and select your preferred payment method before placing the order.',
              );
            },
          ),

          const SizedBox(height: 10),

          _FaqCard(
            icon: Icons.local_shipping_outlined,
            question: 'How can I track my order?',
            onTap: () {
              _showFaq(
                context,
                'How can I track my order?',
                'Open Profile → My Orders and select the order you want to view. Your order status and delivery information will be shown there.',
              );
            },
          ),

          const SizedBox(height: 10),

          _FaqCard(
            icon: Icons.credit_card_outlined,
            question: 'What payment methods are supported?',
            onTap: () {
              _showFaq(
                context,
                'What payment methods are supported?',
                'ShelfSpace can support options such as card payments, bank transfers, and cash on delivery. Available methods may depend on your account and checkout setup.',
              );
            },
          ),

          const SizedBox(height: 10),

          _FaqCard(
            icon: Icons.favorite_border_rounded,
            question: 'How does my wishlist work?',
            onTap: () {
              _showFaq(
                context,
                'How does my wishlist work?',
                'Tap the heart on a book to save it. You can view and manage your saved books from the Wishlist section in the bottom navigation.',
              );
            },
          ),

          const SizedBox(height: 26),

          const Text(
            'Support Options',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 12),

          _SupportCard(
            icon: Icons.email_outlined,
            title: 'Email Support',
            subtitle: 'Send us a message',
            onTap: () {
              _showComingSoon(
                context,
                'Email support',
              );
            },
          ),

          const SizedBox(height: 10),

          _SupportCard(
            icon: Icons.phone_outlined,
            title: 'Phone Support',
            subtitle: 'Speak with our support team',
            onTap: () {
              _showComingSoon(
                context,
                'Phone support',
              );
            },
          ),

          const SizedBox(height: 10),

          _SupportCard(
            icon: Icons.chat_bubble_outline_rounded,
            title: 'Live Chat',
            subtitle: 'Chat with a support representative',
            onTap: () {
              _showComingSoon(
                context,
                'Live chat',
              );
            },
          ),

          const SizedBox(height: 28),

          Center(
            child: Column(
              children: [
                const Text(
                  'ShelfSpace Support',
                  style: TextStyle(
                    color: AppColors.burgundy,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  'We are here to help.',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Version 1.0.0',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(
                      alpha: 0.8,
                    ),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FaqCard extends StatelessWidget {
  final IconData icon;
  final String question;
  final VoidCallback onTap;

  const _FaqCard({
    required this.icon,
    required this.question,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).colorScheme.surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Theme.of(context).colorScheme.outlineVariant,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.burgundy.withValues(
                    alpha: 0.08,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: AppColors.burgundy,
                ),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Text(
                  question,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SupportCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _SupportCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).colorScheme.surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Theme.of(context).colorScheme.outlineVariant,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.burgundy.withValues(
                    alpha: 0.08,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: AppColors.burgundy,
                ),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

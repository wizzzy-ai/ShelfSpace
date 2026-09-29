import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/models.dart';
import '../providers/profile_provider.dart';
import '../widgets/profile_avatar.dart';
import 'edit_profile_screen.dart';
import 'orders_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProfileProvider>();
    final profile = provider.profile;

    return Scaffold(
      appBar: AppBar(title: const Text('My Profile')),
      body: Builder(
        builder: (context) {
          if (provider.isLoading && profile == null) {
            return const Center(child: CircularProgressIndicator());
          }
          if (profile == null) {
            return _ErrorView(
              message: provider.error ?? 'Something went wrong.',
              onRetry: provider.load,
            );
          }
          return RefreshIndicator(
            onRefresh: provider.load,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              children: [
                Center(
                  child: ProfileAvatar(
                    name: profile.name,
                    imagePath: profile.profileImagePath,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  profile.name,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                _InfoCard(
                  title: 'Contact',
                  rows: {'Email': profile.email, 'Phone': profile.phone},
                ),
                _InfoCard(
                  title: 'Shipping Address',
                  rows: {
                    'Street': profile.address.street,
                    'City': profile.address.city,
                    'State': profile.address.state,
                    'Country': profile.address.country,
                    'Postal code': profile.address.postalCode,
                  },
                ),
                _InfoCard(
                  title: 'Payment Methods',
                  rows: {'Default': profile.paymentMethod.display},
                ),
                const SizedBox(height: 8),
                FilledButton.icon(
                  onPressed: () => _openEdit(context, profile),
                  icon: const Icon(Icons.edit_outlined),
                  label: const Text('Edit Profile'),
                ),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const OrdersScreen(),
                    ),
                  ),
                  icon: const Icon(Icons.receipt_long_outlined),
                  label: const Text('My Orders'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _openEdit(BuildContext context, UserProfile profile) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => EditProfileScreen(profile: profile),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.title, required this.rows});

  final String title;
  final Map<String, String> rows;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: textTheme.titleMedium),
            const SizedBox(height: 8),
            for (final entry in rows.entries)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 96,
                      child: Text(entry.key, style: textTheme.bodySmall),
                    ),
                    Expanded(
                      child: Text(entry.value, style: textTheme.bodyMedium),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(message),
          const SizedBox(height: 12),
          FilledButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }
}

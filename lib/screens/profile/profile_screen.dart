import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../admin/admin_dashboard_screen.dart';
import '../orders/orders_screen.dart';
import 'about_shelfspace_screen.dart';
import 'addresses_screen.dart';
import 'edit_profile_screen.dart';
import 'help_support_screen.dart';
import 'payment_methods_screen.dart';
import 'settings_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width >= 1024;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset(
              'assets/icons/app_icon.png',
              height: 32,
              width: 32,
              errorBuilder: (_, _, _) {
                return const Icon(
                  Icons.menu_book_rounded,
                  size: 32,
                  color: AppColors.burgundy,
                );
              },
            ),
            const SizedBox(width: 8),
            const Text('My Profile'),
          ],
        ),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              );
            },
            icon: const Icon(Icons.settings_outlined, color: AppColors.dark),
            icon: Icon(
              Icons.settings_outlined,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: isDesktop ? 900 : 700),
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(
              isDesktop ? 32 : 20,
              8,
              isDesktop ? 32 : 20,
              30,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildProfileHeader(context),

                const SizedBox(height: 28),

                _buildSectionTitle(context, 'My Account'),

                const SizedBox(height: 12),

                _buildMenuCard(
                  context,
                  icon: Icons.receipt_long_outlined,
                  title: 'My Orders',
                  subtitle: 'View your order history and order details',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const OrdersScreen()),
                    );
                  },
                ),

                const SizedBox(height: 10),

                _buildMenuCard(
                  context,
                  icon: Icons.dashboard_outlined,
                  title: 'Admin Panel',
                  subtitle: 'Manage books, orders, and customers',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const AdminDashboardScreen(),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 10),

                _buildMenuCard(
                  context,
                  icon: Icons.favorite_border_rounded,
                  title: 'My Wishlist',
                  subtitle: 'View your saved books',
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Wishlist is available from the bottom navigation.',
                        ),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 10),

                _buildMenuCard(
                  context,
                  icon: Icons.location_on_outlined,
                  title: 'Saved Addresses',
                  subtitle: 'Manage your delivery addresses',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const AddressesScreen(),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 10),

                _buildMenuCard(
                  context,
                  icon: Icons.credit_card_outlined,
                  title: 'Payment Methods',
                  subtitle: 'Manage your payment options',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const PaymentMethodsScreen(),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 28),

                _buildSectionTitle(context, 'Preferences'),

                const SizedBox(height: 12),

                _buildMenuCard(
                  context,
                  icon: Icons.notifications_none_rounded,
                  title: 'Notifications',
                  subtitle: 'Manage your notification preferences',
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Notification preferences are available in Settings.',
                        ),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 10),

                _buildMenuCard(
                  context,
                  icon: Icons.settings_outlined,
                  title: 'Settings',
                  subtitle: 'Manage your app preferences',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const SettingsScreen()),
                    );
                  },
                ),

                const SizedBox(height: 28),

                _buildSectionTitle(context, 'Support'),

                const SizedBox(height: 12),

                _buildMenuCard(
                  context,
                  icon: Icons.help_outline_rounded,
                  title: 'Help & Support',
                  subtitle: 'Get help with your ShelfSpace account',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const HelpSupportScreen(),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 10),

                _buildMenuCard(
                  context,
                  icon: Icons.info_outline_rounded,
                  title: 'About ShelfSpace',
                  subtitle: 'Learn more about ShelfSpace',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const AboutShelfSpaceScreen(),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 28),

                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      _showLogoutDialog(context);
                    },
                    icon: const Icon(Icons.logout_rounded),
                    label: const Text('Sign Out'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.error,
                      side: const BorderSide(color: AppColors.error),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width >= 700;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isDesktop ? 26 : 20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
        border: Border.all(
          color: Theme.of(context).colorScheme.outlineVariant,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: isDesktop ? 84 : 72,
            height: isDesktop ? 84 : 72,
            decoration: const BoxDecoration(
              color: AppColors.burgundy,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              'B',
              style: TextStyle(
                color: AppColors.white,
                fontSize: isDesktop ? 34 : 30,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ShelfSpace User',
                  style: Theme.of(context).textTheme.titleLarge
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 5),
                Text(
                  'user@example.com',
                  style: TextStyle(color: AppColors.mutedText, fontSize: 13),
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 10),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const EditProfileScreen(),
                      ),
                    );
                  },
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: const Text(
                    'Edit Profile',
                    style: TextStyle(
                      color: AppColors.burgundy,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge
          ?.copyWith(fontWeight: FontWeight.bold),
    );
  }

  Widget _buildMenuCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
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
            border: Border.all(color: AppColors.border),
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
                  color: AppColors.burgundy.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: AppColors.burgundy, size: 22),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        fontSize: 12,
                        height: 1.3,
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

  void _showLogoutDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: Theme.of(context).colorScheme.surface,
          title: const Text('Sign out?'),
          content: const Text(
            'Are you sure you want to sign out of ShelfSpace?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: Text(
                'Cancel',
                style: TextStyle(color: AppColors.mutedText),
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext);

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Sign out will be connected to authentication.',
                    ),
                  ),
                );
              },
              child: const Text('Sign Out'),
            ),
          ],
        );
      },
    );
  }
}

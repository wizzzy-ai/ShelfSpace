import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _darkModeEnabled = false;
  bool _orderUpdatesEnabled = true;
  bool _marketingEnabled = false;

  String _selectedLanguage = 'English';

  void _showLanguagePicker() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.cream,
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              20,
              16,
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
                      color: AppColors.border,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Language',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 14),
                _LanguageOption(
                  language: 'English',
                  selected: _selectedLanguage == 'English',
                  onTap: () {
                    setState(() {
                      _selectedLanguage = 'English';
                    });
                    Navigator.pop(sheetContext);
                  },
                ),
                _LanguageOption(
                  language: 'French',
                  selected: _selectedLanguage == 'French',
                  onTap: () {
                    setState(() {
                      _selectedLanguage = 'French';
                    });
                    Navigator.pop(sheetContext);
                  },
                ),
                _LanguageOption(
                  language: 'Spanish',
                  selected: _selectedLanguage == 'Spanish',
                  onTap: () {
                    setState(() {
                      _selectedLanguage = 'Spanish';
                    });
                    Navigator.pop(sheetContext);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showThemePicker() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.cream,
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              20,
              16,
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
                      color: AppColors.border,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Appearance',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 14),
                _ThemeOption(
                  icon: Icons.light_mode_outlined,
                  title: 'Light',
                  subtitle: 'Use the ShelfSpace light theme',
                  selected: !_darkModeEnabled,
                  onTap: () {
                    setState(() {
                      _darkModeEnabled = false;
                    });
                    Navigator.pop(sheetContext);
                  },
                ),
                const SizedBox(height: 10),
                _ThemeOption(
                  icon: Icons.dark_mode_outlined,
                  title: 'Dark',
                  subtitle: 'Use the dark theme',
                  selected: _darkModeEnabled,
                  onTap: () {
                    setState(() {
                      _darkModeEnabled = true;
                    });
                    Navigator.pop(sheetContext);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showDeleteAccountDialog() {
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: AppColors.white,
          title: const Text('Delete account?'),
          content: const Text(
            'This action is permanent. Your account and associated data may be removed.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text(
                'Cancel',
                style: TextStyle(
                  color: AppColors.mutedText,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext);

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Account deletion will be connected later.',
                    ),
                  ),
                );
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: AppColors.cream,
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
          const _SectionLabel(
            title: 'Appearance',
          ),
          const SizedBox(height: 10),
          _SettingCard(
            children: [
              _SettingTile(
                icon: Icons.palette_outlined,
                title: 'Theme',
                subtitle:
                    _darkModeEnabled ? 'Dark' : 'Light',
                onTap: _showThemePicker,
              ),
            ],
          ),

          const SizedBox(height: 24),

          const _SectionLabel(
            title: 'Notifications',
          ),
          const SizedBox(height: 10),
          _SettingCard(
            children: [
              _SwitchTile(
                icon: Icons.notifications_none_rounded,
                title: 'Push Notifications',
                subtitle:
                    'Receive updates from ShelfSpace',
                value: _notificationsEnabled,
                onChanged: (value) {
                  setState(() {
                    _notificationsEnabled = value;
                  });
                },
              ),
              const _TileDivider(),
              _SwitchTile(
                icon: Icons.local_shipping_outlined,
                title: 'Order Updates',
                subtitle:
                    'Get updates about your deliveries',
                value: _orderUpdatesEnabled,
                onChanged: _notificationsEnabled
                    ? (value) {
                        setState(() {
                          _orderUpdatesEnabled = value;
                        });
                      }
                    : null,
              ),
              const _TileDivider(),
              _SwitchTile(
                icon: Icons.campaign_outlined,
                title: 'Promotions',
                subtitle:
                    'Receive new arrivals and offers',
                value: _marketingEnabled,
                onChanged: _notificationsEnabled
                    ? (value) {
                        setState(() {
                          _marketingEnabled = value;
                        });
                      }
                    : null,
              ),
            ],
          ),

          const SizedBox(height: 24),

          const _SectionLabel(
            title: 'Preferences',
          ),
          const SizedBox(height: 10),
          _SettingCard(
            children: [
              _SettingTile(
                icon: Icons.language_outlined,
                title: 'Language',
                subtitle: _selectedLanguage,
                onTap: _showLanguagePicker,
              ),
            ],
          ),

          const SizedBox(height: 24),

          const _SectionLabel(
            title: 'Privacy & Security',
          ),
          const SizedBox(height: 10),
          _SettingCard(
            children: [
              _SettingTile(
                icon: Icons.lock_outline_rounded,
                title: 'Privacy',
                subtitle: 'Manage your privacy preferences',
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Privacy settings will be connected later.',
                      ),
                    ),
                  );
                },
              ),
              const _TileDivider(),
              _SettingTile(
                icon: Icons.security_outlined,
                title: 'Security',
                subtitle: 'Manage account security',
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Security settings will be connected to authentication.',
                      ),
                    ),
                  );
                },
              ),
            ],
          ),

          const SizedBox(height: 24),

          const _SectionLabel(
            title: 'Support',
          ),
          const SizedBox(height: 10),
          _SettingCard(
            children: [
              _SettingTile(
                icon: Icons.help_outline_rounded,
                title: 'Help & Support',
                subtitle: 'Get help with ShelfSpace',
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Help & Support will be connected later.',
                      ),
                    ),
                  );
                },
              ),
              const _TileDivider(),
              _SettingTile(
                icon: Icons.description_outlined,
                title: 'Terms & Conditions',
                subtitle: 'Read our terms',
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Terms & Conditions will be connected later.',
                      ),
                    ),
                  );
                },
              ),
              const _TileDivider(),
              _SettingTile(
                icon: Icons.privacy_tip_outlined,
                title: 'Privacy Policy',
                subtitle: 'Read our privacy policy',
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Privacy Policy will be connected later.',
                      ),
                    ),
                  );
                },
              ),
            ],
          ),

          const SizedBox(height: 24),

          const _SectionLabel(
            title: 'Account',
          ),
          const SizedBox(height: 10),
          _SettingCard(
            children: [
              _SettingTile(
                icon: Icons.delete_outline_rounded,
                title: 'Delete Account',
                subtitle: 'Permanently remove your account',
                iconColor: AppColors.error,
                titleColor: AppColors.error,
                onTap: _showDeleteAccountDialog,
              ),
            ],
          ),

          const SizedBox(height: 28),

          Center(
            child: Column(
              children: [
                Text(
                  'ShelfSpace',
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(
                        color: AppColors.burgundy,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Your World of Books',
                  style: TextStyle(
                    color: AppColors.mutedText,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Version 1.0.0',
                  style: TextStyle(
                    color: AppColors.mutedText,
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

class _SectionLabel extends StatelessWidget {
  final String title;

  const _SectionLabel({
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        color: AppColors.dark,
        fontSize: 17,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}

class _SettingCard extends StatelessWidget {
  final List<Widget> children;

  const _SettingCard({
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.border,
        ),
      ),
      child: Column(
        children: children,
      ),
    );
  }
}

class _SettingTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final Color? iconColor;
  final Color? titleColor;

  const _SettingTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.iconColor,
    this.titleColor,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: (iconColor ?? AppColors.burgundy)
                    .withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: iconColor ?? AppColors.burgundy,
                size: 22,
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
                    style: TextStyle(
                      color: titleColor ?? AppColors.dark,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: AppColors.mutedText,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: AppColors.mutedText,
            ),
          ],
        ),
      ),
    );
  }
}

class _SwitchTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool>? onChanged;

  const _SwitchTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(15),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.burgundy.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.notifications_none_rounded,
              color: AppColors.burgundy,
            ),
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
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: AppColors.mutedText,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: AppColors.burgundy,
          ),
        ],
      ),
    );
  }
}

class _TileDivider extends StatelessWidget {
  const _TileDivider();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.only(left: 72),
      child: Divider(
        height: 1,
        color: AppColors.border,
      ),
    );
  }
}

class _LanguageOption extends StatelessWidget {
  final String language;
  final bool selected;
  final VoidCallback onTap;

  const _LanguageOption({
    required this.language,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
      title: Text(
        language,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
        ),
      ),
      trailing: Icon(
        selected
            ? Icons.radio_button_checked_rounded
            : Icons.radio_button_off_rounded,
        color: selected
            ? AppColors.burgundy
            : AppColors.mutedText,
      ),
    );
  }
}

class _ThemeOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  const _ThemeOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: selected
                  ? AppColors.burgundy
                  : AppColors.border,
            ),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color: AppColors.burgundy,
              ),
              const SizedBox(width: 12),
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
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: AppColors.mutedText,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              if (selected)
                const Icon(
                  Icons.check_circle_rounded,
                  color: AppColors.burgundy,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
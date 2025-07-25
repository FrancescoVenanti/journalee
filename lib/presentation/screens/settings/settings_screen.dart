import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:journalee/data/models/user_model.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/router/app_router.dart';
import '../../providers/auth_provider.dart';
import '../../providers/theme_provider.dart';
import '../../widgets/common/custom_button.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserProvider);
    final themeMode = ref.watch(themeModeProvider);

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // App Bar
            SliverAppBar(
              expandedHeight: 120,
              floating: true,
              pinned: false,
              backgroundColor: Colors.transparent,
              flexibleSpace: FlexibleSpaceBar(
                titlePadding: const EdgeInsets.only(left: 24, bottom: 16),
                title: _buildAppBarTitle(context),
                background: Container(
                  decoration: BoxDecoration(
                    gradient: Theme.of(context).brightness == Brightness.dark
                        ? AppColors.darkBackgroundGradient
                        : AppColors.backgroundGradient,
                  ),
                ),
              ),
            ),

            // Content
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Profile Section
                    _buildProfileSection(context, currentUser),

                    const SizedBox(height: 32),

                    // Appearance Section
                    _buildAppearanceSection(context, ref, themeMode),

                    const SizedBox(height: 32),

                    // General Settings
                    _buildGeneralSection(context),

                    const SizedBox(height: 32),

                    // Support Section
                    _buildSupportSection(context),

                    const SizedBox(height: 32),

                    // Account Section
                    _buildAccountSection(context, ref),

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBarTitle(BuildContext context) {
    return Text(
      'Settings',
      style: AppTextStyles.h3.copyWith(
        color: Theme.of(context).colorScheme.onBackground,
        fontWeight: FontWeight.w700,
      ),
    );
  }

  Widget _buildProfileSection(
      BuildContext context, AsyncValue<UserModel?> currentUser) {
    return _buildSection(
      context,
      title: 'Profile',
      children: [
        currentUser.when(
          data: (user) => _buildProfileTile(context, user),
          loading: () => _buildProfileTileSkeleton(context),
          error: (_, __) => const SizedBox.shrink(),
        ),
      ],
    );
  }

  Widget _buildProfileTile(BuildContext context, UserModel? user) {
    if (user == null) return const SizedBox.shrink();

    return _buildSettingsTile(
      context,
      icon: Icons.person_outline,
      title: user.displayName,
      subtitle: user.email,
      trailing: const Icon(Icons.chevron_right),
      onTap: () => AppRouter.goToProfile(context),
    );
  }

  Widget _buildProfileTileSkeleton(BuildContext context) {
    return _buildSettingsTile(
      context,
      icon: Icons.person_outline,
      title: 'Loading...',
      subtitle: 'Loading...',
      trailing: const Icon(Icons.chevron_right),
      onTap: () {},
    );
  }

  Widget _buildAppearanceSection(
      BuildContext context, WidgetRef ref, ThemeMode themeMode) {
    return _buildSection(
      context,
      title: 'Appearance',
      children: [
        _buildSettingsTile(
          context,
          icon: Icons.palette_outlined,
          title: 'Theme',
          subtitle: _getThemeModeText(themeMode),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => _showThemeSelector(context, ref, themeMode),
        ),
        _buildSettingsTile(
          context,
          icon: Icons.text_fields,
          title: 'Text Size',
          subtitle: 'Default',
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            // Implement text size settings
          },
        ),
      ],
    );
  }

  Widget _buildGeneralSection(BuildContext context) {
    return _buildSection(
      context,
      title: 'General',
      children: [
        _buildSettingsTile(
          context,
          icon: Icons.notifications_outlined,
          title: 'Notifications',
          subtitle: 'Manage notification preferences',
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            // Navigate to notification settings
          },
        ),
        _buildSettingsTile(
          context,
          icon: Icons.backup_outlined,
          title: 'Backup & Sync',
          subtitle: 'Automatic backup enabled',
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            // Navigate to backup settings
          },
        ),
        _buildSettingsTile(
          context,
          icon: Icons.download_outlined,
          title: 'Export Data',
          subtitle: 'Download your journal entries',
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            // Implement data export
          },
        ),
      ],
    );
  }

  Widget _buildSupportSection(BuildContext context) {
    return _buildSection(
      context,
      title: 'Support',
      children: [
        _buildSettingsTile(
          context,
          icon: Icons.help_outline,
          title: 'Help & FAQ',
          subtitle: 'Get help using Journalee',
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            // Navigate to help
          },
        ),
        _buildSettingsTile(
          context,
          icon: Icons.feedback_outlined,
          title: 'Send Feedback',
          subtitle: 'Help us improve the app',
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            // Open feedback form
          },
        ),
        _buildSettingsTile(
          context,
          icon: Icons.info_outline,
          title: 'About',
          subtitle: 'Version 1.0.0',
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            // Show about dialog
            _showAboutDialog(context);
          },
        ),
      ],
    );
  }

  Widget _buildAccountSection(BuildContext context, WidgetRef ref) {
    return _buildSection(
      context,
      title: 'Account',
      children: [
        _buildSettingsTile(
          context,
          icon: Icons.lock_outline,
          title: 'Privacy & Security',
          subtitle: 'Manage your privacy settings',
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            // Navigate to privacy settings
          },
        ),
        _buildSettingsTile(
          context,
          icon: Icons.logout,
          title: 'Sign Out',
          subtitle: 'Sign out of your account',
          trailing: const Icon(Icons.chevron_right),
          onTap: () => _showSignOutDialog(context, ref),
          textColor: AppColors.error,
        ),
        _buildSettingsTile(
          context,
          icon: Icons.delete_outline,
          title: 'Delete Account',
          subtitle: 'Permanently delete your account',
          trailing: const Icon(Icons.chevron_right),
          onTap: () => _showDeleteAccountDialog(context),
          textColor: AppColors.error,
        ),
      ],
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTextStyles.h6.copyWith(
            color: Theme.of(context).colorScheme.onBackground,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.dark
                ? AppColors.cardDark
                : AppColors.cardLight,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Theme.of(context).brightness == Brightness.dark
                  ? AppColors.dividerDark
                  : AppColors.dividerLight,
              width: 0.5,
            ),
          ),
          child: Column(
            children: children.asMap().entries.map((entry) {
              final index = entry.key;
              final child = entry.value;

              return Column(
                children: [
                  child,
                  if (index < children.length - 1)
                    Divider(
                      height: 1,
                      thickness: 0.5,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? AppColors.dividerDark
                          : AppColors.dividerLight,
                    ),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Widget trailing,
    required VoidCallback onTap,
    Color? textColor,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final effectiveTextColor = textColor ??
        (isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight);

    return ListTile(
      leading: Icon(
        icon,
        color: textColor ??
            (isDark
                ? AppColors.textSecondaryDark
                : AppColors.textSecondaryLight),
      ),
      title: Text(
        title,
        style: AppTextStyles.bodyLarge.copyWith(
          color: effectiveTextColor,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: AppTextStyles.bodySmall.copyWith(
          color: isDark
              ? AppColors.textSecondaryDark
              : AppColors.textSecondaryLight,
        ),
      ),
      trailing: trailing,
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 8,
      ),
    );
  }

  String _getThemeModeText(ThemeMode themeMode) {
    switch (themeMode) {
      case ThemeMode.light:
        return 'Light';
      case ThemeMode.dark:
        return 'Dark';
      case ThemeMode.system:
        return 'System';
    }
  }

  void _showThemeSelector(
      BuildContext context, WidgetRef ref, ThemeMode currentMode) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Choose Theme',
              style: AppTextStyles.h5,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            _buildThemeOption(
              context: context,
              ref: ref,
              mode: ThemeMode.system,
              title: 'System',
              subtitle: 'Follow system setting',
              icon: Icons.brightness_auto,
              isSelected: currentMode == ThemeMode.system,
            ),
            _buildThemeOption(
              context: context,
              ref: ref,
              mode: ThemeMode.light,
              title: 'Light',
              subtitle: 'Light theme',
              icon: Icons.brightness_7,
              isSelected: currentMode == ThemeMode.light,
            ),
            _buildThemeOption(
              context: context,
              ref: ref,
              mode: ThemeMode.dark,
              title: 'Dark',
              subtitle: 'Dark theme',
              icon: Icons.brightness_3,
              isSelected: currentMode == ThemeMode.dark,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeOption({
    required BuildContext context,
    required WidgetRef ref,
    required ThemeMode mode,
    required String title,
    required String subtitle,
    required IconData icon,
    required bool isSelected,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing:
          isSelected ? const Icon(Icons.check, color: AppColors.accent) : null,
      onTap: () {
        ref.read(themeModeProvider.notifier).setThemeMode(mode);
        Navigator.pop(context);
      },
    );
  }

  void _showSignOutDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text(
          'Are you sure you want to sign out? You can always sign back in later.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ref.read(authControllerProvider.notifier).signOut();
            },
            style: TextButton.styleFrom(
              foregroundColor: AppColors.error,
            ),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Account'),
        content: const Text(
          'Are you sure you want to delete your account? This action cannot be undone and all your data will be permanently removed.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Implement account deletion
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Account deletion is not implemented yet'),
                ),
              );
            },
            style: TextButton.styleFrom(
              foregroundColor: AppColors.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'Journalee',
      applicationVersion: '1.0.0',
      applicationLegalese: '© 2024 Journalee. All rights reserved.',
      children: [
        const SizedBox(height: 16),
        const Text(
          'Journalee is a collaborative journaling app that helps you capture and share life\'s moments with the people you care about.',
        ),
      ],
    );
  }
}

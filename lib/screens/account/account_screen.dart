import 'package:flutter/material.dart';
import '../../theme.dart';
import '../../models/user.dart';
import '../auth/login_screen.dart';
import '../../app/theme_controller.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  final User _currentUser = User.getMockUser();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Profile Header
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            automaticallyImplyLeading: false,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(gradient: AppColors.primaryGradient),
                child: SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Profile Photo
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.textWhite,
                            width: 3,
                          ),
                          boxShadow: AppShadows.large,
                        ),
                        child: CircleAvatar(
                          radius: 50,
                          backgroundImage: _currentUser.profilePhoto != null
                              ? NetworkImage(_currentUser.profilePhoto!)
                              : null,
                          child: _currentUser.profilePhoto == null
                              ? const Icon(Icons.person, size: 50)
                              : null,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      // Name
                      Text(
                        _currentUser.name,
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(
                              color: AppColors.textWhite,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 4),
                      // Email
                      Text(
                        _currentUser.email,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textWhite.withOpacity(0.9),
                        ),
                      ),
                      if (_currentUser.isVerified)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.verified,
                                size: 16,
                                color: AppColors.textWhite,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Verified',
                                style: AppTypography.caption.copyWith(
                                  color: AppColors.textWhite,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          // Settings Sections
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Account Section
                  _buildSectionHeader('Account'),
                  _buildSettingCard([
                    _buildSettingTile(
                      icon: Icons.person_outline,
                      title: 'Edit Profile',
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Edit profile feature coming soon!'),
                          ),
                        );
                      },
                    ),
                    _buildDivider(),
                    _buildSettingTile(
                      icon: Icons.lock_outline,
                      title: 'Change Password',
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Change password feature coming soon!',
                            ),
                          ),
                        );
                      },
                    ),
                    _buildDivider(),
                    _buildSettingTile(
                      icon: Icons.credit_card_outlined,
                      title: 'Payment Methods',
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Payment methods feature coming soon!',
                            ),
                          ),
                        );
                      },
                    ),
                  ]),
                  const SizedBox(height: AppSpacing.lg),
                  // Preferences Section
                  _buildSectionHeader('Preferences'),
                  _buildSettingCard([
                    _buildSettingTile(
                      icon: Icons.notifications_outlined,
                      title: 'Notifications',
                      trailing: Switch(
                        value: true,
                        onChanged: (value) {},
                        activeThumbColor: AppColors.primary,
                      ),
                      onTap: null,
                    ),
                    _buildDivider(),
                    _buildSettingTile(
                      icon: Icons.language_outlined,
                      title: 'Language',
                      subtitle: 'English',
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Language selection coming soon!'),
                          ),
                        );
                      },
                    ),
                    _buildDivider(),
                    _buildSettingTile(
                      icon: Icons.dark_mode_outlined,
                      title: 'Dark Mode',
                      trailing: ValueListenableBuilder<ThemeMode>(
                        valueListenable: ThemeController.instance.themeNotifier,
                        builder: (context, mode, _) {
                          return Switch(
                            value: mode == ThemeMode.dark,
                            onChanged: (value) {
                              ThemeController.instance.toggleTheme();
                            },
                            activeThumbColor: AppColors.primary,
                          );
                        },
                      ),
                      onTap: null,
                    ),
                  ]),
                  const SizedBox(height: AppSpacing.lg),
                  // Support Section
                  _buildSectionHeader('Support'),
                  _buildSettingCard([
                    _buildSettingTile(
                      icon: Icons.help_outline,
                      title: 'Help Center',
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Help center coming soon!'),
                          ),
                        );
                      },
                    ),
                    _buildDivider(),
                    _buildSettingTile(
                      icon: Icons.privacy_tip_outlined,
                      title: 'Privacy Policy',
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Privacy policy coming soon!'),
                          ),
                        );
                      },
                    ),
                    _buildDivider(),
                    _buildSettingTile(
                      icon: Icons.description_outlined,
                      title: 'Terms of Service',
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Terms of service coming soon!'),
                          ),
                        );
                      },
                    ),
                    _buildDivider(),
                    _buildSettingTile(
                      icon: Icons.info_outline,
                      title: 'About',
                      subtitle: 'Version 1.0.0',
                      onTap: () {
                        _showAboutDialog();
                      },
                    ),
                  ]),
                  const SizedBox(height: AppSpacing.lg),
                  // Logout Button
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: _handleLogout,
                      icon: const Icon(Icons.logout),
                      label: const Text('Logout'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Theme.of(context).colorScheme.error,
                        side: BorderSide(
                          color: Theme.of(context).colorScheme.error,
                        ),
                        padding: const EdgeInsets.symmetric(
                          vertical: AppSpacing.md,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(
        left: AppSpacing.xs,
        bottom: AppSpacing.sm,
      ),
      child: Text(
        title,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          fontSize: 12,
          color: Theme.of(context).textTheme.bodySmall?.color,
        ),
      ),
    );
  }

  Widget _buildSettingCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(AppRadius.md),
        boxShadow: AppShadows.small,
      ),
      child: Column(children: children),
    );
  }

  Widget _buildSettingTile({
    required IconData icon,
    required String title,
    String? subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
      title: Text(title, style: Theme.of(context).textTheme.bodyMedium),
      subtitle: subtitle != null
          ? Text(subtitle, style: Theme.of(context).textTheme.bodySmall)
          : null,
      trailing:
          trailing ??
          (onTap != null
              ? Icon(Icons.chevron_right, color: Theme.of(context).hintColor)
              : null),
      onTap: onTap,
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 1,
      indent: 56,
      color: Theme.of(context).dividerColor,
    );
  }

  void _showAboutDialog() {
    showAboutDialog(
      context: context,
      applicationName: 'Maisonel',
      applicationVersion: '1.0.0',
      applicationIcon: Container(
        padding: const EdgeInsets.all(AppSpacing.sm),
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
        child: const Icon(
          Icons.home_rounded,
          color: AppColors.textWhite,
          size: 32,
        ),
      ),
      children: [
        Text(
          'Find your perfect home with Maisonel - the premier home rental platform.',
          style: AppTypography.bodyMedium,
        ),
      ],
    );
  }

  void _handleLogout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Logout', style: Theme.of(context).textTheme.headlineSmall),
        content: Text(
          'Are you sure you want to logout?',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Cancel',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).textTheme.bodySmall?.color,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const LoginScreen()),
                (route) => false,
              );
            },
            child: Text(
              'Logout',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.error,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

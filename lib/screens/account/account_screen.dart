import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../theme.dart';
import '../../models/user.dart';
import '../auth/login_screen.dart';
import '../../app/theme_controller.dart';
import 'change_password_screen.dart';
import 'payment_methods_screen.dart';
import '../notifications/notifications_screen.dart';
import '../listings/order_requests_screen.dart';
import 'favorites_screen.dart';
import '../../services/api_service.dart';
import '../../cubits/auth/auth_cubit.dart';
import '../../cubits/language/language_cubit.dart';
import 'package:maisonel_v02/l10n/app_localizations.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthUnauthenticated) {
          Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const LoginScreen()),
            (route) => false,
          );
        }
      },
      builder: (context, state) {
        if (state is AuthAuthenticated) {
          final user = User.fromJson(state.user);
          return _buildProfileContent(context, user);
        } else if (state is AuthLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        return Scaffold(
          body: Center(child: Text(AppLocalizations.of(context)!.pleaseLogIn)),
        );
      },
    );
  }

  Widget _buildProfileContent(BuildContext context, User user) {
    final profilePhotoUrl = ApiService.getImageUrl(user.profilePhoto);
    final hasProfilePhoto =
        profilePhotoUrl != null && profilePhotoUrl.trim().isNotEmpty;
    final isFilePhoto =
        hasProfilePhoto && profilePhotoUrl.startsWith('file://');
    final canUseFilePhoto = isFilePhoto && !kIsWeb;
    final ImageProvider? profileImage = hasProfilePhoto
        ? (canUseFilePhoto
              ? FileImage(File.fromUri(Uri.parse(profilePhotoUrl)))
              : NetworkImage(profilePhotoUrl))
        : null;
    final showPlaceholder = !hasProfilePhoto || (isFilePhoto && kIsWeb);
    final displayName = user.name.trim().isEmpty ? 'User' : user.name;
    final phone = user.phone;
    final displayPhone = phone != null && phone.trim().isNotEmpty
        ? phone
        : AppLocalizations.of(context)!.noPhoneNumber;

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
                          backgroundImage: profileImage,
                          child: showPlaceholder
                              ? const Icon(Icons.person, size: 50)
                              : null,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      // Name
                      Text(
                        displayName,
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(
                              color: AppColors.textWhite,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 4),
                      // Phone instead of Email
                      Text(
                        displayPhone,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textWhite,
                        ),
                      ),
                      if (user.isVerified)
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
                                AppLocalizations.of(context)!.verified,
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
                  // Personal Information Section
                  _buildSectionHeader(
                    AppLocalizations.of(context)!.personalInformation,
                  ),
                  _buildSettingCard([
                    _buildInfoTile(
                      icon: Icons.person_outline,
                      label: AppLocalizations.of(context)!.name,
                      value: displayName,
                    ),
                    _buildDivider(),
                    _buildInfoTile(
                      icon: Icons.phone_outlined,
                      label: AppLocalizations.of(context)!.phone,
                      value:
                          displayPhone ==
                              AppLocalizations.of(context)!.noPhoneNumber
                          ? AppLocalizations.of(context)!.notProvided
                          : displayPhone,
                    ),
                    _buildDivider(),
                    _buildInfoTile(
                      icon: Icons.calendar_today_outlined,
                      label: AppLocalizations.of(context)!.birthDate,
                      value: user.birthDate != null
                          ? "${user.birthDate!.day}/${user.birthDate!.month}/${user.birthDate!.year}"
                          : AppLocalizations.of(context)!.notProvided,
                    ),
                    if (user.idDocument != null) ...[
                      _buildDivider(),
                      _buildInfoTile(
                        icon: Icons.badge_outlined,
                        label: AppLocalizations.of(context)!.idDocument,
                        value: AppLocalizations.of(context)!.viewDocument,
                        onTap: () {
                          _showIdDocument(context, user.idDocument!);
                        },
                      ),
                    ],
                  ]),
                  const SizedBox(height: AppSpacing.lg),

                  // Account Section
                  _buildSectionHeader(AppLocalizations.of(context)!.account),
                  _buildSettingCard([
                    _buildSettingTile(
                      icon: Icons.favorite_border,
                      title: AppLocalizations.of(context)!.myFavorites,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const FavoritesScreen(),
                          ),
                        );
                      },
                    ),
                    _buildDivider(),
                    _buildSettingTile(
                      icon: Icons.lock_outline,
                      title: AppLocalizations.of(context)!.changePassword,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ChangePasswordScreen(),
                          ),
                        );
                      },
                    ),
                    _buildDivider(),
                    _buildSettingTile(
                      icon: Icons.credit_card_outlined,
                      title: AppLocalizations.of(context)!.paymentMethods,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const PaymentMethodsScreen(),
                          ),
                        );
                      },
                    ),
                  ]),
                  const SizedBox(height: AppSpacing.lg),
                  // Hosting Section
                  _buildSectionHeader(AppLocalizations.of(context)!.hosting),
                  _buildSettingCard([
                    _buildSettingTile(
                      icon: Icons.dashboard_outlined,
                      title: AppLocalizations.of(context)!.bookingRequests,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const OrderRequestsScreen(),
                          ),
                        );
                      },
                    ),
                  ]),
                  const SizedBox(height: AppSpacing.lg),
                  // Preferences Section
                  _buildSectionHeader(
                    AppLocalizations.of(context)!.preferences,
                  ),
                  _buildSettingCard([
                    _buildSettingTile(
                      icon: Icons.notifications_outlined,
                      title: AppLocalizations.of(context)!.notifications,
                      trailing: Switch(
                        value: true,
                        onChanged: (value) {},
                        activeThumbColor: AppColors.primary,
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const NotificationsScreen(),
                          ),
                        );
                      },
                    ),
                    _buildDivider(),
                    _buildSettingTile(
                      icon: Icons.dark_mode_outlined,
                      title: AppLocalizations.of(context)!.darkMode,
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
                    _buildDivider(),
                    _buildSettingTile(
                      icon: Icons.language,
                      title: AppLocalizations.of(context)!.language,
                      trailing: BlocBuilder<LanguageCubit, LanguageState>(
                        builder: (context, state) {
                          return DropdownButton<String>(
                            value: state.locale.languageCode,
                            underline: const SizedBox(),
                            icon: const Icon(Icons.arrow_drop_down),
                            items: [
                              DropdownMenuItem(
                                value: 'en',
                                child: Text(
                                  AppLocalizations.of(context)!.english,
                                ),
                              ),
                              DropdownMenuItem(
                                value: 'ar',
                                child: Text(
                                  AppLocalizations.of(context)!.arabic,
                                ),
                              ),
                            ],
                            onChanged: (String? value) {
                              if (value != null) {
                                context.read<LanguageCubit>().changeLanguage(
                                  Locale(value),
                                );
                              }
                            },
                          );
                        },
                      ),
                    ),
                  ]),
                  const SizedBox(height: AppSpacing.lg),
                  // Support Section
                  _buildSectionHeader(AppLocalizations.of(context)!.support),
                  _buildSettingCard([
                    _buildDivider(),
                    _buildSettingTile(
                      icon: Icons.privacy_tip_outlined,
                      title: AppLocalizations.of(context)!.privacyPolicy,
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              AppLocalizations.of(
                                context,
                              )!.privacyPolicyComingSoon,
                            ),
                          ),
                        );
                      },
                    ),
                    _buildDivider(),
                    _buildSettingTile(
                      icon: Icons.description_outlined,
                      title: AppLocalizations.of(context)!.termsOfService,
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              AppLocalizations.of(
                                context,
                              )!.termsOfServiceComingSoon,
                            ),
                          ),
                        );
                      },
                    ),
                    _buildDivider(),
                    _buildSettingTile(
                      icon: Icons.info_outline,
                      title: AppLocalizations.of(context)!.about,
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
                      onPressed: () => _handleLogout(context),
                      icon: const Icon(Icons.logout),
                      label: Text(AppLocalizations.of(context)!.logout),
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

  Widget _buildInfoTile({
    required IconData icon,
    required String label,
    required String value,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
      title: Text(label, style: Theme.of(context).textTheme.bodySmall),
      subtitle: Text(
        value,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          fontWeight: FontWeight.bold,
          color: onTap != null ? AppColors.primary : null,
        ),
      ),
      trailing: onTap != null ? const Icon(Icons.open_in_new, size: 18) : null,
      onTap: onTap,
    );
  }

  void _showIdDocument(BuildContext context, String idDocument) {
    final url = ApiService.getImageUrl(idDocument);
    if (url == null) return;

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
              title: Text(
                AppLocalizations.of(context)!.idDocument,
                style: const TextStyle(color: Colors.white),
              ),
            ),
            Expanded(
              child: InteractiveViewer(
                child: Image.network(
                  url,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return const Center(child: CircularProgressIndicator());
                  },
                  errorBuilder: (context, error, stackTrace) => const Center(
                    child: Text(
                      'Failed to load document',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
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
          AppLocalizations.of(context)!.appDescription,
          style: AppTypography.bodyMedium.copyWith(color: AppColors.textWhite),
        ),
      ],
    );
  }

  void _handleLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (c) => AlertDialog(
        title: Text(
          AppLocalizations.of(context)!.logout,
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        content: Text(
          AppLocalizations.of(context)!.logoutConfirmation,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(c).pop(),
            child: Text(
              AppLocalizations.of(context)!.cancel,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).textTheme.bodySmall?.color,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(c).pop(); // pop dialog
              context.read<AuthCubit>().logout();
            },
            child: Text(
              AppLocalizations.of(context)!.logout,
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

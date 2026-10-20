import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../auth/application/auth_controller.dart';
import '../../../auth/presentation/screens/account_deletion_screen.dart';
import '../../../auth/presentation/screens/change_password_screen.dart';
import '../../../profile/presentation/screens/business_settings_screen.dart';
import '../../../profile/presentation/screens/my_profile_screen.dart';
import '../../../ratings/presentation/screens/my_rating_screen.dart';
import '../../../staff/presentation/screens/staff_team_settings_screen.dart';
import '../widgets/settings_widgets.dart';
import 'services_settings_screen.dart';
import 'watermark_settings_screen.dart';

/// «اعدادات الحساب» — المالك، 2026-10-06: one hub, in this order — the account's information, the business's
/// settings, the services' settings (delivery pricing and drivers included), the staff, the watermark — and the
/// account's security below them.
class AccountSettingsScreen extends ConsumerWidget {
  const AccountSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final auth = ref.watch(authControllerProvider);
    final user = auth is AuthSignedIn ? auth.user : null;
    final isBusiness = user?.isBusiness ?? false;

    void open(Widget screen) => Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen));

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settingsAccountSection)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SettingsCard(
            children: [
              SettingsNavTile(icon: Icons.person_outline, title: l10n.accountInfoTitle, subtitle: l10n.accountInfoSubtitle, onTap: () => open(const MyProfileScreen())),
              if (isBusiness) ...[
                const Divider(height: 1),
                SettingsNavTile(
                  icon: Icons.tune_outlined,
                  title: l10n.businessSettingsTitle,
                  subtitle: l10n.businessSettingsSubtitle,
                  // The account is not complete until it has said how it delivers (see AuthUser.setupComplete).
                  badge: user!.setupComplete ? null : l10n.setupRequiredBadge,
                  onTap: () => open(const BusinessSettingsScreen()),
                ),
                const Divider(height: 1),
                SettingsNavTile(icon: Icons.storefront_outlined, title: l10n.settingsServicesSection, subtitle: l10n.servicesSettingsSubtitle, onTap: () => open(const ServicesSettingsScreen())),
                const Divider(height: 1),
                SettingsNavTile(icon: Icons.badge_outlined, title: l10n.staffSettingsTitle, onTap: () => open(const StaffTeamSettingsScreen())),
              ],
              const Divider(height: 1),
              SettingsNavTile(icon: Icons.water_drop_outlined, title: l10n.mediaWatermarkTitle, onTap: () => open(const WatermarkSettingsScreen())),
            ],
          ),
          const SizedBox(height: 24),
          SettingsSectionHeader(l10n.accountSecuritySection),
          const SizedBox(height: 8),
          SettingsCard(
            children: [
              SettingsNavTile(icon: Icons.star_outline, title: l10n.myRatingTitle, onTap: () => open(const MyRatingScreen())),
              const Divider(height: 1),
              SettingsNavTile(icon: Icons.lock_outline, title: l10n.authChangePassword, onTap: () => open(const ChangePasswordScreen())),
              const Divider(height: 1),
              ListTile(leading: const Icon(Icons.devices_outlined), title: Text(l10n.authLogoutAll), onTap: () => _logoutAll(context, ref)),
              const Divider(height: 1),
              SettingsNavTile(
                icon: Icons.delete_forever_outlined,
                title: l10n.accountDeletionTitle,
                color: Theme.of(context).colorScheme.error,
                onTap: () => open(const AccountDeletionScreen()),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

Future<void> _logoutAll(BuildContext context, WidgetRef ref) async {
  final l10n = AppLocalizations.of(context)!;
  final messenger = ScaffoldMessenger.of(context);
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(l10n.authLogoutAll),
      content: Text(l10n.authLogoutAllBody),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context, false), child: Text(l10n.commonCancel)),
        TextButton(onPressed: () => Navigator.pop(context, true), child: Text(l10n.authLogout)),
      ],
    ),
  );
  if (confirmed != true) return;
  try {
    await ref.read(authControllerProvider.notifier).logoutAll();
  } catch (e) {
    messenger.showSnackBar(SnackBar(content: Text(e is ApiException ? e.message : l10n.commonSomethingWentWrong)));
  }
}

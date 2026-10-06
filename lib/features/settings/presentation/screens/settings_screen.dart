import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../auth/application/auth_controller.dart';
import '../widgets/settings_widgets.dart';
import 'account_settings_screen.dart';
import 'app_settings_screen.dart';

/// «الإعدادات» — two doors: the ACCOUNT's settings (who it is, what the business is, its services, its staff, its
/// watermark, its security) and the APP's settings (language, theme, how things look, notifications).
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final auth = ref.watch(authControllerProvider);
    final needsSetup = auth is AuthSignedIn && auth.user.isBusiness && !auth.user.setupComplete;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settingsTitle)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SettingsCard(
            children: [
              SettingsNavTile(
                icon: Icons.manage_accounts_outlined,
                title: l10n.settingsAccountSection,
                subtitle: l10n.settingsAccountSubtitle,
                badge: needsSetup ? l10n.setupRequiredBadge : null,
                onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AccountSettingsScreen())),
              ),
              const Divider(height: 1),
              SettingsNavTile(
                icon: Icons.phone_android_outlined,
                title: l10n.settingsAppSettings,
                subtitle: l10n.settingsAppSubtitle,
                onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AppSettingsScreen())),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

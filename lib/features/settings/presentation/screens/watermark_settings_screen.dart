import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../auth/application/auth_controller.dart';
import '../../../media/presentation/widgets/watermark_repeat_selector.dart';
import '../../application/watermark_settings_controller.dart';
import '../widgets/settings_widgets.dart';

/// «اعدادات العلامة المائية» — what is stamped on the photos this account posts (its mobile number, its business
/// name, and how many times), moved here from the old single settings page.
class WatermarkSettingsScreen extends ConsumerWidget {
  const WatermarkSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final authState = ref.watch(authControllerProvider);
    final authUser = authState is AuthSignedIn ? authState.user : null;
    final settings = ref.watch(watermarkSettingsControllerProvider);
    final notifier = ref.read(watermarkSettingsControllerProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.mediaWatermarkTitle)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(l10n.mediaWatermarkSettingsHint, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).hintColor)),
          const SizedBox(height: 8),
          SettingsCard(
            children: [
              CheckboxListTile(
                value: settings.useMobile,
                onChanged: (value) => notifier.setUseMobile(value ?? false),
                controlAffinity: ListTileControlAffinity.leading,
                activeColor: AppColors.accentGold,
                title: Text(l10n.mediaWatermarkUseMobile),
                subtitle: authUser != null ? Text(authUser.phone) : null,
              ),
              const Divider(height: 1),
              CheckboxListTile(
                value: settings.useBusinessName,
                onChanged: (value) => notifier.setUseBusinessName(value ?? false),
                controlAffinity: ListTileControlAffinity.leading,
                activeColor: AppColors.accentGold,
                title: Text(l10n.mediaWatermarkUseBusinessName),
                subtitle: authUser != null ? Text(authUser.name) : null,
              ),
            ],
          ),
          if (settings.isEnabled) ...[
            const SizedBox(height: 12),
            Text(l10n.mediaWatermarkRepeatCount, style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 8),
            WatermarkRepeatSelector(value: settings.repeatCount, onChanged: notifier.setRepeatCount),
          ],
          const SizedBox(height: 24),
          SettingsCard(
            children: [
              ListTile(
                title: Text(l10n.mediaComposerTitle),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push('/media-composer'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

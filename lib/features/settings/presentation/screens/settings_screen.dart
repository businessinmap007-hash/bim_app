import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../auth/application/auth_controller.dart';
import '../../../booking_settings/presentation/screens/booking_settings_screen.dart';
import '../../../media/presentation/widgets/watermark_repeat_selector.dart';
import '../../application/locale_controller.dart';
import '../../application/theme_mode_controller.dart';
import '../../application/watermark_settings_controller.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final locale = ref.watch(localeControllerProvider);
    final themeMode = ref.watch(themeModeControllerProvider);
    final authState = ref.watch(authControllerProvider);
    final isBusiness = authState is AuthSignedIn && authState.user.isBusiness;
    final authUser = authState is AuthSignedIn ? authState.user : null;
    final watermarkSettings = ref.watch(watermarkSettingsControllerProvider);
    final watermarkNotifier = ref.read(watermarkSettingsControllerProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settingsTitle)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _SectionHeader(l10n.settingsLanguage),
          const SizedBox(height: 8),
          _OptionCard(
            children: [
              _OptionRow(
                label: l10n.settingsLanguageArabic,
                selected: locale.languageCode == 'ar',
                onTap: () => ref.read(localeControllerProvider.notifier).setLocale(const Locale('ar')),
              ),
              const Divider(height: 1),
              _OptionRow(
                label: l10n.settingsLanguageEnglish,
                selected: locale.languageCode == 'en',
                onTap: () => ref.read(localeControllerProvider.notifier).setLocale(const Locale('en')),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _SectionHeader(l10n.settingsAppearance),
          const SizedBox(height: 8),
          _OptionCard(
            children: [
              _OptionRow(
                label: l10n.settingsAppearanceLight,
                selected: themeMode == ThemeMode.light,
                onTap: () => ref.read(themeModeControllerProvider.notifier).setThemeMode(ThemeMode.light),
              ),
              const Divider(height: 1),
              _OptionRow(
                label: l10n.settingsAppearanceDark,
                selected: themeMode == ThemeMode.dark,
                onTap: () => ref.read(themeModeControllerProvider.notifier).setThemeMode(ThemeMode.dark),
              ),
              const Divider(height: 1),
              _OptionRow(
                label: l10n.settingsAppearanceSystem,
                selected: themeMode == ThemeMode.system,
                onTap: () => ref.read(themeModeControllerProvider.notifier).setThemeMode(ThemeMode.system),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _SectionHeader(l10n.settingsAccountSection),
          const SizedBox(height: 8),
          _OptionCard(
            children: [
              ListTile(
                leading: const Icon(Icons.person_outline),
                title: Text(l10n.profileTitle),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push('/profile'),
              ),
            ],
          ),
          if (isBusiness) ...[
            const SizedBox(height: 24),
            _SectionHeader(l10n.settingsServicesSection),
            const SizedBox(height: 8),
            _OptionCard(
              children: [
                ListTile(
                  leading: const Icon(Icons.event_available_outlined),
                  title: Text(l10n.bookingSettingsTitle),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const BookingSettingsScreen()),
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 24),
          _SectionHeader(l10n.mediaWatermarkTitle),
          const SizedBox(height: 4),
          Text(
            l10n.mediaWatermarkSettingsHint,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).hintColor),
          ),
          const SizedBox(height: 8),
          _OptionCard(
            children: [
              CheckboxListTile(
                value: watermarkSettings.useMobile,
                onChanged: (value) => watermarkNotifier.setUseMobile(value ?? false),
                controlAffinity: ListTileControlAffinity.leading,
                activeColor: AppColors.accentGold,
                title: Text(l10n.mediaWatermarkUseMobile),
                subtitle: authUser != null ? Text(authUser.phone) : null,
              ),
              const Divider(height: 1),
              CheckboxListTile(
                value: watermarkSettings.useBusinessName,
                onChanged: (value) => watermarkNotifier.setUseBusinessName(value ?? false),
                controlAffinity: ListTileControlAffinity.leading,
                activeColor: AppColors.accentGold,
                title: Text(l10n.mediaWatermarkUseBusinessName),
                subtitle: authUser != null ? Text(authUser.name) : null,
              ),
            ],
          ),
          if (watermarkSettings.isEnabled) ...[
            const SizedBox(height: 12),
            Text(l10n.mediaWatermarkRepeatCount, style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 8),
            WatermarkRepeatSelector(
              value: watermarkSettings.repeatCount,
              onChanged: watermarkNotifier.setRepeatCount,
            ),
          ],
          const SizedBox(height: 24),
          _SectionHeader(l10n.mediaComposerTitle),
          const SizedBox(height: 8),
          _OptionCard(
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

class _SectionHeader extends StatelessWidget {
  final String label;
  const _SectionHeader(this.label);

  @override
  Widget build(BuildContext context) {
    return Text(label, style: Theme.of(context).textTheme.titleSmall);
  }
}

class _OptionCard extends StatelessWidget {
  final List<Widget> children;
  const _OptionCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: Column(children: children),
    );
  }
}

/// A plain tappable row instead of Radio/RadioListTile — verified with
/// debug logging that both the Radio-based approaches actually DID fire
/// correctly; the earlier "the switch does nothing" symptom was stale tap
/// coordinates against a screen whose layout had shifted (the bottom nav
/// shell landed mid-session), not a real widget bug. Kept this version
/// anyway since it's simpler and equally correct.
class _OptionRow extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _OptionRow({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Expanded(child: Text(label, style: Theme.of(context).textTheme.bodyLarge)),
            Icon(
              selected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
              color: selected ? AppColors.primaryNavy : Theme.of(context).dividerColor,
            ),
          ],
        ),
      ),
    );
  }
}

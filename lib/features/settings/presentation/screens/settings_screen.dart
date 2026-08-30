import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../../application/locale_controller.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final locale = ref.watch(localeControllerProvider);

    void select(String code) => ref.read(localeControllerProvider.notifier).setLocale(Locale(code));

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settingsTitle)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(l10n.settingsLanguage, style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 8),
          Card(
            margin: EdgeInsets.zero,
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                _LanguageOption(
                  label: l10n.settingsLanguageArabic,
                  selected: locale.languageCode == 'ar',
                  onTap: () => select('ar'),
                ),
                const Divider(height: 1),
                _LanguageOption(
                  label: l10n.settingsLanguageEnglish,
                  selected: locale.languageCode == 'en',
                  onTap: () => select('en'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// A plain tappable row instead of Radio/RadioListTile — verified with
/// debug logging that both the Radio-based approaches actually DID fire
/// correctly; the earlier "the switch does nothing" symptom was stale tap
/// coordinates against a screen whose layout had shifted (the bottom nav
/// shell landed mid-session), not a real widget bug. Kept this version
/// anyway since it's simpler and equally correct.
class _LanguageOption extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _LanguageOption({required this.label, required this.selected, required this.onTap});

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

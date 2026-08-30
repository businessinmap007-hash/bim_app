import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../l10n/app_localizations.dart';
import '../../application/locale_controller.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final locale = ref.watch(localeControllerProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settingsTitle)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(l10n.settingsLanguage, style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 8),
          Card(
            margin: EdgeInsets.zero,
            child: RadioGroup<String>(
              groupValue: locale.languageCode,
              onChanged: (value) {
                if (value != null) {
                  ref.read(localeControllerProvider.notifier).setLocale(Locale(value));
                }
              },
              child: Column(
                children: [
                  RadioListTile<String>(
                    title: Text(l10n.settingsLanguageArabic),
                    value: 'ar',
                  ),
                  const Divider(height: 1),
                  RadioListTile<String>(
                    title: Text(l10n.settingsLanguageEnglish),
                    value: 'en',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

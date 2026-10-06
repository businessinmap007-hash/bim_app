import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../agenda/application/agenda_providers.dart';
import '../../application/notification_preferences_controller.dart';

/// «اعدادات الاشعارات» — المالك، 2026-10-06: which notifications are SILENT and which are ACTIVE, each by a switch.
/// Active = it reaches you (push + sound); silent = it still lands in the inbox, nothing pops up. A few things are
/// never silenced (money alerts, the platform's own announcements).
class NotificationSettingsScreen extends ConsumerWidget {
  const NotificationSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final async = ref.watch(notificationPreferencesControllerProvider);
    final localReminders = ref.watch(agendaLocalRemindersProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.notificationSettingsTitle)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(l10n.notificationSettingsHint, style: theme.textTheme.bodySmall),
          const SizedBox(height: 12),
          async.when(
            loading: () => const Padding(padding: EdgeInsets.all(24), child: Center(child: CircularProgressIndicator())),
            error: (_, _) => Column(
              children: [
                Text(l10n.commonSomethingWentWrong),
                const SizedBox(height: 8),
                OutlinedButton(onPressed: () => ref.read(notificationPreferencesControllerProvider.notifier).load(), child: Text(l10n.commonRetry)),
              ],
            ),
            data: (categories) => Card(
              margin: EdgeInsets.zero,
              clipBehavior: Clip.antiAlias,
              child: Column(
                children: [
                  for (var i = 0; i < categories.length; i++) ...[
                    if (i > 0) const Divider(height: 1),
                    SwitchListTile(
                      title: Text(categories[i].label),
                      subtitle: Text(categories[i].enabled ? l10n.notificationActive : l10n.notificationSilent),
                      value: categories[i].enabled,
                      onChanged: (on) async {
                        final messenger = ScaffoldMessenger.of(context);
                        final ok = await ref.read(notificationPreferencesControllerProvider.notifier).set(categories[i].key, on);
                        if (!ok) messenger.showSnackBar(SnackBar(content: Text(l10n.commonSomethingWentWrong)));
                      },
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(l10n.notificationLockedNote, style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor)),
          const SizedBox(height: 20),
          Text(l10n.notificationOnThisPhone, style: theme.textTheme.titleSmall),
          const SizedBox(height: 8),
          Card(
            margin: EdgeInsets.zero,
            child: SwitchListTile(
              title: Text(l10n.agendaLocalRemindersTitle),
              subtitle: Text(l10n.agendaLocalRemindersHint),
              value: localReminders,
              onChanged: (on) async {
                await ref.read(agendaLocalRemindersProvider.notifier).set(on);
                await ref.read(agendaRemindersProvider).sync();
              },
            ),
          ),
        ],
      ),
    );
  }
}

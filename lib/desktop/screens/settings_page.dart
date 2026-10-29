import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/inventory/application/inventory_providers.dart';
import '../../features/inventory/data/inventory_models.dart';
import '../../features/inventory/presentation/inventory_labels.dart';
import '../../l10n/app_localizations.dart';
import '../../shared/widgets/async_value_view.dart';
import '../sync/desktop_sync.dart';
import 'common.dart';

/// «الإعدادات والاشتراك» — switching the suite on (the first month from the wallet), the parts of it this business uses
/// (what its category allows), the owner's approval limit for purchase orders, the subscription's state, and the writes
/// the server refused after an offline spell.
class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  final _limit = TextEditingController();
  bool _seeded = false;

  @override
  void dispose() {
    _limit.dispose();
    super.dispose();
  }

  Future<void> _update(Future<InvSettings> Function() call) async {
    await suiteRun(context, call, queueable: false);
    ref.invalidate(invSettingsProvider);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final api = ref.read(inventoryApiProvider);
    final store = ref.watch(suiteStoreProvider);

    return SuitePage(
      title: l10n.suiteNavSettings,
      child: AsyncValueView<InvSettings>(
        value: ref.watch(invSettingsProvider),
        onRetry: () => ref.invalidate(invSettingsProvider),
        builder: (context, s) {
          if (!_seeded) {
            _limit.text = s.poApprovalThreshold == null ? '' : invNum(s.poApprovalThreshold!);
            _seeded = true;
          }
          if (!s.available) return Text(l10n.stkNotAvailable);

          final sub = s.subscription;
          final rejected = store.rejected();

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SuiteSection(
                title: l10n.suiteSubscription,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(sub.price > 0 ? l10n.stkSubscriptionPrice(InvLabels.money(sub.price)) : l10n.stkSubscriptionFree),
                    Text(l10n.suiteSubscriptionStatus(_status(l10n, sub.status))),
                    if (sub.paidUntil != null) Text(l10n.suitePaidUntil(MaterialLocalizations.of(context).formatMediumDate(sub.paidUntil!))),
                    const SizedBox(height: 6),
                    Text(l10n.suiteSubscriptionRules, style: Theme.of(context).textTheme.bodySmall),
                    const SizedBox(height: 10),
                    if (s.isOwner && !s.enabled) FilledButton(onPressed: () => _update(() => api.updateSettings(enabled: true)), child: Text(l10n.stkEnableAction)),
                    if (s.isOwner && s.enabled && sub.status != 'active') FilledButton(onPressed: () => _update(api.renew), child: Text(l10n.suiteRenew)),
                    if (!s.isOwner && !s.enabled) Text(l10n.stkOwnerEnables),
                  ],
                ),
              ),
              if (s.enabled)
                SuiteSection(
                  title: l10n.suiteParts,
                  child: Column(
                    children: [
                      Text(l10n.suitePartsHint, style: Theme.of(context).textTheme.bodySmall),
                      for (final f in s.features)
                        SwitchListTile(
                          title: Text(f.label),
                          subtitle: f.optional ? Text(l10n.suiteOptional) : null,
                          value: f.on,
                          onChanged: !s.isOwner || f.key == 'units'
                              ? null
                              : (v) => _update(() => api.updateSettings(features: [
                                    for (final x in s.features)
                                      if (x.key == f.key ? v : x.on) x.key,
                                  ])),
                        ),
                    ],
                  ),
                ),
              if (s.enabled && s.isOwner)
                SuiteSection(
                  title: l10n.suiteApprovalLimit,
                  child: Row(
                    children: [
                      NumField(controller: _limit, label: l10n.suiteApprovalLimitField, width: 240),
                      const SizedBox(width: 12),
                      FilledButton(
                        onPressed: () {
                          final v = parseNum(_limit.text);
                          _update(() => api.updateSettings(poApprovalThreshold: v, clearThreshold: v == null));
                        },
                        child: Text(l10n.commonSave),
                      ),
                    ],
                  ),
                ),
              if (rejected.isNotEmpty)
                SuiteSection(
                  title: l10n.suiteRejectedTitle,
                  actions: [
                    TextButton(
                      onPressed: () async {
                        await store.clearRejected();
                        setState(() {});
                      },
                      child: Text(l10n.suiteClear),
                    ),
                  ],
                  child: Column(
                    children: [
                      for (final r in rejected)
                        ListTile(dense: true, title: Text('${r['message']}'), subtitle: Text('${r['method']} ${r['path']} · ${r['at']}')),
                    ],
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  String _status(AppLocalizations l10n, String status) => switch (status) {
        'active' => l10n.suiteSubActive,
        'grace' => l10n.suiteSubGrace,
        'read_only' => l10n.suiteSubReadOnly,
        _ => l10n.suiteSubNone,
      };
}

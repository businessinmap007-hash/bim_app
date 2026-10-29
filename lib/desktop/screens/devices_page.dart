import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/inventory/application/inventory_providers.dart';
import '../../features/inventory/data/inventory_models.dart';
import '../../l10n/app_localizations.dart';
import '../../shared/widgets/async_value_view.dart';
import '../desktop_app.dart';
import '../lan/lan_link.dart';
import '../shell/desktop_shell.dart';
import '../sync/desktop_sync.dart';
import 'common.dart';

final _devicesProvider = FutureProvider.autoDispose<List<InvDevice>>((ref) => ref.watch(inventoryApiProvider).devices());

const _roles = ['main', 'manager', 'warehouse', 'purchases', 'cashier'];

String _roleLabel(AppLocalizations l10n, String role) => switch (role) {
      'main' => l10n.suiteRoleMain,
      'manager' => l10n.suiteRoleManager,
      'warehouse' => l10n.suiteRoleWarehouse,
      'purchases' => l10n.suiteRolePurchases,
      _ => l10n.suiteRoleCashier,
    };

/// «الأجهزة» (owner, 2026-10-29): the main computer collects every other computer of the business over the office
/// network — they pair once with a code shown here — and each computer is given a role that decides its screens.
class DevicesPage extends ConsumerStatefulWidget {
  const DevicesPage({super.key});

  @override
  ConsumerState<DevicesPage> createState() => _DevicesPageState();
}

class _DevicesPageState extends ConsumerState<DevicesPage> {
  String? _code;
  Map<String, Map<String, dynamic>>? _found;
  bool _searching = false;

  Future<void> _registerThis({required String role, required bool hub}) async {
    final l10n = AppLocalizations.of(context)!;
    final store = ref.read(suiteStoreProvider);
    final name = TextEditingController(text: _roleLabel(l10n, role));
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.suiteDeviceName),
        content: TextField(controller: name),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(l10n.commonCancel)),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: Text(l10n.commonSave)),
        ],
      ),
    );
    if (ok == true && mounted) {
      await suiteRun(context, () => ref.read(inventoryApiProvider).registerDevice(uuid: store.deviceUuid, name: name.text.trim(), role: role, isHub: hub), queueable: false);
      if (hub) {
        final business = ref.read(suiteBusinessProvider)!;
        await ref.read(suiteSyncProvider.notifier).startHub(businessId: business.id, businessName: business.name);
      }
      ref.invalidate(_devicesProvider);
      ref.invalidate(thisDeviceProvider);
    }
    name.dispose();
  }

  Future<void> _pair(String address) async {
    final l10n = AppLocalizations.of(context)!;
    final code = TextEditingController();
    final name = TextEditingController();
    var role = 'warehouse';
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: Text(l10n.suitePairTitle),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: code, decoration: InputDecoration(labelText: l10n.suitePairCode)),
              TextField(controller: name, decoration: InputDecoration(labelText: l10n.suiteDeviceName)),
              DropdownButtonFormField<String>(
                initialValue: role,
                decoration: InputDecoration(labelText: l10n.suiteRole),
                items: [for (final r in _roles.skip(1)) DropdownMenuItem(value: r, child: Text(_roleLabel(l10n, r)))],
                onChanged: (v) => setState(() => role = v ?? role),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: Text(l10n.commonCancel)),
            FilledButton(onPressed: () => Navigator.pop(ctx, true), child: Text(l10n.suitePair)),
          ],
        ),
      ),
    );
    if (ok == true && mounted) {
      final paired = await ref.read(suiteSyncProvider.notifier).lan.pair(address: address, code: code.text.trim(), name: name.text.trim(), role: role);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(paired ? l10n.suitePaired : l10n.suitePairFailed)));
        setState(() {});
      }
    }
    code.dispose();
    name.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final sync = ref.watch(suiteSyncProvider.notifier);
    final store = ref.watch(suiteStoreProvider);
    final settings = ref.watch(invSettingsProvider).valueOrNull;
    final hub = sync.hub;
    final isOwner = settings?.isOwner ?? false;

    return SuitePage(
      title: l10n.suiteNavDevices,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SuiteSection(
            title: l10n.suiteThisComputer,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SelectableText('ID: ${store.deviceUuid}', style: Theme.of(context).textTheme.bodySmall),
                const SizedBox(height: 8),
                if (hub?.running == true) ...[
                  Text(l10n.suiteIsMain, style: const TextStyle(fontWeight: FontWeight.w800, color: Color(0xFF1F7A44))),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      FilledButton(onPressed: () => setState(() => _code = hub!.newPairingCode()), child: Text(l10n.suiteNewPairingCode)),
                      const SizedBox(width: 12),
                      if (_code != null && hub!.activeCode == _code)
                        Text(_code!, style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w800, letterSpacing: 6)),
                    ],
                  ),
                  Text(l10n.suitePairingHint, style: Theme.of(context).textTheme.bodySmall),
                ] else if (sync.lan.paired) ...[
                  Text(l10n.suitePairedWith(store.meta.get('lan_hub_name') ?? '', sync.lan.hubAddress ?? '')),
                  TextButton(onPressed: () async {
                    await sync.lan.unpair();
                    setState(() {});
                  }, child: Text(l10n.suiteUnpair)),
                ] else ...[
                  if (isOwner)
                    Wrap(spacing: 8, runSpacing: 8, children: [
                      FilledButton(onPressed: () => _registerThis(role: 'main', hub: true), child: Text(l10n.suiteMakeMain)),
                      for (final r in _roles.skip(1)) OutlinedButton(onPressed: () => _registerThis(role: r, hub: false), child: Text(_roleLabel(l10n, r))),
                    ]),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    icon: const Icon(Icons.wifi_find),
                    label: Text(l10n.suiteFindMain),
                    onPressed: _searching
                        ? null
                        : () async {
                            setState(() => _searching = true);
                            final found = await LanClient.discover();
                            if (mounted) {
                              setState(() {
                                _found = found;
                                _searching = false;
                              });
                            }
                          },
                  ),
                  if (_found != null && _found!.isEmpty) Text(l10n.suiteNoMainFound),
                  for (final e in (_found ?? const <String, Map<String, dynamic>>{}).entries)
                    ListTile(
                      title: Text('${e.value['name'] ?? ''}'),
                      subtitle: Text(e.key),
                      trailing: FilledButton(onPressed: () => _pair(e.key), child: Text(l10n.suitePair)),
                    ),
                ],
              ],
            ),
          ),
          if (hub?.running == true)
            SuiteSection(
              title: l10n.suitePairedComputers,
              child: Column(
                children: [
                  for (final p in hub!.peers())
                    ListTile(
                      title: Text(p.name),
                      subtitle: Text('${_roleLabel(l10n, p.role)} · ${p.uuid.substring(0, 8)}'),
                      trailing: Wrap(spacing: 8, children: [
                        if (isOwner)
                          OutlinedButton(
                            onPressed: () async {
                              await suiteRun(context, () => ref.read(inventoryApiProvider).registerDevice(uuid: p.uuid, name: p.name, role: p.role), queueable: false);
                              ref.invalidate(_devicesProvider);
                            },
                            child: Text(l10n.suiteRegister),
                          ),
                        TextButton(onPressed: () async {
                          await hub.forget(p.uuid);
                          setState(() {});
                        }, child: Text(l10n.suiteForget)),
                      ]),
                    ),
                ],
              ),
            ),
          SuiteSection(
            title: l10n.suiteRegisteredDevices,
            child: AsyncValueView<List<InvDevice>>(
              value: ref.watch(_devicesProvider),
              onRetry: () => ref.invalidate(_devicesProvider),
              builder: (context, rows) => Column(
                children: [
                  if (rows.isEmpty) Text(l10n.suiteNoDevices),
                  for (final d in rows)
                    ListTile(
                      leading: Icon(d.isHub ? Icons.dns_outlined : Icons.computer_outlined),
                      title: Text(d.name + (d.uuid == store.deviceUuid ? ' (${l10n.suiteThisComputer})' : '')),
                      subtitle: Text('${_roleLabel(l10n, d.role)}${d.lastSeenAt == null ? '' : ' · ${MaterialLocalizations.of(context).formatShortDate(d.lastSeenAt!)}'}'),
                      trailing: isOwner
                          ? Wrap(spacing: 8, children: [
                              DropdownButton<String>(
                                value: d.role,
                                items: [for (final r in _roles) DropdownMenuItem(value: r, child: Text(_roleLabel(l10n, r)))],
                                onChanged: (v) async {
                                  if (v == null) return;
                                  await suiteRun(context, () => ref.read(inventoryApiProvider).updateDevice(d.id, {'role': v, 'screens': null}), queueable: false);
                                  ref.invalidate(_devicesProvider);
                                  ref.invalidate(thisDeviceProvider);
                                },
                              ),
                              TextButton(
                                onPressed: () async {
                                  await suiteRun(context, () => ref.read(inventoryApiProvider).revokeDevice(d.id), queueable: false);
                                  ref.invalidate(_devicesProvider);
                                },
                                child: Text(l10n.suiteRevoke),
                              ),
                            ])
                          : null,
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

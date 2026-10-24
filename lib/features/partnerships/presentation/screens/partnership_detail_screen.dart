import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../l10n/app_localizations.dart';
import '../../application/partnerships_providers.dart';
import '../../data/models/partnership.dart';
import '../widgets/partnership_widgets.dart';
import 'grant_allocation_screen.dart';

/// One partnership as one of its two parties reads it: who, the state, and every allocation inside it with the room's card. The
/// owner grants and edits; the partner prices what it was given.
class PartnershipDetailScreen extends ConsumerWidget {
  final int partnershipId;

  const PartnershipDetailScreen({super.key, required this.partnershipId});

  Future<void> _run(BuildContext context, WidgetRef ref, Future<void> Function() action) async {
    final l10n = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.of(context);

    try {
      await action();
      ref.invalidate(partnershipDetailProvider(partnershipId));
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(e is ApiException && e.message.isNotEmpty ? e.message : l10n.commonSomethingWentWrong)));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final async = ref.watch(partnershipDetailProvider(partnershipId));
    final api = ref.read(partnershipsApiProvider);

    return Scaffold(
      appBar: AppBar(title: Text(async.valueOrNull?.partnership.other?.name ?? l10n.pshTitle)),
      floatingActionButton: (async.valueOrNull?.partnership.isOwner ?? false) && async.value!.partnership.isActive
          ? FloatingActionButton.extended(
              onPressed: () async {
                final done = await Navigator.of(context).push<bool>(MaterialPageRoute(builder: (_) => GrantAllocationScreen(partnershipId: partnershipId)));
                if (done == true) ref.invalidate(partnershipDetailProvider(partnershipId));
              },
              icon: const Icon(Icons.add),
              label: Text(l10n.pshGrant),
            )
          : null,
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => Center(child: OutlinedButton(onPressed: () => ref.invalidate(partnershipDetailProvider(partnershipId)), child: Text(l10n.commonRetry))),
        data: (detail) {
          final p = detail.partnership;
          final (statusLabel, statusColor) = partnershipStatusLabel(l10n, p.status);

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
            children: [
              Card(
                margin: EdgeInsets.zero,
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        Expanded(child: Text('${partnershipKindLabel(l10n, p.relationshipType)} · ${p.isOwner ? l10n.pshRoleOwner : l10n.pshRolePartner}', style: theme.textTheme.titleSmall)),
                        Text(statusLabel, style: TextStyle(color: statusColor, fontWeight: FontWeight.w800)),
                      ]),
                      if ((p.note ?? '').isNotEmpty) Padding(padding: const EdgeInsets.only(top: 6), child: Text(p.note!, style: theme.textTheme.bodyMedium)),
                      const SizedBox(height: 8),
                      Row(children: [
                        const Icon(Icons.lock_outline, size: 14),
                        const SizedBox(width: 6),
                        Expanded(child: Text(l10n.pshPrivacy, style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor))),
                      ]),
                      const SizedBox(height: 8),
                      Wrap(spacing: 8, children: [
                        if (p.awaitingMyAnswer) ...[
                          FilledButton(onPressed: () => _run(context, ref, () => api.respond(p.id, accept: true)), child: Text(l10n.pshAccept)),
                          OutlinedButton(onPressed: () => _run(context, ref, () => api.respond(p.id, accept: false)), child: Text(l10n.pshDecline)),
                        ],
                        if (p.status == PartnershipStatus.active) OutlinedButton(onPressed: () => _run(context, ref, () => api.change(p.id, 'pause')), child: Text(l10n.pshPause)),
                        if (p.status == PartnershipStatus.paused) OutlinedButton(onPressed: () => _run(context, ref, () => api.change(p.id, 'resume')), child: Text(l10n.pshResume)),
                        if (p.isOpen && !p.awaitingMyAnswer)
                          TextButton(
                            style: TextButton.styleFrom(foregroundColor: AppColors.error),
                            onPressed: () async {
                              final ok = await showDialog<bool>(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                  content: Text(l10n.pshEndConfirm),
                                  actions: [
                                    TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: Text(l10n.commonCancel)),
                                    FilledButton(onPressed: () => Navigator.of(ctx).pop(true), child: Text(l10n.pshEnd)),
                                  ],
                                ),
                              );
                              if (ok == true && context.mounted) await _run(context, ref, () => api.change(p.id, 'end'));
                            },
                            child: Text(l10n.pshEnd),
                          ),
                      ]),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(l10n.pshAllocations, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
              const SizedBox(height: 8),
              if (detail.allocations.isEmpty)
                Padding(padding: const EdgeInsets.symmetric(vertical: 16), child: Text(p.isOwner ? l10n.pshNoAllocationsOwner : l10n.pshNoAllocationsPartner, style: theme.textTheme.bodyMedium)),
              for (final a in detail.allocations)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _AllocationCard(
                    allocation: a,
                    isOwner: p.isOwner,
                    partnershipActive: p.isActive,
                    onEdit: () async {
                      final done = await Navigator.of(context).push<bool>(MaterialPageRoute(builder: (_) => GrantAllocationScreen(partnershipId: p.id, editing: a)));
                      if (done == true) ref.invalidate(partnershipDetailProvider(partnershipId));
                    },
                    onToggle: () => _run(context, ref, () => api.allocationStatus(p.id, a.id, a.isActive ? 'stop' : 'activate')),
                    onPrice: () async {
                      final res = await showDialog<({String type, double value})>(context: context, builder: (_) => _PriceDialog(allocation: a));
                      if (res != null && context.mounted) await _run(context, ref, () => api.price(p.id, a.id, type: res.type, value: res.value));
                    },
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _AllocationCard extends StatelessWidget {
  final Allocation allocation;
  final bool isOwner;
  final bool partnershipActive;
  final VoidCallback onEdit;
  final VoidCallback onToggle;
  final VoidCallback onPrice;

  const _AllocationCard({required this.allocation, required this.isOwner, required this.partnershipActive, required this.onEdit, required this.onToggle, required this.onPrice});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final a = allocation;
    final room = a.room;
    final c = a.currency;

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (room != null) RoomCardView(room: room),
            const SizedBox(height: 8),
            Wrap(spacing: 12, runSpacing: 4, children: [
              Text(l10n.pshAvailableOf(a.quantityAvailable, a.quantityTotal), style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700)),
              Text(l10n.pshContractLine(money(a.contractPrice, c)), style: theme.textTheme.bodyMedium),
              if (!isOwner) Text(l10n.pshSellLine(money(a.finalPrice, c)), style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w800, color: AppColors.success)),
              if (a.minNights != null || a.maxNights != null)
                Text(a.maxNights == null ? l10n.pshNightsFrom(a.minNights ?? 1) : l10n.pshNightsRange(a.minNights ?? 1, a.maxNights!), style: theme.textTheme.bodySmall),
              if (a.releaseDaysBefore > 0) Text(l10n.pshReleaseLine(a.releaseDaysBefore), style: theme.textTheme.bodySmall),
              if (!a.isActive) Text(l10n.pshAllocationStopped, style: theme.textTheme.bodySmall?.copyWith(color: AppColors.error)),
            ]),
            if (a.upcomingBookings > 0) ...[
              const SizedBox(height: 4),
              Text(l10n.pshStanding(a.upcomingBookings, a.pendingBookings), style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w700)),
              if (!a.isActive) Text(l10n.pshStandingHint, style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor)),
            ],
            const SizedBox(height: 6),
            Row(children: [
              if (isOwner) ...[
                TextButton.icon(onPressed: onEdit, icon: const Icon(Icons.edit_outlined, size: 18), label: Text(l10n.pshEdit)),
                if (a.isActive || partnershipActive) TextButton(onPressed: onToggle, child: Text(a.isActive ? l10n.pshStop : l10n.pshActivate)),
              ] else if (a.isActive)
                FilledButton.tonalIcon(onPressed: onPrice, icon: const Icon(Icons.sell_outlined, size: 18), label: Text(l10n.pshPriceIt)),
            ]),
          ],
        ),
      ),
    );
  }
}

/// The partner prices what it was given: none (the contract price), an amount or a percentage on top — never below the contract.
class _PriceDialog extends StatefulWidget {
  final Allocation allocation;

  const _PriceDialog({required this.allocation});

  @override
  State<_PriceDialog> createState() => _PriceDialogState();
}

class _PriceDialogState extends State<_PriceDialog> {
  late String _type = widget.allocation.markupType;
  late final TextEditingController _value = TextEditingController(text: widget.allocation.markupValue == 0 ? '' : widget.allocation.markupValue.toString());

  @override
  void dispose() {
    _value.dispose();
    super.dispose();
  }

  double get _v => double.tryParse(_value.text.replaceAll(',', '.')) ?? 0;

  double get _final {
    final base = widget.allocation.contractPrice;
    switch (_type) {
      case 'fixed':
        return base + _v;
      case 'percent':
        return base + base * _v / 100;
    }
    return base;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final c = widget.allocation.currency;

    return AlertDialog(
      title: Text(l10n.pshPriceTitle),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.pshContractLine(money(widget.allocation.contractPrice, c)), style: theme.textTheme.bodyMedium),
          const SizedBox(height: 8),
          Wrap(spacing: 8, children: [
            ChoiceChip(label: Text(l10n.pshMarkupNone), selected: _type == 'none', onSelected: (_) => setState(() => _type = 'none')),
            ChoiceChip(label: Text(l10n.pshMarkupFixed), selected: _type == 'fixed', onSelected: (_) => setState(() => _type = 'fixed')),
            ChoiceChip(label: Text(l10n.pshMarkupPercent), selected: _type == 'percent', onSelected: (_) => setState(() => _type = 'percent')),
          ]),
          if (_type != 'none')
            TextField(
              controller: _value,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(labelText: l10n.pshMarkupValue, suffixText: _type == 'percent' ? '%' : c),
              onChanged: (_) => setState(() {}),
            ),
          const SizedBox(height: 12),
          Text(l10n.pshFinalPrice(money(_final, c)), style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
          Text(l10n.pshFloorHint, style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor)),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: Text(l10n.commonCancel)),
        FilledButton(onPressed: () => Navigator.of(context).pop((type: _type, value: _type == 'none' ? 0.0 : _v)), child: Text(l10n.commonSave)),
      ],
    );
  }
}

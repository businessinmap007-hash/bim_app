import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../l10n/app_localizations.dart';
import '../../application/partnerships_providers.dart';
import '../../data/models/partnership.dart';
import '../widgets/partnership_widgets.dart';
import 'partnership_detail_screen.dart';

/// «الشراكات والحصص»: the contracts this business is a party to. A contract between two businesses of any trade (a hotel and a
/// tour company, a factory and a trader) — and only the two can read it.
class PartnershipsScreen extends ConsumerWidget {
  const PartnershipsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final async = ref.watch(myPartnershipsProvider);
    final asked = ref.watch(releaseRequestsProvider).valueOrNull ?? const <ReleaseRequest>[];

    return Scaffold(
      appBar: AppBar(title: Text(l10n.pshTitle)),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final sent = await showModalBottomSheet<bool>(context: context, isScrollControlled: true, builder: (_) => const _InviteSheet());
          if (sent == true) ref.invalidate(myPartnershipsProvider);
        },
        icon: const Icon(Icons.person_add_alt_1_outlined),
        label: Text(l10n.pshInvite),
      ),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => Center(child: OutlinedButton(onPressed: () => ref.invalidate(myPartnershipsProvider), child: Text(l10n.commonRetry))),
        data: (list) => ListView.separated(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
          itemCount: list.length + 1 + (asked.isEmpty ? 0 : 1),
          separatorBuilder: (_, _) => const SizedBox(height: 10),
          itemBuilder: (context, i) {
            if (i == 0) {
              return Row(children: [
                const Icon(Icons.lock_outline, size: 16),
                const SizedBox(width: 6),
                Expanded(child: Text(list.isEmpty ? l10n.pshEmpty : l10n.pshPrivacy, style: theme.textTheme.bodySmall)),
              ]);
            }

            // a guest of the hotel asks for a room held for this partner: the room and the dates, and two buttons
            if (asked.isNotEmpty && i == 1) return _ReleaseRequests(requests: asked);

            final p = list[i - 1 - (asked.isEmpty ? 0 : 1)];
            final (label, color) = partnershipStatusLabel(l10n, p.status);

            return Card(
              margin: EdgeInsets.zero,
              child: ListTile(
                leading: const CircleAvatar(child: Icon(Icons.handshake_outlined)),
                title: Text(p.other?.name ?? '', style: const TextStyle(fontWeight: FontWeight.w700)),
                subtitle: Text('${partnershipKindLabel(l10n, p.relationshipType)} · ${p.isOwner ? l10n.pshRoleOwner : l10n.pshRolePartner}'),
                trailing: p.awaitingMyAnswer
                    ? Chip(label: Text(l10n.pshAwaitingYou), backgroundColor: color.withValues(alpha: 0.15), visualDensity: VisualDensity.compact)
                    : Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 12)),
                onTap: () async {
                  await Navigator.of(context).push(MaterialPageRoute(builder: (_) => PartnershipDetailScreen(partnershipId: p.id)));
                  ref.invalidate(myPartnershipsProvider);
                },
              ),
            );
          },
        ),
      ),
    );
  }
}

/// Find a business by name, say what kind of partner it is, invite it.
class _InviteSheet extends ConsumerStatefulWidget {
  const _InviteSheet();

  @override
  ConsumerState<_InviteSheet> createState() => _InviteSheetState();
}

class _InviteSheetState extends ConsumerState<_InviteSheet> {
  final _search = TextEditingController();
  final _note = TextEditingController();
  Timer? _debounce;
  List<BusinessHit> _hits = const [];
  BusinessHit? _picked;
  String _type = PartnershipKind.agency;
  bool _sending = false;

  @override
  void dispose() {
    _debounce?.cancel();
    _search.dispose();
    _note.dispose();
    super.dispose();
  }

  void _onChanged(String q) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () async {
      try {
        final hits = await ref.read(partnershipsApiProvider).lookup(q.trim());
        if (mounted) setState(() => _hits = hits);
      } catch (_) {
        if (mounted) setState(() => _hits = const []);
      }
    });
  }

  Future<void> _send() async {
    final l10n = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    final picked = _picked;
    if (picked == null) return;

    setState(() => _sending = true);
    try {
      await ref.read(partnershipsApiProvider).invite(partnerId: picked.id, type: _type, note: _note.text.trim());
      messenger.showSnackBar(SnackBar(content: Text(l10n.pshInviteSent)));
      navigator.pop(true);
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(e is ApiException && e.message.isNotEmpty ? e.message : l10n.commonSomethingWentWrong)));
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.fromLTRB(16, 16, 16, 16 + MediaQuery.of(context).viewInsets.bottom),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.pshInvite, style: theme.textTheme.titleLarge),
            const SizedBox(height: 12),
            if (_picked == null) ...[
              TextField(controller: _search, decoration: InputDecoration(prefixIcon: const Icon(Icons.search), hintText: l10n.pshSearchHint), onChanged: _onChanged),
              for (final h in _hits)
                ListTile(
                  dense: true,
                  leading: const Icon(Icons.storefront_outlined),
                  title: Text(h.name),
                  onTap: () => setState(() => _picked = h),
                ),
            ] else ...[
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.storefront_outlined),
                title: Text(_picked!.name, style: const TextStyle(fontWeight: FontWeight.w700)),
                trailing: IconButton(icon: const Icon(Icons.close), onPressed: () => setState(() => _picked = null)),
              ),
              Wrap(
                spacing: 8,
                children: [
                  for (final k in PartnershipKind.all) ChoiceChip(label: Text(partnershipKindLabel(l10n, k)), selected: _type == k, onSelected: (_) => setState(() => _type = k)),
                ],
              ),
              const SizedBox(height: 12),
              TextField(controller: _note, maxLines: 2, decoration: InputDecoration(hintText: l10n.pshNoteHint)),
              const SizedBox(height: 4),
              Text(l10n.pshPrivacy, style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor)),
              const SizedBox(height: 12),
              SizedBox(width: double.infinity, child: FilledButton(onPressed: _sending ? null : _send, child: Text(l10n.pshSend))),
            ],
          ],
        ),
      ),
    );
  }
}

/// «طلبات تحرير غرف»: what the hotel's guests ask this partner to give back — agree and the room goes back to the hotel.
class _ReleaseRequests extends ConsumerWidget {
  final List<ReleaseRequest> requests;

  const _ReleaseRequests({required this.requests});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final fmt = MaterialLocalizations.of(context);

    Future<void> answer(ReleaseRequest r, bool approve) async {
      final messenger = ScaffoldMessenger.of(context);
      try {
        await ref.read(partnershipsApiProvider).answerRelease(r.id, approve: approve);
      } catch (e) {
        messenger.showSnackBar(SnackBar(content: Text(e is ApiException && e.message.isNotEmpty ? e.message : l10n.commonSomethingWentWrong)));
      }
      ref.invalidate(releaseRequestsProvider);
    }

    return Card(
      margin: EdgeInsets.zero,
      color: theme.colorScheme.primaryContainer.withValues(alpha: 0.5),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.pshReleaseTitle, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800)),
            Text(l10n.pshReleaseHint, style: theme.textTheme.bodySmall),
            for (final r in requests) ...[
              const Divider(height: 16),
              Text(l10n.pshReleaseRoom(r.room, fmt.formatShortDate(r.startsAt), fmt.formatShortDate(r.endsAt)), style: theme.textTheme.bodyMedium),
              const SizedBox(height: 6),
              Row(children: [
                FilledButton(onPressed: () => answer(r, true), child: Text(l10n.pshReleaseApprove)),
                const SizedBox(width: 8),
                OutlinedButton(onPressed: () => answer(r, false), child: Text(l10n.pshReleaseDecline)),
              ]),
            ],
          ],
        ),
      ),
    );
  }
}

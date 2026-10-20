import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../core/time/local_format.dart';
import '../../../../l10n/app_localizations.dart';
import '../../application/moderation_providers.dart';
import '../../data/moderation_api.dart';

/// «قرارات الحذف» — the moderators' panel. An account's fifth recent freeze does not delete it by one moderator's hand: it
/// lands here, and a few moderators have to agree. Nobody sees who voted how.
class DeletionProposalsScreen extends ConsumerStatefulWidget {
  const DeletionProposalsScreen({super.key});

  @override
  ConsumerState<DeletionProposalsScreen> createState() =>
      _DeletionProposalsScreenState();
}

class _DeletionProposalsScreenState
    extends ConsumerState<DeletionProposalsScreen> {
  List<DeletionProposal>? _items;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final items = await ref.read(moderationApiProvider).deletionProposals();
      if (mounted) {
        setState(() {
          _items = items;
          _error = null;
        });
      }
    } on ApiException catch (e) {
      if (mounted) setState(() => _error = e.message);
    }
  }

  Future<void> _vote(DeletionProposal p, bool approve) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      await ref.read(moderationApiProvider).voteOnDeletion(p.id, approve);
      await _load();
    } on ApiException catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(e.message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final date = LocalFormat.date(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.panelTitle)),
      body: _error != null
          ? Center(child: Text(_error!))
          : _items == null
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _load,
              child: _items!.isEmpty
                  ? ListView(
                      children: [
                        const SizedBox(height: 120),
                        Center(child: Text(l10n.panelEmpty)),
                      ],
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: _items!.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 12),
                      itemBuilder: (_, i) {
                        final p = _items![i];

                        return Card(
                          margin: EdgeInsets.zero,
                          child: Padding(
                            padding: const EdgeInsets.all(14),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  p.accountName,
                                  style: theme.textTheme.titleMedium,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  p.round > 1
                                      ? l10n.panelSecondRound
                                      : l10n.panelFifthFreeze,
                                  style: theme.textTheme.bodySmall,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  l10n.panelFreezes,
                                  style: theme.textTheme.labelLarge,
                                ),
                                for (final f in p.freezes)
                                  Text(
                                    '${f.at == null ? '' : '${date.format(f.at!)} · '}${f.reason ?? ''}',
                                    style: theme.textTheme.bodySmall,
                                  ),
                                if (p.objection != null) ...[
                                  const SizedBox(height: 8),
                                  Text(
                                    l10n.panelObjection,
                                    style: theme.textTheme.labelLarge,
                                  ),
                                  Text(p.objection!),
                                ],
                                const SizedBox(height: 8),
                                Text(
                                  l10n.panelTally(
                                    p.approvals,
                                    p.approvalsNeeded,
                                    p.rejections,
                                    p.rejectionsNeeded,
                                  ),
                                  style: theme.textTheme.bodyMedium,
                                ),
                                const SizedBox(height: 8),
                                if (p.canVote)
                                  Wrap(
                                    spacing: 8,
                                    children: [
                                      FilledButton(
                                        onPressed: () => _vote(p, true),
                                        child: Text(l10n.panelApprove),
                                      ),
                                      OutlinedButton(
                                        onPressed: () => _vote(p, false),
                                        child: Text(l10n.panelReject),
                                      ),
                                    ],
                                  )
                                else
                                  Text(
                                    l10n.panelVoted,
                                    style: theme.textTheme.bodySmall,
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
    );
  }
}

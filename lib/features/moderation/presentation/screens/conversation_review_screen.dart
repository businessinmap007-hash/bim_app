import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../core/time/local_format.dart';
import '../../../../l10n/app_localizations.dart';
import '../../application/moderation_providers.dart';
import '../../data/moderation_api.dart';

/// The whole reported conversation, read-only. It opens only by the consent of both parties or by the quorum of moderators;
/// until then the server answers with where each way stands, and this screen says so.
class ConversationReviewScreen extends ConsumerStatefulWidget {
  final ReportedItem item;
  const ConversationReviewScreen({super.key, required this.item});

  @override
  ConsumerState<ConversationReviewScreen> createState() =>
      _ConversationReviewScreenState();
}

class _ConversationReviewScreenState
    extends ConsumerState<ConversationReviewScreen> {
  List<ConvMessage>? _messages;
  String? _locked;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);

    try {
      final messages = await ref
          .read(moderationApiProvider)
          .conversationMessages(widget.item);
      if (mounted) setState(() => _messages = messages);
    } on ApiException catch (e) {
      if (mounted) setState(() => _locked = e.message);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final date = LocalFormat.date(context).addClock();

    return Scaffold(
      appBar: AppBar(title: Text(l10n.modConversationTitle)),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _messages == null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.lock_outline, size: 48),
                    const SizedBox(height: 12),
                    Text(
                      _locked ?? l10n.commonSomethingWentWrong,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton(onPressed: _load, child: Text(l10n.commonRetry)),
                  ],
                ),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: _messages!.length,
              separatorBuilder: (_, _) => const SizedBox(height: 8),
              itemBuilder: (_, i) {
                final m = _messages![i];

                return Card(
                  margin: EdgeInsets.zero,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${m.senderName ?? ''}${m.createdAt == null ? '' : ' · ${date.format(m.createdAt!)}'}',
                          style: theme.textTheme.labelSmall,
                        ),
                        const SizedBox(height: 4),
                        Text(m.body),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}

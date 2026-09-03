import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../l10n/app_localizations.dart';
import '../../application/general_chat_providers.dart';
import '../../data/models/chat_thread_summary.dart';
import 'chat_thread_screen.dart';

/// Api\V2\ChatController::index — my general conversations (DMs and any
/// groups I'm in), most-recently-active first. Starting a NEW conversation
/// happens from wherever the other person already is reachable (a business
/// page's "Message" button, a followed account) rather than from a person
/// search here — the app has no such picker yet.
class ChatsListScreen extends ConsumerWidget {
  const ChatsListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final state = ref.watch(chatsListControllerProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.chatsListTitle)),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : state.error != null
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(l10n.commonSomethingWentWrong),
                  const SizedBox(height: 8),
                  OutlinedButton(
                    onPressed: () => ref.read(chatsListControllerProvider.notifier).load(),
                    child: Text(l10n.commonRetry),
                  ),
                ],
              ),
            )
          : state.items.isEmpty
          ? Center(child: Text(l10n.chatsListEmpty))
          : RefreshIndicator(
              onRefresh: () => ref.read(chatsListControllerProvider.notifier).load(),
              child: ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: state.items.length,
                separatorBuilder: (context, index) => const SizedBox(height: 4),
                itemBuilder: (context, index) => _ChatTile(summary: state.items[index]),
              ),
            ),
    );
  }
}

class _ChatTile extends StatelessWidget {
  final ChatThreadSummary summary;
  const _ChatTile({required this.summary});

  @override
  Widget build(BuildContext context) {
    final last = summary.lastMessage;
    return Card(
      margin: EdgeInsets.zero,
      child: ListTile(
        leading: CircleAvatar(child: Icon(summary.isGroup ? Icons.group_outlined : Icons.person_outline)),
        title: Text(summary.displayTitle(), maxLines: 1, overflow: TextOverflow.ellipsis),
        subtitle: last != null
            ? Text(last.body ?? '', maxLines: 1, overflow: TextOverflow.ellipsis)
            : null,
        trailing: summary.unreadCount > 0
            ? CircleAvatar(radius: 11, child: Text('${summary.unreadCount}', style: const TextStyle(fontSize: 11)))
            : null,
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => ChatThreadScreen(threadId: summary.id, title: summary.displayTitle())),
        ),
      ),
    );
  }
}

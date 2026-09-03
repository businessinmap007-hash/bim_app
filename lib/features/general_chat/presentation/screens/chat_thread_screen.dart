import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../chat/data/models/thread_message.dart';
import '../../application/general_chat_providers.dart';

/// One conversation — Api\V2\ChatController::show/postMessage. Group-only
/// actions (rename/leave/delete) sit behind an overflow menu, gated by
/// `thread.isOwner`/`isGroup` the same way the backend gates them.
class ChatThreadScreen extends ConsumerStatefulWidget {
  final int threadId;
  final String title;

  const ChatThreadScreen({super.key, required this.threadId, required this.title});

  @override
  ConsumerState<ChatThreadScreen> createState() => _ChatThreadScreenState();
}

class _ChatThreadScreenState extends ConsumerState<ChatThreadScreen> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final text = _messageController.text;
    if (text.trim().isEmpty) return;
    _messageController.clear();
    await ref.read(chatThreadControllerProvider(widget.threadId).notifier).send(text);
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    }
  }

  Future<void> _rename() async {
    final l10n = AppLocalizations.of(context)!;
    final controller = TextEditingController(text: widget.title);
    final title = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.chatRenameGroup),
        content: TextField(controller: controller, autofocus: true),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.commonCancel)),
          TextButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: Text(l10n.commonSave),
          ),
        ],
      ),
    );
    if (title == null || title.isEmpty || !mounted) return;
    try {
      await ref.read(chatThreadControllerProvider(widget.threadId).notifier).rename(title);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e is ApiException ? e.message : l10n.commonSomethingWentWrong)));
      }
    }
  }

  Future<void> _leaveOrDelete(bool isOwner) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        content: Text(isOwner ? l10n.chatDeleteGroupConfirm : l10n.chatLeaveGroupConfirm),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text(l10n.commonCancel)),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(isOwner ? l10n.commonDelete : l10n.chatLeaveAction),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    try {
      final api = ref.read(generalChatApiProvider);
      if (isOwner) {
        await api.delete(widget.threadId);
      } else {
        await api.leave(widget.threadId);
      }
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e is ApiException ? e.message : l10n.commonSomethingWentWrong)));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final state = ref.watch(chatThreadControllerProvider(widget.threadId));
    final thread = state.thread;
    final isGroup = thread?.isGroup ?? false;
    final isOwner = thread?.isOwner ?? false;

    return Scaffold(
      appBar: AppBar(
        title: Text(thread?.displayTitle().isNotEmpty == true ? thread!.displayTitle() : widget.title),
        actions: [
          if (isGroup)
            PopupMenuButton<String>(
              onSelected: (choice) {
                if (choice == 'rename') _rename();
                if (choice == 'leave') _leaveOrDelete(isOwner);
              },
              itemBuilder: (context) => [
                if (isOwner) PopupMenuItem(value: 'rename', child: Text(l10n.chatRenameGroup)),
                PopupMenuItem(
                  value: 'leave',
                  child: Text(isOwner ? l10n.commonDelete : l10n.chatLeaveAction),
                ),
              ],
            ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: state.isLoading
                ? const Center(child: CircularProgressIndicator())
                : state.error != null
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(l10n.commonSomethingWentWrong),
                        const SizedBox(height: 8),
                        OutlinedButton(
                          onPressed: () => ref.read(chatThreadControllerProvider(widget.threadId).notifier).load(),
                          child: Text(l10n.commonRetry),
                        ),
                      ],
                    ),
                  )
                : state.messages.isEmpty
                ? Center(child: Text(l10n.chatEmpty))
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(12),
                    itemCount: state.messages.length,
                    itemBuilder: (context, index) => _MessageBubble(message: state.messages[index]),
                  ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      decoration: InputDecoration(hintText: l10n.chatMessageHint),
                      minLines: 1,
                      maxLines: 4,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _send(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    onPressed: state.isSending ? null : _send,
                    icon: const Icon(Icons.send_rounded),
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

class _MessageBubble extends StatelessWidget {
  final ThreadMessage message;
  const _MessageBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    if (message.isSystem) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Center(
          child: Text(
            message.body ?? '',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).hintColor),
          ),
        ),
      );
    }

    final isMine = message.isMine;
    final bubbleColor = isMine ? AppColors.accentGold : Theme.of(context).colorScheme.surfaceContainerHighest;
    final textColor = isMine ? AppColors.primaryNavy : Theme.of(context).colorScheme.onSurface;

    return Align(
      alignment: isMine ? AlignmentDirectional.centerEnd : AlignmentDirectional.centerStart,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        decoration: BoxDecoration(color: bubbleColor, borderRadius: BorderRadius.circular(14)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!isMine && message.senderName != null)
              Text(
                message.senderName!,
                style: TextStyle(color: textColor.withValues(alpha: 0.7), fontSize: 11, fontWeight: FontWeight.w600),
              ),
            Text(message.body ?? '', style: TextStyle(color: textColor)),
          ],
        ),
      ),
    );
  }
}

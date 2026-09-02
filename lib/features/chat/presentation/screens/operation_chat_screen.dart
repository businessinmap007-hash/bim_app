import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../../application/chat_providers.dart';
import '../../data/models/thread_message.dart';

/// The customer↔business chat on one order or booking. [operationType] is
/// 'order' | 'booking'.
class OperationChatScreen extends ConsumerStatefulWidget {
  final String operationType;
  final int operationId;
  final String title;

  const OperationChatScreen({
    super.key,
    required this.operationType,
    required this.operationId,
    required this.title,
  });

  @override
  ConsumerState<OperationChatScreen> createState() => _OperationChatScreenState();
}

class _OperationChatScreenState extends ConsumerState<OperationChatScreen> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();

  OperationChatKey get _key => OperationChatKey(widget.operationType, widget.operationId);

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
    await ref.read(operationChatControllerProvider(_key).notifier).send(text);
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final state = ref.watch(operationChatControllerProvider(_key));
    final locked = state.thread?.locked ?? false;

    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
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
                          onPressed: () =>
                              ref.read(operationChatControllerProvider(_key).notifier).load(),
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
          if (locked)
            Padding(
              padding: const EdgeInsets.all(12),
              child: Text(
                l10n.chatLocked,
                style: TextStyle(color: Theme.of(context).hintColor),
                textAlign: TextAlign.center,
              ),
            )
          else
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
        decoration: BoxDecoration(
          color: bubbleColor,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!isMine && message.senderName != null)
              Text(
                message.senderName!,
                style: TextStyle(
                  color: textColor.withValues(alpha: 0.7),
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            Text(message.body ?? '', style: TextStyle(color: textColor)),
          ],
        ),
      ),
    );
  }
}

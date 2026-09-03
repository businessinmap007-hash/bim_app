import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../media/application/media_picker_service.dart';
import '../../../media/data/picked_media.dart';
import '../../../media/presentation/widgets/picked_media_tile.dart';
import '../../../../shared/widgets/thread_access_banner.dart';
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
  final _pickerService = MediaPickerService();
  final List<PickedMedia> _pending = [];
  bool _sending = false;

  OperationChatKey get _key => OperationChatKey(widget.operationType, widget.operationId);

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _pickFromCamera() async {
    final media = await _pickerService.pickFromCamera();
    if (media != null) setState(() => _pending.add(media));
  }

  Future<void> _pickFromGallery() async {
    final media = await _pickerService.pickFromGallery();
    if (media.isNotEmpty) setState(() => _pending.addAll(media));
  }

  void _removePending(int index) => setState(() => _pending.removeAt(index));

  Future<void> _send() async {
    final l10n = AppLocalizations.of(context)!;
    final text = _messageController.text;
    if (text.trim().isEmpty && _pending.isEmpty) return;

    setState(() => _sending = true);
    try {
      final attachments = <Uint8List>[];
      for (final item in _pending) {
        attachments.add(item.processedBytes ?? await item.file.readAsBytes());
      }
      await ref.read(operationChatControllerProvider(_key).notifier).send(text, attachments: attachments);
      _messageController.clear();
      if (mounted) setState(() => _pending.clear());
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e is ApiException ? e.message : l10n.commonSomethingWentWrong)));
      }
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  Future<void> _deleteChat() async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        content: Text(l10n.chatDeleteConfirm),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text(l10n.commonCancel)),
          TextButton(onPressed: () => Navigator.pop(context, true), child: Text(l10n.commonDelete)),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    try {
      await ref.read(operationChatControllerProvider(_key).notifier).deleteChat();
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
    final state = ref.watch(operationChatControllerProvider(_key));
    final locked = state.thread?.locked ?? false;
    final expired = state.thread?.expired ?? false;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          if (expired)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              tooltip: l10n.commonDelete,
              onPressed: _deleteChat,
            ),
        ],
      ),
      body: Column(
        children: [
          if (state.thread != null) ThreadAccessBanner(threadId: state.thread!.id),
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_pending.isNotEmpty)
                      SizedBox(
                        height: 72,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: _pending.length,
                          separatorBuilder: (context, index) => const SizedBox(width: 8),
                          itemBuilder: (context, index) => SizedBox(
                            width: 72,
                            child: PickedMediaTile(
                              media: _pending[index],
                              onRemove: () => _removePending(index),
                            ),
                          ),
                        ),
                      ),
                    if (_pending.isNotEmpty) const SizedBox(height: 8),
                    Row(
                      children: [
                        PopupMenuButton<String>(
                          icon: const Icon(Icons.attach_file),
                          onSelected: (choice) {
                            if (choice == 'camera') _pickFromCamera();
                            if (choice == 'gallery') _pickFromGallery();
                          },
                          itemBuilder: (context) => [
                            PopupMenuItem(value: 'camera', child: Text(l10n.mediaAddFromCamera)),
                            PopupMenuItem(value: 'gallery', child: Text(l10n.mediaAddFromGallery)),
                          ],
                        ),
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
                          onPressed: _sending ? null : _send,
                          icon: _sending
                              ? const SizedBox(
                                  height: 18,
                                  width: 18,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Icon(Icons.send_rounded),
                        ),
                      ],
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

class _MessageBubble extends ConsumerWidget {
  final ThreadMessage message;
  const _MessageBubble({required this.message});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
            for (final attachment in message.attachments)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: _AttachmentView(attachment: attachment, textColor: textColor),
              ),
            if (message.body != null && message.body!.isNotEmpty)
              Padding(
                padding: EdgeInsets.only(top: message.attachments.isNotEmpty ? 6 : 0),
                child: Text(message.body!, style: TextStyle(color: textColor)),
              ),
          ],
        ),
      ),
    );
  }
}

class _AttachmentView extends ConsumerWidget {
  final ThreadAttachment attachment;
  final Color textColor;
  const _AttachmentView({required this.attachment, required this.textColor});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!attachment.isImage) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.insert_drive_file_outlined, size: 18, color: textColor),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              attachment.name ?? '',
              style: TextStyle(color: textColor, decoration: TextDecoration.underline),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      );
    }

    return FutureBuilder<Uint8List>(
      future: ref.read(operationChatApiProvider).fetchAttachmentBytes(attachment.url),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const SizedBox(
            height: 120,
            width: 160,
            child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
          );
        }
        if (!snapshot.hasData || snapshot.hasError) {
          return const SizedBox(height: 120, width: 160, child: Icon(Icons.broken_image_outlined));
        }
        return ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: GestureDetector(
            onTap: () => showDialog(
              context: context,
              builder: (context) => Dialog(
                insetPadding: const EdgeInsets.all(12),
                backgroundColor: Colors.black,
                child: SizedBox.expand(
                  child: InteractiveViewer(
                    child: Image.memory(snapshot.data!, fit: BoxFit.contain),
                  ),
                ),
              ),
            ),
            child: Image.memory(snapshot.data!, height: 160, width: 200, fit: BoxFit.cover),
          ),
        );
      },
    );
  }
}

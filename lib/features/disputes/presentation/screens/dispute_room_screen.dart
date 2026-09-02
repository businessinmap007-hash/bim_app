import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../chat/data/models/thread_message.dart';
import '../../application/disputes_providers.dart';

/// The dispute's arbitration room: text + optional image evidence, gated by
/// an explicit conduct-charter agreement (see ThreadService::conductCharter —
/// accepting is consenting to be ruled against, and fined, for HOW you
/// behave here, separately from who's right about the operation).
class DisputeRoomScreen extends ConsumerStatefulWidget {
  final int disputeId;
  const DisputeRoomScreen({super.key, required this.disputeId});

  @override
  ConsumerState<DisputeRoomScreen> createState() => _DisputeRoomScreenState();
}

class _DisputeRoomScreenState extends ConsumerState<DisputeRoomScreen> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  String? _pendingImagePath;

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (sheetContext) {
        final l10n = AppLocalizations.of(context)!;
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt_outlined),
                title: Text(l10n.profilePhotoCamera),
                onTap: () => Navigator.of(sheetContext).pop(ImageSource.camera),
              ),
              ListTile(
                leading: const Icon(Icons.photo_library_outlined),
                title: Text(l10n.profilePhotoGallery),
                onTap: () => Navigator.of(sheetContext).pop(ImageSource.gallery),
              ),
            ],
          ),
        );
      },
    );
    if (source == null) return;
    final picked = await ImagePicker().pickImage(source: source, imageQuality: 85);
    if (picked != null && mounted) setState(() => _pendingImagePath = picked.path);
  }

  Future<void> _send() async {
    final l10n = AppLocalizations.of(context)!;
    final text = _messageController.text;
    final image = _pendingImagePath;
    if (text.trim().isEmpty && image == null) return;
    _messageController.clear();
    setState(() => _pendingImagePath = null);
    try {
      await ref
          .read(disputeRoomControllerProvider(widget.disputeId).notifier)
          .send(text, imagePath: image);
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.commonSomethingWentWrong)));
      }
    }
  }

  Future<void> _acceptConduct() async {
    final l10n = AppLocalizations.of(context)!;
    try {
      await ref.read(disputeRoomControllerProvider(widget.disputeId).notifier).acceptConduct();
    } catch (e) {
      if (mounted) {
        final message = e is ApiException ? e.message : l10n.commonSomethingWentWrong;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final state = ref.watch(disputeRoomControllerProvider(widget.disputeId));

    return Scaffold(
      appBar: AppBar(title: Text(l10n.disputeRoomTitle)),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : state.purged
          ? Center(child: Text(l10n.disputeRoomPurgedNotice))
          : !state.conductAccepted
          ? _ConductGate(disputeId: widget.disputeId, onAccept: _acceptConduct)
          : Column(
              children: [
                Expanded(
                  child: state.messages.isEmpty
                      ? Center(child: Text(l10n.chatEmpty))
                      : ListView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.all(12),
                          itemCount: state.messages.length,
                          itemBuilder: (context, index) => _MessageBubble(message: state.messages[index]),
                        ),
                ),
                if (state.locked)
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Text(
                      l10n.disputeRoomLocked,
                      style: TextStyle(color: Theme.of(context).hintColor),
                      textAlign: TextAlign.center,
                    ),
                  )
                else
                  SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Column(
                        children: [
                          if (_pendingImagePath != null)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Align(
                                alignment: AlignmentDirectional.centerStart,
                                child: Chip(
                                  avatar: const Icon(Icons.image_outlined, size: 18),
                                  label: const Text('1'),
                                  onDeleted: () => setState(() => _pendingImagePath = null),
                                ),
                              ),
                            ),
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.attach_file),
                                onPressed: _pickImage,
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
                                onPressed: state.isSending ? null : _send,
                                icon: const Icon(Icons.send_rounded),
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

class _ConductGate extends ConsumerWidget {
  final int disputeId;
  final VoidCallback onAccept;
  const _ConductGate({required this.disputeId, required this.onAccept});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final async = ref.watch(disputeConductProvider(disputeId));

    return async.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, _) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(l10n.commonSomethingWentWrong),
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: () => ref.invalidate(disputeConductProvider(disputeId)),
              child: Text(l10n.commonRetry),
            ),
          ],
        ),
      ),
      data: (charter) {
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(charter.title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            for (final section in charter.sections) ...[
              Text(section.title, style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 6),
              for (final clause in section.clauses)
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text('• $clause'),
                ),
              const SizedBox(height: 12),
            ],
            const SizedBox(height: 8),
            FilledButton(onPressed: onAccept, child: Text(l10n.disputeConductAccept)),
          ],
        );
      },
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
            for (final attachment in message.attachments)
              if (attachment.isImage)
                Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(attachment.url, width: 160, fit: BoxFit.cover),
                  ),
                ),
            if (message.body != null && message.body!.isNotEmpty)
              Text(message.body!, style: TextStyle(color: textColor)),
          ],
        ),
      ),
    );
  }
}

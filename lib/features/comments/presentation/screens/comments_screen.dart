import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../l10n/app_localizations.dart';
import '../../application/comments_providers.dart';
import '../../data/models/comment.dart';

/// Comments on one post, with one level of threaded replies. See
/// Api\V2\CommentController — reading is public, writing needs auth (this
/// screen is only reachable from an already-authenticated app, so no
/// separate guest-read path is built).
class CommentsScreen extends ConsumerStatefulWidget {
  final int postId;
  const CommentsScreen({super.key, required this.postId});

  @override
  ConsumerState<CommentsScreen> createState() => _CommentsScreenState();
}

class _CommentsScreenState extends ConsumerState<CommentsScreen> {
  final _composeController = TextEditingController();
  final _scrollController = ScrollController();
  bool _private = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      ref.read(postCommentsControllerProvider(widget.postId).notifier).loadMore();
    }
  }

  @override
  void dispose() {
    _composeController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _post() async {
    final text = _composeController.text.trim();
    if (text.isEmpty) return;
    final l10n = AppLocalizations.of(context)!;
    _composeController.clear();
    try {
      await ref
          .read(postCommentsControllerProvider(widget.postId).notifier)
          .add(text, private: _private);
      setState(() => _private = false);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.commonSomethingWentWrong)));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final state = ref.watch(postCommentsControllerProvider(widget.postId));

    return Scaffold(
      appBar: AppBar(title: Text(l10n.commentsTitle)),
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
                              ref.read(postCommentsControllerProvider(widget.postId).notifier).load(),
                          child: Text(l10n.commonRetry),
                        ),
                      ],
                    ),
                  )
                : state.items.isEmpty
                ? Center(child: Text(l10n.commentsEmpty))
                : ListView.separated(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: state.items.length + (state.isLoadingMore ? 1 : 0),
                    separatorBuilder: (context, index) => const Divider(height: 24),
                    itemBuilder: (context, index) {
                      if (index >= state.items.length) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }
                      return _CommentTile(
                        comment: state.items[index],
                        onDelete: () async {
                          await ref
                              .read(postCommentsControllerProvider(widget.postId).notifier)
                              .delete(state.items[index].id);
                        },
                      );
                    },
                  ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _composeController,
                          decoration: InputDecoration(hintText: l10n.commentComposeHint),
                          minLines: 1,
                          maxLines: 4,
                          textInputAction: TextInputAction.send,
                          onSubmitted: (_) => _post(),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton.filled(
                        onPressed: state.isPosting ? null : _post,
                        icon: const Icon(Icons.send_rounded),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Checkbox(
                        value: _private,
                        onChanged: (v) => setState(() => _private = v ?? false),
                      ),
                      Flexible(
                        child: Text(l10n.commentPrivateToggle, style: Theme.of(context).textTheme.bodySmall),
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

class _CommentTile extends ConsumerStatefulWidget {
  final Comment comment;
  final VoidCallback onDelete;
  const _CommentTile({required this.comment, required this.onDelete});

  @override
  ConsumerState<_CommentTile> createState() => _CommentTileState();
}

class _CommentTileState extends ConsumerState<_CommentTile> {
  bool _repliesExpanded = false;
  bool _replying = false;
  final _replyController = TextEditingController();

  @override
  void dispose() {
    _replyController.dispose();
    super.dispose();
  }

  Future<void> _sendReply() async {
    final text = _replyController.text.trim();
    if (text.isEmpty) return;
    final l10n = AppLocalizations.of(context)!;
    _replyController.clear();
    try {
      await ref.read(commentRepliesControllerProvider(widget.comment.id).notifier).add(text);
      setState(() {
        _replying = false;
        _repliesExpanded = true;
      });
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.commonSomethingWentWrong)));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final comment = widget.comment;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _CommentBody(
          comment: comment,
          onDelete: () => confirmDeleteComment(context, widget.onDelete),
          onReply: () => setState(() => _replying = !_replying),
        ),
        if (comment.repliesCount > 0)
          Padding(
            padding: const EdgeInsets.only(left: 44, top: 4),
            child: TextButton(
              onPressed: () => setState(() => _repliesExpanded = !_repliesExpanded),
              child: Text(
                _repliesExpanded
                    ? l10n.commentHideReplies
                    : '${l10n.commentViewReplies} (${comment.repliesCount})',
              ),
            ),
          ),
        if (_repliesExpanded)
          Padding(
            padding: const EdgeInsets.only(left: 44),
            child: _RepliesList(commentId: comment.id),
          ),
        if (_replying)
          Padding(
            padding: const EdgeInsets.only(left: 44, top: 4),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _replyController,
                    autofocus: true,
                    decoration: InputDecoration(hintText: l10n.commentReplyHint),
                    onSubmitted: (_) => _sendReply(),
                  ),
                ),
                IconButton(icon: const Icon(Icons.send_rounded), onPressed: _sendReply),
              ],
            ),
          ),
      ],
    );
  }
}

Future<void> confirmDeleteComment(BuildContext context, VoidCallback onDelete) async {
  final l10n = AppLocalizations.of(context)!;
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      content: Text(l10n.commentDeleteConfirm),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context, false), child: Text(l10n.commonCancel)),
        TextButton(onPressed: () => Navigator.pop(context, true), child: Text(l10n.commentDeleteAction)),
      ],
    ),
  );
  if (confirmed == true) onDelete();
}

class _CommentBody extends StatelessWidget {
  final Comment comment;
  final VoidCallback onDelete;
  final VoidCallback? onReply;
  const _CommentBody({required this.comment, required this.onDelete, this.onReply});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 16,
          backgroundImage: comment.author?.logoUrl != null ? NetworkImage(comment.author!.logoUrl!) : null,
          child: comment.author?.logoUrl == null ? const Icon(Icons.person_outline, size: 16) : null,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    comment.author?.name ?? '',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  if (comment.isPrivate) ...[
                    const SizedBox(width: 6),
                    Chip(
                      label: Text(l10n.commentPrivateBadge),
                      visualDensity: VisualDensity.compact,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ],
                ],
              ),
              Text(comment.body),
              Row(
                children: [
                  if (onReply != null)
                    TextButton(onPressed: onReply, child: Text(l10n.commentReplyAction)),
                  if (comment.canDelete)
                    TextButton(onPressed: onDelete, child: Text(l10n.commentDeleteAction)),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _RepliesList extends ConsumerWidget {
  final int commentId;
  const _RepliesList({required this.commentId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final state = ref.watch(commentRepliesControllerProvider(commentId));

    if (state.isLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 8),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (state.error != null) {
      return Text(l10n.commonSomethingWentWrong);
    }

    return Column(
      children: [
        for (final reply in state.items)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: _CommentBody(
              comment: reply,
              onDelete: () => confirmDeleteComment(
                context,
                () => ref.read(commentRepliesControllerProvider(commentId).notifier).delete(reply.id),
              ),
            ),
          ),
        if (state.hasMore)
          TextButton(
            onPressed: () => ref.read(commentRepliesControllerProvider(commentId).notifier).loadMore(),
            child: Text(l10n.commentViewReplies),
          ),
      ],
    );
  }
}

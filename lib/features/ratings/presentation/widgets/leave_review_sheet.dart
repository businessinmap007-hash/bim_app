import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../../application/ratings_providers.dart';

/// Opens the star-rating + comment sheet for a completed order/booking.
/// Returns true if a review was actually submitted, so the caller can show
/// its own confirmation without this sheet needing to know about orders vs
/// bookings at all.
Future<bool> showLeaveReviewSheet(
  BuildContext context, {
  required String operationType,
  required int operationId,
}) async {
  final result = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    builder: (_) => _LeaveReviewSheet(operationType: operationType, operationId: operationId),
  );
  return result ?? false;
}

class _LeaveReviewSheet extends ConsumerStatefulWidget {
  final String operationType;
  final int operationId;
  const _LeaveReviewSheet({required this.operationType, required this.operationId});

  @override
  ConsumerState<_LeaveReviewSheet> createState() => _LeaveReviewSheetState();
}

class _LeaveReviewSheetState extends ConsumerState<_LeaveReviewSheet> {
  int _stars = 0;
  final _commentController = TextEditingController();
  bool _submitting = false;
  String? _error;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final l10n = AppLocalizations.of(context)!;
    if (_stars == 0) {
      setState(() => _error = l10n.ratingsSelectStarsError);
      return;
    }
    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      await ref.read(ratingsApiProvider).submitReview(
        operationType: widget.operationType,
        operationId: widget.operationId,
        stars: _stars,
        comment: _commentController.text.trim(),
      );
      if (mounted) Navigator.of(context).pop(true);
    } catch (_) {
      if (mounted) setState(() => _error = l10n.commonSomethingWentWrong);
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 20, 20, 20 + MediaQuery.of(context).viewInsets.bottom),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.ratingsLeaveReview, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (i) {
                final starValue = i + 1;
                return IconButton(
                  onPressed: () => setState(() {
                    _stars = starValue;
                    _error = null;
                  }),
                  icon: Icon(
                    starValue <= _stars ? Icons.star_rounded : Icons.star_border_rounded,
                    color: AppColors.accentGold,
                    size: 36,
                  ),
                );
              }),
            ),
            if (_error != null) ...[
              const SizedBox(height: 4),
              Center(
                child: Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
              ),
            ],
            const SizedBox(height: 12),
            TextField(
              controller: _commentController,
              maxLines: 3,
              decoration: InputDecoration(hintText: l10n.ratingsCommentHint),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: _submitting ? null : _submit,
              child: _submitting
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                  : Text(l10n.ratingsSubmit),
            ),
          ],
        ),
      ),
    );
  }
}

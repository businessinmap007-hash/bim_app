import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../chat/application/chat_providers.dart';
import '../../../chat/presentation/screens/operation_chat_screen.dart';
import '../../application/owner_listings_providers.dart';
import '../../data/owner_listings_api.dart';

/// A buyer's conversation about an owner listing: the app's chat, with a bar on top for «اتفقنا». No phone number can be
/// written in it; when the two agree either asks to swap numbers, the other accepts, the platform's fee is taken and each
/// side then sees the other's number.
class OwnerListingChatScreen extends ConsumerWidget {
  final int inquiryId;
  final String title;

  const OwnerListingChatScreen({
    super.key,
    required this.inquiryId,
    required this.title,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final inquiry = ref.watch(ownerInquiryProvider(inquiryId)).valueOrNull;

    return OperationChatScreen(
      operationType: 'listing',
      operationId: inquiryId,
      title: title,
      banner: inquiry == null ? null : _RevealBar(inquiry: inquiry),
    );
  }
}

class _RevealBar extends ConsumerStatefulWidget {
  final OwnerInquiry inquiry;
  const _RevealBar({required this.inquiry});

  @override
  ConsumerState<_RevealBar> createState() => _RevealBarState();
}

class _RevealBarState extends ConsumerState<_RevealBar> {
  bool _busy = false;

  Future<void> _run(
    Future<OwnerInquiry> Function(OwnerListingsApi api) action,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _busy = true);
    try {
      await action(ref.read(ownerListingsApiProvider));
      ref.invalidate(ownerInquiryProvider(widget.inquiry.id));
      ref.invalidate(myOwnerInquiriesProvider);
      // the room says what happened («طلب تبادل الأرقام»…): bring it in
      await ref
          .read(
            operationChatControllerProvider(
              OperationChatKey('listing', widget.inquiry.id),
            ).notifier,
          )
          .load();
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            e is ApiException ? e.message : l10n.commonSomethingWentWrong,
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  String _fee(AppLocalizations l10n, OwnerInquiry i) {
    String n(double v) =>
        v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toStringAsFixed(2);
    return i.myShare > 0
        ? l10n.olFeeLine(n(i.feeTotal), n(i.myShare))
        : l10n.olFeeLineOther(n(i.feeTotal));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final i = widget.inquiry;

    Widget card(List<Widget> children, {Color? color}) => Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(12, 8, 12, 0),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color ?? theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );

    if (i.revealed) {
      return card([
        Row(
          children: [
            Expanded(
              child: Text(
                l10n.olPhoneIs(i.otherName, i.otherPhone ?? '—'),
                style: theme.textTheme.titleSmall,
              ),
            ),
            if (i.otherPhone != null)
              IconButton(
                tooltip: l10n.olCopy,
                icon: const Icon(Icons.copy),
                onPressed: () =>
                    Clipboard.setData(ClipboardData(text: i.otherPhone!)),
              ),
          ],
        ),
      ]);
    }

    if (i.listingStatus == 'done' || i.listingStatus == 'expired') {
      return card([
        Text(l10n.olListingEnded, style: theme.textTheme.bodySmall),
      ]);
    }

    if (i.requestedByMe) {
      return card([
        Text(l10n.olRevealWaiting, style: theme.textTheme.bodyMedium),
        Text(_fee(l10n, i), style: theme.textTheme.bodySmall),
        Align(
          alignment: AlignmentDirectional.centerEnd,
          child: TextButton(
            onPressed: _busy
                ? null
                : () => _run((api) => api.revealCancel(i.id)),
            child: Text(l10n.olRevealWithdraw),
          ),
        ),
      ]);
    }

    if (i.requestedByOther) {
      return card([
        Text(
          l10n.olRevealAsked(i.otherName),
          style: theme.textTheme.titleSmall,
        ),
        Text(_fee(l10n, i), style: theme.textTheme.bodySmall),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: FilledButton(
                onPressed: _busy
                    ? null
                    : () => _run((api) => api.revealAccept(i.id)),
                child: Text(l10n.olRevealAccept),
              ),
            ),
            const SizedBox(width: 8),
            OutlinedButton(
              onPressed: _busy
                  ? null
                  : () => _run((api) => api.revealCancel(i.id)),
              child: Text(l10n.olRevealDecline),
            ),
          ],
        ),
      ]);
    }

    return card([
      Text(l10n.olNoPhoneNote, style: theme.textTheme.bodySmall),
      const SizedBox(height: 8),
      OutlinedButton.icon(
        onPressed: _busy ? null : () => _run((api) => api.revealRequest(i.id)),
        icon: const Icon(Icons.handshake_outlined),
        label: Text(l10n.olWeAgree),
      ),
      Text(_fee(l10n, i), style: theme.textTheme.bodySmall),
    ]);
  }
}

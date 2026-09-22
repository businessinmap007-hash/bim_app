import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../l10n/app_localizations.dart';
import '../../application/booking_providers.dart';

/// What this booking asks of YOU up front — the deposit held from your wallet
/// (or covered by your guarantee), the service fee, and whether your balance
/// covers it. Silent while loading, on error, once the booking is over, and when
/// nothing is asked of this party. Shows only the caller's own side.
class BookingMoneyCard extends ConsumerWidget {
  final int bookingId;
  const BookingMoneyCard({super.key, required this.bookingId});

  static const _over = {'completed', 'cancelled', 'rejected', 'expired'};

  String _n(double v) => v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toStringAsFixed(2);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final preview = ref.watch(bookingFinancialPreviewProvider(bookingId)).asData?.value;
    if (preview == null || preview.isEmpty || _over.contains(preview.status)) return const SizedBox.shrink();

    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final okColor = Colors.green.shade700;
    final badColor = theme.colorScheme.error;

    Widget row(String label, String value, {Color? color, bool bold = false}) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(child: Text(label)),
          Text(value, style: TextStyle(color: color, fontWeight: bold ? FontWeight.w600 : null)),
        ],
      ),
    );

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.bookingMoneyTitle, style: theme.textTheme.titleSmall),
            const SizedBox(height: 8),
            if (preview.depositRequired)
              row(
                preview.coveredByGuarantee ? l10n.bookingMoneyGuarantee : l10n.bookingMoneyDeposit,
                preview.coveredByGuarantee ? _n(preview.guaranteeApplied) : _n(preview.depositWalletRequired),
              ),
            if (preview.feeRequired > 0) row(l10n.bookingMoneyFee, _n(preview.feeRequired)),
            for (final promo in preview.promotions) Text(promo, style: theme.textTheme.bodySmall?.copyWith(color: okColor)),
            const Divider(height: 16),
            row(l10n.bookingMoneyTotal, _n(preview.requiredTotal), bold: true),
            row(l10n.bookingMoneyBalance, _n(preview.balance)),
            const SizedBox(height: 4),
            Text(
              preview.ready ? l10n.bookingMoneyReady : l10n.bookingMoneyShort,
              style: TextStyle(color: preview.ready ? okColor : badColor, fontWeight: FontWeight.w600),
            ),
            if (preview.feeRequired > 0)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(l10n.bookingMoneyFeeNonRefundable, style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor)),
              ),
            if (!preview.counterpartReady)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(l10n.bookingMoneyOtherPending, style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor)),
              ),
          ],
        ),
      ),
    );
  }
}

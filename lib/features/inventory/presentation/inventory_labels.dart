import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';

/// Words and colours shared by the phone and the desktop screens of the inventory suite.
class InvLabels {
  const InvLabels._();

  static String verdict(AppLocalizations l10n, String verdict) => switch (verdict) {
        'no' => l10n.stkVerdictNo,
        'tight' => l10n.stkVerdictTight,
        'yes' => l10n.stkVerdictYes,
        'empty' => l10n.stkVerdictEmpty,
        _ => l10n.stkVerdictUnknown,
      };

  /// (background, foreground) — told apart by lightness too, not hue alone
  static (Color, Color) verdictColors(String verdict) => switch (verdict) {
        'no' || 'empty' => (const Color(0xFFF9E4DF), const Color(0xFFB93A22)),
        'tight' => (const Color(0xFFFBF0D9), const Color(0xFF7A5200)),
        'yes' => (const Color(0xFFE7F3EC), const Color(0xFF1F7A44)),
        _ => (const Color(0xFFF1EEE6), const Color(0xFF5B6474)),
      };

  static String moveType(AppLocalizations l10n, String type) => switch (type) {
        'receipt' => l10n.stkMoveReceipt,
        'sale' => l10n.stkMoveSale,
        'sale_reversal' => l10n.stkMoveSaleReversal,
        'waste' => l10n.stkMoveWaste,
        'transfer_out' => l10n.stkMoveTransferOut,
        'transfer_in' => l10n.stkMoveTransferIn,
        'adjustment' => l10n.stkMoveAdjustment,
        'supplier_return' => l10n.stkMoveSupplierReturn,
        'opening' => l10n.stkMoveOpening,
        _ => l10n.stkMoveReversal,
      };

  static String poStatus(AppLocalizations l10n, String status) => switch (status) {
        'draft' => l10n.stkPoDraft,
        'pending_approval' => l10n.stkPoPending,
        'approved' => l10n.stkPoApproved,
        'partially_received' => l10n.stkPoPartial,
        'received' => l10n.stkPoReceived,
        'closed' => l10n.stkPoClosed,
        'rejected' => l10n.stkPoRejected,
        _ => l10n.stkPoCancelled,
      };

  static String money(num v) {
    final fixed = v.toStringAsFixed(2);
    final trimmed = fixed.endsWith('.00') ? fixed.substring(0, fixed.length - 3) : fixed;
    final parts = trimmed.split('.');
    final digits = parts[0].replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+$)'), (m) => '${m[1]},');
    return parts.length > 1 ? '$digits.${parts[1]}' : digits;
  }
}

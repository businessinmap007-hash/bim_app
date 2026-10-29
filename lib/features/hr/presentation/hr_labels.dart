import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';

/// Words and colours of the attendance month, shared by the desktop board and the employee's phone.
class HrLabels {
  const HrLabels._();

  static String status(AppLocalizations l10n, String s) => switch (s) {
        'present' => l10n.hrPresent,
        'late' => l10n.hrLate,
        'absent' => l10n.hrAbsent,
        'leave' => l10n.hrOnLeave,
        'unpaid_leave' => l10n.hrUnpaidLeave,
        'rest' => l10n.hrRest,
        'holiday' => l10n.hrHoliday,
        _ => '—',
      };

  /// A cell's fill — told apart by lightness as well as hue.
  static Color cell(String s) => switch (s) {
        'present' => const Color(0xFF9FD3B4),
        'late' => const Color(0xFFF2C879),
        'absent' => const Color(0xFFE79A8B),
        'leave' || 'unpaid_leave' => const Color(0xFFA9C4E8),
        'rest' || 'holiday' => const Color(0xFFE6E2D8),
        _ => Colors.transparent,
      };

  static String kind(AppLocalizations l10n, String k) => switch (k) {
        'leave' => l10n.hrKindLeave,
        'correction' => l10n.hrKindCorrection,
        _ => l10n.hrKindOvertime,
      };

  static String leaveType(AppLocalizations l10n, String t) => switch (t) {
        'annual' => l10n.hrLeaveAnnual,
        'casual' => l10n.hrLeaveCasual,
        'sick' => l10n.hrLeaveSick,
        _ => l10n.hrLeaveUnpaid,
      };

  static String requestSummary(AppLocalizations l10n, String kind, Map<String, dynamic> data, String from, String to) => switch (kind) {
        'leave' => '${leaveType(l10n, '${data['type'] ?? 'annual'}')} · $from → $to (${data['days'] ?? ''})',
        'correction' => '$from · ${data['check_in'] ?? '—'} / ${data['check_out'] ?? '—'}',
        _ => '$from · ${hours(((data['minutes'] ?? 0) as num).toInt() + ((data['night_minutes'] ?? 0) as num).toInt())} ${l10n.hrHoursShort}',
      };

  static String requestStatus(AppLocalizations l10n, String s) => switch (s) {
        'pending' => l10n.hrPending,
        'approved' => l10n.hrApproved,
        'rejected' => l10n.hrRejected,
        _ => l10n.hrCancelled,
      };

  static String hours(int minutes) {
    final h = minutes / 60;
    return h == h.roundToDouble() ? h.toInt().toString() : h.toStringAsFixed(1);
  }

  static String lineLabel(AppLocalizations l10n, Map<String, dynamic> line) => switch (line['key']) {
        'basic' => l10n.hrLineBasic,
        'overtime' => l10n.hrLineOvertime,
        'bonus' => l10n.hrLineBonus,
        'attendance' => l10n.hrLineAttendance,
        'unpaid_leave' => l10n.hrUnpaidLeave,
        'advance' => l10n.hrLineAdvance,
        'penalty' => l10n.hrLinePenalty,
        'insurance' => l10n.hrLineInsurance,
        'tax' => l10n.hrLineTax,
        _ => '${line['label'] ?? ''}',
      };
}

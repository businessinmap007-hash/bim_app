import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../../shared/widgets/person_card.dart';
import '../../../notifications/application/notifications_providers.dart';
import '../../application/staff_providers.dart';

/// Tapping the "you've been invited as staff" notification opens this
/// instead of the business's page — the business's own card (photo, name)
/// straight from the notification's `actor`, with Accept/Decline right on
/// it, since accepting/declining is the one thing this tap is actually for.
Future<void> showStaffInvitationDialog(
  BuildContext context,
  WidgetRef ref, {
  required int businessId,
  required String businessName,
  String? businessLogoUrl,
}) {
  return showDialog<void>(
    context: context,
    builder: (context) => _StaffInvitationDialog(
      businessId: businessId,
      businessName: businessName,
      businessLogoUrl: businessLogoUrl,
    ),
  );
}

class _StaffInvitationDialog extends ConsumerStatefulWidget {
  final int businessId;
  final String businessName;
  final String? businessLogoUrl;

  const _StaffInvitationDialog({
    required this.businessId,
    required this.businessName,
    this.businessLogoUrl,
  });

  @override
  ConsumerState<_StaffInvitationDialog> createState() => _StaffInvitationDialogState();
}

class _StaffInvitationDialogState extends ConsumerState<_StaffInvitationDialog> {
  bool _submitting = false;

  Future<void> _respond(bool accept) async {
    final l10n = AppLocalizations.of(context)!;
    setState(() => _submitting = true);
    try {
      final api = ref.read(staffApiProvider);
      if (accept) {
        await api.acceptInvitation(widget.businessId);
      } else {
        await api.declineInvitation(widget.businessId);
      }
      // Refresh the pending list for whenever the user next opens it —
      // safe even if it was never loaded (the provider just (re)fetches).
      ref.invalidate(staffInvitationsControllerProvider);
      // The backend just rewrote this same notification in place (its
      // action_type moves off open_staff_invitation so a second tap never
      // re-opens this dialog) — refresh so the list/badge reflect that
      // instead of still showing the original "you're invited" text.
      ref.invalidate(notificationsControllerProvider);
      ref.invalidate(unreadNotificationCountProvider);
      if (context.mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(accept ? l10n.staffInvitationAccepted : l10n.staffInvitationDeclined)),
        );
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.commonSomethingWentWrong)));
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return AlertDialog(
      title: Text(l10n.staffInvitationsTitle),
      content: PersonCard.forBusiness(name: widget.businessName, logoUrl: widget.businessLogoUrl),
      actionsAlignment: MainAxisAlignment.spaceBetween,
      actions: [
        OutlinedButton(
          onPressed: _submitting ? null : () => _respond(false),
          child: Text(l10n.staffInvitationDecline),
        ),
        FilledButton(
          onPressed: _submitting ? null : () => _respond(true),
          child: _submitting
              ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2))
              : Text(l10n.staffInvitationAccept),
        ),
      ],
    );
  }
}

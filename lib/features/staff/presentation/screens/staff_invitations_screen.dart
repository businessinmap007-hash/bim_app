import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../../shared/widgets/async_value_view.dart';
import '../../../../shared/widgets/person_card.dart';
import '../../../business/presentation/screens/business_detail_screen.dart';
import '../../application/staff_providers.dart';
import '../../data/models/staff_member.dart';

/// A grant I haven't answered yet — same PersonCard the owner sees right
/// after adding me, populated with the INVITING BUSINESS's info instead of
/// mine. Tapping the card opens the business's own page; Accept/Decline sit
/// beside it so the choice doesn't require leaving this screen first.
class StaffInvitationsScreen extends ConsumerWidget {
  const StaffInvitationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final state = ref.watch(staffInvitationsControllerProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.staffInvitationsTitle)),
      body: AsyncValueView(
        value: state,
        onRetry: () => ref.read(staffInvitationsControllerProvider.notifier).refresh(),
        builder: (context, invitations) {
          if (invitations.isEmpty) {
            return Center(child: Text(l10n.staffInvitationsEmpty));
          }

          return RefreshIndicator(
            onRefresh: () => ref.read(staffInvitationsControllerProvider.notifier).refresh(),
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: invitations.length,
              separatorBuilder: (_, _) => const SizedBox(height: 8),
              itemBuilder: (context, i) => _InvitationCard(invitation: invitations[i]),
            ),
          );
        },
      ),
    );
  }
}

class _InvitationCard extends ConsumerStatefulWidget {
  final StaffInvitation invitation;
  const _InvitationCard({required this.invitation});

  @override
  ConsumerState<_InvitationCard> createState() => _InvitationCardState();
}

class _InvitationCardState extends ConsumerState<_InvitationCard> {
  bool _submitting = false;

  Future<void> _respond(bool accept) async {
    final l10n = AppLocalizations.of(context)!;
    setState(() => _submitting = true);
    try {
      final controller = ref.read(staffInvitationsControllerProvider.notifier);
      if (accept) {
        await controller.accept(widget.invitation.businessId);
      } else {
        await controller.decline(widget.invitation.businessId);
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(accept ? l10n.staffInvitationAccepted : l10n.staffInvitationDeclined)),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.commonSomethingWentWrong)));
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final invitation = widget.invitation;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        PersonCard.forBusiness(
          name: invitation.businessName,
          phone: invitation.businessPhone,
          logoUrl: invitation.businessLogoUrl,
          subtitle: invitation.title?.isNotEmpty == true ? invitation.title : invitation.businessPhone,
          onTap: () => Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (_) => BusinessDetailScreen(businessId: invitation.businessId))),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: _submitting ? null : () => _respond(false),
                child: Text(l10n.staffInvitationDecline),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: FilledButton(
                onPressed: _submitting ? null : () => _respond(true),
                child: _submitting
                    ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2))
                    : Text(l10n.staffInvitationAccept),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

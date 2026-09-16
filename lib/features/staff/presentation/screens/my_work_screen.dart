import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../../application/my_work_providers.dart';
import '../../application/staff_providers.dart';
import '../../data/models/staff_membership.dart';
import 'staff_invitations_screen.dart';

/// "أعمالي" — every business I work for as a delegated staff member, with a
/// check-in/check-out for each. Reachable by any signed-in account; a
/// business account never has memberships of its own, so this simply shows
/// empty for them rather than needing its own gate.
class MyWorkScreen extends ConsumerWidget {
  const MyWorkScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final state = ref.watch(myWorkControllerProvider);

    final invitationsCount = ref.watch(staffInvitationsControllerProvider).valueOrNull?.length ?? 0;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.myWorkTitle),
        actions: [
          IconButton(
            tooltip: l10n.staffInvitationsTitle,
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const StaffInvitationsScreen()),
            ),
            icon: Badge(
              isLabelVisible: invitationsCount > 0,
              label: Text('$invitationsCount'),
              child: const Icon(Icons.mail_outline),
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(myWorkControllerProvider.notifier).load(),
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
                      onPressed: () => ref.read(myWorkControllerProvider.notifier).load(),
                      child: Text(l10n.commonRetry),
                    ),
                  ],
                ),
              )
            : state.memberships.isEmpty
            ? Center(child: Text(l10n.myWorkEmpty))
            : ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: state.memberships.length,
                separatorBuilder: (context, index) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final membership = state.memberships[index];
                  final status = state.attendanceByBusiness[membership.businessId] ?? AttendanceStatus.empty;
                  final busy = state.busyBusinessIds.contains(membership.businessId);

                  return _MembershipCard(
                    membership: membership,
                    status: status,
                    busy: busy,
                    onCheckIn: () => ref.read(myWorkControllerProvider.notifier).checkIn(membership.businessId),
                    onCheckOut: () => ref.read(myWorkControllerProvider.notifier).checkOut(membership.businessId),
                  );
                },
              ),
      ),
    );
  }
}

class _MembershipCard extends StatelessWidget {
  final StaffMembership membership;
  final AttendanceStatus status;
  final bool busy;
  final VoidCallback onCheckIn;
  final VoidCallback onCheckOut;

  const _MembershipCard({
    required this.membership,
    required this.status,
    required this.busy,
    required this.onCheckIn,
    required this.onCheckOut,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final timeFormat = DateFormat('HH:mm');

    final String statusLabel;
    final Color statusColor;
    if (status.isPresent) {
      statusLabel = l10n.staffAttendancePresent;
      statusColor = AppColors.success;
    } else if (status.checkedOutAt != null) {
      statusLabel = l10n.staffAttendanceCheckedOut;
      statusColor = Theme.of(context).hintColor;
    } else {
      statusLabel = l10n.staffAttendanceNotCheckedIn;
      statusColor = Theme.of(context).hintColor;
    }

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundImage: membership.businessLogoUrl != null
                      ? NetworkImage(membership.businessLogoUrl!)
                      : null,
                  child: membership.businessLogoUrl == null ? const Icon(Icons.storefront_outlined) : null,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(membership.businessName, style: Theme.of(context).textTheme.titleSmall),
                      if (membership.title != null && membership.title!.isNotEmpty)
                        Text(membership.title!, style: Theme.of(context).textTheme.bodySmall),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(color: statusColor, shape: BoxShape.circle),
                ),
                const SizedBox(width: 6),
                Text(statusLabel, style: TextStyle(color: statusColor, fontSize: 12, fontWeight: FontWeight.w600)),
                if (status.checkedInAt != null) ...[
                  const Text(' · '),
                  Text(timeFormat.format(status.checkedInAt!), style: Theme.of(context).textTheme.bodySmall),
                ],
              ],
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: status.isPresent
                  ? OutlinedButton(
                      onPressed: busy ? null : onCheckOut,
                      child: busy
                          ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2))
                          : Text(l10n.attendanceCheckOut),
                    )
                  : FilledButton(
                      onPressed: busy ? null : onCheckIn,
                      child: busy
                          ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2))
                          : Text(l10n.attendanceCheckIn),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../booking/presentation/screens/business_bookings_screen.dart';
import '../../../orders/presentation/screens/business_orders_screen.dart';
import '../../../delivery/application/delivery_providers.dart';
import '../../../delivery/data/models/roster_driver.dart';
import '../../../delivery/presentation/screens/driver_dashboard_screen.dart';
import '../../../delivery/presentation/screens/token_scan_screen.dart';
import '../../application/my_work_providers.dart';
import '../../application/staff_providers.dart';
import '../../data/models/staff_membership.dart';
import 'staff_invitations_screen.dart';

/// Runs the plain check-in/out for a membership that never turned on GPS+QR
/// verification, or — when it did — first gets the phone's own location and
/// has the employee scan the business's display code (TokenScanScreen,
/// reused as-is: the code is a bare one-time token, same shape as the
/// delivery-loop tokens it already reads) before calling the API with both.
Future<void> _performAttendance(
  BuildContext context,
  WidgetRef ref,
  StaffMembership membership, {
  required bool isCheckIn,
}) async {
  final l10n = AppLocalizations.of(context)!;
  final notifier = ref.read(myWorkControllerProvider.notifier);

  if (!membership.attendanceVerificationEnabled) {
    try {
      if (isCheckIn) {
        await notifier.checkIn(membership.businessId);
      } else {
        await notifier.checkOut(membership.businessId);
      }
    } catch (e) {
      if (context.mounted) _showAttendanceError(context, e);
    }
    return;
  }

  var permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
  }
  if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.attendanceLocationRequired)));
    }
    return;
  }
  final position = await Geolocator.getCurrentPosition();
  if (!context.mounted) return;

  final token = await Navigator.of(context).push<String>(
    MaterialPageRoute(
      builder: (_) => TokenScanScreen(title: l10n.attendanceScanQrTitle, hint: l10n.attendanceScanQrHint),
    ),
  );
  if (token == null) return;

  try {
    if (isCheckIn) {
      await notifier.checkIn(membership.businessId, qrToken: token, lat: position.latitude, lng: position.longitude);
    } else {
      await notifier.checkOut(membership.businessId, qrToken: token, lat: position.latitude, lng: position.longitude);
    }
  } catch (e) {
    if (context.mounted) _showAttendanceError(context, e);
  }
}

void _showAttendanceError(BuildContext context, Object e) {
  final l10n = AppLocalizations.of(context)!;
  ScaffoldMessenger.of(
    context,
  ).showSnackBar(SnackBar(content: Text(e is ApiException ? e.message : l10n.commonSomethingWentWrong)));
}

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
    // A driver a business linked to its team works for it: that job is listed
    // here (no rating - only a business account earns one).
    final driver = ref.watch(myLinkedDriverProvider).valueOrNull;
    final linkedDriver = (driver != null && driver.businessId != null) ? driver : null;

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
            : (state.memberships.isEmpty && linkedDriver == null)
            ? Center(child: Text(l10n.myWorkEmpty))
            : ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: state.memberships.length + (linkedDriver == null ? 0 : 1),
                separatorBuilder: (context, index) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  if (linkedDriver != null && index == 0) {
                    return _DriverJobCard(driver: linkedDriver);
                  }
                  final membership = state.memberships[index - (linkedDriver == null ? 0 : 1)];
                  final status = state.attendanceByBusiness[membership.businessId] ?? AttendanceStatus.empty;
                  final busy = state.busyBusinessIds.contains(membership.businessId);

                  return _MembershipCard(
                    membership: membership,
                    status: status,
                    busy: busy,
                    onCheckIn: () => _performAttendance(context, ref, membership, isCheckIn: true),
                    onCheckOut: () => _performAttendance(context, ref, membership, isCheckIn: false),
                  );
                },
              ),
      ),
    );
  }
}

class _DriverJobCard extends StatelessWidget {
  final DriverStatus driver;
  const _DriverJobCard({required this.driver});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Card(
      margin: EdgeInsets.zero,
      child: ListTile(
        leading: const Icon(Icons.delivery_dining_outlined),
        title: Text(driver.businessName ?? ''),
        subtitle: Text(l10n.myWorkDriverRole),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const DriverDashboardScreen()),
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
            if (membership.capabilities.contains('orders')) ...[
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => BusinessOrdersScreen(businessId: membership.businessId)),
                  ),
                  icon: const Icon(Icons.receipt_long_outlined, size: 18),
                  label: Text(l10n.businessOrdersTitle),
                ),
              ),
            ],
            if (membership.capabilities.contains('bookings')) ...[
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => BusinessBookingsScreen(businessId: membership.businessId)),
                  ),
                  icon: const Icon(Icons.event_note_outlined, size: 18),
                  label: Text(l10n.businessBookingsTitle),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

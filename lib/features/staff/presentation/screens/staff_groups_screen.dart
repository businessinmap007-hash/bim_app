import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../orders/presentation/screens/business_orders_screen.dart';
import '../../application/staff_groups_providers.dart';
import '../../data/models/staff_group.dart';

/// "فرق العمل" — the roster grouped by what each person does here (المنيو،
/// مناديب التوصيل، ...), each card showing today's operations, whether they
/// checked in, and — drivers only — whether they're currently carrying an
/// order. Read-only monitoring; capabilities themselves are still granted
/// from "الموظفون".
class StaffGroupsScreen extends ConsumerWidget {
  const StaffGroupsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final state = ref.watch(staffGroupsControllerProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.staffGroupsTitle)),
      body: RefreshIndicator(
        onRefresh: () => ref.read(staffGroupsControllerProvider.notifier).load(),
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
                      onPressed: () => ref.read(staffGroupsControllerProvider.notifier).load(),
                      child: Text(l10n.commonRetry),
                    ),
                  ],
                ),
              )
            : state.groups.isEmpty
            ? Center(child: Text(l10n.staffEmpty))
            : ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: state.groups.length,
                separatorBuilder: (context, index) => const SizedBox(height: 12),
                itemBuilder: (context, index) => _GroupSection(group: state.groups[index]),
              ),
      ),
    );
  }
}

class _GroupSection extends StatefulWidget {
  final StaffGroup group;
  const _GroupSection({required this.group});

  @override
  State<_GroupSection> createState() => _GroupSectionState();
}

class _GroupSectionState extends State<_GroupSection> {
  bool _expanded = true;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final languageCode = Localizations.localeOf(context).languageCode;

    return Card(
      margin: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            onTap: () => setState(() => _expanded = !_expanded),
            title: Text(widget.group.name(languageCode), style: Theme.of(context).textTheme.titleSmall),
            subtitle: Text('${widget.group.members.length}'),
            trailing: Icon(_expanded ? Icons.expand_less : Icons.expand_more),
          ),
          if (_expanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              child: widget.group.members.isEmpty
                  ? Padding(padding: const EdgeInsets.all(8), child: Text(l10n.staffGroupsEmptyGroup))
                  : Column(
                      children: [
                        for (final member in widget.group.members) ...[
                          _MemberCard(member: member),
                          const SizedBox(height: 8),
                        ],
                      ],
                    ),
            ),
        ],
      ),
    );
  }
}

String _hhmm(DateTime dt) => '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';

class _MemberCard extends StatelessWidget {
  final StaffGroupMember member;
  const _MemberCard({required this.member});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final String attendanceLabel;
    final Color attendanceColor;
    if (member.isPresent) {
      attendanceLabel = member.checkedInAt != null
          ? l10n.staffAttendancePresentSince(_hhmm(member.checkedInAt!))
          : l10n.staffAttendancePresent;
      attendanceColor = AppColors.success;
    } else if (member.checkedOutAt != null) {
      attendanceLabel = l10n.staffAttendanceCheckedOutAt(_hhmm(member.checkedOutAt!));
      attendanceColor = Theme.of(context).hintColor;
    } else {
      attendanceLabel = l10n.staffAttendanceNotCheckedIn;
      attendanceColor = Theme.of(context).hintColor;
    }

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundImage: member.logoUrl != null ? NetworkImage(member.logoUrl!) : null,
                child: member.logoUrl == null ? const Icon(Icons.person_outline, size: 18) : null,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      member.title?.isNotEmpty == true ? '${member.name} — ${member.title}' : member.name,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                    ),
                    Row(
                      children: [
                        Container(
                          width: 7,
                          height: 7,
                          decoration: BoxDecoration(color: attendanceColor, shape: BoxShape.circle),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          attendanceLabel,
                          style: TextStyle(color: attendanceColor, fontSize: 11, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.checklist_outlined, size: 14, color: Theme.of(context).hintColor),
              const SizedBox(width: 4),
              Text(
                l10n.staffActivityOperationsCount(member.operationsToday),
                style: Theme.of(context).textTheme.bodySmall,
              ),
              if (member.isDriver) ...[
                const SizedBox(width: 10),
                Icon(
                  Icons.delivery_dining_outlined,
                  size: 14,
                  color: member.driverBusy ? AppColors.accentGold : Theme.of(context).hintColor,
                ),
                const SizedBox(width: 4),
                Text(
                  member.driverBusy
                      ? l10n.deliveryDriverBusy(member.activeOrderCount)
                      : l10n.deliveryDriverOnDuty,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ],
          ),
          if (member.isDriver) ...[
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.staffAssignTask)));
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const BusinessOrdersScreen()),
                  );
                },
                child: Text(l10n.staffAssignTask),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

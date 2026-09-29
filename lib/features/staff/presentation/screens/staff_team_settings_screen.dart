import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../l10n/app_localizations.dart';
import 'attendance_verification_settings_screen.dart';
import 'staff_activity_screen.dart';
import 'staff_groups_screen.dart';
import 'staff_screen.dart';

/// «جمع ما يخص فريق العمل فى زر واحد (اعدادات فريق العمل) وداخله Tabs لكل
/// صفحة» — المالك، 2026-09-29. One settings entry for everything about
/// staff instead of 4 separate tiles: roster ([StaffScreen]), group
/// monitoring ([StaffGroupsScreen]), activity log ([StaffActivityScreen]),
/// and the attendance-verification toggle
/// ([AttendanceVerificationSettingsScreen]) — each stripped down to just its
/// body, since none of them were reached from anywhere but their own
/// (now-removed) Service Settings tile.
class StaffTeamSettingsScreen extends ConsumerStatefulWidget {
  const StaffTeamSettingsScreen({super.key});

  @override
  ConsumerState<StaffTeamSettingsScreen> createState() =>
      _StaffTeamSettingsScreenState();
}

class _StaffTeamSettingsScreenState
    extends ConsumerState<StaffTeamSettingsScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    // "Add staff" only makes sense on the roster tab.
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) setState(() {});
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.staffTeamSettingsTitle),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: [
            Tab(text: l10n.staffTitle),
            Tab(text: l10n.staffGroupsTitle),
            Tab(text: l10n.staffActivityTitle),
            Tab(text: l10n.attendanceVerificationSettingsTitle),
          ],
        ),
      ),
      floatingActionButton: _tabController.index == 0
          ? FloatingActionButton(
              onPressed: () => showStaffMemberSheet(context, ref),
              child: const Icon(Icons.person_add_alt_1_outlined),
            )
          : null,
      body: TabBarView(
        controller: _tabController,
        children: const [
          StaffScreen(),
          StaffGroupsScreen(),
          StaffActivityScreen(),
          AttendanceVerificationSettingsScreen(),
        ],
      ),
    );
  }
}

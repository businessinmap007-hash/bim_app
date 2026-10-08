import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../business/presentation/screens/business_detail_screen.dart';
import '../../application/hospital_providers.dart';
import '../../data/models/hospital_department.dart';

/// The «الأقسام والأطباء» tab of a hospital's or a medical centre's page: its departments, each with its doctors. A doctor
/// with an account on the app opens that doctor's own page (where the booking is); a doctor the hospital listed as text
/// is just a name.
class HospitalDepartmentsTab extends ConsumerWidget {
  final int hospitalId;
  const HospitalDepartmentsTab({super.key, required this.hospitalId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final async = ref.watch(hospitalDepartmentsProvider(hospitalId));

    return async.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, _) => Center(child: Text(l10n.commonSomethingWentWrong)),
      data: (departments) {
        if (departments.isEmpty) return Center(child: Text(l10n.hospitalNoDepartments));

        return Builder(
          builder: (context) => CustomScrollView(
            // no PageStorageKey here: the ExpansionTiles keep their open state in PageStorage too, and the two collide
            slivers: [
              SliverOverlapInjector(handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context)),
              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverList.separated(
                  itemCount: departments.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 8),
                  itemBuilder: (context, i) => DepartmentCard(department: departments[i]),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// One department with its doctors. Shared by the patient's tab; the manager's screen draws its own rows.
class DepartmentCard extends StatelessWidget {
  final HospitalDepartment department;
  const DepartmentCard({super.key, required this.department});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: ExpansionTile(
        shape: const Border(),
        collapsedShape: const Border(),
        initiallyExpanded: department.doctors.isNotEmpty,
        title: Text(department.name, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
        subtitle: Text(l10n.hospitalDoctorCount(department.doctors.length), style: theme.textTheme.bodySmall),
        children: [
          if (department.doctors.isEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Align(alignment: AlignmentDirectional.centerStart, child: Text(l10n.hospitalNoDoctors, style: theme.textTheme.bodySmall)),
            )
          else
            for (final d in department.doctors)
              ListTile(
                leading: const Icon(Icons.medical_services_outlined),
                title: Text(d.name),
                // a doctor with an account has a page to visit; one listed as text does not
                trailing: d.businessId == null ? null : const Icon(Icons.chevron_right),
                onTap: d.businessId == null
                    ? null
                    : () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => BusinessDetailScreen(businessId: d.businessId!)),
                      ),
              ),
        ],
      ),
    );
  }
}

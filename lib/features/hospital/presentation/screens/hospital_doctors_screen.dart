import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/widgets/async_value_view.dart';
import '../../application/hospital_providers.dart';
import '../../data/models/hospital_department.dart';

/// The hospital's side of «الأطباء تحت الأقسام»: its departments (the specialties it ticked in the business settings)
/// and the doctors under each. A doctor with an account is invited and shows once accepted; a doctor with no account is
/// listed as text at once.
class HospitalDoctorsScreen extends ConsumerWidget {
  const HospitalDoctorsScreen({super.key});

  Future<void> _remove(BuildContext context, WidgetRef ref, HospitalDoctorEntry doctor) async {
    final l10n = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        content: Text(l10n.hospitalDoctorRemoveConfirm),
        actions: [
          TextButton(onPressed: () => Navigator.of(dialogContext).pop(false), child: Text(l10n.commonCancel)),
          FilledButton(onPressed: () => Navigator.of(dialogContext).pop(true), child: Text(l10n.commonDelete)),
        ],
      ),
    );
    if (ok != true) return;

    try {
      await ref.read(hospitalApiProvider).removeDoctor(doctor.id);
      ref.invalidate(myHospitalDepartmentsProvider);
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(e is ApiException && e.message.isNotEmpty ? e.message : l10n.commonSomethingWentWrong)));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final async = ref.watch(myHospitalDepartmentsProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.hospitalManageTitle)),
      body: AsyncValueView(
        value: async,
        onRetry: () => ref.invalidate(myHospitalDepartmentsProvider),
        builder: (context, departments) {
          if (departments.isEmpty) {
            return Center(child: Padding(padding: const EdgeInsets.all(24), child: Text(l10n.hospitalManageNoDepartments, textAlign: TextAlign.center)));
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(l10n.hospitalManageHint, style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor)),
              const SizedBox(height: 12),
              for (final d in departments)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Card(
                    margin: EdgeInsets.zero,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(child: Text(d.name, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700))),
                              TextButton.icon(
                                onPressed: () => _addDoctor(context, ref, d),
                                icon: const Icon(Icons.person_add_alt_1_outlined, size: 18),
                                label: Text(l10n.hospitalAddDoctor),
                              ),
                            ],
                          ),
                          if (d.doctors.isEmpty)
                            Padding(padding: const EdgeInsets.symmetric(vertical: 8), child: Text(l10n.hospitalNoDoctors, style: theme.textTheme.bodySmall))
                          else
                            for (final doc in d.doctors)
                              ListTile(
                                contentPadding: EdgeInsets.zero,
                                dense: true,
                                leading: Icon(doc.businessId == null ? Icons.person_outline : Icons.verified_user_outlined),
                                title: Text(doc.name),
                                subtitle: doc.isPending ? Text(l10n.hospitalDoctorPending) : null,
                                trailing: IconButton(
                                  tooltip: l10n.commonDelete,
                                  icon: const Icon(Icons.delete_outline),
                                  onPressed: () => _remove(context, ref, doc),
                                ),
                              ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _addDoctor(BuildContext context, WidgetRef ref, HospitalDepartment department) async {
    final added = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => _AddDoctorSheet(department: department),
    );
    if (added == true) ref.invalidate(myHospitalDepartmentsProvider);
  }
}

class _AddDoctorSheet extends ConsumerStatefulWidget {
  final HospitalDepartment department;
  const _AddDoctorSheet({required this.department});

  @override
  ConsumerState<_AddDoctorSheet> createState() => _AddDoctorSheetState();
}

class _AddDoctorSheetState extends ConsumerState<_AddDoctorSheet> {
  bool _withAccount = true;
  final _search = TextEditingController();
  final _name = TextEditingController();
  final _title = TextEditingController();
  Timer? _debounce;
  List<DoctorCandidate> _found = const [];
  DoctorCandidate? _picked;
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _debounce?.cancel();
    _search.dispose();
    _name.dispose();
    _title.dispose();
    super.dispose();
  }

  void _onSearch(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () async {
      if (value.trim().length < 2) {
        if (mounted) setState(() => _found = const []);
        return;
      }
      try {
        final found = await ref.read(hospitalApiProvider).findDoctors(value.trim());
        if (mounted) setState(() => _found = found);
      } catch (_) {}
    });
  }

  bool get _ready => _withAccount ? _picked != null : _name.text.trim().isNotEmpty;

  Future<void> _submit() async {
    final l10n = AppLocalizations.of(context)!;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await ref.read(hospitalApiProvider).addDoctor(
        optionId: widget.department.optionId,
        userId: _withAccount ? _picked!.id : null,
        name: _withAccount ? null : _name.text.trim(),
        title: _title.text.trim(),
      );
      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      if (mounted) {
        setState(() {
          _busy = false;
          _error = e is ApiException && e.message.isNotEmpty ? e.message : l10n.commonSomethingWentWrong;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.fromLTRB(16, 0, 16, 16 + MediaQuery.of(context).viewInsets.bottom),
      child: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('${l10n.hospitalAddDoctor} — ${widget.department.name}', style: theme.textTheme.titleMedium),
              const SizedBox(height: 12),
              SegmentedButton<bool>(
                segments: [
                  ButtonSegment(value: true, label: Text(l10n.hospitalDoctorWithAccount)),
                  ButtonSegment(value: false, label: Text(l10n.hospitalDoctorNoAccount)),
                ],
                selected: {_withAccount},
                onSelectionChanged: (s) => setState(() => _withAccount = s.first),
              ),
              const SizedBox(height: 12),
              if (_withAccount) ...[
                TextField(
                  controller: _search,
                  decoration: InputDecoration(hintText: l10n.hospitalSearchDoctorHint, prefixIcon: const Icon(Icons.search), isDense: true),
                  onChanged: _onSearch,
                ),
                RadioGroup<int>(
                  groupValue: _picked?.id,
                  onChanged: (id) => setState(() => _picked = _found.firstWhere((c) => c.id == id)),
                  child: Column(
                    children: [for (final c in _found) RadioListTile<int>(value: c.id, title: Text(c.name))],
                  ),
                ),
                if (_picked != null && _found.every((c) => c.id != _picked!.id)) ListTile(leading: const Icon(Icons.check_circle_outline), title: Text(_picked!.name)),
                const SizedBox(height: 4),
                Text(l10n.hospitalInviteNote, style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor)),
              ] else
                TextField(
                  controller: _name,
                  decoration: InputDecoration(labelText: l10n.hospitalDoctorName),
                  onChanged: (_) => setState(() {}),
                ),
              const SizedBox(height: 8),
              TextField(controller: _title, decoration: InputDecoration(labelText: l10n.hospitalDoctorTitle)),
              if (_error != null) ...[
                const SizedBox(height: 8),
                Text(_error!, style: TextStyle(color: theme.colorScheme.error)),
              ],
              const SizedBox(height: 16),
              FilledButton(
                onPressed: _ready && !_busy ? _submit : null,
                child: _busy ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2)) : Text(l10n.hospitalAddDoctor),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../l10n/app_localizations.dart';
import '../../application/course_providers.dart';
import '../../data/models/course.dart';

/// «مجموعات الكورسات» — the business opens a group of a course (when it starts, when it meets, how many seats), closes
/// it when it is full or over, and sees how many seats are taken.
class CourseGroupsScreen extends ConsumerWidget {
  const CourseGroupsScreen({super.key});

  Future<void> _edit(BuildContext context, WidgetRef ref, BusinessCourses data, {CourseGroup? group}) async {
    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (_) => _GroupForm(courses: data.courses, group: group),
    );
    if (saved == true) ref.invalidate(myCoursesProvider);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final locale = Localizations.localeOf(context).toString();
    final async = ref.watch(myCoursesProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.courseManageTitle)),
      floatingActionButton: async.valueOrNull == null || async.value!.courses.isEmpty
          ? null
          : FloatingActionButton.extended(
              onPressed: () => _edit(context, ref, async.value!),
              icon: const Icon(Icons.add),
              label: Text(l10n.courseAddGroup),
            ),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => Center(
          child: TextButton(onPressed: () => ref.invalidate(myCoursesProvider), child: Text(l10n.commonSomethingWentWrong)),
        ),
        data: (data) {
          if (data.courses.isEmpty) {
            return Center(
              child: Padding(padding: const EdgeInsets.all(24), child: Text(l10n.courseNoCourses, textAlign: TextAlign.center)),
            );
          }

          final fmt = DateFormat.yMMMd(locale);

          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(myCoursesProvider),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
              children: [
                for (final course in data.courses) ...[
                  Text(course.name, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 8),
                  for (final g in data.groups.where((g) => g.offeringId == course.id))
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Card(
                        margin: EdgeInsets.zero,
                        child: ListTile(
                          onTap: () => _edit(context, ref, data, group: g),
                          title: Text(g.name, style: const TextStyle(fontWeight: FontWeight.w700)),
                          subtitle: Text(
                            [
                              if ((g.scheduleText ?? '').isNotEmpty) g.scheduleText!,
                              if (g.startsOn != null) l10n.courseStartsOn(fmt.format(g.startsOn!)),
                              l10n.courseTaken(g.seatsTaken, g.seats),
                              if (!g.isActive) l10n.courseGroupClosed,
                            ].join(' · '),
                          ),
                          trailing: const Icon(Icons.edit_outlined),
                        ),
                      ),
                    ),
                  if (data.groups.where((g) => g.offeringId == course.id).isEmpty)
                    Padding(padding: const EdgeInsets.only(bottom: 10), child: Text(l10n.courseNoGroups)),
                  const SizedBox(height: 8),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}

class _GroupForm extends ConsumerStatefulWidget {
  final List<CourseInfo> courses;
  final CourseGroup? group;
  const _GroupForm({required this.courses, this.group});

  @override
  ConsumerState<_GroupForm> createState() => _GroupFormState();
}

class _GroupFormState extends ConsumerState<_GroupForm> {
  late int _offeringId;
  late final TextEditingController _name;
  late final TextEditingController _level;
  late final TextEditingController _schedule;
  late DateTime _startsOn;
  DateTime? _endsOn;
  late int _seats;
  bool _active = true;
  bool _busy = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    final g = widget.group;
    _offeringId = g?.offeringId ?? widget.courses.first.id;
    _name = TextEditingController(text: g?.name ?? '');
    _level = TextEditingController(text: g?.level ?? '');
    _schedule = TextEditingController(text: g?.scheduleText ?? '');
    _startsOn = g?.startsOn ?? DateTime.now().add(const Duration(days: 7));
    _endsOn = g?.endsOn;
    _seats = g?.seats ?? 10;
    _active = g?.isActive ?? true;
  }

  @override
  void dispose() {
    _name.dispose();
    _level.dispose();
    _schedule.dispose();
    super.dispose();
  }

  Future<void> _pick({required bool end}) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: (end ? _endsOn : null) ?? _startsOn,
      firstDate: end ? _startsOn : DateTime(now.year, now.month, now.day),
      lastDate: now.add(const Duration(days: 730)),
    );
    if (picked == null || !mounted) return;
    setState(() {
      if (end) {
        _endsOn = picked;
      } else {
        _startsOn = picked;
        if (_endsOn != null && _endsOn!.isBefore(picked)) _endsOn = null;
      }
    });
  }

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context)!;
    if (_name.text.trim().isEmpty) {
      setState(() => _error = l10n.courseNameRequired);
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    final api = ref.read(courseApiProvider);
    try {
      final level = _level.text.trim().isEmpty ? null : _level.text.trim();
      final schedule = _schedule.text.trim().isEmpty ? null : _schedule.text.trim();
      if (widget.group == null) {
        await api.create(offeringId: _offeringId, name: _name.text.trim(), level: level, scheduleText: schedule, startsOn: _startsOn, endsOn: _endsOn, seats: _seats);
      } else {
        await api.update(widget.group!.id, offeringId: _offeringId, name: _name.text.trim(), level: level, scheduleText: schedule, startsOn: _startsOn, endsOn: _endsOn, seats: _seats, isActive: _active);
      }
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

  Future<void> _delete() async {
    final l10n = AppLocalizations.of(context)!;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await ref.read(courseApiProvider).delete(widget.group!.id);
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
    final locale = Localizations.localeOf(context).toString();
    final fmt = DateFormat.yMMMd(locale);
    final editing = widget.group != null;

    return Padding(
      padding: EdgeInsets.fromLTRB(16, 16, 16, 16 + MediaQuery.of(context).viewInsets.bottom),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(editing ? l10n.courseEditGroup : l10n.courseAddGroup, style: theme.textTheme.titleLarge),
            const SizedBox(height: 14),
            if (widget.courses.length > 1) ...[
              DropdownButtonFormField<int>(
                initialValue: _offeringId,
                isExpanded: true,
                decoration: InputDecoration(labelText: l10n.courseOfCourse),
                items: [for (final c in widget.courses) DropdownMenuItem(value: c.id, child: Text(c.name))],
                onChanged: (v) => setState(() => _offeringId = v ?? _offeringId),
              ),
              const SizedBox(height: 12),
            ],
            TextField(controller: _name, decoration: InputDecoration(labelText: l10n.courseGroupName)),
            const SizedBox(height: 12),
            TextField(controller: _level, decoration: InputDecoration(labelText: l10n.courseGroupLevel, hintText: l10n.courseGroupLevelHint)),
            const SizedBox(height: 12),
            TextField(controller: _schedule, decoration: InputDecoration(labelText: l10n.courseGroupSchedule)),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _pick(end: false),
                    child: Text('${l10n.courseGroupStarts}: ${fmt.format(_startsOn)}', overflow: TextOverflow.ellipsis),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _pick(end: true),
                    child: Text(
                      _endsOn == null ? l10n.courseGroupEnds : '${l10n.courseGroupEndsShort}: ${fmt.format(_endsOn!)}',
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: Text(l10n.courseGroupSeats, style: theme.textTheme.bodyLarge)),
                IconButton(onPressed: _seats > 1 ? () => setState(() => _seats--) : null, icon: const Icon(Icons.remove_circle_outline)),
                Text('$_seats', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                IconButton(onPressed: _seats < 1000 ? () => setState(() => _seats++) : null, icon: const Icon(Icons.add_circle_outline)),
              ],
            ),
            if (editing)
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(l10n.courseGroupOpen),
                value: _active,
                onChanged: (v) => setState(() => _active = v),
              ),
            if (_error != null) Padding(padding: const EdgeInsets.only(top: 6), child: Text(_error!, style: TextStyle(color: theme.colorScheme.error))),
            const SizedBox(height: 14),
            FilledButton(
              onPressed: _busy ? null : _save,
              child: _busy ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2)) : Text(l10n.commonSave),
            ),
            if (editing) ...[
              const SizedBox(height: 8),
              TextButton(
                onPressed: _busy ? null : _delete,
                style: TextButton.styleFrom(foregroundColor: theme.colorScheme.error),
                child: Text(l10n.courseDeleteGroup),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

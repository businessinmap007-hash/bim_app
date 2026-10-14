import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../core/time/clock_format.dart';
import '../../../../core/time/egypt_time.dart';
import '../../../../core/time/local_format.dart';
import '../../../../l10n/app_localizations.dart';
import '../../application/investigations_providers.dart';
import '../screens/investigation_order_detail_screen.dart';
import 'investigation_widgets.dart';

/// The «الحجز» tab of a lab's or a radiology centre's page: the tests it does and what it charges and its packages
/// («باقات», each at its own price), for a lab the sample taken at home, an optional photo of the doctor's paper
/// request, the day and time the patient chooses — and one button: the order goes to this centre at once and the centre
/// accepts it (keeping the time asked for, or proposing another).
class CenterTestsTab extends ConsumerStatefulWidget {
  final int centerId;
  const CenterTestsTab({super.key, required this.centerId});

  @override
  ConsumerState<CenterTestsTab> createState() => _CenterTestsTabState();
}

class _CenterTestsTabState extends ConsumerState<CenterTestsTab> {
  final Set<int> _picked = {};
  final Set<int> _packages = {};
  final _notes = TextEditingController();
  File? _photo;
  bool _home = false;
  DateTime? _day;
  String? _time;
  bool _sending = false;

  @override
  void dispose() {
    _notes.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery, maxWidth: 1600, maxHeight: 1600, imageQuality: 70);
    if (picked != null && mounted) setState(() => _photo = File(picked.path));
  }

  static String _dayKey(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  DateTime? get _requestedAt {
    final day = _day;
    final time = ClockFormat.parse(_time);
    if (day == null || time == null) return null;

    return DateTime(day.year, day.month, day.day, time.hour, time.minute);
  }

  Future<void> _send() async {
    final l10n = AppLocalizations.of(context)!;
    setState(() => _sending = true);
    try {
      final order = await ref.read(investigationsApiProvider).requestFromCenter(
        centerId: widget.centerId,
        optionIds: _picked.toList(),
        packageIds: _packages.toList(),
        homeCollection: _home,
        requestedAt: _requestedAt,
        notes: _notes.text.trim(),
        photoPath: _photo?.path,
      );
      ref.invalidate(myInvestigationOrdersProvider);
      if (!mounted) return;
      setState(() {
        _picked.clear();
        _packages.clear();
        _photo = null;
        _home = false;
        _day = null;
        _time = null;
        _notes.clear();
        _sending = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.invRequestSent)));
      Navigator.of(context).push(MaterialPageRoute(builder: (_) => InvestigationOrderDetailScreen(orderId: order.id)));
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e is ApiException && e.message.isNotEmpty ? e.message : l10n.commonSomethingWentWrong)));
        setState(() => _sending = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final async = ref.watch(centerOfferProvider(widget.centerId));

    return async.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, _) => Center(child: Text(l10n.commonSomethingWentWrong)),
      data: (offer) {
        if (offer.tests.isEmpty && offer.packages.isEmpty) return Center(child: Text(l10n.invNoTests));

        final testsTotal = offer.tests.where((t) => _picked.contains(t.optionId)).fold<double>(0, (a, t) => a + (t.price ?? 0));
        final packagesTotal = offer.packages.where((p) => _packages.contains(p.id)).fold<double>(0, (a, p) => a + p.price);
        final anything = _picked.isNotEmpty || _packages.isNotEmpty;
        final total = testsTotal + packagesTotal + (_home && anything ? (offer.homeFee ?? 0) : 0);
        final count = _picked.length + _packages.length;
        final today = EgyptTime.now();
        final days = [for (var i = 0; i < 7; i++) DateTime(today.year, today.month, today.day).add(Duration(days: i))];

        Widget heading(String text) => Padding(
          padding: const EdgeInsets.only(top: 8, bottom: 6),
          child: Text(text, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
        );

        Widget section(String kind) {
          final rows = offer.tests.where((t) => t.kind == kind).toList();
          if (rows.isEmpty) return const SizedBox.shrink();

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              heading(investigationKindLabel(l10n, kind)),
              for (final t in rows)
                Card(
                  margin: const EdgeInsets.only(bottom: 6),
                  child: CheckboxListTile(
                    value: _picked.contains(t.optionId),
                    onChanged: (on) => setState(() => on == true ? _picked.add(t.optionId) : _picked.remove(t.optionId)),
                    controlAffinity: ListTileControlAffinity.leading,
                    title: Text(t.name),
                    secondary: Text(
                      '${formatInvestigationMoney(t.price ?? 0)} ${l10n.invCurrency}',
                      style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
                    ),
                  ),
                ),
            ],
          );
        }

        Widget packagesSection() {
          if (offer.packages.isEmpty) return const SizedBox.shrink();

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              heading(l10n.invPackagesHeading),
              for (final p in offer.packages)
                Card(
                  margin: const EdgeInsets.only(bottom: 6),
                  child: CheckboxListTile(
                    value: _packages.contains(p.id),
                    onChanged: (on) => setState(() => on == true ? _packages.add(p.id) : _packages.remove(p.id)),
                    controlAffinity: ListTileControlAffinity.leading,
                    title: Text(p.name),
                    subtitle: Text(
                      [if (p.tests.isNotEmpty) l10n.invIncludes(p.tests.join('، ')), if (p.note != null) p.note!].join('\n'),
                      style: theme.textTheme.bodySmall,
                    ),
                    secondary: Text(
                      '${formatInvestigationMoney(p.price)} ${l10n.invCurrency}',
                      style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
                    ),
                  ),
                ),
            ],
          );
        }

        Widget when() {
          final times = _day == null ? null : ref.watch(centerTimesProvider((centerId: widget.centerId, day: _dayKey(_day!))));

          return Card(
            margin: EdgeInsets.zero,
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.invPickDay, style: theme.textTheme.titleSmall),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 64,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: days.length,
                      separatorBuilder: (_, _) => const SizedBox(width: 8),
                      itemBuilder: (context, i) {
                        final d = days[i];
                        final selected = _day != null && _dayKey(_day!) == _dayKey(d);

                        return ChoiceChip(
                          selected: selected,
                          onSelected: (_) => setState(() {
                            _day = d;
                            _time = null;
                          }),
                          label: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(LocalFormat.weekday(context).format(d), style: theme.textTheme.bodySmall),
                              Text(LocalFormat.dayNumber(context).format(d), style: theme.textTheme.titleMedium),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  if (times != null) ...[
                    const SizedBox(height: 12),
                    Text(l10n.invPickTime, style: theme.textTheme.titleSmall),
                    const SizedBox(height: 8),
                    times.when(
                      loading: () => const Padding(padding: EdgeInsets.all(8), child: LinearProgressIndicator()),
                      error: (_, _) => Text(l10n.commonSomethingWentWrong),
                      data: (slot) => slot.times.isEmpty
                          ? Text(l10n.invNoTimes, style: theme.textTheme.bodySmall)
                          : Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                for (final t in slot.times)
                                  ChoiceChip(
                                    label: Text(ClockFormat.hhmm(context, t)),
                                    selected: _time == t,
                                    onSelected: (_) => setState(() => _time = t),
                                  ),
                              ],
                            ),
                    ),
                  ],
                ],
              ),
            ),
          );
        }

        final ready = anything && _requestedAt != null;

        return Builder(
          builder: (context) => CustomScrollView(
            key: const PageStorageKey('center_tests'),
            slivers: [
              SliverOverlapInjector(handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context)),
              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    Text(l10n.invPickTests, style: theme.textTheme.titleLarge),
                    section('lab'),
                    section('radiology'),
                    packagesSection(),
                    const SizedBox(height: 8),
                    // a lab that takes the sample at the patient's home says what it charges
                    if (offer.homeFee != null)
                      Card(
                        margin: EdgeInsets.zero,
                        child: SwitchListTile(
                          value: _home,
                          onChanged: (v) => setState(() => _home = v),
                          title: Text(l10n.invHomeCollection),
                          secondary: Text(
                            '+${formatInvestigationMoney(offer.homeFee!)} ${l10n.invCurrency}',
                            style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
                          ),
                        ),
                      ),
                    const SizedBox(height: 8),
                    OutlinedButton.icon(
                      onPressed: _pickPhoto,
                      icon: Icon(_photo == null ? Icons.upload_outlined : Icons.check_circle_outline),
                      label: Text(l10n.invAttachPaper),
                    ),
                    const SizedBox(height: 8),
                    when(),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _notes,
                      minLines: 2,
                      maxLines: 4,
                      decoration: InputDecoration(labelText: l10n.invNotesLabel, alignLabelWithHint: true),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(child: Text(!anything ? l10n.invNothingSelected : l10n.invSelectedCount(count), style: theme.textTheme.bodySmall)),
                        Text('${formatInvestigationMoney(total)} ${l10n.invCurrency}', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
                      ],
                    ),
                    if (anything && _requestedAt == null)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(l10n.invChooseTime, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.error)),
                      ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: !ready || _sending ? null : _send,
                        child: _sending
                            ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                            : Text(l10n.invSendRequest),
                      ),
                    ),
                  ]),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

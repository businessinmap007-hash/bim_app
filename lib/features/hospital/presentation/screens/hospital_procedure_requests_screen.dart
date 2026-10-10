import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/widgets/app_bar_tab_bar.dart';
import '../../../../shared/widgets/async_value_view.dart';
import '../../application/hospital_providers.dart';
import '../../data/models/hospital_procedure.dart';
import '../widgets/procedure_widgets.dart';

/// The hospital's side of a procedure request: new ones (accept with a date, decline), the ones scheduled (mark done),
/// and the finished.
class HospitalProcedureRequestsScreen extends ConsumerWidget {
  const HospitalProcedureRequestsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.procRequestsTitle),
          bottom: AppBarTabBar(tabs: [Tab(text: l10n.invTabIncoming), Tab(text: l10n.procTabUpcoming), Tab(text: l10n.invTabDone)]),
        ),
        body: const TabBarView(children: [_Tab(tab: 'incoming'), _Tab(tab: 'upcoming'), _Tab(tab: 'done')]),
      ),
    );
  }
}

class _Tab extends ConsumerStatefulWidget {
  final String tab;
  const _Tab({required this.tab});

  @override
  ConsumerState<_Tab> createState() => _TabState();
}

class _TabState extends ConsumerState<_Tab> {
  void _refresh() {
    for (final t in ['incoming', 'upcoming', 'done']) {
      ref.invalidate(hospitalProcedureRequestsProvider(t));
    }
  }

  Future<void> _run(Future<Object?> Function() action) async {
    final l10n = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.of(context);
    try {
      await action();
      _refresh();
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(e is ApiException && e.message.isNotEmpty ? e.message : l10n.commonSomethingWentWrong)));
    }
  }

  Future<void> _accept(ProcedureRequestItem r) async {
    final l10n = AppLocalizations.of(context)!;
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      helpText: l10n.procPickSchedule,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
      initialDate: r.preferredDate != null && r.preferredDate!.isAfter(now) ? r.preferredDate! : now.add(const Duration(days: 2)),
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(context: context, initialTime: const TimeOfDay(hour: 9, minute: 0));
    if (time == null || !mounted) return;

    double? quote;
    // a procedure with no price needs one now (the hospital's quote after assessment)
    if (r.price == null) {
      final c = TextEditingController();
      final ok = await showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: Text(l10n.procQuoteTitle),
          content: TextField(
            controller: c,
            autofocus: true,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(labelText: l10n.invPriceLabel, suffixText: l10n.invCurrency),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(dialogContext).pop(false), child: Text(l10n.procSkipQuote)),
            FilledButton(onPressed: () => Navigator.of(dialogContext).pop(true), child: Text(l10n.invAccept)),
          ],
        ),
      );
      quote = ok == true ? double.tryParse(c.text.trim().replaceAll(',', '.')) : null;
      c.dispose();
    }

    final at = DateTime(date.year, date.month, date.day, time.hour, time.minute);
    await _run(() => ref.read(hospitalApiProvider).acceptProcedure(r.id, scheduledAt: at, price: quote));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final async = ref.watch(hospitalProcedureRequestsProvider(widget.tab));

    return AsyncValueView(
      value: async,
      onRetry: _refresh,
      builder: (context, rows) {
        if (rows.isEmpty) return Center(child: Text(l10n.procRequestsEmpty));

        return RefreshIndicator(
          onRefresh: () async => _refresh(),
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: rows.length,
            separatorBuilder: (_, _) => const SizedBox(height: 10),
            itemBuilder: (context, i) {
              final r = rows[i];

              return ProcedureRequestCard(
                request: r,
                forHospital: true,
                actions: [
                  if (r.status == ProcedureRequestItem.requested) ...[
                    FilledButton(onPressed: () => _accept(r), child: Text(l10n.procAcceptSchedule)),
                    OutlinedButton(
                      onPressed: () => _run(() => ref.read(hospitalApiProvider).declineProcedure(r.id)),
                      child: Text(l10n.invDecline),
                    ),
                  ] else if (r.status == ProcedureRequestItem.accepted)
                    FilledButton(
                      onPressed: () => _run(() => ref.read(hospitalApiProvider).completeProcedure(r.id)),
                      child: Text(l10n.procMarkDone),
                    ),
                ],
              );
            },
          ),
        );
      },
    );
  }
}

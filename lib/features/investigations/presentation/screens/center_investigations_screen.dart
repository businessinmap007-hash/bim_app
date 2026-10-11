import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/widgets/app_bar_tab_bar.dart';
import '../../../../shared/widgets/async_value_view.dart';
import '../../../../shared/widgets/form_save_button.dart';
import '../../../../shared/widgets/full_screen_gallery.dart';
import '../../application/investigations_providers.dart';
import '../../data/models/investigation.dart';
import '../widgets/investigation_widgets.dart';
import 'center_results_screen.dart';
import 'investigation_orders_screen.dart' show InvestigationOrderCard;

/// A lab's, a radiology centre's (or a hospital's) side: the orders patients sent it — accept one with a time, decline
/// it, upload the results — and its own price list of the tests it does.
class CenterInvestigationsScreen extends ConsumerWidget {
  const CenterInvestigationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.invCenterTitle),
          actions: [
            IconButton(
              tooltip: l10n.invPriceList,
              icon: const Icon(Icons.price_change_outlined),
              onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const CenterPriceListScreen())),
            ),
          ],
          bottom: AppBarTabBar(tabs: [Tab(text: l10n.invTabIncoming), Tab(text: l10n.invTabAccepted), Tab(text: l10n.invTabDone)]),
        ),
        body: const TabBarView(children: [_CenterTab(tab: 'incoming'), _CenterTab(tab: 'accepted'), _CenterTab(tab: 'done')]),
      ),
    );
  }
}

class _CenterTab extends ConsumerStatefulWidget {
  final String tab;
  const _CenterTab({required this.tab});

  @override
  ConsumerState<_CenterTab> createState() => _CenterTabState();
}

class _CenterTabState extends ConsumerState<_CenterTab> {
  int? _busyId;

  void _refresh() {
    for (final t in ['incoming', 'accepted', 'done']) {
      ref.invalidate(centerInvestigationOrdersProvider(t));
    }
  }

  Future<void> _act(InvestigationOrder order, Future<void> Function() action, {String? done}) async {
    final l10n = AppLocalizations.of(context)!;
    setState(() => _busyId = order.id);
    try {
      await action();
      _refresh();
      if (done != null && mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(done)));
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e is ApiException && e.message.isNotEmpty ? e.message : l10n.commonSomethingWentWrong)));
      }
    } finally {
      if (mounted) setState(() => _busyId = null);
    }
  }

  Future<void> _accept(InvestigationOrder order) async {
    final l10n = AppLocalizations.of(context)!;
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      helpText: l10n.invPickAppointment,
      firstDate: now,
      lastDate: now.add(const Duration(days: 180)),
      initialDate: now.add(const Duration(days: 1)),
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(context: context, initialTime: const TimeOfDay(hour: 9, minute: 0));
    if (time == null || !mounted) return;
    final at = DateTime(date.year, date.month, date.day, time.hour, time.minute);

    await _act(order, () => ref.read(investigationsApiProvider).accept(order.id, appointmentAt: at));
  }

  Future<void> _results(InvestigationOrder order) async {
    final l10n = AppLocalizations.of(context)!;
    final sent = await Navigator.of(context).push<bool>(MaterialPageRoute(builder: (_) => CenterResultsScreen(order: order)));
    if (sent == true) {
      _refresh();
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.invResultsAttached)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final async = ref.watch(centerInvestigationOrdersProvider(widget.tab));

    return AsyncValueView(
      value: async,
      onRetry: _refresh,
      builder: (context, orders) {
        if (orders.isEmpty) return Center(child: Text(l10n.invCenterEmpty));

        return RefreshIndicator(
          onRefresh: () async => _refresh(),
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: orders.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (context, i) {
              final o = orders[i];
              final busy = _busyId == o.id;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  InvestigationOrderCard(
                    order: o,
                    title: o.patient?.name,
                    onTap: () {
                      if (o.resultFiles.isNotEmpty) {
                        FullScreenGallery.show(context, urls: o.resultFiles);
                      } else if (o.resultDocuments.isNotEmpty) {
                        launchUrl(Uri.parse(o.resultDocuments.first), mode: LaunchMode.externalApplication);
                      }
                    },
                  ),
                  if ((o.notes ?? '').isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(14, 6, 14, 0),
                      child: Text(l10n.invDoctorNote(o.notes!), style: Theme.of(context).textTheme.bodySmall),
                    ),
                  if (o.requestFiles.isNotEmpty)
                    Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: TextButton.icon(
                        onPressed: () => FullScreenGallery.show(context, urls: o.requestFiles),
                        icon: const Icon(Icons.image_outlined),
                        label: Text(l10n.invAttachPaper.split('(').first.trim()),
                      ),
                    ),
                  const SizedBox(height: 6),
                  if (o.status == InvestigationOrder.sent)
                    Row(
                      children: [
                        Expanded(
                          child: FilledButton(onPressed: busy ? null : () => _accept(o), child: Text(l10n.invAccept)),
                        ),
                        const SizedBox(width: 8),
                        OutlinedButton(
                          onPressed: busy ? null : () => _act(o, () => ref.read(investigationsApiProvider).decline(o.id)),
                          child: Text(l10n.invDecline),
                        ),
                      ],
                    )
                  else if (o.status == InvestigationOrder.accepted)
                    FilledButton.icon(
                      onPressed: busy ? null : () => _results(o),
                      icon: const Icon(Icons.edit_note_outlined),
                      label: Text(l10n.invWriteResults),
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

/// The centre's own price list of the platform's tests and exams — a price for each test it does, nothing for the rest.
/// It is the same list the patient sees on the centre's page and is charged from.
class CenterPriceListScreen extends ConsumerStatefulWidget {
  const CenterPriceListScreen({super.key});

  @override
  ConsumerState<CenterPriceListScreen> createState() => _CenterPriceListScreenState();
}

class _CenterPriceListScreenState extends ConsumerState<CenterPriceListScreen> {
  final Map<int, TextEditingController> _controllers = {};
  Map<int, String> _saved = {};
  bool _saving = false;
  String? _error;

  TextEditingController _controller(CenterTest t) =>
      _controllers.putIfAbsent(t.optionId, () => TextEditingController(text: t.price == null ? '' : formatInvestigationMoney(t.price!)));

  bool get _dirty => _controllers.entries.any((e) => e.value.text.trim() != (_saved[e.key] ?? ''));

  @override
  void dispose() {
    for (final c in _controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context)!;
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      final prices = {
        for (final e in _controllers.entries) e.key: double.tryParse(e.value.text.trim().replaceAll(',', '.')),
      };
      final saved = await ref.read(investigationsApiProvider).savePrices(prices);
      _saved = {for (final t in saved) t.optionId: t.price == null ? '' : formatInvestigationMoney(t.price!)};
      ref.invalidate(centerPriceListProvider);
    } catch (e) {
      _error = e is ApiException && e.message.isNotEmpty ? e.message : l10n.commonSomethingWentWrong;
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final async = ref.watch(centerPriceListProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.invPriceList)),
      body: AsyncValueView(
        value: async,
        onRetry: () => ref.invalidate(centerPriceListProvider),
        builder: (context, tests) {
          if (_saved.isEmpty) {
            _saved = {for (final t in tests) t.optionId: t.price == null ? '' : formatInvestigationMoney(t.price!)};
          }

          Widget group(String kind) {
            final rows = tests.where((t) => t.kind == kind).toList();

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 12, bottom: 6),
                  child: Text(investigationKindLabel(l10n, kind), style: theme.textTheme.titleMedium),
                ),
                for (final t in rows)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        Expanded(child: Text(t.name)),
                        SizedBox(
                          width: 110,
                          child: TextField(
                            controller: _controller(t),
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            onChanged: (_) => setState(() {}),
                            decoration: InputDecoration(hintText: l10n.invPriceLabel, isDense: true, suffixText: l10n.invCurrency),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            );
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(l10n.invPriceListHint, style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor)),
              group('lab'),
              group('radiology'),
              if (_error != null) ...[
                const SizedBox(height: 8),
                Text(_error!, style: TextStyle(color: theme.colorScheme.error)),
              ],
              const SizedBox(height: 16),
              FormSaveButton(saving: _saving, saved: !_dirty, onPressed: _save),
            ],
          );
        },
      ),
    );
  }
}

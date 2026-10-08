import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/widgets/async_value_view.dart';
import '../../../../shared/widgets/full_screen_gallery.dart';
import '../../application/investigations_providers.dart';
import '../../data/models/investigation.dart';
import '../widgets/investigation_widgets.dart';

/// One investigation order, from the patient's side: its items and steps, the registered centres with what each charges
/// for the WHOLE order (to share it with one), and the results when they are in. The doctor opens the same screen to
/// follow the order; only the patient sees the share section.
class InvestigationOrderDetailScreen extends ConsumerStatefulWidget {
  final int orderId;
  const InvestigationOrderDetailScreen({super.key, required this.orderId});

  @override
  ConsumerState<InvestigationOrderDetailScreen> createState() => _InvestigationOrderDetailScreenState();
}

class _InvestigationOrderDetailScreenState extends ConsumerState<InvestigationOrderDetailScreen> {
  int? _centerId;
  bool _busy = false;

  Future<void> _run(Future<void> Function() action) async {
    final l10n = AppLocalizations.of(context)!;
    setState(() => _busy = true);
    try {
      await action();
      ref.invalidate(investigationOrderProvider(widget.orderId));
      ref.invalidate(investigationCentersProvider(widget.orderId));
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e is ApiException && e.message.isNotEmpty ? e.message : l10n.commonSomethingWentWrong)));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _send(InvestigationCenter center) async {
    final l10n = AppLocalizations.of(context)!;
    await _run(() async {
      await ref.read(investigationsApiProvider).send(widget.orderId, center.id);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.invSent)));
    });
  }

  Future<void> _cancel() async {
    final l10n = AppLocalizations.of(context)!;
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        content: Text(l10n.invCancelConfirm),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text(l10n.invKeepOrder)),
          TextButton(onPressed: () => Navigator.pop(context, true), child: Text(l10n.invCancelOrder)),
        ],
      ),
    );
    if (ok == true) await _run(() => ref.read(investigationsApiProvider).cancel(widget.orderId));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final async = ref.watch(investigationOrderProvider(widget.orderId));

    return Scaffold(
      appBar: AppBar(title: Text(l10n.invTitle)),
      body: AsyncValueView(
        value: async,
        onRetry: () => ref.invalidate(investigationOrderProvider(widget.orderId)),
        builder: (context, order) => _body(context, l10n, order),
      ),
    );
  }

  Widget _body(BuildContext context, AppLocalizations l10n, InvestigationOrder order) {
    final theme = Theme.of(context);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          margin: EdgeInsets.zero,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        order.doctor != null ? l10n.invFromDoctor(order.doctor!.name) : l10n.invOwnRequest,
                        style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                      ),
                    ),
                    InvestigationStatusPill(status: order.status),
                  ],
                ),
                if (order.issuedAt != null)
                  Text(formatInvestigationDate(context, order.issuedAt!), style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor)),
                if (order.step > 0) ...[const SizedBox(height: 14), InvestigationSteps(step: order.step)],
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Card(
          margin: EdgeInsets.zero,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InvestigationItemRows(items: order.items, centerChosen: order.center != null),
                if (order.total != null) ...[
                  const Divider(height: 20),
                  Row(
                    children: [
                      Text(l10n.invTotal, style: theme.textTheme.titleSmall),
                      const Spacer(),
                      Text(
                        '${formatInvestigationMoney(order.total!)} ${l10n.invCurrency}',
                        style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                      ),
                    ],
                  ),
                ],
                if ((order.notes ?? '').isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(l10n.invDoctorNote(order.notes!), style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor)),
                ],
              ],
            ),
          ),
        ),
        if (order.center != null && order.status != InvestigationOrder.issued) ...[
          const SizedBox(height: 12),
          Card(
            margin: EdgeInsets.zero,
            child: ListTile(
              leading: const Icon(Icons.local_hospital_outlined),
              title: Text(order.center!.name),
              subtitle: Text(
                [
                  if (order.appointmentAt != null) l10n.invAppointment(formatInvestigationDate(context, order.appointmentAt!)),
                  if ((order.centerNote ?? '').isNotEmpty) l10n.invCenterNote(order.centerNote!),
                ].join('\n'),
              ),
            ),
          ),
        ],
        if (order.requestFiles.isNotEmpty) ...[
          const SizedBox(height: 12),
          _thumbs(context, order.requestFiles),
        ],
        if (order.hasResults) ...[
          const SizedBox(height: 16),
          Text(l10n.invResults, style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          _thumbs(context, order.resultFiles),
        ],
        if (order.canSend) ..._shareSection(context, l10n),
        if (order.canCancel) ...[
          const SizedBox(height: 12),
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: TextButton(onPressed: _busy ? null : _cancel, child: Text(l10n.invCancelOrder)),
          ),
        ],
      ],
    );
  }

  Widget _thumbs(BuildContext context, List<String> urls) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (var i = 0; i < urls.length; i++)
          InkWell(
            onTap: () => FullScreenGallery.show(context, urls: urls, initialIndex: i),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                urls[i],
                width: 96,
                height: 96,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => const SizedBox(width: 96, height: 96, child: Icon(Icons.broken_image_outlined)),
              ),
            ),
          ),
      ],
    );
  }

  List<Widget> _shareSection(BuildContext context, AppLocalizations l10n) {
    final theme = Theme.of(context);
    final centers = ref.watch(investigationCentersProvider(widget.orderId));

    return [
      const SizedBox(height: 20),
      Text(l10n.invShareTitle, style: theme.textTheme.titleMedium),
      Text(l10n.invShareHint, style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor)),
      const SizedBox(height: 8),
      centers.when(
        loading: () => const Padding(padding: EdgeInsets.all(16), child: Center(child: CircularProgressIndicator())),
        error: (_, _) => Text(l10n.commonSomethingWentWrong),
        data: (list) {
          if (list.isEmpty) return Padding(padding: const EdgeInsets.symmetric(vertical: 12), child: Text(l10n.invNoCenters));
          final selected = list.where((c) => c.id == _centerId).firstOrNull ?? list.first;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final c in list)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Card(
                    margin: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(color: c.id == selected.id ? theme.colorScheme.primary : Colors.transparent, width: 2),
                    ),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () => setState(() => _centerId = c.id),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(c.name, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
                                  Text(
                                    c.coversAll ? l10n.invCoversAll : l10n.invCoversSome(c.covers, c.of),
                                    style: theme.textTheme.bodySmall?.copyWith(color: c.coversAll ? null : theme.hintColor),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              '${formatInvestigationMoney(c.total)} ${l10n.invCurrency}',
                              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              Text(l10n.invShareNever, style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor)),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _busy ? null : () => _send(selected),
                  child: _busy
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                      : Text(l10n.invShareButton(selected.name)),
                ),
              ),
            ],
          );
        },
      ),
    ];
  }
}

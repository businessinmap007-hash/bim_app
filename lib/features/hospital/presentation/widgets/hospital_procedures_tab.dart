import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../l10n/app_localizations.dart';
import '../../application/hospital_providers.dart';
import '../../data/models/hospital_procedure.dart';
import '../screens/my_procedure_requests_screen.dart';
import 'procedure_widgets.dart';

/// The «الإجراءات الطبية» tab of a hospital's page: the surgeries, endoscopies and treatments it offers, with its own
/// price (or «السعر بعد التقييم»). Tapping one asks for it — an optional preferred day and a note; the hospital answers
/// with a date.
class HospitalProceduresTab extends ConsumerWidget {
  final int hospitalId;
  const HospitalProceduresTab({super.key, required this.hospitalId});

  Future<void> _ask(BuildContext context, WidgetRef ref, ProcedureOffering offering) async {
    final l10n = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    final sent = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => _AskSheet(offering: offering),
    );

    if (sent == true) {
      ref.invalidate(myProcedureRequestsProvider);
      messenger.showSnackBar(
        SnackBar(
          content: Text(l10n.procRequestSent),
          action: SnackBarAction(
            label: l10n.procMyRequestsTitle,
            onPressed: () => navigator.push(MaterialPageRoute(builder: (_) => const MyProcedureRequestsScreen())),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final async = ref.watch(hospitalProceduresProvider(hospitalId));

    return async.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, _) => Center(child: Text(l10n.commonSomethingWentWrong)),
      data: (sections) {
        if (sections.isEmpty) return Center(child: Text(l10n.procNoneOffered));

        return Builder(
          builder: (context) => CustomScrollView(
            slivers: [
              SliverOverlapInjector(handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context)),
              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    for (final s in sections) ...[
                      Padding(
                        padding: const EdgeInsets.only(top: 8, bottom: 6),
                        child: Text(procedureKindLabel(l10n, s.kind), style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                      ),
                      for (final p in s.procedures)
                        Card(
                          margin: const EdgeInsets.only(bottom: 6),
                          child: ListTile(
                            title: Text(p.name),
                            subtitle: Text(procedurePriceText(l10n, p.price)),
                            trailing: const Icon(Icons.chevron_right),
                            onTap: () => _ask(context, ref, p),
                          ),
                        ),
                    ],
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

class _AskSheet extends ConsumerStatefulWidget {
  final ProcedureOffering offering;
  const _AskSheet({required this.offering});

  @override
  ConsumerState<_AskSheet> createState() => _AskSheetState();
}

class _AskSheetState extends ConsumerState<_AskSheet> {
  DateTime? _date;
  final _notes = TextEditingController();
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _notes.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final d = await showDatePicker(
      context: context,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
      initialDate: _date ?? now.add(const Duration(days: 7)),
    );
    if (d != null && mounted) setState(() => _date = d);
  }

  Future<void> _send() async {
    final l10n = AppLocalizations.of(context)!;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await ref.read(hospitalApiProvider).requestProcedure(offeringId: widget.offering.id, preferredDate: _date, notes: _notes.text.trim());
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

    return Padding(
      padding: EdgeInsets.fromLTRB(16, 0, 16, 16 + MediaQuery.of(context).viewInsets.bottom),
      child: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(widget.offering.name, style: theme.textTheme.titleMedium),
              const SizedBox(height: 4),
              Text(procedurePriceText(l10n, widget.offering.price), style: theme.textTheme.bodyMedium),
              const SizedBox(height: 14),
              OutlinedButton.icon(
                onPressed: _pickDate,
                icon: const Icon(Icons.event_outlined),
                label: Text(_date == null ? l10n.procPickPreferredDate : DateFormat.yMMMEd(locale).format(_date!)),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _notes,
                minLines: 2,
                maxLines: 4,
                decoration: InputDecoration(labelText: l10n.invNotesLabel, alignLabelWithHint: true),
              ),
              if (_error != null) ...[
                const SizedBox(height: 8),
                Text(_error!, style: TextStyle(color: theme.colorScheme.error)),
              ],
              const SizedBox(height: 14),
              FilledButton(
                onPressed: _busy ? null : _send,
                child: _busy ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2)) : Text(l10n.procAskButton),
              ),
              const SizedBox(height: 6),
              Text(l10n.procAskNote, style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor)),
            ],
          ),
        ),
      ),
    );
  }
}

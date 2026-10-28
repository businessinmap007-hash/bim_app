import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../core/time/local_format.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../booking/data/models/gala_dinner.dart';
import '../../application/booking_settings_controller.dart';

/// «العشاء الإلزامي»: the hotel's gala nights (رأس السنة، الكريسماس…). Every stay over such a night pays its dinner — each adult the price,
/// each child from the free age the hotel's percentage of it — whatever meal plan the guest chose, and on a partner's sale too.
class GalaDinnersScreen extends ConsumerStatefulWidget {
  const GalaDinnersScreen({super.key});

  @override
  ConsumerState<GalaDinnersScreen> createState() => _GalaDinnersScreenState();
}

class _GalaDinnersScreenState extends ConsumerState<GalaDinnersScreen> {
  List<GalaDinner>? _galas;
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final g = await ref.read(bookingSettingsApiProvider).galaDinners();
      if (mounted) setState(() => _galas = g);
    } catch (_) {
      if (mounted) setState(() => _failed = true);
    }
  }

  Future<void> _edit([GalaDinner? gala]) async {
    final saved = await showDialog<bool>(context: context, builder: (_) => _GalaDialog(gala: gala));
    if (saved == true) await _load();
  }

  Future<void> _delete(GalaDinner gala) async {
    final l10n = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.of(context);
    try {
      await ref.read(bookingSettingsApiProvider).deleteGalaDinner(gala.id);
      await _load();
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(e is ApiException && e.message.isNotEmpty ? e.message : l10n.commonSomethingWentWrong)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final galas = _galas;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.galaTitle)),
      floatingActionButton: galas == null ? null : FloatingActionButton.extended(onPressed: () => _edit(), icon: const Icon(Icons.add), label: Text(l10n.galaAdd)),
      body: _failed
          ? Center(child: Text(l10n.commonSomethingWentWrong))
          : galas == null
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
              children: [
                Text(l10n.galaIntro, style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor)),
                const SizedBox(height: 12),
                if (galas.isEmpty) Padding(padding: const EdgeInsets.only(top: 24), child: Center(child: Text(l10n.galaEmpty))),
                for (final g in galas)
                  Card(
                    margin: const EdgeInsets.only(bottom: 10),
                    child: ListTile(
                      leading: const Icon(Icons.celebration_outlined),
                      title: Text('${g.name} · ${LocalFormat.date(context).format(g.date)}'),
                      subtitle: Text(l10n.galaSummary(g.adultPrice.toStringAsFixed(0), g.childPercent.toStringAsFixed(g.childPercent % 1 == 0 ? 0 : 2), g.childFreeUnder)),
                      onTap: () => _edit(g),
                      trailing: IconButton(tooltip: l10n.commonDelete, icon: const Icon(Icons.delete_outline), onPressed: () => _delete(g)),
                    ),
                  ),
              ],
            ),
    );
  }
}

/// One gala night: the date, its name, the adult price, a child's percentage and the age under which a child is free. Owns its own
/// controllers, so they live exactly as long as the dialog.
class _GalaDialog extends ConsumerStatefulWidget {
  final GalaDinner? gala;
  const _GalaDialog({this.gala});

  @override
  ConsumerState<_GalaDialog> createState() => _GalaDialogState();
}

class _GalaDialogState extends ConsumerState<_GalaDialog> {
  late final _name = TextEditingController(text: widget.gala?.name ?? '');
  late final _price = TextEditingController(text: widget.gala == null ? '' : widget.gala!.adultPrice.toStringAsFixed(0));
  late final _percent = TextEditingController(text: (widget.gala?.childPercent ?? 50).toStringAsFixed(0));
  late DateTime? _date = widget.gala?.date;
  late int _freeUnder = widget.gala?.childFreeUnder ?? 6;
  bool _saving = false;
  String? _error;

  @override
  void dispose() {
    _name.dispose();
    _price.dispose();
    _percent.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _date ?? now,
      firstDate: DateTime(now.year, now.month, now.day),
      lastDate: now.add(const Duration(days: 730)),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context)!;
    final price = double.tryParse(_price.text.trim().replaceAll(',', '.'));
    if (_date == null || _name.text.trim().isEmpty || price == null) {
      setState(() => _error = l10n.galaMissing);
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      final gala = GalaDinner(
        id: widget.gala?.id ?? 0,
        date: _date!,
        name: _name.text.trim(),
        adultPrice: price,
        childPercent: (double.tryParse(_percent.text.trim().replaceAll(',', '.')) ?? 50).clamp(0, 100).toDouble(),
        childFreeUnder: _freeUnder,
      );
      await ref.read(bookingSettingsApiProvider).saveGalaDinner(gala);
      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      if (mounted) {
        setState(() {
          _saving = false;
          _error = e is ApiException && e.message.isNotEmpty ? e.message : l10n.commonSomethingWentWrong;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return AlertDialog(
      title: Text(widget.gala == null ? l10n.galaAdd : l10n.galaEdit),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            OutlinedButton.icon(
              icon: const Icon(Icons.event_outlined),
              label: Text(_date == null ? l10n.galaDate : LocalFormat.date(context).format(_date!)),
              onPressed: _pickDate,
            ),
            const SizedBox(height: 8),
            TextField(controller: _name, decoration: InputDecoration(labelText: l10n.galaName, hintText: l10n.galaNameHint)),
            TextField(
              controller: _price,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(labelText: l10n.galaAdultPrice),
            ),
            TextField(
              controller: _percent,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(labelText: l10n.galaChildPercent, suffixText: '%'),
            ),
            const SizedBox(height: 8),
            Row(children: [
              Expanded(child: Text(l10n.galaFreeUnder)),
              DropdownButton<int>(
                value: _freeUnder,
                items: [for (var a = 0; a <= 17; a++) DropdownMenuItem(value: a, child: Text('$a'))],
                onChanged: (v) => v == null ? null : setState(() => _freeUnder = v),
              ),
            ]),
            if (_error != null) Padding(padding: const EdgeInsets.only(top: 8), child: Text(_error!, style: TextStyle(color: theme.colorScheme.error))),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: _saving ? null : () => Navigator.of(context).pop(false), child: Text(l10n.commonCancel)),
        FilledButton(onPressed: _saving ? null : _save, child: Text(l10n.commonSave)),
      ],
    );
  }
}

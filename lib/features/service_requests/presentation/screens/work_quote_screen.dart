import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../core/time/egypt_time.dart';
import '../../../../core/time/local_format.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../location/presentation/widgets/location_picker_field.dart';
import '../../application/service_requests_providers.dart';
import 'service_request_detail_screen.dart';

/// «اطلب عرض سعر»: what he wants made or mended (kitchen in aluminium, a hundred boxes, an iron gate), how many, by when
/// and for how much at most, and which kind of workshop or factory should answer — his governorate's, or any in Egypt.
/// Each answers with a price and the days it needs; the one he picks becomes an appointment at the maker.
class WorkQuoteScreen extends ConsumerStatefulWidget {
  const WorkQuoteScreen({super.key});

  @override
  ConsumerState<WorkQuoteScreen> createState() => _WorkQuoteScreenState();
}

class _WorkQuoteScreenState extends ConsumerState<WorkQuoteScreen> {
  final _what = TextEditingController();
  final _details = TextEditingController();
  final _quantity = TextEditingController();
  final _unit = TextEditingController();
  final _price = TextEditingController();

  int? _tradeId;
  LocationSelection? _where;
  DateTime? _deadline;
  bool _nationwide = false;
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _what.dispose();
    _details.dispose();
    _quantity.dispose();
    _unit.dispose();
    _price.dispose();
    super.dispose();
  }

  Future<void> _pickDeadline() async {
    final now = EgyptTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: _deadline ?? now.add(const Duration(days: 14)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
    );
    if (date != null) setState(() => _deadline = date);
  }

  Future<void> _submit() async {
    final l10n = AppLocalizations.of(context)!;
    final trade = _tradeId;
    final where = _where;
    if (trade == null ||
        where == null ||
        _what.text.trim().length < 3 ||
        _details.text.trim().length < 10) {
      setState(() => _error = l10n.workQuoteRequired);
      return;
    }

    setState(() {
      _busy = true;
      _error = null;
    });

    try {
      final created = await ref
          .read(serviceRequestsApiProvider)
          .createWorkQuote(
            tradeId: trade,
            what: _what.text,
            details: _details.text,
            governorateId: where.governorateId,
            cityId: where.cityId,
            quantity: int.tryParse(_quantity.text.trim()),
            unit: _unit.text,
            deadline: _deadline,
            maxPrice: double.tryParse(_price.text.trim().replaceAll(',', '')),
            nationwide: _nationwide,
          );
      ref.invalidate(myServiceRequestsProvider);
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => ServiceRequestDetailScreen(requestId: created.id),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _busy = false;
        _error = e is ApiException ? e.message : l10n.commonSomethingWentWrong;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final trades = ref.watch(workTradesProvider).valueOrNull ?? const [];

    return Scaffold(
      appBar: AppBar(title: Text(l10n.workQuoteTitle)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            l10n.workQuoteIntro,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<int>(
            initialValue: trades.any((t) => t.id == _tradeId) ? _tradeId : null,
            isExpanded: true,
            decoration: InputDecoration(labelText: l10n.workQuoteTradeLabel),
            items: [
              for (final t in trades)
                DropdownMenuItem<int>(value: t.id, child: Text(t.name)),
            ],
            onChanged: (v) => setState(() => _tradeId = v),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _what,
            maxLength: 120,
            decoration: InputDecoration(labelText: l10n.workQuoteWhatLabel),
          ),
          TextField(
            controller: _details,
            maxLines: 4,
            maxLength: 2000,
            decoration: InputDecoration(labelText: l10n.workQuoteDetailsLabel),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _quantity,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: l10n.workQuoteQuantityLabel,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _unit,
                  maxLength: 30,
                  decoration: InputDecoration(
                    labelText: l10n.workQuoteUnitLabel,
                    counterText: '',
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: _pickDeadline,
            child: InputDecorator(
              decoration: InputDecoration(
                labelText: l10n.workQuoteDeadlineLabel,
                suffixIcon: _deadline == null
                    ? const Icon(Icons.event)
                    : IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => setState(() => _deadline = null),
                      ),
              ),
              child: Text(
                _deadline == null
                    ? '—'
                    : LocalFormat.date(context).format(_deadline!),
              ),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _price,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(labelText: l10n.homeServiceBudgetLabel),
          ),
          const SizedBox(height: 12),
          LocationPickerField(
            value: _where,
            onChanged: (v) => setState(() => _where = v),
          ),
          const SizedBox(height: 4),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            value: _nationwide,
            title: Text(l10n.workQuoteNationwide),
            subtitle: Text(l10n.workQuoteNationwideHelp),
            onChanged: (v) => setState(() => _nationwide = v),
          ),
          if (_error != null) ...[
            const SizedBox(height: 8),
            Text(
              _error!,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ],
          const SizedBox(height: 16),
          FilledButton(
            onPressed: _busy ? null : _submit,
            child: _busy
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(l10n.workQuoteSubmit),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../core/time/egypt_time.dart';
import '../../../../core/time/local_format.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../location/presentation/widgets/location_picker_field.dart';
import '../../application/service_requests_providers.dart';
import 'service_request_detail_screen.dart';

/// «أحتاج فنيًا»: the trade (plumber, electrician…), what is wrong, where (a city — never the address), when and the most
/// he would pay. Only the craftsmen of that trade in his governorate are told; each answers with his quote and the one he
/// picks becomes a visit appointment.
class HomeServiceScreen extends ConsumerStatefulWidget {
  const HomeServiceScreen({super.key});

  @override
  ConsumerState<HomeServiceScreen> createState() => _HomeServiceScreenState();
}

class _HomeServiceScreenState extends ConsumerState<HomeServiceScreen> {
  final _job = TextEditingController();
  final _price = TextEditingController();

  int? _tradeId;
  LocationSelection? _where;
  DateTime? _when;
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _job.dispose();
    _price.dispose();
    super.dispose();
  }

  Future<void> _pickTime() async {
    final now = EgyptTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: _when ?? now.add(const Duration(days: 1)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 30)),
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 10, minute: 0),
    );
    if (time == null) return;
    setState(
      () => _when = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      ),
    );
  }

  Future<void> _submit() async {
    final l10n = AppLocalizations.of(context)!;
    final trade = _tradeId;
    final where = _where;
    if (trade == null || where == null) {
      setState(() => _error = l10n.homeServiceTradeRequired);
      return;
    }
    if (_job.text.trim().length < 5) {
      setState(() => _error = l10n.homeServiceJobLabel);
      return;
    }

    setState(() {
      _busy = true;
      _error = null;
    });

    try {
      final created = await ref
          .read(serviceRequestsApiProvider)
          .createHomeService(
            tradeId: trade,
            governorateId: where.governorateId,
            cityId: where.cityId,
            details: _job.text,
            startsAt: _when,
            maxPrice: double.tryParse(_price.text.trim().replaceAll(',', '')),
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
    final trades = ref.watch(homeTradesProvider).valueOrNull ?? const [];

    return Scaffold(
      appBar: AppBar(title: Text(l10n.homeServiceTitle)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            l10n.homeServiceIntro,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<int>(
            initialValue: trades.any((t) => t.id == _tradeId) ? _tradeId : null,
            isExpanded: true,
            decoration: InputDecoration(labelText: l10n.homeServiceTradeLabel),
            items: [
              for (final t in trades)
                DropdownMenuItem<int>(value: t.id, child: Text(t.name)),
            ],
            onChanged: (v) => setState(() => _tradeId = v),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _job,
            maxLines: 4,
            maxLength: 1000,
            decoration: InputDecoration(labelText: l10n.homeServiceJobLabel),
          ),
          const SizedBox(height: 4),
          LocationPickerField(
            value: _where,
            onChanged: (v) => setState(() => _where = v),
          ),
          const SizedBox(height: 4),
          Text(
            l10n.homeServiceNoAddress,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 12),
          InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: _pickTime,
            child: InputDecorator(
              decoration: InputDecoration(
                labelText: l10n.homeServiceWhenLabel,
                suffixIcon: _when == null
                    ? const Icon(Icons.event)
                    : IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => setState(() => _when = null),
                      ),
              ),
              child: Text(
                _when == null
                    ? l10n.homeServiceAnyTime
                    : LocalFormat.dayDate(context).addClock().format(_when!),
              ),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _price,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(labelText: l10n.homeServiceBudgetLabel),
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
                : Text(l10n.homeServiceSubmit),
          ),
        ],
      ),
    );
  }
}

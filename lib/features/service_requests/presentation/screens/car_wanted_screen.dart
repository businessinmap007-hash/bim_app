import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../core/time/egypt_time.dart';
import '../../../../core/time/local_format.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../location/presentation/widgets/location_picker_field.dart';
import '../../application/service_requests_providers.dart';
import 'service_request_detail_screen.dart';

/// «أريد سيارة»: what he is after (buy or rent, the kind, the make, from which year, the most he will pay), where, and
/// when he could see one. The showrooms and private sellers of the governorate answer with what they have.
class CarWantedScreen extends ConsumerStatefulWidget {
  const CarWantedScreen({super.key});

  @override
  ConsumerState<CarWantedScreen> createState() => _CarWantedScreenState();
}

class _CarWantedScreenState extends ConsumerState<CarWantedScreen> {
  final _year = TextEditingController();
  final _price = TextEditingController();
  final _days = TextEditingController(text: '3');
  final _details = TextEditingController();

  String _deal = 'buy';
  int? _typeId;
  int? _brandId;
  LocationSelection? _where;
  DateTime? _viewing;
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _year.dispose();
    _price.dispose();
    _days.dispose();
    _details.dispose();
    super.dispose();
  }

  Future<void> _pickTime() async {
    final now = EgyptTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: _viewing ?? now.add(const Duration(days: 1)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 30)),
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 17, minute: 0),
    );
    if (time == null) return;
    setState(
      () => _viewing = DateTime(
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
    final where = _where;
    if (where == null) {
      setState(() => _error = l10n.carGovernorateRequired);
      return;
    }

    setState(() {
      _busy = true;
      _error = null;
    });

    try {
      final created = await ref
          .read(serviceRequestsApiProvider)
          .createCarWanted(
            deal: _deal,
            governorateId: where.governorateId,
            cityId: where.cityId,
            vehicleTypeOptionId: _typeId,
            brandOptionId: _brandId,
            yearMin: int.tryParse(_year.text.trim()),
            maxPrice: double.tryParse(_price.text.trim().replaceAll(',', '')),
            days: int.tryParse(_days.text.trim()),
            startsAt: _viewing,
            details: _details.text,
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
    final options = ref.watch(carOptionsProvider).valueOrNull;
    final rent = _deal == 'rent';

    return Scaffold(
      appBar: AppBar(title: Text(l10n.carWantedTitle)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            l10n.carWantedIntro,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          SegmentedButton<String>(
            segments: [
              ButtonSegment(value: 'buy', label: Text(l10n.carDealBuy)),
              ButtonSegment(value: 'rent', label: Text(l10n.carDealRent)),
            ],
            selected: {_deal},
            onSelectionChanged: (s) => setState(() => _deal = s.first),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<int?>(
            initialValue: _typeId,
            isExpanded: true,
            decoration: InputDecoration(labelText: l10n.carTypeLabel),
            items: [
              DropdownMenuItem<int?>(
                value: null,
                child: Text(l10n.carAnyChoice),
              ),
              for (final o in options?.vehicleTypes ?? const [])
                DropdownMenuItem<int?>(value: o.id, child: Text(o.name)),
            ],
            onChanged: (v) => setState(() => _typeId = v),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<int?>(
            initialValue: _brandId,
            isExpanded: true,
            decoration: InputDecoration(labelText: l10n.carBrandLabel),
            items: [
              DropdownMenuItem<int?>(
                value: null,
                child: Text(l10n.carAnyChoice),
              ),
              for (final o in options?.brands ?? const [])
                DropdownMenuItem<int?>(value: o.id, child: Text(o.name)),
            ],
            onChanged: (v) => setState(() => _brandId = v),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _year,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: l10n.carYearMinLabel),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _price,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: InputDecoration(
                    labelText: rent
                        ? l10n.carMaxPriceRent
                        : l10n.carMaxPriceBuy,
                  ),
                ),
              ),
            ],
          ),
          if (rent) ...[
            const SizedBox(height: 12),
            TextField(
              controller: _days,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: l10n.carDaysLabel),
            ),
          ],
          const SizedBox(height: 16),
          LocationPickerField(
            value: _where,
            onChanged: (v) => setState(() => _where = v),
          ),
          const SizedBox(height: 12),
          InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: _pickTime,
            child: InputDecorator(
              decoration: InputDecoration(
                labelText: l10n.carViewingWhen,
                suffixIcon: _viewing == null
                    ? const Icon(Icons.event)
                    : IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => setState(() => _viewing = null),
                      ),
              ),
              child: Text(
                _viewing == null
                    ? '—'
                    : LocalFormat.dayDate(context).addClock().format(_viewing!),
              ),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _details,
            maxLines: 3,
            maxLength: 1000,
            decoration: InputDecoration(labelText: l10n.rideDetailsLabel),
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
                : Text(l10n.carWantedSubmit),
          ),
        ],
      ),
    );
  }
}

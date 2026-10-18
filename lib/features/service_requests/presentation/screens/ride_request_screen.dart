import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../core/time/egypt_time.dart';
import '../../../../core/time/local_format.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../empty_returns/presentation/widgets/empty_returns_section.dart';
import '../../../location/presentation/widgets/location_picker_field.dart';
import '../../application/service_requests_providers.dart';
import '../../data/service_requests_api.dart';
import 'service_request_detail_screen.dart';

/// «اطلب ليموزين»: a city each way (no map), how many, when, and the price he offers. The drivers of the pick-up
/// governorate are told and answer with their own prices — see Api\V2\ServiceRequestController.
class RideRequestScreen extends ConsumerStatefulWidget {
  const RideRequestScreen({super.key});

  @override
  ConsumerState<RideRequestScreen> createState() => _RideRequestScreenState();
}

class _RideRequestScreenState extends ConsumerState<RideRequestScreen> {
  final _price = TextEditingController();
  final _distance = TextEditingController();
  final _details = TextEditingController();

  LocationSelection? _from;
  LocationSelection? _to;
  int _passengers = 1;
  DateTime? _startsAt;
  RideQuoteResult? _quote;
  bool _priceTouched = false;
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _price.dispose();
    _distance.dispose();
    _details.dispose();
    super.dispose();
  }

  Future<void> _requote() async {
    final from = _from;
    final to = _to;
    if (from == null || to == null) return;

    try {
      final quote = await ref
          .read(serviceRequestsApiProvider)
          .quote(
            originCityId: from.cityId,
            destinationCityId: to.cityId,
            distanceKm: double.tryParse(_distance.text.trim()),
          );
      if (!mounted) return;
      setState(() {
        _quote = quote;
        if (!_priceTouched && quote.suggestedPrice != null) {
          _price.text = quote.suggestedPrice!.toStringAsFixed(0);
        }
      });
    } catch (_) {
      // an unreadable quote only leaves the price empty; posting still validates on the server
    }
  }

  Future<void> _pickTime() async {
    final now = EgyptTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: _startsAt ?? now,
      firstDate: now,
      lastDate: now.add(const Duration(days: 30)),
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(
        _startsAt ?? now.add(const Duration(hours: 1)),
      ),
    );
    if (time == null) return;
    setState(
      () => _startsAt = DateTime(
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
    final from = _from;
    final to = _to;
    if (from == null || to == null) {
      setState(() => _error = l10n.rideFieldsRequired);
      return;
    }

    setState(() {
      _busy = true;
      _error = null;
    });

    try {
      final created = await ref
          .read(serviceRequestsApiProvider)
          .createRide(
            origin: RidePlace(
              governorateId: from.governorateId,
              cityId: from.cityId,
              label: from.label,
            ),
            destination: RidePlace(
              governorateId: to.governorateId,
              cityId: to.cityId,
              label: to.label,
            ),
            passengers: _passengers,
            startsAt: _startsAt,
            price: double.tryParse(_price.text.trim()),
            distanceKm: double.tryParse(_distance.text.trim()),
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
    final quote = _quote;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.rideRequestTitle)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            l10n.rideRequestIntro,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          Text(
            l10n.rideFromLabel,
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 8),
          LocationPickerField(
            value: _from,
            onChanged: (v) {
              setState(() => _from = v);
              _requote();
            },
          ),
          const SizedBox(height: 16),
          Text(l10n.rideToLabel, style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 8),
          LocationPickerField(
            value: _to,
            onChanged: (v) {
              setState(() => _to = v);
              _requote();
            },
          ),
          if (quote != null && quote.needsDistance) ...[
            const SizedBox(height: 12),
            Text(
              l10n.rideDistanceNeeded,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _distance,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: InputDecoration(labelText: l10n.rideDistanceLabel),
              onChanged: (_) => _requote(),
            ),
          ],
          if (quote != null && quote.known) ...[
            const SizedBox(height: 12),
            Text(
              l10n.rideDistanceKm((quote.distanceKm ?? 0).toStringAsFixed(0)),
            ),
          ],
          // the drivers going back empty on this very line, at a lower price (booked as an ordinary trip reservation)
          if (_from != null && _to != null && _from!.cityId != _to!.cityId)
            EmptyReturnsSection(fromCityId: _from!.cityId, toCityId: _to!.cityId),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Text(
                  l10n.ridePassengersLabel,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              ),
              IconButton(
                onPressed: _passengers > 1
                    ? () => setState(() => _passengers--)
                    : null,
                icon: const Icon(Icons.remove_circle_outline),
              ),
              Text('$_passengers'),
              IconButton(
                onPressed: _passengers < 30
                    ? () => setState(() => _passengers++)
                    : null,
                icon: const Icon(Icons.add_circle_outline),
              ),
            ],
          ),
          const SizedBox(height: 8),
          InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: _pickTime,
            child: InputDecorator(
              decoration: InputDecoration(
                labelText: l10n.rideWhenLabel,
                suffixIcon: _startsAt == null
                    ? const Icon(Icons.schedule)
                    : IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => setState(() => _startsAt = null),
                      ),
              ),
              child: Text(
                _startsAt == null
                    ? l10n.rideWhenNow
                    : LocalFormat.dayDate(
                        context,
                      ).addClock().format(_startsAt!),
              ),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _price,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: l10n.ridePriceLabel,
              helperText: quote?.suggestedPrice == null
                  ? null
                  : l10n.rideSuggestedPrice(
                      quote!.suggestedPrice!.toStringAsFixed(0),
                    ),
            ),
            onChanged: (_) => _priceTouched = true,
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
                : Text(l10n.rideSubmit),
          ),
        ],
      ),
    );
  }
}

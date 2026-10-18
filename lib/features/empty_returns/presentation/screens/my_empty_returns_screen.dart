import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../core/time/egypt_time.dart';
import '../../../../core/time/local_format.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../location/presentation/widgets/location_picker_field.dart';
import '../../application/empty_returns_providers.dart';
import '../../data/empty_returns_api.dart';

/// «راجع فاضي» for the limousine driver: he publishes the way home at a price he sets (never above the usual fare of
/// that distance) and sees, below, what he has published. The customers asking for that ride are shown it and book it.
class MyEmptyReturnsScreen extends ConsumerStatefulWidget {
  const MyEmptyReturnsScreen({super.key});

  @override
  ConsumerState<MyEmptyReturnsScreen> createState() =>
      _MyEmptyReturnsScreenState();
}

class _MyEmptyReturnsScreenState extends ConsumerState<MyEmptyReturnsScreen> {
  final _price = TextEditingController();
  final _distance = TextEditingController();
  final _notes = TextEditingController();

  LocationSelection? _from;
  LocationSelection? _to;
  DateTime? _departsAt;
  int _seats = 4;
  EmptyReturnQuote? _quote;
  bool _priceTouched = false;
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _price.dispose();
    _distance.dispose();
    _notes.dispose();
    super.dispose();
  }

  Future<void> _requote() async {
    final from = _from;
    final to = _to;
    if (from == null || to == null || from.cityId == to.cityId) {
      setState(() => _quote = null);
      return;
    }

    try {
      final quote = await ref
          .read(emptyReturnsApiProvider)
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
      // an unreadable quote only leaves the price empty; publishing still validates on the server
    }
  }

  Future<void> _pickTime() async {
    final now = EgyptTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: _departsAt ?? now,
      firstDate: now,
      lastDate: now.add(const Duration(days: 3)),
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(
        _departsAt ?? now.add(const Duration(hours: 1)),
      ),
    );
    if (time == null) return;
    setState(
      () => _departsAt = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      ),
    );
  }

  Future<void> _publish() async {
    final l10n = AppLocalizations.of(context)!;
    final from = _from;
    final to = _to;
    final when = _departsAt;
    final price = double.tryParse(_price.text.trim());

    if (from == null || to == null || from.cityId == to.cityId) {
      setState(() => _error = l10n.emptyReturnChooseCities);
      return;
    }
    if (when == null) {
      setState(() => _error = l10n.emptyReturnChooseWhen);
      return;
    }
    if (price == null || price < 1) {
      setState(() => _error = l10n.ridePriceLabel);
      return;
    }

    setState(() {
      _busy = true;
      _error = null;
    });

    try {
      await ref
          .read(emptyReturnsApiProvider)
          .publish(
            originCityId: from.cityId,
            destinationCityId: to.cityId,
            departsAt: when,
            price: price,
            seats: _seats,
            distanceKm: double.tryParse(_distance.text.trim()),
            notes: _notes.text,
          );
      ref.invalidate(myEmptyReturnsProvider);
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.emptyReturnPublished)));
      setState(() {
        _busy = false;
        _departsAt = null;
        _notes.clear();
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _busy = false;
        _error = e is ApiException ? e.message : l10n.commonSomethingWentWrong;
      });
    }
  }

  Future<void> _cancel(EmptyReturnOffer offer) async {
    final l10n = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.of(context);
    try {
      await ref.read(emptyReturnsApiProvider).cancel(offer.id);
      ref.invalidate(myEmptyReturnsProvider);
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.emptyReturnCancelled)),
      );
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            e is ApiException ? e.message : l10n.commonSomethingWentWrong,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final quote = _quote;
    final mine = ref.watch(myEmptyReturnsProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.emptyReturnTitle)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(l10n.emptyReturnDriverIntro, style: theme.textTheme.bodyMedium),
          const SizedBox(height: 16),
          Text(
            l10n.emptyReturnPublishTitle,
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          Text(l10n.emptyReturnFrom, style: theme.textTheme.titleSmall),
          const SizedBox(height: 8),
          LocationPickerField(
            value: _from,
            onChanged: (v) {
              setState(() => _from = v);
              _requote();
            },
          ),
          const SizedBox(height: 12),
          Text(l10n.emptyReturnTo, style: theme.textTheme.titleSmall),
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
            Text(l10n.rideDistanceNeeded, style: theme.textTheme.bodySmall),
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
          const SizedBox(height: 12),
          InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: _pickTime,
            child: InputDecorator(
              decoration: InputDecoration(
                labelText: l10n.emptyReturnWhen,
                suffixIcon: const Icon(Icons.schedule),
              ),
              child: Text(
                _departsAt == null
                    ? '—'
                    : LocalFormat.dayDate(
                        context,
                      ).addClock().format(_departsAt!),
              ),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _price,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: l10n.emptyReturnPriceLabel,
              helperText:
                  quote?.suggestedPrice == null || quote?.referencePrice == null
                  ? null
                  : l10n.emptyReturnPriceHelp(
                      quote!.suggestedPrice!.toStringAsFixed(0),
                      quote.referencePrice!.toStringAsFixed(0),
                    ),
              helperMaxLines: 3,
            ),
            onChanged: (_) => _priceTouched = true,
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Text(
                  l10n.emptyReturnSeatsLabel,
                  style: theme.textTheme.titleSmall,
                ),
              ),
              IconButton(
                onPressed: _seats > 1 ? () => setState(() => _seats--) : null,
                icon: const Icon(Icons.remove_circle_outline),
              ),
              Text('$_seats'),
              IconButton(
                onPressed: _seats < 30 ? () => setState(() => _seats++) : null,
                icon: const Icon(Icons.add_circle_outline),
              ),
            ],
          ),
          TextField(
            controller: _notes,
            maxLines: 2,
            maxLength: 500,
            decoration: InputDecoration(labelText: l10n.emptyReturnNotesLabel),
          ),
          if (_error != null) ...[
            const SizedBox(height: 8),
            Text(_error!, style: TextStyle(color: theme.colorScheme.error)),
          ],
          const SizedBox(height: 12),
          FilledButton(
            onPressed: _busy ? null : _publish,
            child: _busy
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(l10n.emptyReturnPublish),
          ),
          const SizedBox(height: 24),
          Text(l10n.emptyReturnMineTitle, style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          mine.when(
            loading: () => const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (_, _) => Text(l10n.commonSomethingWentWrong),
            data: (list) => list.isEmpty
                ? Text(l10n.emptyReturnNone, style: theme.textTheme.bodySmall)
                : Column(
                    children: [
                      for (final offer in list)
                        _MineTile(offer: offer, onCancel: () => _cancel(offer)),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

class _MineTile extends StatelessWidget {
  final EmptyReturnOffer offer;
  final VoidCallback onCancel;

  const _MineTile({required this.offer, required this.onCancel});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final cancelled = offer.status == 'cancelled';
    final status = cancelled
        ? l10n.emptyReturnStatusCancelled
        : (offer.isAhead
              ? l10n.emptyReturnStatusLive
              : l10n.emptyReturnStatusPassed);
    final when = offer.departsAt == null
        ? ''
        : LocalFormat.dayDate(context).addClock().format(offer.departsAt!);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Column(
        children: [
          ListTile(
            title: Text('${offer.originCity} ← ${offer.destinationCity}'),
            subtitle: Text(
              '$when · ${l10n.emptyReturnPriceEgp(offer.price.toStringAsFixed(0))}\n$status',
            ),
            isThreeLine: true,
          ),
          // below the title: a long city pair must not be squeezed by the button
          if (!cancelled && offer.isAhead)
            Align(
              alignment: AlignmentDirectional.centerEnd,
              child: TextButton(
                onPressed: onCancel,
                child: Text(
                  l10n.emptyReturnCancel,
                  style: TextStyle(color: theme.colorScheme.error),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

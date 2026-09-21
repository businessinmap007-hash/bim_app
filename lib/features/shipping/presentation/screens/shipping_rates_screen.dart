import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/widgets/async_value_view.dart';
import '../../application/shipping_providers.dart';
import '../../data/shipping_api.dart';

/// A Shipping & Delivery company's fixed price - and the weekdays it runs - from
/// its own governorate to every other one. A blank price means "we don't ship
/// there"; no day picked means every day. A merchant only sees a company
/// running the route today or tomorrow.
class ShippingRatesScreen extends ConsumerStatefulWidget {
  const ShippingRatesScreen({super.key});

  @override
  ConsumerState<ShippingRatesScreen> createState() => _ShippingRatesScreenState();
}

class _ShippingRatesScreenState extends ConsumerState<ShippingRatesScreen> {
  final Map<int, TextEditingController> _prices = {};
  final Map<int, Set<int>> _days = {};
  bool _saving = false;

  TextEditingController _priceFor(ShippingRateRow row) {
    return _prices.putIfAbsent(
      row.governorateId,
      () => TextEditingController(text: row.price == null ? '' : (row.price! == row.price!.roundToDouble() ? row.price!.toStringAsFixed(0) : '${row.price}')),
    );
  }

  Set<int> _daysFor(ShippingRateRow row) => _days.putIfAbsent(row.governorateId, () => {...?row.days});

  @override
  void dispose() {
    for (final c in _prices.values) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context)!;
    final rates = <int, ({double? price, List<int>? days})>{
      for (final e in _prices.entries)
        e.key: (
          price: e.value.text.trim().isEmpty ? null : double.tryParse(e.value.text.trim()),
          days: (_days[e.key] ?? const <int>{}).isEmpty ? null : (_days[e.key]!.toList()..sort()),
        ),
    };
    setState(() => _saving = true);
    try {
      await ref.read(shippingApiProvider).saveRates(rates);
      ref.invalidate(shippingRatesProvider);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.shippingSaved)));
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e is ApiException ? e.message : l10n.commonSomethingWentWrong)),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context);
    final isEnglish = locale.languageCode == 'en';
    final async = ref.watch(shippingRatesProvider);
    // 2024-01-07 was a Sunday, so day 0 = Sunday ... 6 = Saturday.
    String dayName(int d) => DateFormat.E(locale.toString()).format(DateTime(2024, 1, 7 + d));

    return Scaffold(
      appBar: AppBar(title: Text(l10n.shippingRatesTitle)),
      body: AsyncValueView<List<ShippingRateRow>>(
        value: async,
        onRetry: () => ref.invalidate(shippingRatesProvider),
        builder: (context, rows) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(l10n.shippingRatesHint, style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 12),
            for (final row in rows)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(child: Text(isEnglish && row.nameEn.isNotEmpty ? row.nameEn : row.nameAr, style: Theme.of(context).textTheme.titleSmall)),
                        SizedBox(
                          width: 110,
                          child: TextField(
                            controller: _priceFor(row),
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            decoration: const InputDecoration(isDense: true),
                          ),
                        ),
                      ],
                    ),
                    Wrap(
                      spacing: 6,
                      children: [
                        for (final d in const [6, 0, 1, 2, 3, 4, 5])
                          FilterChip(
                            label: Text(dayName(d), style: const TextStyle(fontSize: 11)),
                            visualDensity: VisualDensity.compact,
                            selected: _daysFor(row).contains(d),
                            onSelected: (on) => setState(() => on ? _daysFor(row).add(d) : _daysFor(row).remove(d)),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 4),
            Text(l10n.shippingDaysHint, style: TextStyle(color: Theme.of(context).hintColor, fontSize: 12)),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: _saving ? null : _save,
              child: _saving
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                  : Text(l10n.commonSave),
            ),
          ],
        ),
      ),
    );
  }
}

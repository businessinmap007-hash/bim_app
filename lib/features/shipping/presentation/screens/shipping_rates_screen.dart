import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/widgets/async_value_view.dart';
import '../../application/shipping_providers.dart';
import '../../data/shipping_api.dart';

/// A Shipping & Delivery company's fixed price from its own governorate to
/// every other one. A blank field means "we don't ship there".
class ShippingRatesScreen extends ConsumerStatefulWidget {
  const ShippingRatesScreen({super.key});

  @override
  ConsumerState<ShippingRatesScreen> createState() => _ShippingRatesScreenState();
}

class _ShippingRatesScreenState extends ConsumerState<ShippingRatesScreen> {
  final Map<int, TextEditingController> _controllers = {};
  bool _saving = false;

  TextEditingController _controllerFor(ShippingRateRow row) {
    return _controllers.putIfAbsent(
      row.governorateId,
      () => TextEditingController(text: row.price == null ? '' : (row.price! == row.price!.roundToDouble() ? row.price!.toStringAsFixed(0) : '${row.price}')),
    );
  }

  @override
  void dispose() {
    for (final c in _controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context)!;
    final prices = <int, double?>{
      for (final e in _controllers.entries) e.key: e.value.text.trim().isEmpty ? null : double.tryParse(e.value.text.trim()),
    };
    setState(() => _saving = true);
    try {
      await ref.read(shippingApiProvider).saveRates(prices);
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
    final isEnglish = Localizations.localeOf(context).languageCode == 'en';
    final async = ref.watch(shippingRatesProvider);

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
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Expanded(child: Text(isEnglish && row.nameEn.isNotEmpty ? row.nameEn : row.nameAr)),
                    SizedBox(
                      width: 110,
                      child: TextField(
                        controller: _controllerFor(row),
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: const InputDecoration(isDense: true),
                      ),
                    ),
                  ],
                ),
              ),
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

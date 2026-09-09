import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../l10n/app_localizations.dart';
import '../../application/market_catalog_providers.dart';
import '../../data/models/market_catalog_group.dart';

/// One section's worth of rows («فاكهة», «خضار»...), each already named from
/// the platform's vocabulary — the merchant only fills price/quantity/brand
/// per row, then saves the whole section in one request.
class MarketCatalogGroupScreen extends ConsumerStatefulWidget {
  final int groupId;
  const MarketCatalogGroupScreen({super.key, required this.groupId});

  @override
  ConsumerState<MarketCatalogGroupScreen> createState() => _MarketCatalogGroupScreenState();
}

class _MarketCatalogGroupScreenState extends ConsumerState<MarketCatalogGroupScreen> {
  final Map<int, TextEditingController> _quantity = {};
  final Map<int, TextEditingController> _supplyPrice = {};
  final Map<int, TextEditingController> _basePrice = {};
  final Map<int, TextEditingController> _brandName = {};
  final Map<int, String?> _saleUnit = {};
  bool _initialized = false;
  bool _saving = false;

  void _initControllers(MarketCatalogGroup group) {
    if (_initialized) return;
    for (final row in group.rows) {
      _quantity[row.optionId] = TextEditingController(text: row.item?.availableQuantity?.toString() ?? '');
      _supplyPrice[row.optionId] = TextEditingController(text: row.item?.supplyPrice?.toString() ?? '');
      _basePrice[row.optionId] = TextEditingController(text: row.item?.basePrice?.toString() ?? '');
      _brandName[row.optionId] = TextEditingController(text: row.item?.brandName ?? '');
      _saleUnit[row.optionId] = row.item?.saleUnit;
    }
    _initialized = true;
  }

  @override
  void dispose() {
    for (final c in [..._quantity.values, ..._supplyPrice.values, ..._basePrice.values, ..._brandName.values]) {
      c.dispose();
    }
    super.dispose();
  }

  double? _parseDouble(String text) => text.trim().isEmpty ? null : double.tryParse(text.trim());
  int? _parseInt(String text) => text.trim().isEmpty ? null : int.tryParse(text.trim());

  Future<void> _save(MarketCatalogGroup group) async {
    final l10n = AppLocalizations.of(context)!;
    setState(() => _saving = true);

    final rows = <int, ({int? quantity, double? supplyPrice, double? basePrice, String? saleUnit, String? brandName})>{};
    for (final row in group.rows) {
      rows[row.optionId] = (
        quantity: _parseInt(_quantity[row.optionId]!.text),
        supplyPrice: _parseDouble(_supplyPrice[row.optionId]!.text),
        basePrice: _parseDouble(_basePrice[row.optionId]!.text),
        saleUnit: _saleUnit[row.optionId],
        brandName: _brandName[row.optionId]!.text.trim().isEmpty ? null : _brandName[row.optionId]!.text.trim(),
      );
    }

    try {
      final result = await ref.read(marketCatalogControllerProvider.notifier).saveGroup(widget.groupId, rows);
      if (!mounted) return;
      setState(() => _saving = false);
      final message = l10n.marketCatalogSaved(result.saved) + (result.cleared > 0 ? l10n.marketCatalogCleared(result.cleared) : '');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
    } catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.commonSomethingWentWrong)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final languageCode = Localizations.localeOf(context).languageCode;
    final catalog = ref.watch(marketCatalogControllerProvider).value;
    final group = catalog?.groups.where((g) => g.groupId == widget.groupId).firstOrNull;

    if (group == null) {
      return Scaffold(appBar: AppBar(), body: const SizedBox.shrink());
    }

    _initControllers(group);

    final margin = catalog?.defaultMarginPercent;

    return Scaffold(
      appBar: AppBar(
        title: Text(group.name(languageCode)),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Center(
              child: _saving
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                  : TextButton(onPressed: () => _save(group), child: Text(l10n.marketCatalogSave)),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          if (margin != null)
            Container(
              width: double.infinity,
              color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.4),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                l10n.marketCatalogDefaultMargin(margin.toStringAsFixed(margin == margin.roundToDouble() ? 0 : 1)),
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(12),
              itemCount: group.rows.length,
              separatorBuilder: (context, index) => const Divider(height: 24),
              itemBuilder: (context, index) {
                final row = group.rows[index];
                return _RowEditor(
                  title: row.name(languageCode),
                  quantityController: _quantity[row.optionId]!,
                  supplyPriceController: _supplyPrice[row.optionId]!,
                  basePriceController: _basePrice[row.optionId]!,
                  brandNameController: _brandName[row.optionId]!,
                  saleUnit: _saleUnit[row.optionId],
                  saleUnits: catalog?.saleUnits ?? const [],
                  isPriced: row.item != null,
                  onUnitChanged: (value) => setState(() => _saleUnit[row.optionId] = value),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _RowEditor extends StatelessWidget {
  final String title;
  final TextEditingController quantityController;
  final TextEditingController supplyPriceController;
  final TextEditingController basePriceController;
  final TextEditingController brandNameController;
  final String? saleUnit;
  final List<SaleUnitOption> saleUnits;
  final bool isPriced;
  final ValueChanged<String?> onUnitChanged;

  const _RowEditor({
    required this.title,
    required this.quantityController,
    required this.supplyPriceController,
    required this.basePriceController,
    required this.brandNameController,
    required this.saleUnit,
    required this.saleUnits,
    required this.isPriced,
    required this.onUnitChanged,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            if (isPriced) const Padding(padding: EdgeInsets.only(left: 6), child: Icon(Icons.check_circle, size: 16, color: Colors.green)),
            Expanded(child: Text(title, style: const TextStyle(fontWeight: FontWeight.w700))),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: brandNameController,
                decoration: InputDecoration(labelText: l10n.marketCatalogBrand, isDense: true, border: const OutlineInputBorder()),
              ),
            ),
            const SizedBox(width: 8),
            SizedBox(
              width: 110,
              child: TextField(
                controller: quantityController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: InputDecoration(labelText: l10n.marketCatalogQuantity, isDense: true, border: const OutlineInputBorder()),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: supplyPriceController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}'))],
                decoration: InputDecoration(labelText: l10n.marketCatalogSupplyPrice, isDense: true, border: const OutlineInputBorder()),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: basePriceController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}'))],
                decoration: InputDecoration(labelText: l10n.marketCatalogSalePrice, isDense: true, border: const OutlineInputBorder()),
              ),
            ),
            const SizedBox(width: 8),
            SizedBox(
              width: 130,
              child: DropdownButtonFormField<String>(
                initialValue: saleUnit != null && saleUnits.any((u) => u.code == saleUnit) ? saleUnit : null,
                isExpanded: true,
                decoration: InputDecoration(labelText: l10n.marketCatalogUnit, isDense: true, border: const OutlineInputBorder()),
                items: saleUnits.map((u) => DropdownMenuItem(value: u.code, child: Text(u.label, overflow: TextOverflow.ellipsis))).toList(),
                onChanged: onUnitChanged,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../offers/data/models/commercial_offer.dart';
import '../../application/business_offers_providers.dart';
import '../../data/models/offerable_item.dart';

const _offerableTypes = ['menu_item', 'product', 'service'];
const _endModeDate = 'date';
const _endModeStock = 'while_stock';
const _endModeLimited = 'limited';

/// Create or edit one commercial offer (Api\V2\BusinessOfferController). Only
/// the three "priced row" offerable types are supported here (menu item,
/// retail product, service price) — see OfferableResolver on the backend,
/// which is the only thing that ever prices `bookable_item`/`package`
/// offers, through their own booking/package screens instead of a flat
/// final_price.
class OfferFormScreen extends ConsumerStatefulWidget {
  final CommercialOffer? existing;
  const OfferFormScreen({super.key, this.existing});

  @override
  ConsumerState<OfferFormScreen> createState() => _OfferFormScreenState();
}

class _OfferFormScreenState extends ConsumerState<OfferFormScreen> {
  String _offerableType = 'menu_item';
  OfferableItem? _item;
  final _titleCtrl = TextEditingController();
  final _finalPriceCtrl = TextEditingController();
  String _endMode = _endModeDate;
  DateTime? _endsAt;
  final _quantityCtrl = TextEditingController();
  bool _isRefundable = false;

  bool _saving = false;
  String? _error;

  bool get _isEdit => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final existing = widget.existing;
    if (existing != null) {
      _offerableType = existing.offerableType;
      _item = OfferableItem(
        id: existing.offerableId,
        label: existing.title('ar'),
        price: existing.basePrice ?? existing.finalPrice,
        currency: existing.currency,
      );
      _titleCtrl.text = existing.titleAr;
      _finalPriceCtrl.text = _trimNum(existing.finalPrice);
      _isRefundable = false;
      if (existing.availabilityMode == 'while_stock_lasts') {
        _endMode = _endModeStock;
      } else if (existing.availabilityMode == 'limited_quantity') {
        _endMode = _endModeLimited;
        _quantityCtrl.text = existing.availableQuantity?.toString() ?? '';
      } else {
        _endMode = _endModeDate;
        _endsAt = existing.endsAt;
      }
    }
  }

  String _trimNum(double v) => v == v.roundToDouble() ? v.toInt().toString() : v.toString();

  @override
  void dispose() {
    _titleCtrl.dispose();
    _finalPriceCtrl.dispose();
    _quantityCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickItem() async {
    final picked = await showModalBottomSheet<OfferableItem>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) => _ItemPickerSheet(offerableType: _offerableType),
    );
    if (picked != null) setState(() => _item = picked);
  }

  Future<void> _pickEndDate() async {
    final l10n = AppLocalizations.of(context)!;
    final picked = await showDatePicker(
      context: context,
      initialDate: _endsAt ?? DateTime.now().add(const Duration(days: 7)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      helpText: l10n.businessOfferEndsAtLabel,
    );
    if (picked != null) setState(() => _endsAt = picked);
  }

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context)!;
    final item = _item;
    if (item == null) {
      setState(() => _error = l10n.businessOfferPickItemFirst);
      return;
    }
    final finalPrice = double.tryParse(_finalPriceCtrl.text.trim());
    if (finalPrice == null || finalPrice <= 0) {
      setState(() => _error = l10n.validationRequired);
      return;
    }
    if (finalPrice >= item.price) {
      setState(() => _error = l10n.businessOfferPriceTooHigh(item.price.toStringAsFixed(2), item.currency));
      return;
    }
    int? quantity;
    if (_endMode == _endModeLimited) {
      quantity = int.tryParse(_quantityCtrl.text.trim());
      if (quantity == null || quantity <= 0) {
        setState(() => _error = l10n.validationRequired);
        return;
      }
    }
    if (_endMode == _endModeDate && _endsAt == null) {
      setState(() => _error = l10n.businessOfferPickEndDate);
      return;
    }

    setState(() {
      _saving = true;
      _error = null;
    });

    final availabilityMode = switch (_endMode) {
      _endModeStock => 'while_stock_lasts',
      _endModeLimited => 'limited_quantity',
      _ => 'instant',
    };

    final api = ref.read(businessOffersApiProvider);
    try {
      if (_isEdit) {
        await api.update(
          widget.existing!.id,
          offerableType: _offerableType,
          offerableId: item.id,
          finalPrice: finalPrice,
          availabilityMode: availabilityMode,
          availableQuantity: quantity,
          endsAt: _endMode == _endModeDate ? _endsAt : null,
          isRefundable: _isRefundable,
          titleAr: _titleCtrl.text.trim().isEmpty ? item.label : _titleCtrl.text.trim(),
        );
      } else {
        await api.create(
          offerableType: _offerableType,
          offerableId: item.id,
          finalPrice: finalPrice,
          availabilityMode: availabilityMode,
          availableQuantity: quantity,
          endsAt: _endMode == _endModeDate ? _endsAt : null,
          isRefundable: _isRefundable,
          titleAr: _titleCtrl.text.trim().isEmpty ? item.label : _titleCtrl.text.trim(),
        );
      }
      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      setState(() {
        _saving = false;
        _error = e is ApiException ? e.message : l10n.commonSomethingWentWrong;
      });
    }
  }

  String _typeLabel(AppLocalizations l10n, String type) => switch (type) {
    'menu_item' => l10n.businessOfferTypeMenuItem,
    'product' => l10n.businessOfferTypeProduct,
    'service' => l10n.businessOfferTypeService,
    _ => type,
  };

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final item = _item;

    return Scaffold(
      appBar: AppBar(title: Text(_isEdit ? l10n.businessOfferEditTitle : l10n.businessOfferAddTitle)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.businessOfferTypeLabel, style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                for (final type in _offerableTypes)
                  ChoiceChip(
                    label: Text(_typeLabel(l10n, type)),
                    selected: _offerableType == type,
                    onSelected: _isEdit
                        ? null
                        : (_) => setState(() {
                            _offerableType = type;
                            _item = null;
                          }),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: _pickItem,
              icon: const Icon(Icons.search),
              label: Text(item?.label ?? l10n.businessOfferPickItem),
            ),
            if (item != null) ...[
              const SizedBox(height: 4),
              Text(
                l10n.businessOfferCurrentPrice(item.price.toStringAsFixed(2), item.currency),
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
            const SizedBox(height: 16),
            TextField(
              controller: _titleCtrl,
              decoration: InputDecoration(labelText: l10n.businessOfferTitleLabel, hintText: item?.label),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _finalPriceCtrl,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(labelText: l10n.businessOfferFinalPriceLabel),
            ),
            const SizedBox(height: 16),
            Text(l10n.businessOfferEndConditionLabel, style: Theme.of(context).textTheme.labelLarge),
            RadioListTile<String>(
              contentPadding: EdgeInsets.zero,
              value: _endModeDate,
              groupValue: _endMode,
              title: Text(l10n.businessOfferEndsAtLabel),
              subtitle: _endMode == _endModeDate
                  ? Text(_endsAt != null ? '${_endsAt!.year}-${_endsAt!.month.toString().padLeft(2, '0')}-${_endsAt!.day.toString().padLeft(2, '0')}' : l10n.businessOfferPickEndDate)
                  : null,
              onChanged: (v) => setState(() => _endMode = v!),
            ),
            if (_endMode == _endModeDate)
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: TextButton(onPressed: _pickEndDate, child: Text(l10n.businessOfferPickEndDate)),
              ),
            RadioListTile<String>(
              contentPadding: EdgeInsets.zero,
              value: _endModeStock,
              groupValue: _endMode,
              title: Text(l10n.businessOfferWhileStockLasts),
              onChanged: (v) => setState(() => _endMode = v!),
            ),
            RadioListTile<String>(
              contentPadding: EdgeInsets.zero,
              value: _endModeLimited,
              groupValue: _endMode,
              title: Text(l10n.businessOfferLimitedQuantity),
              onChanged: (v) => setState(() => _endMode = v!),
            ),
            if (_endMode == _endModeLimited)
              TextField(
                controller: _quantityCtrl,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: l10n.businessOfferQuantityLabel),
              ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              value: _isRefundable,
              onChanged: (v) => setState(() => _isRefundable = v),
              title: Text(l10n.businessOfferRefundableLabel),
            ),
            if (_error != null) ...[
              const SizedBox(height: 12),
              Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
            ],
            const SizedBox(height: 20),
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

class _ItemPickerSheet extends ConsumerStatefulWidget {
  final String offerableType;
  const _ItemPickerSheet({required this.offerableType});

  @override
  ConsumerState<_ItemPickerSheet> createState() => _ItemPickerSheetState();
}

class _ItemPickerSheetState extends ConsumerState<_ItemPickerSheet> {
  final _searchCtrl = TextEditingController();
  final _scrollController = ScrollController();
  List<OfferableItem> _items = const [];
  bool _loading = true;
  bool _loadingMore = false;
  bool _hasMore = false;
  int _page = 1;

  @override
  void initState() {
    super.initState();
    _load();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
        _loadMore();
      }
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    _page = 1;
    final result = await ref
        .read(offerableItemsApiProvider)
        .fetch(widget.offerableType, q: _searchCtrl.text.trim(), page: _page);
    if (!mounted) return;
    setState(() {
      _items = result.items;
      _hasMore = result.hasMore;
      _loading = false;
    });
  }

  Future<void> _loadMore() async {
    if (_loadingMore || !_hasMore) return;
    setState(() => _loadingMore = true);
    final result = await ref
        .read(offerableItemsApiProvider)
        .fetch(widget.offerableType, q: _searchCtrl.text.trim(), page: _page + 1);
    if (!mounted) return;
    _page += 1;
    setState(() {
      _items = [..._items, ...result.items];
      _hasMore = result.hasMore;
      _loadingMore = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return SafeArea(
      child: FractionallySizedBox(
        heightFactor: 0.85,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: _searchCtrl,
                decoration: InputDecoration(
                  labelText: l10n.navSearch,
                  prefixIcon: const Icon(Icons.search),
                ),
                onSubmitted: (_) => _load(),
              ),
            ),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : _items.isEmpty
                  ? Center(child: Text(l10n.businessOfferNoItemsFound))
                  : ListView.builder(
                      controller: _scrollController,
                      itemCount: _items.length + (_loadingMore ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index >= _items.length) {
                          return const Padding(
                            padding: EdgeInsets.symmetric(vertical: 16),
                            child: Center(child: CircularProgressIndicator()),
                          );
                        }
                        final item = _items[index];
                        return ListTile(
                          title: Text(item.label),
                          trailing: Text('${item.price.toStringAsFixed(2)} ${item.currency}'),
                          onTap: () => Navigator.of(context).pop(item),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

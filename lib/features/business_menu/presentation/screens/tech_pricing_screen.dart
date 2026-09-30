import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/utils/localized_name.dart';
import '../../application/business_menu_providers.dart';
import '../../data/models/menu_item.dart';
import '../../data/models/menu_vocabulary.dart';

/// «التسعير والتفاصيل» — «منيو مواصفات 1»: a merchant PICKS a real catalog
/// product (a real phone model, its specs already curated — see
/// TechDeviceSpecsSeeder) instead of typing a device's specs by hand, then
/// only sets condition/price/stock/description. Distinct from
/// [MenuItemEditScreen]'s generic form the same way «تعبئة الرفوف»
/// (MenuMarketCatalogService) is its own distinct surface — one experience
/// per shape, not one form trying to cover every shape. See
/// [[tech-spec-menu-implementation]].
///
/// Opened for a `detailed` branch (see [VocabularyGroup.detailed]) instead
/// of the plain quantity/price dialog — and, unlike an ordinary branch, a
/// detailed one may carry several of these (several real models), so the
/// branch itself is always required, even when editing an existing item.
class TechPricingScreen extends ConsumerStatefulWidget {
  final VocabularyOptionRef lineOption;
  final BusinessMenuItem? existingItem;
  const TechPricingScreen({
    super.key,
    required this.lineOption,
    this.existingItem,
  });

  @override
  ConsumerState<TechPricingScreen> createState() => _TechPricingScreenState();
}

class _TechPricingScreenState extends ConsumerState<TechPricingScreen> {
  final _priceController = TextEditingController();
  final _stockController = TextEditingController();
  final _descController = TextEditingController();
  CatalogProductRef? _product;
  int? _conditionOptionId;
  bool _conditionSeeded = false;
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    final item = widget.existingItem;
    if (item != null) {
      _priceController.text = item.basePrice.toStringAsFixed(2);
      _stockController.text = item.availableQuantity?.toString() ?? '';
      _descController.text = item.descriptionAr ?? '';
      _product = item.catalogProduct;
    }
  }

  @override
  void dispose() {
    _priceController.dispose();
    _stockController.dispose();
    _descController.dispose();
    super.dispose();
  }

  /// Condition can only be matched against the vocabulary's own option ids
  /// once it has loaded — done once, the first time [conditionGroup] is
  /// available, not on every rebuild.
  void _seedConditionFromItem(VocabularyGroup? conditionGroup) {
    if (_conditionSeeded || conditionGroup == null) return;
    _conditionSeeded = true;
    final item = widget.existingItem;
    if (item == null) return;
    final ids = item.modifierOptions.map((o) => o.id).toSet();
    for (final o in conditionGroup.options) {
      if (ids.contains(o.id)) {
        _conditionOptionId = o.id;
        return;
      }
    }
  }

  Future<void> _pickProduct() async {
    final picked = await showModalBottomSheet<CatalogProductRef>(
      context: context,
      isScrollControlled: true,
      builder: (_) => const _ProductPickerSheet(),
    );
    if (picked != null && mounted) setState(() => _product = picked);
  }

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context)!;
    if (_product == null) {
      setState(() => _error = l10n.techPricingPickProduct);
      return;
    }
    final price = double.tryParse(
      _priceController.text.trim().replaceAll(',', '.').replaceAll('٫', '.'),
    );
    if (price == null || price < 0) {
      setState(() => _error = l10n.menuPriceRequired);
      return;
    }

    setState(() {
      _saving = true;
      _error = null;
    });

    try {
      final api = ref.read(businessMenuApiProvider);
      final stock = int.tryParse(_stockController.text.trim());
      final modifierIds = <int>[?_conditionOptionId];
      final desc = _descController.text.trim();

      if (widget.existingItem == null) {
        await api.createItem(
          nameAr: _product!.name,
          nameEn: _product!.name,
          descriptionAr: desc,
          basePrice: price,
          availableQuantity: stock,
          catalogProductId: _product!.id,
          lineOptionId: widget.lineOption.id,
          modifierOptionIds: modifierIds,
        );
      } else {
        await api.updateItem(
          widget.existingItem!.id,
          nameAr: _product!.name,
          nameEn: _product!.name,
          descriptionAr: desc,
          basePrice: price,
          availableQuantity: stock,
          catalogProductId: _product!.id,
          lineOptionId: widget.lineOption.id,
          modifierOptionIds: modifierIds,
          sortOrder: widget.existingItem!.sortOrder,
          isActive: widget.existingItem!.isActive,
        );
      }
      if (mounted) Navigator.of(context).pop(true);
    } catch (_) {
      if (mounted) setState(() => _error = l10n.commonSomethingWentWrong);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isEnglish = Localizations.localeOf(context).languageCode == 'en';
    final vocabAsync = ref.watch(menuVocabularyProvider);
    final conditionGroup = vocabAsync.maybeWhen(
      data: (v) => v.conditionGroup,
      orElse: () => null,
    );
    _seedConditionFromItem(conditionGroup);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.techPricingTitle)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            l10n.techPricingProductLabel,
            style: theme.textTheme.labelMedium,
          ),
          const SizedBox(height: 8),
          _ProductPickerField(product: _product, onTap: _pickProduct),
          if (_product != null && _product!.specs.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(l10n.menuCardSpecsTitle, style: theme.textTheme.labelMedium),
            const SizedBox(height: 8),
            _SpecTable(specs: _product!.specs),
          ],
          if (conditionGroup != null) ...[
            const SizedBox(height: 16),
            Text(
              l10n.techPricingConditionLabel,
              style: theme.textTheme.labelMedium,
            ),
            const SizedBox(height: 8),
            _ConditionToggle(
              options: conditionGroup.options,
              selectedId: _conditionOptionId,
              isEnglish: isEnglish,
              onChanged: (id) => setState(() => _conditionOptionId = id),
            ),
          ],
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: TextField(
                  controller: _priceController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9.,٫]')),
                  ],
                  decoration: InputDecoration(
                    labelText: l10n.menuItemBasePriceHint,
                    floatingLabelBehavior: FloatingLabelBehavior.always,
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: AppColors.accentGold,
                        width: 1.5,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: _stockController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: InputDecoration(
                    labelText: l10n.menuItemAvailableQuantityHint,
                    floatingLabelBehavior: FloatingLabelBehavior.always,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _descController,
            maxLines: 2,
            decoration: InputDecoration(
              labelText: l10n.menuItemDescriptionArHint,
              floatingLabelBehavior: FloatingLabelBehavior.always,
            ),
          ),
          if (_error != null) ...[
            const SizedBox(height: 12),
            Text(_error!, style: TextStyle(color: theme.colorScheme.error)),
          ],
        ],
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        child: SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: _saving ? null : _save,
            child: _saving
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(l10n.commonSave),
          ),
        ),
      ),
    );
  }
}

/// The tappable "المنتج" row — either "اختر منتجًا حقيقيًا" (nothing picked
/// yet) or the picked product's own name/brand/image, mirroring the TechPricing
/// canvas's product card.
class _ProductPickerField extends StatelessWidget {
  final CatalogProductRef? product;
  final VoidCallback onTap;
  const _ProductPickerField({required this.product, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          border: Border.all(color: theme.dividerColor),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(10),
              ),
              clipBehavior: Clip.antiAlias,
              child: product?.image != null
                  ? Image.network(product!.image!, fit: BoxFit.cover)
                  : Icon(Icons.smartphone_outlined, color: theme.hintColor),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product?.name ??
                        AppLocalizations.of(context)!.techPricingPickProduct,
                    style: theme.textTheme.titleSmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (product?.brand != null)
                    Text(
                      product!.brand!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.hintColor,
                      ),
                    ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: theme.hintColor),
          ],
        ),
      ),
    );
  }
}

/// Read-only preview of the picked product's real spec table — same visual
/// shape as the customer-facing add-to-cart sheet's own `_SpecTable`.
class _SpecTable extends StatelessWidget {
  final List<CatalogSpecRow> specs;
  const _SpecTable({required this.specs});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: theme.dividerColor),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          for (var i = 0; i < specs.length; i++)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: i == specs.length - 1
                  ? null
                  : BoxDecoration(
                      border: Border(
                        bottom: BorderSide(color: theme.dividerColor),
                      ),
                    ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      specs[i].name,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.hintColor,
                      ),
                    ),
                  ),
                  Text(
                    specs[i].value,
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.end,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

/// «حالة المنتج» as a single-select segmented toggle (جديد/مستعمل), matching
/// the TechPricing canvas's two-button look — never a multi-select chip row,
/// a product has exactly one condition.
class _ConditionToggle extends StatelessWidget {
  final List<VocabularyOptionRef> options;
  final int? selectedId;
  final bool isEnglish;
  final ValueChanged<int> onChanged;
  const _ConditionToggle({
    required this.options,
    required this.selectedId,
    required this.isEnglish,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        border: Border.all(color: theme.dividerColor),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          for (final o in options)
            Expanded(
              child: InkWell(
                onTap: () => onChanged(o.id),
                borderRadius: BorderRadius.circular(7),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: selectedId == o.id ? AppColors.accentGold : null,
                    borderRadius: BorderRadius.circular(7),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    localizedName(o.nameAr, o.nameEn, isEnglish),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: selectedId == o.id
                          ? FontWeight.w700
                          : FontWeight.w500,
                      color: selectedId == o.id ? AppColors.primaryNavy : null,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Search-and-pick a real catalog master — mirrors
/// prescriptions/business_picker_sheet.dart's own debounced-search shape.
class _ProductPickerSheet extends ConsumerStatefulWidget {
  const _ProductPickerSheet();

  @override
  ConsumerState<_ProductPickerSheet> createState() =>
      _ProductPickerSheetState();
}

class _ProductPickerSheetState extends ConsumerState<_ProductPickerSheet> {
  final _controller = TextEditingController();
  Timer? _debounce;
  List<CatalogProductRef> _results = const [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _search('');
  }

  @override
  void dispose() {
    _controller.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onChanged(String q) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () => _search(q));
  }

  Future<void> _search(String q) async {
    setState(() => _loading = true);
    try {
      final results = await ref
          .read(businessMenuApiProvider)
          .catalogLookup(q.trim());
      if (mounted) setState(() => _results = results);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.techPricingPickProduct,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _controller,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: l10n.techPricingSearchHint,
                  prefixIcon: const Icon(Icons.search),
                ),
                onChanged: _onChanged,
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 380,
                child: _loading
                    ? const Center(child: CircularProgressIndicator())
                    : _results.isEmpty
                    ? Center(child: Text(l10n.techPricingNoResults))
                    : ListView.builder(
                        itemCount: _results.length,
                        itemBuilder: (context, index) {
                          final p = _results[index];
                          return ListTile(
                            leading: CircleAvatar(
                              backgroundImage: p.image != null
                                  ? NetworkImage(p.image!)
                                  : null,
                              child: p.image == null
                                  ? const Icon(Icons.smartphone_outlined)
                                  : null,
                            ),
                            title: Text(p.name),
                            subtitle: p.brand != null ? Text(p.brand!) : null,
                            onTap: () => Navigator.of(context).pop(p),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

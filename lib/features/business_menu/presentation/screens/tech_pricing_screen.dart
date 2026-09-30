import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_theme.dart';
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
///
/// Forced into [AppTheme.dark] regardless of the device's own theme
/// setting — the Tech Catalog Setup canvas's navy/gold palette IS the
/// app's existing dark theme byte-for-byte (same hex values), so a device
/// shop's own catalog surfaces keep that identity always, the way a
/// dedicated "electronics store" corner of the app would, rather than
/// flipping to the light theme whenever the merchant's phone happens to be
/// in light mode. «لماذا ال UX/UI غير مطابق للتصميم على كانفا» — المالك،
/// 2026-09-30: this and [TechProductDetailScreen] both do this now.
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
      backgroundColor: AppColors.darkBackground,
      builder: (_) => Theme(
        data: AppTheme.dark(),
        child: const _ProductPickerSheet(),
      ),
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
    return Theme(data: AppTheme.dark(), child: Builder(builder: _buildScaffold));
  }

  Widget _buildScaffold(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final labelStyle = theme.textTheme.labelMedium?.copyWith(color: Colors.white.withValues(alpha: 0.55));
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
          Text(l10n.techPricingProductLabel, style: labelStyle),
          const SizedBox(height: 8),
          _ProductPickerField(product: _product, onTap: _pickProduct),
          if (_product != null && _product!.specs.isNotEmpty) ...[
            const SizedBox(height: 18),
            Text(l10n.menuCardSpecsTitle, style: labelStyle),
            const SizedBox(height: 8),
            _SpecTable(specs: _product!.specs),
          ],
          if (conditionGroup != null) ...[
            const SizedBox(height: 18),
            Text(l10n.techPricingConditionLabel, style: labelStyle),
            const SizedBox(height: 8),
            _ConditionToggle(
              options: conditionGroup.options,
              selectedId: _conditionOptionId,
              isEnglish: isEnglish,
              onChanged: (id) => setState(() => _conditionOptionId = id),
            ),
          ],
          const SizedBox(height: 18),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 1,
                child: _DarkField(
                  label: l10n.menuItemBasePriceHint,
                  controller: _priceController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.,٫]'))],
                  goldBorder: true,
                  valueColor: AppColors.accentGold,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                flex: 1,
                child: _DarkField(
                  label: l10n.menuItemAvailableQuantityHint,
                  controller: _stockController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _DarkField(
            label: l10n.menuItemDescriptionArHint,
            controller: _descController,
            maxLines: 3,
            counter: '${_descController.text.length}/300',
          ),
          if (_error != null) ...[
            const SizedBox(height: 12),
            Text(_error!, style: TextStyle(color: theme.colorScheme.error)),
          ],
        ],
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(16, 12, 16, 20),
        child: SizedBox(
          width: double.infinity,
          child: FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.accentGold,
              foregroundColor: AppColors.primaryNavy,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: _saving ? null : _save,
            child: _saving
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primaryNavy),
                  )
                : Text(l10n.commonSave, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          ),
        ),
      ),
    );
  }
}

/// A dark-surface field matching the canvas's own input rows — label above
/// the value (not a floating Material label), `#11213B` fill, subtle white
/// border, gold border when [goldBorder] (the canvas's own "السعر" field).
class _DarkField extends StatefulWidget {
  final String label;
  final TextEditingController controller;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final int maxLines;
  final bool goldBorder;
  final Color? valueColor;
  final String? counter;
  const _DarkField({
    required this.label,
    required this.controller,
    this.keyboardType,
    this.inputFormatters,
    this.maxLines = 1,
    this.goldBorder = false,
    this.valueColor,
    this.counter,
  });

  @override
  State<_DarkField> createState() => _DarkFieldState();
}

class _DarkFieldState extends State<_DarkField> {
  @override
  void initState() {
    super.initState();
    if (widget.counter != null) widget.controller.addListener(_onChanged);
  }

  @override
  void dispose() {
    if (widget.counter != null) widget.controller.removeListener(_onChanged);
    super.dispose();
  }

  void _onChanged() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final border = widget.goldBorder ? AppColors.accentGold : Colors.white.withValues(alpha: 0.14);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.darkSurface,
        border: Border.all(color: border, width: widget.goldBorder ? 1.5 : 1),
        borderRadius: BorderRadius.circular(10),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.label,
                style: TextStyle(
                  fontSize: 11,
                  color: widget.goldBorder ? AppColors.accentGold.withValues(alpha: 0.75) : Colors.white.withValues(alpha: 0.45),
                ),
              ),
              if (widget.counter != null)
                Text(widget.counter!, style: TextStyle(fontSize: 10, color: Colors.white.withValues(alpha: 0.3))),
            ],
          ),
          TextField(
            controller: widget.controller,
            keyboardType: widget.keyboardType,
            inputFormatters: widget.inputFormatters,
            maxLines: widget.maxLines,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: widget.valueColor ?? Colors.white,
            ),
            decoration: const InputDecoration(
              border: InputBorder.none,
              isDense: true,
              contentPadding: EdgeInsets.zero,
              filled: false,
            ),
          ),
        ],
      ),
    );
  }
}

/// The tappable "المنتج" row — either "اختر منتجًا حقيقيًا" (nothing picked
/// yet) or the picked product's own name/brand/image, matching the
/// TechPricing canvas's product card exactly.
class _ProductPickerField extends StatelessWidget {
  final CatalogProductRef? product;
  final VoidCallback onTap;
  const _ProductPickerField({required this.product, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppColors.darkSurface,
          border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppColors.primaryNavyLight, AppColors.primaryNavy],
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              clipBehavior: Clip.antiAlias,
              child: product?.image != null
                  ? Image.network(product!.image!, fit: BoxFit.cover)
                  : const Icon(Icons.smartphone_outlined, color: AppColors.accentGold, size: 20),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product?.name ?? AppLocalizations.of(context)!.techPricingPickProduct,
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.white),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (product?.brand != null)
                    Text(
                      product!.brand!,
                      style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.45)),
                    ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.white.withValues(alpha: 0.5), size: 15),
          ],
        ),
      ),
    );
  }
}

/// Read-only preview of the picked product's real spec table — same visual
/// shape as the customer-facing add-to-cart sheet's own `_SpecTable`, dark-styled.
class _SpecTable extends StatelessWidget {
  final List<CatalogSpecRow> specs;
  const _SpecTable({required this.specs});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
        borderRadius: BorderRadius.circular(12),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          for (var i = 0; i < specs.length; i++)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              color: i.isEven ? Colors.white.withValues(alpha: 0.03) : null,
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      specs[i].name,
                      style: TextStyle(fontSize: 12.5, color: Colors.white.withValues(alpha: 0.5)),
                    ),
                  ),
                  Text(
                    specs[i].value,
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white),
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
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: AppColors.darkSurface,
        border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
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
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: selectedId == o.id ? FontWeight.w700 : FontWeight.w500,
                      color: selectedId == o.id ? AppColors.primaryNavy : Colors.white,
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
/// prescriptions/business_picker_sheet.dart's own debounced-search shape,
/// dark-styled to match the canvas.
class _ProductPickerSheet extends ConsumerStatefulWidget {
  const _ProductPickerSheet();

  @override
  ConsumerState<_ProductPickerSheet> createState() => _ProductPickerSheetState();
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
      final results = await ref.read(businessMenuApiProvider).catalogLookup(q.trim());
      if (mounted) setState(() => _results = results);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.techPricingPickProduct,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _controller,
                autofocus: true,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: l10n.techPricingSearchHint,
                  hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.35)),
                  prefixIcon: Icon(Icons.search, color: Colors.white.withValues(alpha: 0.5)),
                  filled: true,
                  fillColor: AppColors.darkSurface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.14)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.14)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.accentGold, width: 1.5),
                  ),
                ),
                onChanged: _onChanged,
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 380,
                child: _loading
                    ? const Center(child: CircularProgressIndicator(color: AppColors.accentGold))
                    : _results.isEmpty
                    ? Center(
                        child: Text(l10n.techPricingNoResults, style: TextStyle(color: Colors.white.withValues(alpha: 0.5))),
                      )
                    : ListView.builder(
                        itemCount: _results.length,
                        itemBuilder: (context, index) {
                          final p = _results[index];
                          return ListTile(
                            leading: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [AppColors.primaryNavyLight, AppColors.primaryNavy],
                                ),
                                shape: BoxShape.circle,
                              ),
                              clipBehavior: Clip.antiAlias,
                              child: p.image != null
                                  ? Image.network(p.image!, fit: BoxFit.cover)
                                  : const Icon(Icons.smartphone_outlined, color: AppColors.accentGold, size: 18),
                            ),
                            title: Text(p.name, style: const TextStyle(color: Colors.white)),
                            subtitle: p.brand != null
                                ? Text(p.brand!, style: TextStyle(color: Colors.white.withValues(alpha: 0.45)))
                                : null,
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

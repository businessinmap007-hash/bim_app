import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/utils/localized_name.dart';
import '../../../media/application/media_picker_service.dart';
import '../../../media/data/picked_media.dart';
import '../../../media/presentation/widgets/media_source_badge.dart';
import '../../application/business_menu_providers.dart';
import '../../data/models/menu_item.dart';
import '../../data/models/menu_item_image.dart';
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
  final _picker = MediaPickerService();

  /// Photos picked in this visit, uploaded after the item is saved — kept
  /// with their bytes so the strip can preview them on every platform.
  final List<({PickedMedia media, Uint8List bytes})> _newPhotos = [];

  /// «مستعمل» / «كسر زيرو» — a second-hand unit, photographed live only.
  bool _isSecondHand(VocabularyGroup? conditionGroup) {
    final picked = conditionGroup?.options.where((o) => o.id == _conditionOptionId).firstOrNull;
    return picked != null && (picked.nameEn == 'Used' || picked.nameEn == 'Nearly New');
  }

  Future<void> _takePhoto() async {
    final picked = await _picker.pickFromCamera();
    if (picked == null) return;
    final bytes = await picked.file.readAsBytes();
    if (mounted) setState(() => _newPhotos.add((media: picked, bytes: bytes)));
  }

  Future<void> _pickFromGallery() async {
    final picked = await _picker.pickFromGallery();
    for (final p in picked) {
      final bytes = await p.file.readAsBytes();
      if (mounted) setState(() => _newPhotos.add((media: p, bytes: bytes)));
    }
  }

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
      builder: (_) => _ProductPickerSheet(lineOptionId: widget.lineOption.id),
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

      final int itemId;
      if (widget.existingItem == null) {
        itemId = (await api.createItem(
          nameAr: _product!.name,
          nameEn: _product!.name,
          descriptionAr: desc,
          basePrice: price,
          availableQuantity: stock,
          catalogProductId: _product!.id,
          lineOptionId: widget.lineOption.id,
          modifierOptionIds: modifierIds,
        )).id;
      } else {
        itemId = widget.existingItem!.id;
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
      for (final p in _newPhotos) {
        await api.addPickedImage(itemId, p.media);
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
              onChanged: (id) => setState(() {
                _conditionOptionId = id;
                // A used unit keeps only its live shots — a gallery photo
                // picked while it was «جديد» no longer qualifies.
                if (_isSecondHand(conditionGroup)) {
                  _newPhotos.removeWhere((p) => p.media.source != MediaSource.camera);
                }
              }),
            ),
          ],
          const SizedBox(height: 16),
          Text(l10n.techPricingPhotosLabel, style: theme.textTheme.labelMedium),
          const SizedBox(height: 8),
          _PhotoStrip(
            existing: widget.existingItem?.images ?? const [],
            picked: _newPhotos,
            onRemovePicked: (i) => setState(() => _newPhotos.removeAt(i)),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              OutlinedButton.icon(
                onPressed: _takePhoto,
                icon: const Icon(Icons.photo_camera_rounded),
                label: Text(l10n.techPricingTakePhoto),
              ),
              if (!_isSecondHand(conditionGroup))
                OutlinedButton.icon(
                  onPressed: _pickFromGallery,
                  icon: const Icon(Icons.photo_library_rounded),
                  label: Text(l10n.techPricingFromGallery),
                ),
            ],
          ),
          if (_isSecondHand(conditionGroup)) ...[
            const SizedBox(height: 6),
            Text(
              l10n.techPricingUsedCameraOnly,
              style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor),
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
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
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
                    flex: 2,
                    child: Text(
                      specs[i].name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.75),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // One line: a long value shrinks to fit instead of wrapping.
                  Expanded(
                    flex: 3,
                    child: Align(
                      alignment: AlignmentDirectional.centerEnd,
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          specs[i].value,
                          maxLines: 1,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

/// «حالة المنتج» as a single-select segmented toggle (جديد/مستعمل/كسر زيرو), matching
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

  /// Below this a segment's label starts to wrap — the toggle then turns
  /// into a radio list instead of squeezing.
  static const double _minSegmentWidth = 96;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    String label(VocabularyOptionRef o) => localizedName(o.nameAr, o.nameEn, isEnglish);

    // «جديد · مستعمل · كسر زيرو» on one row when the screen has room for
    // every segment; a radio list otherwise — المالك، 2026-10-01.
    return LayoutBuilder(
      builder: (context, constraints) {
        final fitsOneRow = options.isNotEmpty && (constraints.maxWidth - 6) / options.length >= _minSegmentWidth;

        if (!fitsOneRow) {
          return Container(
            decoration: BoxDecoration(
              border: Border.all(color: theme.dividerColor),
              borderRadius: BorderRadius.circular(10),
            ),
            child: RadioGroup<int>(
              groupValue: selectedId,
              onChanged: (id) {
                if (id != null) onChanged(id);
              },
              child: Column(
                children: [
                  for (final o in options)
                    RadioListTile<int>(
                      value: o.id,
                      dense: true,
                      activeColor: AppColors.accentGold,
                      title: Text(label(o), style: theme.textTheme.bodyMedium),
                    ),
                ],
              ),
            ),
          );
        }

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
                        label(o),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: selectedId == o.id ? FontWeight.w700 : FontWeight.w500,
                          color: selectedId == o.id ? AppColors.primaryNavy : null,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

/// Search-and-pick a real catalog master — mirrors
/// prescriptions/business_picker_sheet.dart's own debounced-search shape.
///
/// Narrowed to the branch it was opened from («تابلت» → tablets), then by two
/// chip rows: the brand, and once a brand is picked, its series — «أوبو» →
/// «F» → every F model. A merchant whose model is not listed adds it from
/// the button at the bottom ([_NewModelSheet]).
class _ProductPickerSheet extends ConsumerStatefulWidget {
  final int lineOptionId;
  const _ProductPickerSheet({required this.lineOptionId});

  @override
  ConsumerState<_ProductPickerSheet> createState() =>
      _ProductPickerSheetState();
}

class _ProductPickerSheetState extends ConsumerState<_ProductPickerSheet> {
  final _controller = TextEditingController();
  Timer? _debounce;
  CatalogLookupResult _result = const CatalogLookupResult(items: []);
  List<CatalogFacet> _brands = const [];
  int? _brandId;
  String? _series;
  bool _loading = true;
  int _request = 0;

  @override
  void initState() {
    super.initState();
    _search();
  }

  @override
  void dispose() {
    _controller.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onChanged(String _) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), _search);
  }

  Future<void> _search() async {
    final request = ++_request;
    setState(() => _loading = true);
    try {
      final result = await ref
          .read(businessMenuApiProvider)
          .catalogLookup(
            _controller.text.trim(),
            lineOptionId: widget.lineOptionId,
            brandId: _brandId,
            series: _series,
          );
      // A slower, older response must not overwrite a newer one.
      if (!mounted || request != _request) return;
      setState(() {
        _result = result;
        // The brand row is the branch's whole brand list — keep the first
        // full one rather than letting a search shrink the chips under the
        // merchant's finger.
        if (_brands.isEmpty || _brandId == null) _brands = result.brands;
      });
    } catch (_) {
      if (mounted && request == _request) {
        setState(() => _result = const CatalogLookupResult(items: []));
      }
    } finally {
      if (mounted && request == _request) setState(() => _loading = false);
    }
  }

  void _pickBrand(int? id) {
    setState(() {
      _brandId = id;
      _series = null;
    });
    _search();
  }

  void _pickSeries(String? name) {
    setState(() => _series = name);
    _search();
  }

  Future<void> _addMissing() async {
    final created = await showModalBottomSheet<CatalogProductRef>(
      context: context,
      isScrollControlled: true,
      builder: (_) => _NewModelSheet(
        lineOptionId: widget.lineOptionId,
        brands: _brands,
        initialBrandId: _brandId,
        initialSeries: _series,
        initialModel: _controller.text.trim(),
      ),
    );
    if (created != null && mounted) Navigator.of(context).pop(created);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final items = _result.items;
    final series = _brandId == null ? const <CatalogFacet>[] : _result.series;

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
              Text(l10n.techPricingPickProduct, style: theme.textTheme.titleMedium),
              const SizedBox(height: 12),
              TextField(
                controller: _controller,
                decoration: InputDecoration(
                  hintText: l10n.techPricingSearchHint,
                  prefixIcon: const Icon(Icons.search),
                ),
                onChanged: _onChanged,
              ),
              if (_brands.isNotEmpty) ...[
                const SizedBox(height: 10),
                _FacetChips(
                  allLabel: l10n.techPricingAllBrands,
                  facets: _brands,
                  selected: (f) => f.id == _brandId,
                  allSelected: _brandId == null,
                  onAll: () => _pickBrand(null),
                  onPick: (f) => _pickBrand(f.id),
                ),
              ],
              if (series.isNotEmpty) ...[
                const SizedBox(height: 6),
                _FacetChips(
                  allLabel: l10n.techPricingAllBrands,
                  facets: series,
                  dense: true,
                  selected: (f) => f.name == _series,
                  allSelected: _series == null,
                  onAll: () => _pickSeries(null),
                  onPick: (f) => _pickSeries(f.name),
                ),
              ],
              const SizedBox(height: 8),
              SizedBox(
                height: 340,
                child: _loading
                    ? const Center(child: CircularProgressIndicator())
                    : items.isEmpty
                    ? Center(child: Text(l10n.techPricingNoResults))
                    : ListView.builder(
                        itemCount: items.length,
                        itemBuilder: (context, index) {
                          final p = items[index];
                          final subtitle = [
                            ?p.brand,
                            ?p.series,
                          ].join(' · ');
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
                            subtitle: subtitle.isEmpty ? null : Text(subtitle),
                            trailing: p.pending
                                ? Chip(
                                    label: Text(l10n.techPricingPending),
                                    visualDensity: VisualDensity.compact,
                                  )
                                : null,
                            onTap: () => Navigator.of(context).pop(p),
                          );
                        },
                      ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _addMissing,
                  icon: const Icon(Icons.add),
                  label: Text(l10n.techPricingNotFound),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// One horizontally scrolling row of choice chips with a leading «الكل».
class _FacetChips extends StatelessWidget {
  final String allLabel;
  final List<CatalogFacet> facets;
  final bool Function(CatalogFacet) selected;
  final bool allSelected;
  final VoidCallback onAll;
  final ValueChanged<CatalogFacet> onPick;
  final bool dense;
  const _FacetChips({
    required this.allLabel,
    required this.facets,
    required this.selected,
    required this.allSelected,
    required this.onAll,
    required this.onPick,
    this.dense = false,
  });

  @override
  Widget build(BuildContext context) {
    final density = dense ? VisualDensity.compact : VisualDensity.standard;
    return SizedBox(
      height: dense ? 36 : 42,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          ChoiceChip(
            label: Text(allLabel),
            selected: allSelected,
            visualDensity: density,
            onSelected: (_) => onAll(),
          ),
          for (final f in facets)
            Padding(
              padding: const EdgeInsetsDirectional.only(start: 6),
              child: ChoiceChip(
                label: Text('${f.name} (${f.count})'),
                selected: selected(f),
                visualDensity: density,
                onSelected: (_) => onPick(f),
              ),
            ),
        ],
      ),
    );
  }
}

/// «الموديل مش موجود» — brand (from the branch's own brand chips, or typed),
/// series, model name and the core specs. Saved as a PENDING catalog product:
/// the merchant can price it immediately, everyone else sees it once an admin
/// approves it.
class _NewModelSheet extends ConsumerStatefulWidget {
  final int lineOptionId;
  final List<CatalogFacet> brands;
  final int? initialBrandId;
  final String? initialSeries;
  final String initialModel;
  const _NewModelSheet({
    required this.lineOptionId,
    required this.brands,
    this.initialBrandId,
    this.initialSeries,
    this.initialModel = '',
  });

  @override
  ConsumerState<_NewModelSheet> createState() => _NewModelSheetState();
}

class _NewModelSheetState extends ConsumerState<_NewModelSheet> {
  /// -1 = «ماركة أخرى» (typed by hand).
  late int? _brandId = widget.initialBrandId;
  late final _brandName = TextEditingController();
  late final _series = TextEditingController(text: widget.initialSeries ?? '');
  late final _model = TextEditingController(text: widget.initialModel);
  final _processor = TextEditingController();
  final _ram = TextEditingController();
  final _storage = TextEditingController();
  final _screen = TextEditingController();
  final _os = TextEditingController();
  final _rearCamera = TextEditingController();
  final _frontCamera = TextEditingController();
  final _battery = TextEditingController();
  bool _saving = false;
  String? _error;

  @override
  void dispose() {
    for (final c in [_brandName, _series, _model, _processor, _ram, _storage, _screen, _os, _rearCamera, _frontCamera, _battery]) {
      c.dispose();
    }
    super.dispose();
  }

  String? _text(TextEditingController c) {
    final v = c.text.trim();
    return v.isEmpty ? null : v;
  }

  num? _number(TextEditingController c) =>
      num.tryParse(c.text.trim().replaceAll(',', '.').replaceAll('٫', '.'));

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context)!;
    final typedBrand = _brandId == -1 ? _text(_brandName) : null;
    if (_text(_model) == null || _brandId == null || (_brandId == -1 && typedBrand == null)) {
      setState(() => _error = l10n.techPricingModelRequired);
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      final product = await ref.read(businessMenuApiProvider).proposeCatalogProduct(
        lineOptionId: widget.lineOptionId,
        brandId: _brandId == -1 ? null : _brandId,
        brandName: typedBrand,
        series: _text(_series),
        model: _text(_model)!,
        processor: _text(_processor),
        ramGb: _number(_ram),
        storage: _text(_storage),
        screenInches: _number(_screen),
        os: _text(_os),
        rearCameraMp: _number(_rearCamera),
        frontCameraMp: _number(_frontCamera),
        batteryMah: _number(_battery)?.round(),
      );
      if (mounted) Navigator.of(context).pop(product);
    } catch (_) {
      if (mounted) setState(() => _error = l10n.commonSomethingWentWrong);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Widget _field(TextEditingController c, String label, {bool number = false}) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: TextField(
      controller: c,
      keyboardType: number ? const TextInputType.numberWithOptions(decimal: true) : null,
      decoration: InputDecoration(
        labelText: label,
        floatingLabelBehavior: FloatingLabelBehavior.always,
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(l10n.techPricingNewModelTitle, style: theme.textTheme.titleMedium),
              const SizedBox(height: 4),
              Text(
                l10n.techPricingNewModelNote,
                style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor),
              ),
              const SizedBox(height: 14),
              DropdownButtonFormField<int>(
                initialValue: _brandId,
                decoration: InputDecoration(
                  labelText: l10n.techPricingBrandLabel,
                  floatingLabelBehavior: FloatingLabelBehavior.always,
                ),
                items: [
                  for (final b in widget.brands)
                    DropdownMenuItem(value: b.id, child: Text(b.name)),
                  DropdownMenuItem(value: -1, child: Text(l10n.techPricingOtherBrand)),
                ],
                onChanged: (v) => setState(() => _brandId = v),
              ),
              const SizedBox(height: 10),
              if (_brandId == -1) _field(_brandName, l10n.techPricingBrandNameHint),
              _field(_series, l10n.techPricingSeriesLabel),
              _field(_model, l10n.techPricingModelLabel),
              _field(_processor, l10n.techPricingProcessorLabel),
              Row(
                children: [
                  Expanded(child: _field(_ram, l10n.techPricingRamLabel, number: true)),
                  const SizedBox(width: 10),
                  Expanded(child: _field(_storage, l10n.techPricingStorageLabel)),
                ],
              ),
              Row(
                children: [
                  Expanded(child: _field(_screen, l10n.techPricingScreenLabel, number: true)),
                  const SizedBox(width: 10),
                  Expanded(child: _field(_os, l10n.techPricingOsLabel)),
                ],
              ),
              Row(
                children: [
                  Expanded(child: _field(_rearCamera, l10n.techPricingRearCameraLabel, number: true)),
                  const SizedBox(width: 10),
                  Expanded(child: _field(_frontCamera, l10n.techPricingFrontCameraLabel, number: true)),
                ],
              ),
              _field(_battery, l10n.techPricingBatteryLabel, number: true),
              if (_error != null) ...[
                Text(_error!, style: TextStyle(color: theme.colorScheme.error)),
                const SizedBox(height: 8),
              ],
              FilledButton(
                onPressed: _saving ? null : _save,
                child: _saving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(l10n.commonSave),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The item's photos in one row — already-saved ones and the ones picked in
/// this visit — each with the camera/gallery badge albums use, so a live shot
/// is visibly a live shot.
class _PhotoStrip extends StatelessWidget {
  final List<MenuItemImage> existing;
  final List<({PickedMedia media, Uint8List bytes})> picked;
  final ValueChanged<int> onRemovePicked;
  const _PhotoStrip({required this.existing, required this.picked, required this.onRemovePicked});

  @override
  Widget build(BuildContext context) {
    if (existing.isEmpty && picked.isEmpty) return const SizedBox.shrink();

    Widget tile(ImageProvider image, MediaSource source, {VoidCallback? onRemove}) => Padding(
      padding: const EdgeInsetsDirectional.only(end: 8),
      child: SizedBox(
        width: 96,
        height: 96,
        child: Stack(
          children: [
            Positioned.fill(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image(image: image, fit: BoxFit.cover),
              ),
            ),
            MediaSourceBadge(source: source),
            if (onRemove != null)
              PositionedDirectional(
                top: 4,
                start: 4,
                child: GestureDetector(
                  onTap: onRemove,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.55), shape: BoxShape.circle),
                    child: const Icon(Icons.close_rounded, color: Colors.white, size: 14),
                  ),
                ),
              ),
          ],
        ),
      ),
    );

    return SizedBox(
      height: 96,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          for (final img in existing)
            tile(NetworkImage(img.url), img.isFromCamera ? MediaSource.camera : MediaSource.gallery),
          for (var i = 0; i < picked.length; i++)
            tile(MemoryImage(picked[i].bytes), picked[i].media.source, onRemove: () => onRemovePicked(i)),
        ],
      ),
    );
  }
}

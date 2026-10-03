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
import '../../data/business_menu_api.dart' show BusinessMenuApi;
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
  /// «كاش» / «تقسيط»: one price per option of the trade's price axis. The rows the
  /// merchant switched on, each with its price; saved as the item's variants.
  final Map<int, TextEditingController> _axisPrice = {};
  final Set<int> _axisOn = {};
  bool _axisSeeded = false;
  CatalogProductRef? _product;
  /// A kind with no catalog: the merchant names the item and picks, from the
  /// option groups that DESCRIBE it («مودرن»، «زان»), what it is made of.
  final _nameController = TextEditingController();
  final Set<int> _choiceIds = {};
  bool _choicesSeeded = false;
  int? _conditionOptionId;
  bool _conditionSeeded = false;

  /// What THIS unit states for the kind's `per_item` fields — a car's year,
  /// mileage, gearbox, colour. Words/figures are typed, a choice is picked.
  final Map<int, TextEditingController> _unitText = {};
  final Map<int, int?> _unitOption = {};
  bool _unitSeeded = false;
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
      _nameController.text = item.nameAr;
    }
  }

  @override
  void dispose() {
    _priceController.dispose();
    _stockController.dispose();
    _descController.dispose();
    _nameController.dispose();
    for (final c in _axisPrice.values) {
      c.dispose();
    }
    for (final c in _unitText.values) {
      c.dispose();
    }
    super.dispose();
  }

  /// The unit's own fields once the kind is known (the vocabulary loads after
  /// the screen opens) — seeded from the item being edited, once.
  void _seedUnitFields(DetailProfile? profile) {
    if (_unitSeeded || profile == null) return;
    _unitSeeded = true;
    final saved = {for (final a in widget.existingItem?.attributes ?? const <ItemAttributeValue>[]) a.attributeId: a};
    for (final f in profile.fields.where((f) => f.perItem)) {
      final value = saved[f.id];
      if (f.dataType == 'select') {
        _unitOption[f.id] = value?.optionId;
      } else {
        final number = value?.number;
        _unitText[f.id] = TextEditingController(
          text: number != null
              ? (number == number.roundToDouble() ? number.toInt().toString() : number.toString())
              : (value?.text ?? ''),
        );
      }
    }
  }

  /// attribute id -> value to send, for the kind's per-unit fields. A blank
  /// sends '' so an edit can remove a value it once stated. null = nothing to
  /// say (a basic menu, or a kind with no per-unit fields).
  Map<int, String>? _unitValues(DetailProfile? profile) {
    final fields = profile?.fields.where((f) => f.perItem).toList() ?? const <DetailField>[];
    if (fields.isEmpty) return null;
    return {
      for (final f in fields)
        f.id: f.dataType == 'select'
            ? (_unitOption[f.id]?.toString() ?? '')
            : (_unitText[f.id]?.text.trim() ?? ''),
    };
  }

  /// The first per-unit figure that is not a number, as the field's name.
  String? _badUnitNumber(DetailProfile? profile) {
    for (final f in profile?.fields.where((f) => f.perItem && f.dataType == 'number') ?? const <DetailField>[]) {
      final t = _unitText[f.id]?.text.trim() ?? '';
      if (t.isNotEmpty && double.tryParse(t.replaceAll(',', '').replaceAll('٫', '.')) == null) return f.name;
    }
    return null;
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
    final profile = _profileFor(ref.read(menuVocabularyProvider).asData?.value);
    final usesCatalog = profile?.usesCatalog ?? true;
    if (usesCatalog && _product == null) {
      setState(() => _error = l10n.techPricingPickProduct);
      return;
    }
    if (!usesCatalog && _nameController.text.trim().isEmpty) {
      setState(() => _error = l10n.menuNameRequired);
      return;
    }
    double? parse(String text) => double.tryParse(text.trim().replaceAll(',', '.').replaceAll('٫', '.'));
    final axis = ref.read(menuVocabularyProvider).asData?.value.priceAxis;
    // With a price axis each option offered has ITS OWN price; the item's own
    // price is the first one offered (the default the customer sees first).
    final axisRows = <({VocabularyOptionRef option, double price})>[
      if (axis != null)
        for (final o in axis.options)
          if (_axisOn.contains(o.id) && (parse(_axisPrice[o.id]?.text ?? '') ?? 0) > 0)
            (option: o, price: parse(_axisPrice[o.id]!.text)!),
    ];
    final price = axis != null ? (axisRows.isEmpty ? null : axisRows.first.price) : parse(_priceController.text);
    if (price == null || price < 0) {
      setState(() => _error = l10n.menuPriceRequired);
      return;
    }

    final bad = _badUnitNumber(profile);
    if (bad != null) {
      setState(() => _error = l10n.techPricingFieldNotNumber(bad));
      return;
    }

    setState(() {
      _saving = true;
      _error = null;
    });

    try {
      final api = ref.read(businessMenuApiProvider);
      final unitValues = _unitValues(profile);
      final stock = int.tryParse(_stockController.text.trim());
      // The condition toggle's option, plus what the merchant chose from the
      // describing groups — never the condition twice.
      final conditionIds = ref.read(menuVocabularyProvider).asData?.value.conditionGroup?.options.map((o) => o.id).toSet() ?? <int>{};
      final modifierIds = <int>{
        ..._choiceIds.where((id) => !conditionIds.contains(id)),
        ?_conditionOptionId,
      }.toList();
      final nameAr = usesCatalog ? _product!.name : _nameController.text.trim();
      final desc = _descController.text.trim();

      final int itemId;
      if (widget.existingItem == null) {
        itemId = (await api.createItem(
          nameAr: nameAr,
          nameEn: usesCatalog ? _product!.name : null,
          descriptionAr: desc,
          basePrice: price,
          availableQuantity: stock,
          catalogProductId: usesCatalog ? _product!.id : null,
          lineOptionId: widget.lineOption.id,
          modifierOptionIds: modifierIds,
          attributes: unitValues,
        )).id;
      } else {
        itemId = widget.existingItem!.id;
        await api.updateItem(
          widget.existingItem!.id,
          nameAr: nameAr,
          nameEn: usesCatalog ? _product!.name : null,
          descriptionAr: desc,
          basePrice: price,
          availableQuantity: stock,
          catalogProductId: usesCatalog ? _product!.id : null,
          lineOptionId: widget.lineOption.id,
          modifierOptionIds: modifierIds,
          attributes: unitValues,
          sortOrder: widget.existingItem!.sortOrder,
          isActive: widget.existingItem!.isActive,
        );
      }
      if (axis != null) await _syncAxisVariants(api, itemId, axis, axisRows);
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

  /// Keeps the item's payment variants equal to what the merchant switched on:
  /// a price per offered option (the first is the default), the rest removed.
  Future<void> _syncAxisVariants(
    BusinessMenuApi api,
    int itemId,
    PriceAxis axis,
    List<({VocabularyOptionRef option, double price})> rows,
  ) async {
    final existing = (await api.item(itemId)).variants.where((v) => v.type == 'payment').toList();
    final byName = {for (final v in existing) v.nameAr: v};
    final onById = {for (final r in rows) r.option.id: r.price};
    var first = true;

    for (final o in axis.options) {
      final current = byName[o.nameAr];
      final price = onById[o.id];
      if (price == null) {
        if (current != null) await api.deleteVariant(itemId, current.id);
        continue;
      }
      if (current == null) {
        await api.addVariant(itemId, type: 'payment', nameAr: o.nameAr, nameEn: o.nameEn, price: price, isDefault: first);
      } else {
        await api.updateVariant(itemId, current.id, type: 'payment', nameAr: o.nameAr, nameEn: o.nameEn, price: price, isDefault: first);
      }
      first = false;
    }
  }

  /// Fills the rows once: the options this item already has a price for.
  void _seedAxis(PriceAxis axis) {
    if (_axisSeeded) return;
    _axisSeeded = true;
    for (final o in axis.options) {
      _axisPrice[o.id] ??= TextEditingController();
    }
    final item = widget.existingItem;
    if (item == null) return;
    ref.read(businessMenuApiProvider).item(item.id).then((full) {
      if (!mounted) return;
      setState(() {
        for (final v in full.variants.where((v) => v.type == 'payment')) {
          final o = axis.options.where((o) => o.nameAr == v.nameAr).firstOrNull;
          if (o == null) continue;
          _axisOn.add(o.id);
          _axisPrice[o.id]!.text = (v.price ?? 0).toStringAsFixed(0);
        }
      });
    });
  }

  /// The picked product's specs in the order its detail kind lists them,
  /// limited to that kind's fields — a phone never shows a car's rows. A
  /// kind with none of this product's values (or no kind at all) falls back
  /// to every spec the product has.
  List<CatalogSpecRow> _profileSpecs(List<CatalogSpecRow> specs, DetailProfile? profile) {
    if (profile == null || profile.fields.isEmpty) return specs;
    final byCode = {for (final s in specs) s.code: s};
    // The unit states its own per-unit fields below; the catalog's row for
    // the same attribute would only contradict or repeat it.
    final ordered = [
      for (final f in profile.fields)
        if (!f.perItem && byCode[f.code] != null) byCode[f.code]!,
    ];
    return ordered.isEmpty ? specs : ordered;
  }

  DetailProfile? _profileFor(MenuVocabulary? v) => v?.lines
      .where((g) => g.options.any((o) => o.id == widget.lineOption.id))
      .map((g) => g.detailProfile)
      .whereType<DetailProfile>()
      .firstOrNull;

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

    // The kind of details this branch's group is (mobiles, laptops, cars…) —
    // decided in the admin's «أشكال المنيو», never here.
    final detailProfile = _profileFor(vocabAsync.asData?.value);
    _seedUnitFields(detailProfile);
    // «طريقة السداد كاش وتقسيط وهم سعرين مختلفين» — المالك، 2026-10-03: a trade
    // whose price axis is set in «مكونات الخدمة» asks for one price per option.
    final priceAxis = vocabAsync.asData?.value.priceAxis;
    if (priceAxis != null) _seedAxis(priceAxis);
    final usesCatalog = detailProfile?.usesCatalog ?? true;
    if (!_choicesSeeded && widget.existingItem != null) {
      _choicesSeeded = true;
      _choiceIds.addAll(widget.existingItem!.modifierOptions.map((o) => o.id));
    }
    // The groups «مكونات الخدمة» made DESCRIBE what an item is for this trade.
    final describing = vocabAsync.maybeWhen(
      data: (v) {
        final lineIds = v.lines.map((g) => g.groupId).toSet();
        // «مكونات الخدمة» decides, per trade, which groups describe an item and in
        // what order — nothing is chosen on the menu kind any more.
        return v.modifiers.where((g) => g.descriptive && g.options.isNotEmpty && !lineIds.contains(g.groupId)).toList()
          ..sort((a, b) => a.descriptiveSort.compareTo(b.descriptiveSort));
      },
      orElse: () => const <VocabularyGroup>[],
    );

    // The page is drawn exactly like the admin's «أشكال المنيو» phone preview —
    // small muted section labels, compact fields, per-unit fields two to a row,
    // a navy segmented condition toggle, price beside quantity — المالك،
    // 2026-10-02. Compact fields come from the theme override below.
    final fieldTheme = theme.inputDecorationTheme;
    Widget label(String text) => Padding(
          padding: const EdgeInsets.only(top: 12, bottom: 6),
          child: Text(
            text,
            style: theme.textTheme.labelMedium?.copyWith(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.primaryNavy.withValues(alpha: 0.6),
            ),
          ),
        );

    return Scaffold(
      appBar: AppBar(title: Text(l10n.techPricingTitle)),
      body: Theme(
        data: theme.copyWith(
          inputDecorationTheme: fieldTheme.copyWith(
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          ),
        ),
        child: ListView(
        padding: const EdgeInsets.fromLTRB(14, 8, 14, 14),
        children: [
          // What it is — the branch the merchant tapped («غرفة نوم»): the
          // preview's small gold pill.
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.accentGold,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                localizedName(widget.lineOption.nameAr, widget.lineOption.nameEn, isEnglish),
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.primaryNavy),
              ),
            ),
          ),
          if (usesCatalog) ...[
            label(l10n.techPricingProductLabel),
            _ProductPickerField(product: _product, onTap: _pickProduct),
          ] else ...[
            label(l10n.menuItemNameArHint),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(hintText: l10n.menuItemNameArHint),
            ),
          ],
          if (usesCatalog && _product != null && _product!.specs.isNotEmpty) ...[
            label(l10n.menuCardSpecsTitle),
            _SpecTable(specs: _profileSpecs(_product!.specs, detailProfile)),
          ],
          // «لهذه الوحدة بالذات» — what only THIS unit can say (a car's year,
          // mileage, gearbox, colour); the catalog knows the model, not the unit.
          // A list field nobody filled with choices («الخامة» — the wood comes
          // from the option groups below) would be a box over nothing.
          if (detailProfile != null)
            Builder(builder: (context) {
              final unitFields = detailProfile.fields
                  .where((f) => f.perItem && !(f.dataType == 'select' && f.options.isEmpty))
                  .toList();
              if (unitFields.isEmpty && describing.isEmpty) return const SizedBox.shrink();
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  label(usesCatalog ? l10n.techPricingUnitDetails : l10n.techPricingItemDetails),
                  LayoutBuilder(builder: (context, c) {
                    // Two to a row, as the preview's 44% boxes.
                    final w = (c.maxWidth - 8) / 2;
                    return Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final f in unitFields)
                          SizedBox(
                            width: f.dataType == 'select' && DetailDisplay.asChips(f.display, f.options.length) ? c.maxWidth : w,
                            child: f.dataType == 'select' && DetailDisplay.asChips(f.display, f.options.length)
                                ? _ChipsField(
                                    label: f.name,
                                    options: [for (final o in f.options) (id: o.id, name: o.name)],
                                    selected: {if (_unitOption[f.id] != null) _unitOption[f.id]!},
                                    multi: false,
                                    onChanged: (ids) => setState(() => _unitOption[f.id] = ids.isEmpty ? null : ids.first),
                                  )
                                : f.dataType == 'select'
                                ? DropdownButtonFormField<int>(
                                    initialValue: _unitOption[f.id],
                                    isExpanded: true,
                                    decoration: InputDecoration(labelText: f.name),
                                    items: [
                                      for (final o in f.options) DropdownMenuItem(value: o.id, child: Text(o.name)),
                                    ],
                                    onChanged: (id) => setState(() => _unitOption[f.id] = id),
                                  )
                                : TextField(
                                    controller: _unitText[f.id],
                                    keyboardType: f.dataType == 'number'
                                        ? const TextInputType.numberWithOptions(decimal: true)
                                        : TextInputType.text,
                                    decoration: InputDecoration(hintText: f.name, suffixText: f.unit),
                                  ),
                          ),
                        // «اختيار الوصف ونوع الخشب من مجموعات الخيارات»: one
                        // dropdown per describing group — the style, the wood —
                        // never a wall of buttons, never typed.
                        for (final g in describing)
                          SizedBox(
                            width: DetailDisplay.asChips(g.display, g.options.length) ? c.maxWidth : w,
                            child: () {
                              final options = [
                                for (final o in g.options) (id: o.id, name: localizedName(o.nameAr, o.nameEn, isEnglish)),
                              ];
                              // «اختيار متعدد ام واحد فقط» — set per group in «مكونات الخدمة».
                              final multi = g.multiple;
                              void change(Set<int> ids) => setState(() {
                                _choiceIds.removeAll(g.options.map((o) => o.id));
                                _choiceIds.addAll(multi || ids.isEmpty ? ids : {ids.first});
                              });
                              return DetailDisplay.asChips(g.display, g.options.length)
                                  ? _ChipsField(label: g.groupName, options: options, selected: _choiceIds, multi: multi, onChanged: change)
                                  : _MultiChoiceField(label: g.groupName, options: options, selected: _choiceIds, multi: multi, onChanged: change);
                            }(),
                          ),
                      ],
                    );
                  }),
                ],
              );
            }),
          if (conditionGroup != null) ...[
            label(l10n.techPricingConditionLabel),
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
          // Price beside quantity, then the description — the preview's order;
          // the photos come last (the preview has no room for them).
          if (priceAxis != null) ...[
            label(l10n.techPricingPriceBy(priceAxis.groupName)),
            for (final o in priceAxis.options)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Container(
                  padding: const EdgeInsetsDirectional.fromSTEB(4, 2, 10, 2),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: _axisOn.contains(o.id) ? AppColors.accentGold : AppColors.primaryNavy.withValues(alpha: 0.18),
                      width: _axisOn.contains(o.id) ? 1.5 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Checkbox(
                        value: _axisOn.contains(o.id),
                        activeColor: AppColors.primaryNavy,
                        onChanged: (on) => setState(() => on == true ? _axisOn.add(o.id) : _axisOn.remove(o.id)),
                      ),
                      Expanded(
                        child: Text(
                          localizedName(o.nameAr, o.nameEn, isEnglish),
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.primaryNavy),
                        ),
                      ),
                      SizedBox(
                        width: 150,
                        child: TextField(
                          controller: _axisPrice[o.id],
                          enabled: _axisOn.contains(o.id),
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.,٫]'))],
                          decoration: InputDecoration(hintText: l10n.techPricingPriceFor),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (priceAxis == null)
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
                    hintText: l10n.menuItemBasePriceHint,
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
              if (priceAxis == null) const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: _stockController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: InputDecoration(hintText: l10n.menuItemAvailableQuantityHint),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _descController,
            minLines: 2,
            maxLines: 4,
            decoration: InputDecoration(hintText: l10n.menuItemDescriptionArHint),
          ),
          label(l10n.techPricingPhotosLabel),
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
          if (_error != null) ...[
            const SizedBox(height: 12),
            Text(_error!, style: TextStyle(color: theme.colorScheme.error)),
          ],
        ],
        ),
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
                        color: selectedId == o.id ? Colors.white : null,
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

/// A describing group («طراز الأثاث»، «أنواع الأخشاب») as ONE dropdown-looking
/// field instead of a row of chips: tap it, tick what applies in a sheet, done.
/// Several can be ticked (a bedroom may be beech AND MDF); the field shows them
/// joined, under the group's name.
class _MultiChoiceField extends StatelessWidget {
  final String label;
  final List<({int id, String name})> options;
  final Set<int> selected;
  /// false = one choice: tapping an option picks it and closes the sheet.
  final bool multi;
  final ValueChanged<Set<int>> onChanged;
  const _MultiChoiceField({
    required this.label,
    required this.options,
    required this.selected,
    this.multi = true,
    required this.onChanged,
  });

  Future<void> _open(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final picked = {for (final o in options) if (selected.contains(o.id)) o.id};
    final result = await showModalBottomSheet<Set<int>>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheetContext) => StatefulBuilder(
        builder: (context, setSheet) => SafeArea(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * 0.7),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                  child: Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: Text(label, style: Theme.of(context).textTheme.titleMedium),
                  ),
                ),
                Flexible(
                  child: ListView(
                    shrinkWrap: true,
                    children: [
                      for (final o in options)
                        if (multi)
                          CheckboxListTile(
                            value: picked.contains(o.id),
                            title: Text(o.name),
                            activeColor: AppColors.primaryNavy,
                            controlAffinity: ListTileControlAffinity.leading,
                            onChanged: (on) => setSheet(() => on == true ? picked.add(o.id) : picked.remove(o.id)),
                          )
                        else
                          ListTile(
                            title: Text(o.name),
                            trailing: picked.contains(o.id) ? const Icon(Icons.check, color: AppColors.primaryNavy) : null,
                            onTap: () => Navigator.of(sheetContext).pop({o.id}),
                          ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                  child: Row(
                    children: [
                      TextButton(
                        onPressed: multi ? () => setSheet(picked.clear) : () => Navigator.of(sheetContext).pop(<int>{}),
                        child: Text(l10n.commonClear),
                      ),
                      const Spacer(),
                      if (multi)
                        FilledButton(
                          onPressed: () => Navigator.of(sheetContext).pop(picked),
                          child: Text(l10n.commonOk),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    if (result != null) onChanged(result);
  }

  @override
  Widget build(BuildContext context) {
    final names = [for (final o in options) if (selected.contains(o.id)) o.name];
    return InkWell(
      onTap: () => _open(context),
      borderRadius: BorderRadius.circular(12),
      child: InputDecorator(
        isEmpty: names.isEmpty,
        decoration: InputDecoration(
          labelText: label,
          suffixIcon: const Icon(Icons.arrow_drop_down),
        ),
        child: Text(
          names.join('، '),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}

/// A list field drawn as BUTTONS — the canvas's look: its label small above,
/// every option a chip, one tap. [multi] false = pick one (tap it again to clear);
/// true = tick as many as apply. The admin chooses buttons or a dropdown per field.
class _ChipsField extends StatelessWidget {
  final String label;
  final List<({int id, String name})> options;
  final Set<int> selected;
  final bool multi;
  final ValueChanged<Set<int>> onChanged;
  const _ChipsField({
    required this.label,
    required this.options,
    required this.selected,
    required this.multi,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.labelMedium?.copyWith(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.primaryNavy.withValues(alpha: 0.6),
          ),
        ),
        const SizedBox(height: 6),
        // The canvas's buttons: roomy, softly rounded rectangles — the chosen one
        // gold with bold navy text, the rest white with a thin border.
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            for (final o in options)
              Builder(builder: (context) {
                final on = selected.contains(o.id);
                return Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(14),
                    onTap: () {
                      final next = {...selected};
                      if (multi) {
                        on ? next.remove(o.id) : next.add(o.id);
                      } else {
                        next
                          ..removeAll(options.map((e) => e.id))
                          ..addAll(on ? const {} : {o.id});
                      }
                      onChanged(next);
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 120),
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 11),
                      decoration: BoxDecoration(
                        color: on ? AppColors.accentGold : Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: on ? AppColors.accentGold : AppColors.primaryNavy.withValues(alpha: 0.18),
                        ),
                      ),
                      child: Text(
                        o.name,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: on ? FontWeight.w800 : FontWeight.w600,
                          color: AppColors.primaryNavy,
                        ),
                      ),
                    ),
                  ),
                );
              }),
          ],
        ),
      ],
    );
  }
}

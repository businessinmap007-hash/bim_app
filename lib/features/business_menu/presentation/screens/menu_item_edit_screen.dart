import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/widgets/horizontal_mouse_wheel_scroll.dart';
import '../../../media/application/media_picker_service.dart';
import '../../application/business_menu_providers.dart';
import '../../data/models/menu_item.dart';
import '../../data/models/menu_section.dart';
import '../../data/models/menu_variant.dart';

/// Create (itemId == null) or edit (itemId set) one menu item. Create shows
/// only the base-fields form — images/variants/extras all hang off an
/// existing item id, so they only appear once the item exists (matching how
/// the backend itself models them as sub-resources of a saved MenuItem).
class MenuItemEditScreen extends ConsumerStatefulWidget {
  final int? itemId;
  /// Pre-selects a branch (line option) on a NEW item — e.g. tapping
  /// "+ إضافة علامة تجارية" under "ثلاجات" in the grouped items list opens
  /// this already pointed at that branch, so the merchant only fills in the
  /// brand and price. Ignored when editing an existing item (its own value
  /// wins via `_seedFrom`).
  final int? initialLineOptionId;
  const MenuItemEditScreen({super.key, this.itemId, this.initialLineOptionId});

  @override
  ConsumerState<MenuItemEditScreen> createState() => _MenuItemEditScreenState();
}

class _MenuItemEditScreenState extends ConsumerState<MenuItemEditScreen> {
  final _nameArController = TextEditingController();
  final _nameEnController = TextEditingController();
  final _descArController = TextEditingController();
  final _descEnController = TextEditingController();
  final _priceController = TextEditingController();
  final _supplyPriceController = TextEditingController();
  final _brandController = TextEditingController();
  final _availableQuantityController = TextEditingController();
  final _sortController = TextEditingController(text: '0');
  int? _sectionId;
  String? _saleUnit;
  bool _isActive = true;
  bool _saving = false;
  String? _error;
  bool _initialized = false;
  // What this item IS (a `line` option, e.g. "ثلاجات") and what qualifies it
  // (brand, condition...) — from the merchant's own vocabulary, see
  // HasOfferingOptions. Null/empty for a hand-typed item (a restaurant dish).
  late int? _lineOptionId = widget.initialLineOptionId;
  Set<int> _modifierOptionIds = {};

  @override
  void dispose() {
    _nameArController.dispose();
    _nameEnController.dispose();
    _descArController.dispose();
    _descEnController.dispose();
    _priceController.dispose();
    _supplyPriceController.dispose();
    _brandController.dispose();
    _availableQuantityController.dispose();
    _sortController.dispose();
    super.dispose();
  }

  void _seedFrom(BusinessMenuItem item) {
    if (_initialized) return;
    _initialized = true;
    _nameArController.text = item.nameAr;
    _nameEnController.text = item.nameEn ?? '';
    _descArController.text = item.descriptionAr ?? '';
    _descEnController.text = item.descriptionEn ?? '';
    _priceController.text = item.basePrice.toStringAsFixed(2);
    _supplyPriceController.text = item.supplyPrice?.toStringAsFixed(2) ?? '';
    _brandController.text = item.brandName ?? '';
    _availableQuantityController.text = item.availableQuantity?.toString() ?? '';
    _sortController.text = '${item.sortOrder}';
    _sectionId = item.menuSectionId;
    _saleUnit = item.saleUnit;
    _lineOptionId = item.lineOption?.id;
    _modifierOptionIds = item.modifierOptions.map((o) => o.id).toSet();
  }

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context)!;
    if (_nameArController.text.trim().isEmpty) {
      setState(() => _error = l10n.menuNameRequired);
      return;
    }
    final price = double.tryParse(_priceController.text.trim());
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
      final supplyPrice = double.tryParse(_supplyPriceController.text.trim());
      final availableQuantity = int.tryParse(_availableQuantityController.text.trim());
      // Once this business has a `line` vocabulary, the section is grown
      // from the picked line option's own group server-side — sending a
      // manual one here would fight that (see BusinessMenuItemController's
      // `explicitSection` guard), so it stays null in that mode.
      final hasLines = ref.read(menuVocabularyProvider).maybeWhen(data: (v) => v.hasLines, orElse: () => false);
      if (widget.itemId == null) {
        final created = await api.createItem(
          nameAr: _nameArController.text.trim(),
          nameEn: _nameEnController.text.trim(),
          menuSectionId: hasLines ? null : _sectionId,
          descriptionAr: _descArController.text.trim(),
          descriptionEn: _descEnController.text.trim(),
          basePrice: price,
          supplyPrice: supplyPrice,
          saleUnit: _saleUnit,
          brandName: _brandController.text.trim(),
          availableQuantity: availableQuantity,
          lineOptionId: _lineOptionId,
          modifierOptionIds: _modifierOptionIds.toList(),
          sortOrder: int.tryParse(_sortController.text.trim()) ?? 0,
          isActive: _isActive,
        );
        if (mounted) Navigator.of(context).pop(created.id);
      } else {
        await api.updateItem(
          widget.itemId!,
          nameAr: _nameArController.text.trim(),
          nameEn: _nameEnController.text.trim(),
          menuSectionId: hasLines ? null : _sectionId,
          descriptionAr: _descArController.text.trim(),
          descriptionEn: _descEnController.text.trim(),
          basePrice: price,
          supplyPrice: supplyPrice,
          saleUnit: _saleUnit,
          brandName: _brandController.text.trim(),
          availableQuantity: availableQuantity,
          lineOptionId: _lineOptionId,
          modifierOptionIds: _modifierOptionIds.toList(),
          sortOrder: int.tryParse(_sortController.text.trim()) ?? 0,
          isActive: _isActive,
        );
        ref.invalidate(menuItemEditControllerProvider(widget.itemId!));
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.commonSave)));
        }
      }
    } catch (_) {
      if (mounted) setState(() => _error = l10n.commonSomethingWentWrong);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final sectionsState = ref.watch(menuSectionsControllerProvider);

    if (widget.itemId == null) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.menuItemAddTitle)),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [_buildFormFields(context, l10n, sectionsState.items)],
        ),
        bottomNavigationBar: _SaveBar(saving: _saving, onSave: _save),
      );
    }

    final async = ref.watch(menuItemEditControllerProvider(widget.itemId!));
    return Scaffold(
      appBar: AppBar(title: Text(l10n.menuItemEditTitle)),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(l10n.commonSomethingWentWrong),
              const SizedBox(height: 8),
              OutlinedButton(
                onPressed: () => ref.read(menuItemEditControllerProvider(widget.itemId!).notifier).load(),
                child: Text(l10n.commonRetry),
              ),
            ],
          ),
        ),
        data: (item) {
          _seedFrom(item);
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _ImagesSection(item: item),
              const SizedBox(height: 22),
              _buildFormFields(context, l10n, sectionsState.items),
              const SizedBox(height: 24),
              _VariantsSection(item: item),
              const SizedBox(height: 24),
              _ExtraGroupsSection(item: item),
              const SizedBox(height: 24),
              _ExtrasSection(item: item),
            ],
          );
        },
      ),
      bottomNavigationBar: async.maybeWhen(
        data: (_) => _SaveBar(saving: _saving, onSave: _save),
        orElse: () => null,
      ),
    );
  }

  static InputDecoration _fieldDecoration(String label, {String? helper}) {
    return InputDecoration(
      labelText: label,
      helperText: helper,
      helperMaxLines: 2,
      // Always-floated: the label sits small above the value, like every
      // other field on this screen, instead of only moving there on
      // focus/content — a plain unfocused empty field looked identical to
      // a filled one otherwise.
      floatingLabelBehavior: FloatingLabelBehavior.always,
    );
  }

  Widget _buildFormFields(BuildContext context, AppLocalizations l10n, List<BusinessMenuSection> sections) {
    final vocabAsync = ref.watch(menuVocabularyProvider);
    final hasLines = vocabAsync.maybeWhen(data: (v) => v.hasLines, orElse: () => false);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _nameArController,
          decoration: _fieldDecoration(l10n.menuItemNameArHint),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _nameEnController,
          decoration: _fieldDecoration(l10n.menuItemNameEnHint),
        ),
        const SizedBox(height: 12),
        // Once this business has its own catalog vocabulary, what an item
        // IS comes from there instead of a hand-typed section — see
        // Business\MenuItemController::itemTypes()'s "one vocabulary, not
        // two" rule on the web panel this mirrors.
        if (hasLines)
          _LineOptionField(value: _lineOptionId, onChanged: (v) => setState(() => _lineOptionId = v))
        else
          DropdownButtonFormField<int?>(
            initialValue: _sectionId,
            decoration: _fieldDecoration(l10n.menuItemSectionLabel),
            items: [
              DropdownMenuItem(value: null, child: Text(l10n.menuItemNoSection)),
              for (final s in sections) DropdownMenuItem(value: s.id, child: Text(s.nameAr)),
            ],
            onChanged: (v) => setState(() => _sectionId = v),
          ),
        const SizedBox(height: 12),
        TextField(
          controller: _descArController,
          maxLines: 2,
          decoration: _fieldDecoration(l10n.menuItemDescriptionArHint),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _descEnController,
          maxLines: 2,
          decoration: _fieldDecoration(l10n.menuItemDescriptionEnHint),
        ),
        const SizedBox(height: 16),
        Text(l10n.menuItemBasePriceHint, style: Theme.of(context).textTheme.labelMedium),
        const SizedBox(height: 8),
        // Price and its unit answer one question together ("how much, per
        // what") — grouped side by side instead of two unrelated-looking
        // stacked fields. The price side is the one the owner sets most
        // often, so its border stays visible even unfocused.
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: TextField(
                controller: _priceController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: l10n.menuItemBasePriceHint,
                  floatingLabelBehavior: FloatingLabelBehavior.always,
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.accentGold, width: 1.5),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _SaleUnitField(value: _saleUnit, onChanged: (v) => setState(() => _saleUnit = v)),
            ),
          ],
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _supplyPriceController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: _fieldDecoration(l10n.menuItemSupplyPriceHint, helper: l10n.menuItemSupplyPriceHelper),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _brandController,
          decoration: _fieldDecoration(l10n.menuItemBrandNameHint),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _availableQuantityController,
          keyboardType: TextInputType.number,
          decoration: _fieldDecoration(l10n.menuItemAvailableQuantityHint),
        ),
        const SizedBox(height: 12),
        _ModifiersField(
          selectedIds: _modifierOptionIds,
          onChanged: (ids) => setState(() => _modifierOptionIds = ids),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _sortController,
          keyboardType: TextInputType.number,
          decoration: _fieldDecoration(l10n.menuItemSortOrderHint),
        ),
        const SizedBox(height: 12),
        _ActiveToggleCard(value: _isActive, onChanged: (v) => setState(() => _isActive = v)),
        if (_error != null) ...[
          const SizedBox(height: 12),
          Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
        ],
      ],
    );
  }
}

/// The "نشط" row as a bordered card matching every other field on this
/// screen, instead of the bare SwitchListTile every other admin form uses —
/// this one screen got the closer visual pass, not a new house style.
class _ActiveToggleCard extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  const _ActiveToggleCard({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.inputDecorationTheme.fillColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.dividerColor),
      ),
      child: SwitchListTile(
        title: Text(l10n.menuItemActiveLabel, style: theme.textTheme.titleSmall),
        value: value,
        onChanged: onChanged,
      ),
    );
  }
}

/// The save action, pinned to the bottom of the screen instead of scrolling
/// away at the end of a long form — the one action every visit to this
/// screen ends with.
class _SaveBar extends StatelessWidget {
  final bool saving;
  final VoidCallback onSave;
  const _SaveBar({required this.saving, required this.onSave});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return SafeArea(
      minimum: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: SizedBox(
        width: double.infinity,
        child: FilledButton(
          onPressed: saving ? null : onSave,
          child: saving
              ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
              : Text(l10n.commonSave),
        ),
      ),
    );
  }
}

/// "بالقطعة" (null) or one of the shared catalog_units — a burger and a
/// kilo of onions live in the same item list, priced differently.
class _SaleUnitField extends ConsumerWidget {
  final String? value;
  final ValueChanged<String?> onChanged;
  const _SaleUnitField({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final unitsAsync = ref.watch(saleUnitOptionsProvider);

    return unitsAsync.when(
      loading: () => const LinearProgressIndicator(),
      error: (_, _) => const SizedBox.shrink(),
      data: (units) {
        // The saved code might not be in the freshly-fetched list (retired
        // from catalog_units after this item was set) — fall back to "by
        // the item" rather than crashing the dropdown on a stale value.
        final validValue = units.any((u) => u.code == value) ? value : null;
        return DropdownButtonFormField<String?>(
          initialValue: validValue,
          decoration: InputDecoration(
            labelText: l10n.menuItemSaleUnitLabel,
            floatingLabelBehavior: FloatingLabelBehavior.always,
          ),
          items: [
            DropdownMenuItem(value: null, child: Text(l10n.menuItemSaleUnitByItem)),
            for (final u in units) DropdownMenuItem(value: u.code, child: Text(u.label)),
          ],
          onChanged: onChanged,
        );
      },
    );
  }
}

/// What this item IS, from the merchant's own vocabulary — e.g. "ثلاجات"
/// under "أنواع الأجهزة الكهربائية". Replaces the free-text section picker
/// once a business has one (see the "one vocabulary, not two" rule this
/// mirrors from Business\MenuItemController::itemTypes() on the web panel):
/// picking a value here is what grows the item's section server-side.
class _LineOptionField extends ConsumerWidget {
  final int? value;
  final ValueChanged<int?> onChanged;
  const _LineOptionField({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final vocabAsync = ref.watch(menuVocabularyProvider);

    return vocabAsync.when(
      loading: () => const LinearProgressIndicator(),
      error: (_, _) => const SizedBox.shrink(),
      data: (vocab) {
        final groups = vocab.lines.where((g) => g.options.isNotEmpty).toList();
        if (groups.isEmpty) return const SizedBox.shrink();
        // Only worth naming the group beside the option when this business
        // actually has more than one to tell apart.
        final multipleGroups = groups.length > 1;
        final validValue = groups.expand((g) => g.options).any((o) => o.id == value) ? value : null;

        return DropdownButtonFormField<int?>(
          initialValue: validValue,
          decoration: InputDecoration(
            labelText: l10n.menuItemBranchLabel,
            floatingLabelBehavior: FloatingLabelBehavior.always,
          ),
          items: [
            DropdownMenuItem(value: null, child: Text(l10n.menuItemNoBranch)),
            for (final g in groups)
              for (final o in g.options)
                DropdownMenuItem(
                  value: o.id,
                  child: Text(multipleGroups ? '${o.nameAr} — ${g.groupName}' : o.nameAr),
                ),
          ],
          onChanged: onChanged,
        );
      },
    );
  }
}

/// What qualifies the item — brand, condition... any number of `modifier`
/// options, grouped by their own vocabulary group. One chip row per group;
/// picking within a group toggles that option (a business may need more
/// than one qualifier at once, e.g. a brand AND a condition).
class _ModifiersField extends ConsumerWidget {
  final Set<int> selectedIds;
  final ValueChanged<Set<int>> onChanged;
  const _ModifiersField({required this.selectedIds, required this.onChanged});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vocabAsync = ref.watch(menuVocabularyProvider);

    return vocabAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, _) => const SizedBox.shrink(),
      data: (vocab) {
        final groups = vocab.modifiers.where((g) => g.options.isNotEmpty).toList();
        if (groups.isEmpty) return const SizedBox.shrink();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (final g in groups) ...[
              Text(g.groupName, style: Theme.of(context).textTheme.labelMedium),
              const SizedBox(height: 6),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final o in g.options)
                    FilterChip(
                      label: Text(o.nameAr),
                      selected: selectedIds.contains(o.id),
                      onSelected: (selected) {
                        final next = Set<int>.from(selectedIds);
                        selected ? next.add(o.id) : next.remove(o.id);
                        onChanged(next);
                      },
                    ),
                ],
              ),
              const SizedBox(height: 12),
            ],
          ],
        );
      },
    );
  }
}

class _ImagesSection extends ConsumerStatefulWidget {
  final BusinessMenuItem item;
  const _ImagesSection({required this.item});

  @override
  ConsumerState<_ImagesSection> createState() => _ImagesSectionState();
}

class _ImagesSectionState extends ConsumerState<_ImagesSection> {
  final _picker = MediaPickerService();
  bool _uploading = false;

  Future<void> _addImage() async {
    final picked = await _picker.pickFromGallery(allowMultiple: false);
    if (picked.isEmpty) return;
    setState(() => _uploading = true);
    try {
      await ref
          .read(menuItemEditControllerProvider(widget.item.id).notifier)
          .addImage(picked.first.file.path);
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  Future<void> _deleteImage(int imageId) async {
    await ref.read(menuItemEditControllerProvider(widget.item.id).notifier).deleteImage(imageId);
  }

  static const _tileSize = 92.0;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final images = widget.item.images;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.menuItemImagesSection, style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 10),
        SizedBox(
          height: _tileSize,
          child: MouseWheelHorizontalScroll(
            builder: (context, controller) => ListView.separated(
              controller: controller,
              scrollDirection: Axis.horizontal,
              // +1 for the trailing "add photo" tile.
              itemCount: images.length + 1,
              separatorBuilder: (context, index) => const SizedBox(width: 10),
              itemBuilder: (context, index) {
                if (index == images.length) {
                  return _AddImageTile(uploading: _uploading, onTap: _uploading ? null : _addImage);
                }
                final image = images[index];
                return SizedBox(
                  width: _tileSize,
                  height: _tileSize,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: Image.network(
                          image.url,
                          width: _tileSize,
                          height: _tileSize,
                          fit: BoxFit.cover,
                        ),
                      ),
                      PositionedDirectional(
                        top: 6,
                        start: 6,
                        child: InkWell(
                          onTap: () => _deleteImage(image.id),
                          borderRadius: BorderRadius.circular(11),
                          child: const CircleAvatar(
                            radius: 11,
                            backgroundColor: Colors.black54,
                            child: Icon(Icons.close, size: 13, color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

class _AddImageTile extends StatelessWidget {
  final bool uploading;
  final VoidCallback? onTap;
  const _AddImageTile({required this.uploading, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: _ImagesSectionState._tileSize,
        height: _ImagesSectionState._tileSize,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.accentGold.withValues(alpha: 0.55), width: 1.5),
        ),
        child: uploading
            ? const Center(child: SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2)))
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.add, color: AppColors.accentGold, size: 22),
                  const SizedBox(height: 4),
                  Text(
                    l10n.menuItemAddImage,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: AppColors.accentGold, fontSize: 11, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
      ),
    );
  }
}

class _VariantsSection extends ConsumerWidget {
  final BusinessMenuItem item;
  const _VariantsSection({required this.item});

  Future<void> _openForm(BuildContext context, WidgetRef ref, {MenuVariant? existing}) async {
    final l10n = AppLocalizations.of(context)!;
    final typeController = TextEditingController(text: existing?.type ?? '');
    final nameArController = TextEditingController(text: existing?.nameAr ?? '');
    final nameEnController = TextEditingController(text: existing?.nameEn ?? '');
    final priceController = TextEditingController(text: existing?.price?.toStringAsFixed(2) ?? '');
    final priceDeltaController = TextEditingController(text: existing?.priceDelta?.toStringAsFixed(2) ?? '');
    bool isDefault = existing?.isDefault ?? false;
    String? error;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) => StatefulBuilder(
        builder: (sheetContext, setSheetState) => Padding(
          padding: EdgeInsets.fromLTRB(20, 20, 20, 20 + MediaQuery.of(sheetContext).viewInsets.bottom),
          child: SafeArea(
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    existing == null ? l10n.menuItemAddVariant : l10n.menuItemEditVariant,
                    style: Theme.of(sheetContext).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 16),
                  TextField(controller: typeController, decoration: InputDecoration(labelText: l10n.menuItemVariantTypeHint)),
                  const SizedBox(height: 12),
                  TextField(controller: nameArController, decoration: InputDecoration(labelText: l10n.menuItemNameArHint)),
                  const SizedBox(height: 12),
                  TextField(controller: nameEnController, decoration: InputDecoration(labelText: l10n.menuItemNameEnHint)),
                  const SizedBox(height: 12),
                  TextField(
                    controller: priceController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(labelText: l10n.menuItemVariantPriceHint),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: priceDeltaController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                    decoration: InputDecoration(labelText: l10n.menuItemVariantPriceDeltaHint),
                  ),
                  const SizedBox(height: 8),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(l10n.menuItemVariantDefaultLabel),
                    value: isDefault,
                    onChanged: (v) => setSheetState(() => isDefault = v),
                  ),
                  if (error != null) ...[
                    const SizedBox(height: 8),
                    Text(error!, style: TextStyle(color: Theme.of(sheetContext).colorScheme.error)),
                  ],
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: () async {
                      if (typeController.text.trim().isEmpty || nameArController.text.trim().isEmpty) {
                        setSheetState(() => error = l10n.menuNameRequired);
                        return;
                      }
                      try {
                        final notifier = ref.read(menuItemEditControllerProvider(item.id).notifier);
                        final price = double.tryParse(priceController.text.trim());
                        final priceDelta = double.tryParse(priceDeltaController.text.trim());
                        if (existing == null) {
                          await notifier.addVariant(
                            type: typeController.text.trim(),
                            nameAr: nameArController.text.trim(),
                            nameEn: nameEnController.text.trim(),
                            price: price,
                            priceDelta: priceDelta,
                            isDefault: isDefault,
                          );
                        } else {
                          await notifier.updateVariant(
                            existing.id,
                            type: typeController.text.trim(),
                            nameAr: nameArController.text.trim(),
                            nameEn: nameEnController.text.trim(),
                            price: price,
                            priceDelta: priceDelta,
                            isDefault: isDefault,
                          );
                        }
                        if (sheetContext.mounted) Navigator.of(sheetContext).pop();
                      } catch (_) {
                        setSheetState(() => error = l10n.commonSomethingWentWrong);
                      }
                    },
                    child: Text(l10n.commonSave),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _delete(BuildContext context, WidgetRef ref, MenuVariant variant) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        content: Text(l10n.menuItemDeleteRowConfirm),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text(l10n.commonCancel)),
          TextButton(onPressed: () => Navigator.pop(context, true), child: Text(l10n.commonDelete)),
        ],
      ),
    );
    if (confirmed == true) {
      await ref.read(menuItemEditControllerProvider(item.id).notifier).deleteVariant(variant.id);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(l10n.menuItemVariantsSection, style: Theme.of(context).textTheme.titleSmall),
            InkWell(
              onTap: () => _openForm(context, ref),
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.add, size: 16, color: AppColors.accentGold),
                    const SizedBox(width: 4),
                    Text(
                      l10n.menuItemAddVariant,
                      style: const TextStyle(color: AppColors.accentGold, fontWeight: FontWeight.w600, fontSize: 13),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        if (item.variants.isNotEmpty)
          SizedBox(
            height: 60,
            child: MouseWheelHorizontalScroll(
              builder: (context, controller) => ListView.separated(
                controller: controller,
                scrollDirection: Axis.horizontal,
                itemCount: item.variants.length,
                separatorBuilder: (context, index) => const SizedBox(width: 10),
                itemBuilder: (context, index) {
                  final v = item.variants[index];
                  final priceLabel = v.price != null
                      ? v.price!.toStringAsFixed(0)
                      : (v.priceDelta != null ? '+${v.priceDelta!.toStringAsFixed(0)}' : '');
                  return _VariantChip(
                    label: v.nameAr,
                    priceLabel: priceLabel,
                    highlighted: v.isDefault,
                    onTap: () => _openForm(context, ref, existing: v),
                    onLongPress: () => _delete(context, ref, v),
                  );
                },
              ),
            ),
          ),
      ],
    );
  }
}

/// One size/variant as a tappable chip — tap edits, long-press deletes
/// (the sheet itself has no delete action, so this is the only way in).
/// The item's default variant is highlighted gold, the same "this is the
/// one" treatment the customer-facing menu gives it.
class _VariantChip extends StatelessWidget {
  final String label;
  final String priceLabel;
  final bool highlighted;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  const _VariantChip({
    required this.label,
    required this.priceLabel,
    required this.highlighted,
    required this.onTap,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      onLongPress: onLongPress,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: highlighted ? AppColors.accentGold.withValues(alpha: 0.14) : theme.inputDecorationTheme.fillColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: highlighted ? AppColors.accentGold : theme.dividerColor, width: highlighted ? 1.5 : 1),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(label, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
            if (priceLabel.isNotEmpty)
              Text(
                priceLabel,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: highlighted ? AppColors.accentGold : theme.hintColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _ExtraGroupsSection extends ConsumerWidget {
  final BusinessMenuItem item;
  const _ExtraGroupsSection({required this.item});

  Future<void> _openForm(BuildContext context, WidgetRef ref, {MenuExtraGroup? existing}) async {
    final l10n = AppLocalizations.of(context)!;
    final nameArController = TextEditingController(text: existing?.nameAr ?? '');
    final nameEnController = TextEditingController(text: existing?.nameEn ?? '');
    String selectionType = existing?.selectionType ?? MenuExtraGroup.selectionMultiple;
    String? error;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) => StatefulBuilder(
        builder: (sheetContext, setSheetState) => Padding(
          padding: EdgeInsets.fromLTRB(20, 20, 20, 20 + MediaQuery.of(sheetContext).viewInsets.bottom),
          child: SafeArea(
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    existing == null ? l10n.menuItemAddExtraGroup : l10n.menuItemEditExtraGroup,
                    style: Theme.of(sheetContext).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 16),
                  TextField(controller: nameArController, decoration: InputDecoration(labelText: l10n.menuItemExtraGroupNameHint)),
                  const SizedBox(height: 12),
                  TextField(controller: nameEnController, decoration: InputDecoration(labelText: l10n.menuItemNameEnHint)),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: selectionType,
                    decoration: InputDecoration(labelText: l10n.menuItemExtraGroupSelectionLabel),
                    items: [
                      DropdownMenuItem(
                        value: MenuExtraGroup.selectionSingle,
                        child: Text(l10n.menuItemExtraGroupSelectionSingle),
                      ),
                      DropdownMenuItem(
                        value: MenuExtraGroup.selectionMultiple,
                        child: Text(l10n.menuItemExtraGroupSelectionMultiple),
                      ),
                    ],
                    onChanged: (v) => setSheetState(() => selectionType = v ?? MenuExtraGroup.selectionMultiple),
                  ),
                  if (error != null) ...[
                    const SizedBox(height: 8),
                    Text(error!, style: TextStyle(color: Theme.of(sheetContext).colorScheme.error)),
                  ],
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: () async {
                      if (nameArController.text.trim().isEmpty) {
                        setSheetState(() => error = l10n.menuNameRequired);
                        return;
                      }
                      try {
                        final notifier = ref.read(menuItemEditControllerProvider(item.id).notifier);
                        if (existing == null) {
                          await notifier.addExtraGroup(
                            nameAr: nameArController.text.trim(),
                            nameEn: nameEnController.text.trim(),
                            selectionType: selectionType,
                          );
                        } else {
                          await notifier.updateExtraGroup(
                            existing.id,
                            nameAr: nameArController.text.trim(),
                            nameEn: nameEnController.text.trim(),
                            selectionType: selectionType,
                          );
                        }
                        if (sheetContext.mounted) Navigator.of(sheetContext).pop();
                      } catch (_) {
                        setSheetState(() => error = l10n.commonSomethingWentWrong);
                      }
                    },
                    child: Text(l10n.commonSave),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _delete(BuildContext context, WidgetRef ref, MenuExtraGroup group) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        content: Text(l10n.menuItemDeleteRowConfirm),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text(l10n.commonCancel)),
          TextButton(onPressed: () => Navigator.pop(context, true), child: Text(l10n.commonDelete)),
        ],
      ),
    );
    if (confirmed == true) {
      await ref.read(menuItemEditControllerProvider(item.id).notifier).deleteExtraGroup(group.id);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(l10n.menuItemExtraGroupsSection, style: Theme.of(context).textTheme.titleSmall),
            TextButton.icon(
              onPressed: () => _openForm(context, ref),
              icon: const Icon(Icons.add),
              label: Text(l10n.menuItemAddExtraGroup),
            ),
          ],
        ),
        for (final g in item.extraGroups)
          Card(
            margin: const EdgeInsets.only(top: 8),
            child: ListTile(
              onTap: () => _openForm(context, ref, existing: g),
              title: Text(g.nameAr),
              subtitle: Text(
                g.isSingle ? l10n.menuItemExtraGroupSelectionSingle : l10n.menuItemExtraGroupSelectionMultiple,
              ),
              trailing: IconButton(icon: const Icon(Icons.delete_outline), onPressed: () => _delete(context, ref, g)),
            ),
          ),
      ],
    );
  }
}

class _ExtrasSection extends ConsumerWidget {
  final BusinessMenuItem item;
  const _ExtrasSection({required this.item});

  Future<void> _openForm(BuildContext context, WidgetRef ref, {MenuExtra? existing}) async {
    final l10n = AppLocalizations.of(context)!;
    int? extraGroupId = existing?.extraGroupId;
    final nameArController = TextEditingController(text: existing?.nameAr ?? '');
    final nameEnController = TextEditingController(text: existing?.nameEn ?? '');
    final priceController = TextEditingController(text: existing?.price.toStringAsFixed(2) ?? '');
    final maxQtyController = TextEditingController(text: '${existing?.maxQty ?? 1}');
    String? error;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) => StatefulBuilder(
        builder: (sheetContext, setSheetState) => Padding(
          padding: EdgeInsets.fromLTRB(20, 20, 20, 20 + MediaQuery.of(sheetContext).viewInsets.bottom),
          child: SafeArea(
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    existing == null ? l10n.menuItemAddExtra : l10n.menuItemEditExtra,
                    style: Theme.of(sheetContext).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<int?>(
                    initialValue: extraGroupId,
                    decoration: InputDecoration(labelText: l10n.menuItemExtraGroupHint),
                    items: [
                      DropdownMenuItem(value: null, child: Text(l10n.menuItemExtraGroupNone)),
                      for (final g in item.extraGroups) DropdownMenuItem(value: g.id, child: Text(g.nameAr)),
                    ],
                    onChanged: (v) => setSheetState(() => extraGroupId = v),
                  ),
                  const SizedBox(height: 12),
                  TextField(controller: nameArController, decoration: InputDecoration(labelText: l10n.menuItemNameArHint)),
                  const SizedBox(height: 12),
                  TextField(controller: nameEnController, decoration: InputDecoration(labelText: l10n.menuItemNameEnHint)),
                  const SizedBox(height: 12),
                  TextField(
                    controller: priceController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(labelText: l10n.menuItemExtraPriceHint),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: maxQtyController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(labelText: l10n.menuItemExtraMaxQtyHint),
                  ),
                  if (error != null) ...[
                    const SizedBox(height: 8),
                    Text(error!, style: TextStyle(color: Theme.of(sheetContext).colorScheme.error)),
                  ],
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: () async {
                      final price = double.tryParse(priceController.text.trim());
                      if (nameArController.text.trim().isEmpty || price == null) {
                        setSheetState(() => error = l10n.menuPriceRequired);
                        return;
                      }
                      try {
                        final notifier = ref.read(menuItemEditControllerProvider(item.id).notifier);
                        final maxQty = int.tryParse(maxQtyController.text.trim()) ?? 1;
                        if (existing == null) {
                          await notifier.addExtra(
                            extraGroupId: extraGroupId,
                            nameAr: nameArController.text.trim(),
                            nameEn: nameEnController.text.trim(),
                            price: price,
                            maxQty: maxQty,
                          );
                        } else {
                          await notifier.updateExtra(
                            existing.id,
                            extraGroupId: extraGroupId,
                            nameAr: nameArController.text.trim(),
                            nameEn: nameEnController.text.trim(),
                            price: price,
                            maxQty: maxQty,
                          );
                        }
                        if (sheetContext.mounted) Navigator.of(sheetContext).pop();
                      } catch (_) {
                        setSheetState(() => error = l10n.commonSomethingWentWrong);
                      }
                    },
                    child: Text(l10n.commonSave),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _delete(BuildContext context, WidgetRef ref, MenuExtra extra) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        content: Text(l10n.menuItemDeleteRowConfirm),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text(l10n.commonCancel)),
          TextButton(onPressed: () => Navigator.pop(context, true), child: Text(l10n.commonDelete)),
        ],
      ),
    );
    if (confirmed == true) {
      await ref.read(menuItemEditControllerProvider(item.id).notifier).deleteExtra(extra.id);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(l10n.menuItemExtrasSection, style: Theme.of(context).textTheme.titleSmall),
            TextButton.icon(
              onPressed: () => _openForm(context, ref),
              icon: const Icon(Icons.add),
              label: Text(l10n.menuItemAddExtra),
            ),
          ],
        ),
        for (final e in item.extras)
          Card(
            margin: const EdgeInsets.only(top: 8),
            child: ListTile(
              onTap: () => _openForm(context, ref, existing: e),
              title: Text(e.nameAr),
              subtitle: Text(
                e.extraGroupId == null
                    ? e.price.toStringAsFixed(2)
                    : '${item.extraGroups.firstWhere((g) => g.id == e.extraGroupId, orElse: () => MenuExtraGroup(id: 0, nameAr: '', selectionType: MenuExtraGroup.selectionMultiple, isActive: true)).nameAr} · ${e.price.toStringAsFixed(2)}',
              ),
              trailing: IconButton(icon: const Icon(Icons.delete_outline), onPressed: () => _delete(context, ref, e)),
            ),
          ),
      ],
    );
  }
}

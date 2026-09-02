import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../l10n/app_localizations.dart';
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
  const MenuItemEditScreen({super.key, this.itemId});

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
  final _sortController = TextEditingController(text: '0');
  int? _sectionId;
  bool _isActive = true;
  bool _saving = false;
  String? _error;
  bool _initialized = false;

  @override
  void dispose() {
    _nameArController.dispose();
    _nameEnController.dispose();
    _descArController.dispose();
    _descEnController.dispose();
    _priceController.dispose();
    _supplyPriceController.dispose();
    _brandController.dispose();
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
    _sortController.text = '${item.sortOrder}';
    _sectionId = item.menuSectionId;
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
      if (widget.itemId == null) {
        final created = await api.createItem(
          nameAr: _nameArController.text.trim(),
          nameEn: _nameEnController.text.trim(),
          menuSectionId: _sectionId,
          descriptionAr: _descArController.text.trim(),
          descriptionEn: _descEnController.text.trim(),
          basePrice: price,
          supplyPrice: supplyPrice,
          brandName: _brandController.text.trim(),
          sortOrder: int.tryParse(_sortController.text.trim()) ?? 0,
          isActive: _isActive,
        );
        if (mounted) Navigator.of(context).pop(created.id);
      } else {
        await api.updateItem(
          widget.itemId!,
          nameAr: _nameArController.text.trim(),
          nameEn: _nameEnController.text.trim(),
          menuSectionId: _sectionId,
          descriptionAr: _descArController.text.trim(),
          descriptionEn: _descEnController.text.trim(),
          basePrice: price,
          supplyPrice: supplyPrice,
          brandName: _brandController.text.trim(),
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
        body: _buildForm(context, l10n, sectionsState.items),
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
              _buildFormFields(context, l10n, sectionsState.items),
              const SizedBox(height: 24),
              _ImagesSection(item: item),
              const SizedBox(height: 24),
              _VariantsSection(item: item),
              const SizedBox(height: 24),
              _ExtrasSection(item: item),
            ],
          );
        },
      ),
    );
  }

  Widget _buildForm(BuildContext context, AppLocalizations l10n, List<BusinessMenuSection> sections) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [_buildFormFields(context, l10n, sections)],
    );
  }

  Widget _buildFormFields(BuildContext context, AppLocalizations l10n, List<BusinessMenuSection> sections) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _nameArController,
          decoration: InputDecoration(labelText: l10n.menuItemNameArHint),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _nameEnController,
          decoration: InputDecoration(labelText: l10n.menuItemNameEnHint),
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<int?>(
          initialValue: _sectionId,
          decoration: InputDecoration(labelText: l10n.menuItemSectionLabel),
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
          decoration: InputDecoration(labelText: l10n.menuItemDescriptionArHint),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _descEnController,
          maxLines: 2,
          decoration: InputDecoration(labelText: l10n.menuItemDescriptionEnHint),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _priceController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(labelText: l10n.menuItemBasePriceHint),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _supplyPriceController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(labelText: l10n.menuItemSupplyPriceHint),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _brandController,
          decoration: InputDecoration(labelText: l10n.menuItemBrandNameHint),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _sortController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(labelText: l10n.menuItemSortOrderHint),
        ),
        const SizedBox(height: 8),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(l10n.menuItemActiveLabel),
          value: _isActive,
          onChanged: (v) => setState(() => _isActive = v),
        ),
        if (_error != null) ...[
          const SizedBox(height: 8),
          Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
        ],
        const SizedBox(height: 16),
        FilledButton(
          onPressed: _saving ? null : _save,
          child: _saving
              ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
              : Text(l10n.commonSave),
        ),
      ],
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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(l10n.menuItemImagesSection, style: Theme.of(context).textTheme.titleSmall),
            TextButton.icon(
              onPressed: _uploading ? null : _addImage,
              icon: _uploading
                  ? const SizedBox(height: 16, width: 16, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.add_photo_alternate_outlined),
              label: Text(l10n.menuItemAddImage),
            ),
          ],
        ),
        if (widget.item.images.isNotEmpty)
          SizedBox(
            height: 90,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: widget.item.images.length,
              separatorBuilder: (context, index) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final image = widget.item.images[index];
                return Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(image.url, width: 90, height: 90, fit: BoxFit.cover),
                    ),
                    Positioned(
                      top: 0,
                      right: 0,
                      child: InkWell(
                        onTap: () => _deleteImage(image.id),
                        child: const CircleAvatar(
                          radius: 12,
                          backgroundColor: Colors.black54,
                          child: Icon(Icons.close, size: 14, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
      ],
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
            TextButton.icon(
              onPressed: () => _openForm(context, ref),
              icon: const Icon(Icons.add),
              label: Text(l10n.menuItemAddVariant),
            ),
          ],
        ),
        for (final v in item.variants)
          Card(
            margin: const EdgeInsets.only(top: 8),
            child: ListTile(
              onTap: () => _openForm(context, ref, existing: v),
              title: Text('${v.type}: ${v.nameAr}${v.isDefault ? ' ★' : ''}'),
              subtitle: Text(
                v.price != null ? v.price!.toStringAsFixed(2) : (v.priceDelta != null ? '+${v.priceDelta!.toStringAsFixed(2)}' : ''),
              ),
              trailing: IconButton(icon: const Icon(Icons.delete_outline), onPressed: () => _delete(context, ref, v)),
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
    final groupController = TextEditingController(text: existing?.groupKey ?? '');
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
                  TextField(controller: groupController, decoration: InputDecoration(labelText: l10n.menuItemExtraGroupHint)),
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
                            groupKey: groupController.text.trim(),
                            nameAr: nameArController.text.trim(),
                            nameEn: nameEnController.text.trim(),
                            price: price,
                            maxQty: maxQty,
                          );
                        } else {
                          await notifier.updateExtra(
                            existing.id,
                            groupKey: groupController.text.trim(),
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
              subtitle: Text(e.price.toStringAsFixed(2)),
              trailing: IconButton(icon: const Icon(Icons.delete_outline), onPressed: () => _delete(context, ref, e)),
            ),
          ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../business_menu/application/business_menu_providers.dart';
import '../../../business_menu/data/models/menu_item.dart';
import '../../application/menu_bundle_providers.dart';
import '../../data/models/menu_bundle.dart';

/// Create (bundleId == null) or edit one bundle — name, pricing mode, and its
/// fixed component list, all in one form (unlike a menu item's variants/
/// extras, a bundle's composition isn't a sub-resource with its own screen:
/// it's edited as a whole, matching how the backend saves it).
class MenuBundleEditScreen extends ConsumerStatefulWidget {
  final int? bundleId;
  const MenuBundleEditScreen({super.key, this.bundleId});

  @override
  ConsumerState<MenuBundleEditScreen> createState() => _MenuBundleEditScreenState();
}

class _MenuBundleEditScreenState extends ConsumerState<MenuBundleEditScreen> {
  final _nameArController = TextEditingController();
  final _nameEnController = TextEditingController();
  final _priceController = TextEditingController();

  String _pricingMode = MenuBundle.pricingFixed;
  bool _isActive = true;
  bool _saving = false;
  bool _loadingMenuItems = true;
  String? _error;
  bool _seeded = false;

  /// menu_item_id → qty, insertion order preserved for a stable form.
  final Map<int, int> _selected = {};
  List<BusinessMenuItem> _menuItems = const [];

  bool get _isEdit => widget.bundleId != null;

  @override
  void initState() {
    super.initState();
    _loadMenuItems();
  }

  Future<void> _loadMenuItems() async {
    try {
      final api = ref.read(businessMenuApiProvider);
      final page = await api.items(isActive: true, page: 1);
      if (mounted) setState(() => _menuItems = page.items);
    } catch (_) {
      // The picker just stays empty; the form's own error banner (on save)
      // covers a genuinely broken connection.
    } finally {
      if (mounted) setState(() => _loadingMenuItems = false);
    }
  }

  void _seedFrom(MenuBundle bundle) {
    if (_seeded) return;
    _seeded = true;
    _nameArController.text = bundle.nameAr;
    _nameEnController.text = bundle.nameEn ?? '';
    _pricingMode = bundle.pricingMode;
    _priceController.text = bundle.pricingMode == MenuBundle.pricingFixed
        ? (bundle.fixedPrice?.toStringAsFixed(2) ?? '')
        : (bundle.discountValue?.toStringAsFixed(2) ?? '');
    _isActive = bundle.isActive;
    for (final item in bundle.items) {
      _selected[item.menuItemId] = item.qty;
    }
  }

  @override
  void dispose() {
    _nameArController.dispose();
    _nameEnController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  double get _componentsSubtotal {
    var sum = 0.0;
    for (final item in _menuItems) {
      final qty = _selected[item.id];
      if (qty != null) sum += item.basePrice * qty;
    }
    return sum;
  }

  double? get _previewPrice {
    final value = double.tryParse(_priceController.text.trim());
    if (value == null) return null;
    return switch (_pricingMode) {
      MenuBundle.pricingDiscountPercent => (_componentsSubtotal * (1 - value / 100)).clamp(0, double.infinity),
      MenuBundle.pricingDiscountFixed => (_componentsSubtotal - value).clamp(0, double.infinity),
      _ => value,
    };
  }

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context)!;
    final nameAr = _nameArController.text.trim();
    final price = double.tryParse(_priceController.text.trim());

    if (nameAr.isEmpty || price == null || _selected.length < 2) {
      setState(() => _error = l10n.menuBundleFormError);
      return;
    }

    setState(() {
      _saving = true;
      _error = null;
    });

    final items = _selected.entries.map((e) => MapEntry(e.key, e.value)).toList();

    try {
      final controller = ref.read(menuBundlesControllerProvider.notifier);
      if (_isEdit) {
        await controller.update(
          widget.bundleId!,
          nameAr: nameAr,
          nameEn: _nameEnController.text.trim().isEmpty ? null : _nameEnController.text.trim(),
          pricingMode: _pricingMode,
          fixedPrice: _pricingMode == MenuBundle.pricingFixed ? price : null,
          discountValue: _pricingMode == MenuBundle.pricingFixed ? null : price,
          items: items,
          isActive: _isActive,
        );
      } else {
        await controller.create(
          nameAr: nameAr,
          nameEn: _nameEnController.text.trim().isEmpty ? null : _nameEnController.text.trim(),
          pricingMode: _pricingMode,
          fixedPrice: _pricingMode == MenuBundle.pricingFixed ? price : null,
          discountValue: _pricingMode == MenuBundle.pricingFixed ? null : price,
          items: items,
          isActive: _isActive,
        );
      }
      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      if (mounted) setState(() => _error = l10n.commonSomethingWentWrong);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    if (_isEdit) {
      final async = ref.watch(menuBundlesControllerProvider);
      final bundle = async.items.where((b) => b.id == widget.bundleId).firstOrNull;
      if (bundle != null) _seedFrom(bundle);
    }

    return Scaffold(
      appBar: AppBar(title: Text(_isEdit ? l10n.menuBundleEditTitle : l10n.menuBundleAdd)),
      body: _loadingMenuItems
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                TextField(
                  controller: _nameArController,
                  decoration: InputDecoration(labelText: l10n.menuItemNameArHint),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _nameEnController,
                  decoration: InputDecoration(labelText: l10n.menuItemNameEnHint),
                ),
                const SizedBox(height: 16),
                Text(l10n.menuBundlePricingMode, style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(height: 4),
                SegmentedButton<String>(
                  segments: [
                    ButtonSegment(value: MenuBundle.pricingFixed, label: Text(l10n.menuBundlePricingFixed)),
                    ButtonSegment(value: MenuBundle.pricingDiscountPercent, label: Text(l10n.menuBundlePricingDiscountPercent)),
                    ButtonSegment(value: MenuBundle.pricingDiscountFixed, label: Text(l10n.menuBundlePricingDiscountFixed)),
                  ],
                  selected: {_pricingMode},
                  onSelectionChanged: (s) => setState(() => _pricingMode = s.first),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _priceController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    labelText: _pricingMode == MenuBundle.pricingFixed
                        ? l10n.menuBundleFixedPrice
                        : _pricingMode == MenuBundle.pricingDiscountPercent
                        ? l10n.menuBundleDiscountPercent
                        : l10n.menuBundleDiscountFixed,
                  ),
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 8),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  value: _isActive,
                  onChanged: (v) => setState(() => _isActive = v),
                  title: Text(l10n.menuItemActiveLabel),
                ),
                const Divider(height: 32),
                Text(l10n.menuBundleComponents, style: Theme.of(context).textTheme.titleSmall),
                Text(
                  l10n.menuBundleComponentsHint,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).hintColor),
                ),
                const SizedBox(height: 8),
                for (final item in _menuItems)
                  _ComponentRow(
                    item: item,
                    qty: _selected[item.id],
                    onToggle: (checked) => setState(() {
                      if (checked) {
                        _selected[item.id] = 1;
                      } else {
                        _selected.remove(item.id);
                      }
                    }),
                    onQtyChanged: (qty) => setState(() => _selected[item.id] = qty),
                  ),
                const SizedBox(height: 16),
                if (_selected.isNotEmpty) ...[
                  Text('${l10n.menuBundleComponentsSubtotal}: ${_componentsSubtotal.toStringAsFixed(2)}'),
                  if (_previewPrice != null)
                    Text(
                      '${l10n.menuBundleFinalPrice}: ${_previewPrice!.toStringAsFixed(2)}',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  const SizedBox(height: 16),
                ],
                if (_error != null) ...[
                  Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
                  const SizedBox(height: 8),
                ],
                FilledButton(
                  onPressed: _saving ? null : _save,
                  child: _saving
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                      : Text(l10n.commonSave),
                ),
              ],
            ),
    );
  }
}

class _ComponentRow extends StatelessWidget {
  final BusinessMenuItem item;
  final int? qty;
  final ValueChanged<bool> onToggle;
  final ValueChanged<int> onQtyChanged;

  const _ComponentRow({required this.item, required this.qty, required this.onToggle, required this.onQtyChanged});

  @override
  Widget build(BuildContext context) {
    final selected = qty != null;
    return Row(
      children: [
        Expanded(
          child: CheckboxListTile(
            contentPadding: EdgeInsets.zero,
            value: selected,
            onChanged: (checked) => onToggle(checked ?? false),
            title: Text(item.nameAr),
            subtitle: Text(item.basePrice.toStringAsFixed(2)),
          ),
        ),
        if (selected) ...[
          IconButton(
            onPressed: qty! > 1 ? () => onQtyChanged(qty! - 1) : null,
            icon: const Icon(Icons.remove_circle_outline),
          ),
          SizedBox(width: 24, child: Text('$qty', textAlign: TextAlign.center)),
          IconButton(
            onPressed: () => onQtyChanged(qty! + 1),
            icon: const Icon(Icons.add_circle_outline),
          ),
        ],
      ],
    );
  }
}

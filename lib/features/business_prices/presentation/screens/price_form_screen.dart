import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../l10n/app_localizations.dart';
import '../../application/business_prices_providers.dart';
import '../../data/models/price_options.dart';
import '../../data/models/price_row.dart';

/// Create or edit one (service, item type, line) price row. Mirrors the web
/// `business.prices` create/edit form, including the line/modifier
/// vocabulary picker — see Api\V2\BusinessServicePriceController.
class PriceFormScreen extends ConsumerStatefulWidget {
  final PriceRow? existing;
  const PriceFormScreen({super.key, this.existing});

  @override
  ConsumerState<PriceFormScreen> createState() => _PriceFormScreenState();
}

class _PriceFormScreenState extends ConsumerState<PriceFormScreen> {
  int? _serviceId;
  String? _itemType;
  final _priceCtrl = TextEditingController();
  final _currencyCtrl = TextEditingController(text: 'EGP');
  String _chargeMode = 'standard';
  final _chargeAmountCtrl = TextEditingController();
  final _durationCtrl = TextEditingController();
  bool _isActive = true;
  bool _discountEnabled = false;
  final _discountPercentCtrl = TextEditingController();
  int? _lineOptionId;
  final Set<int> _selectedModifiers = {};
  final Map<int, TextEditingController> _modifierAdjustCtrls = {};
  final Map<int, String> _modifierAdjustType = {};

  bool _saving = false;
  String? _error;

  bool get _isEdit => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final existing = widget.existing;
    if (existing != null) {
      _serviceId = existing.service.id;
      _itemType = existing.bookableItemType;
      _priceCtrl.text = _trimNum(existing.price);
      _currencyCtrl.text = existing.currency;
      _chargeMode = existing.chargeMode;
      _chargeAmountCtrl.text = existing.chargeAmount != 0 ? _trimNum(existing.chargeAmount) : '';
      _durationCtrl.text = existing.durationMinutes?.toString() ?? '';
      _isActive = existing.isActive;
      _discountEnabled = existing.discountEnabled;
      _discountPercentCtrl.text = existing.discountPercent.toString();
      _lineOptionId = existing.lineOption?.id;
      for (final m in existing.modifierOptions) {
        _selectedModifiers.add(m.id);
        final adjust = existing.modifierAdjust[m.id];
        _modifierAdjustCtrls[m.id] = TextEditingController(text: adjust != null ? _trimNum(adjust.value) : '');
        _modifierAdjustType[m.id] = adjust?.type ?? 'amount';
      }
    }
  }

  String _trimNum(double v) {
    if (v == v.roundToDouble()) return v.toInt().toString();
    return v.toString();
  }

  TextEditingController _ctrlFor(int optionId) {
    return _modifierAdjustCtrls.putIfAbsent(optionId, () => TextEditingController());
  }

  @override
  void dispose() {
    _priceCtrl.dispose();
    _currencyCtrl.dispose();
    _chargeAmountCtrl.dispose();
    _durationCtrl.dispose();
    _discountPercentCtrl.dispose();
    for (final c in _modifierAdjustCtrls.values) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _save(PriceOptions options) async {
    final l10n = AppLocalizations.of(context)!;
    if (_serviceId == null || _itemType == null || _itemType!.isEmpty) {
      setState(() => _error = l10n.validationRequired);
      return;
    }
    final price = double.tryParse(_priceCtrl.text.trim());
    if (price == null || price < 0) {
      setState(() => _error = l10n.validationRequired);
      return;
    }

    final modifierAdjust = <int, double>{};
    final modifierAdjustType = <int, String>{};
    for (final id in _selectedModifiers) {
      final raw = _modifierAdjustCtrls[id]?.text.trim() ?? '';
      if (raw.isEmpty) continue;
      final value = double.tryParse(raw);
      if (value == null) continue;
      modifierAdjust[id] = value;
      modifierAdjustType[id] = _modifierAdjustType[id] ?? 'amount';
    }

    setState(() {
      _saving = true;
      _error = null;
    });

    final api = ref.read(businessPricesApiProvider);
    try {
      if (_isEdit) {
        await api.update(
          widget.existing!.id,
          serviceId: _serviceId!,
          bookableItemType: _itemType!,
          price: price,
          chargeMode: _chargeMode,
          chargeAmount: double.tryParse(_chargeAmountCtrl.text.trim()) ?? 0,
          durationMinutes: int.tryParse(_durationCtrl.text.trim()),
          currency: _currencyCtrl.text.trim().isEmpty ? 'EGP' : _currencyCtrl.text.trim(),
          isActive: _isActive,
          discountEnabled: _discountEnabled,
          discountPercent: _discountEnabled ? (int.tryParse(_discountPercentCtrl.text.trim()) ?? 0) : 0,
          lineOptionId: _lineOptionId,
          modifierOptionIds: _selectedModifiers.toList(),
          modifierAdjust: modifierAdjust,
          modifierAdjustType: modifierAdjustType,
        );
      } else {
        await api.create(
          serviceId: _serviceId!,
          bookableItemType: _itemType!,
          price: price,
          chargeMode: _chargeMode,
          chargeAmount: double.tryParse(_chargeAmountCtrl.text.trim()) ?? 0,
          durationMinutes: int.tryParse(_durationCtrl.text.trim()),
          currency: _currencyCtrl.text.trim().isEmpty ? 'EGP' : _currencyCtrl.text.trim(),
          isActive: _isActive,
          discountEnabled: _discountEnabled,
          discountPercent: _discountEnabled ? (int.tryParse(_discountPercentCtrl.text.trim()) ?? 0) : 0,
          lineOptionId: _lineOptionId,
          modifierOptionIds: _selectedModifiers.toList(),
          modifierAdjust: modifierAdjust,
          modifierAdjustType: modifierAdjustType,
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

  String _chargeModeLabel(AppLocalizations l10n, String mode) => switch (mode) {
    'free' => l10n.priceChargeModeFree,
    'reservation_fee' => l10n.priceChargeModeReservationFee,
    'minimum_charge' => l10n.priceChargeModeMinimum,
    _ => l10n.priceChargeModeStandard,
  };

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final optionsAsync = ref.watch(priceOptionsProvider);

    return Scaffold(
      appBar: AppBar(title: Text(_isEdit ? l10n.businessPriceEditTitle : l10n.businessPriceAddTitle)),
      body: optionsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => Center(child: Text(l10n.commonSomethingWentWrong)),
        data: (options) {
          if (options.services.isEmpty) {
            return Center(child: Padding(padding: const EdgeInsets.all(24), child: Text(l10n.priceNoServicesWarning)));
          }
          PriceServiceOption? currentService;
          for (final s in options.services) {
            if (s.id == _serviceId) {
              currentService = s;
              break;
            }
          }
          final itemTypes = currentService?.itemTypes ?? const [];

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DropdownButtonFormField<int>(
                  initialValue: _serviceId,
                  decoration: InputDecoration(labelText: l10n.priceFieldService),
                  items: options.services
                      .map((s) => DropdownMenuItem(value: s.id, child: Text(s.name ?? s.key ?? '#${s.id}')))
                      .toList(),
                  onChanged: (v) => setState(() {
                    _serviceId = v;
                    _itemType = null;
                  }),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: itemTypes.any((t) => t.key == _itemType) ? _itemType : null,
                  decoration: InputDecoration(
                    labelText: l10n.priceFieldItemType,
                    hintText: currentService == null
                        ? l10n.priceFieldItemTypePickServiceFirst
                        : (itemTypes.isEmpty ? l10n.priceFieldItemTypeEmpty : l10n.priceFieldItemTypeHint),
                  ),
                  items: itemTypes.map((t) => DropdownMenuItem(value: t.key, child: Text(t.label ?? t.key))).toList(),
                  onChanged: currentService == null ? null : (v) => setState(() => _itemType = v),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: TextField(
                        controller: _priceCtrl,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: InputDecoration(labelText: l10n.priceFieldPrice),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: _currencyCtrl,
                        textCapitalization: TextCapitalization.characters,
                        decoration: InputDecoration(labelText: l10n.priceFieldCurrency),
                      ),
                    ),
                  ],
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  value: _isActive,
                  onChanged: (v) => setState(() => _isActive = v),
                  title: Text(l10n.priceFieldActive),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  initialValue: _chargeMode,
                  decoration: InputDecoration(labelText: l10n.priceChargeModeLabel),
                  items: options.chargeModes
                      .map((m) => DropdownMenuItem(value: m, child: Text(_chargeModeLabel(l10n, m))))
                      .toList(),
                  onChanged: (v) => setState(() => _chargeMode = v ?? 'standard'),
                ),
                if (_chargeMode == 'reservation_fee' || _chargeMode == 'minimum_charge') ...[
                  const SizedBox(height: 12),
                  TextField(
                    controller: _chargeAmountCtrl,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(labelText: l10n.priceFieldChargeAmount),
                  ),
                ],
                const SizedBox(height: 12),
                TextField(
                  controller: _durationCtrl,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: l10n.priceFieldDuration, hintText: l10n.priceFieldDurationHint),
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  value: _discountEnabled,
                  onChanged: (v) => setState(() => _discountEnabled = v),
                  title: Text(l10n.priceDiscountEnable),
                ),
                if (_discountEnabled) ...[
                  const SizedBox(height: 4),
                  TextField(
                    controller: _discountPercentCtrl,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(labelText: l10n.priceFieldDiscountPercent),
                  ),
                ],
                if (options.lines.isNotEmpty || options.modifiers.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  Text(l10n.priceVocabTitle, style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                ],
                if (options.lines.isNotEmpty) ...[
                  DropdownButtonFormField<int>(
                    initialValue: _lineOptionId,
                    decoration: InputDecoration(labelText: l10n.priceLineLabel),
                    items: [
                      DropdownMenuItem<int>(value: null, child: Text(l10n.priceLineNone)),
                      for (final group in options.lines)
                        for (final option in group.options)
                          DropdownMenuItem<int>(value: option.id, child: Text('${group.group} — ${option.name ?? ''}')),
                    ],
                    onChanged: (v) => setState(() => _lineOptionId = v),
                  ),
                  const SizedBox(height: 12),
                ],
                if (options.modifiers.isNotEmpty) ...[
                  Text(l10n.priceModifiersLabel, style: Theme.of(context).textTheme.labelLarge),
                  for (final group in options.modifiers) ...[
                    Padding(
                      padding: const EdgeInsets.only(top: 8, bottom: 4),
                      child: Text(group.group, style: Theme.of(context).textTheme.bodySmall),
                    ),
                    for (final option in group.options) _ModifierRow(
                      option: option,
                      selected: _selectedModifiers.contains(option.id),
                      adjustController: _ctrlFor(option.id),
                      adjustType: _modifierAdjustType[option.id] ?? 'amount',
                      onToggle: (checked) => setState(() {
                        if (checked) {
                          _selectedModifiers.add(option.id);
                        } else {
                          _selectedModifiers.remove(option.id);
                        }
                      }),
                      onTypeChanged: (type) => setState(() => _modifierAdjustType[option.id] = type),
                    ),
                  ],
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(l10n.priceModifierAdjustHint, style: Theme.of(context).textTheme.bodySmall),
                  ),
                ],
                if (_error != null) ...[
                  const SizedBox(height: 12),
                  Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
                ],
                const SizedBox(height: 20),
                FilledButton(
                  onPressed: _saving ? null : () => _save(options),
                  child: _saving
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                      : Text(l10n.commonSave),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _ModifierRow extends StatelessWidget {
  final PriceVocabOption option;
  final bool selected;
  final TextEditingController adjustController;
  final String adjustType;
  final ValueChanged<bool> onToggle;
  final ValueChanged<String> onTypeChanged;

  const _ModifierRow({
    required this.option,
    required this.selected,
    required this.adjustController,
    required this.adjustType,
    required this.onToggle,
    required this.onTypeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Checkbox(value: selected, onChanged: (v) => onToggle(v ?? false)),
        Expanded(child: Text(option.name ?? '#${option.id}')),
        if (selected) ...[
          SizedBox(
            width: 70,
            child: TextField(
              controller: adjustController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
              decoration: const InputDecoration(isDense: true, hintText: '0'),
            ),
          ),
          const SizedBox(width: 6),
          DropdownButton<String>(
            value: adjustType,
            items: const [
              DropdownMenuItem(value: 'amount', child: Text('ج')),
              DropdownMenuItem(value: 'percent', child: Text('%')),
            ],
            onChanged: (v) => onTypeChanged(v ?? 'amount'),
          ),
        ],
      ],
    );
  }
}

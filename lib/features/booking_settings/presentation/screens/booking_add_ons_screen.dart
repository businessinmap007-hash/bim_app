import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/widgets/form_save_button.dart';
import '../../application/booking_settings_controller.dart';
import '../../data/models/add_on_models.dart';

/// «إضافات الحجز» — priced ONCE for the whole business, like a restaurant's extras:
///
///  · what the guest adds on top of the room (the meal plans: بدون / شامل الإفطار / نصف إقامة / إقامة كاملة — one
///    choice by default, shown to the guest as radio buttons), added to each night;
///  · what a particular room carries («إطلالة على المسبح +150») — priced here once, ticked on the rooms that have it.
class BookingAddOnsScreen extends ConsumerStatefulWidget {
  const BookingAddOnsScreen({super.key});

  @override
  ConsumerState<BookingAddOnsScreen> createState() => _BookingAddOnsScreenState();
}

class _BookingAddOnsScreenState extends ConsumerState<BookingAddOnsScreen> {
  BookingAddOns? _data;
  final _amounts = <int, TextEditingController>{};
  bool _failed = false;
  bool _saving = false;
  String? _error;
  String? _savedSignature;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    for (final c in _amounts.values) {
      c.dispose();
    }
    super.dispose();
  }

  String _text(double v) => v == 0 ? '' : (v % 1 == 0 ? v.toStringAsFixed(0) : v.toStringAsFixed(2));

  void _adopt(BookingAddOns data) {
    _data = data;
    for (final g in [...data.addOns, ...data.features]) {
      for (final o in g.options) {
        final c = _amounts.putIfAbsent(o.id, () => TextEditingController()..addListener(_refresh));
        c.text = _text(o.value);
      }
    }
    _savedSignature = _signature();
  }

  void _refresh() => setState(() {});

  Future<void> _load() async {
    try {
      final data = await ref.read(bookingSettingsApiProvider).bookingAddOns();
      if (mounted) setState(() => _adopt(data));
    } catch (_) {
      if (mounted) setState(() => _failed = true);
    }
  }

  /// The form as the server would receive it — the bar says «تم الحفظ» exactly while this equals what was saved.
  BookingAddOns _current() {
    List<AddOnGroup> read(List<AddOnGroup> groups) => [
      for (final g in groups)
        g.copyWith(
          options: [for (final o in g.options) o.copyWith(value: double.tryParse(_amounts[o.id]?.text.trim().replaceAll(',', '.') ?? '') ?? 0)],
        ),
    ];

    return BookingAddOns(addOns: read(_data!.addOns), features: read(_data!.features));
  }

  String _signature() => _data == null ? '' : jsonEncode(_current().toJson());

  void _edit({required bool feature, required int groupId, String? selectionType, int? optionId, bool? enabled, bool? perPerson}) {
    AddOnGroup change(AddOnGroup g) {
      if (g.groupId != groupId) return g;

      return g.copyWith(
        selectionType: selectionType,
        options: [for (final o in g.options) o.id == optionId ? o.copyWith(enabled: enabled, perPerson: perPerson) : o],
      );
    }

    setState(() {
      _data = BookingAddOns(
        addOns: feature ? _data!.addOns : [for (final g in _data!.addOns) change(g)],
        features: feature ? [for (final g in _data!.features) change(g)] : _data!.features,
      );
    });
  }

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context)!;
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      final saved = await ref.read(bookingSettingsApiProvider).saveBookingAddOns(_current());
      if (mounted) setState(() => _adopt(saved));
    } catch (e) {
      if (mounted) setState(() => _error = e is ApiException && e.message.isNotEmpty ? e.message : l10n.commonSomethingWentWrong);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Widget _option(BuildContext context, AppLocalizations l10n, AddOnGroup group, AddOnOption o, {required bool feature}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(o.name),
          value: o.enabled,
          onChanged: (v) => _edit(feature: feature, groupId: group.groupId, optionId: o.id, enabled: v),
        ),
        if (o.enabled)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _amounts[o.id],
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(labelText: feature ? l10n.addOnPriceFeature : l10n.addOnPricePerNight, prefixText: '+'),
                  ),
                ),
                if (!feature) ...[
                  const SizedBox(width: 12),
                  Row(
                    children: [
                      Checkbox(value: o.perPerson, onChanged: (v) => _edit(feature: false, groupId: group.groupId, optionId: o.id, perPerson: v ?? false)),
                      Text(l10n.addOnPerPerson),
                    ],
                  ),
                ],
              ],
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final data = _data;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.bookingAddOnsTitle)),
      body: _failed
          ? Center(child: Text(l10n.commonSomethingWentWrong))
          : data == null
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text(l10n.bookingAddOnsIntro, style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor)),
                if (data.addOns.isEmpty && data.features.isEmpty) ...[
                  const SizedBox(height: 24),
                  Center(child: Text(l10n.bookingAddOnsEmpty)),
                ],
                if (data.addOns.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  Text(l10n.bookingAddOnsGuestChoice, style: theme.textTheme.titleMedium),
                  for (final group in data.addOns) ...[
                    const SizedBox(height: 12),
                    Text(group.name, style: theme.textTheme.titleSmall),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: SegmentedButton<String>(
                        segments: [
                          ButtonSegment(value: 'single', label: Text(l10n.addOnSelectionSingle)),
                          ButtonSegment(value: 'multiple', label: Text(l10n.addOnSelectionMultiple)),
                        ],
                        selected: {group.selectionType ?? 'single'},
                        onSelectionChanged: (s) => _edit(feature: false, groupId: group.groupId, selectionType: s.first),
                      ),
                    ),
                    for (final o in group.options) _option(context, l10n, group, o, feature: false),
                  ],
                ],
                if (data.features.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  Text(l10n.bookingAddOnsRoomFeatures, style: theme.textTheme.titleMedium),
                  const SizedBox(height: 4),
                  Text(l10n.bookingAddOnsRoomFeaturesHint, style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor)),
                  for (final group in data.features) ...[
                    const SizedBox(height: 12),
                    Text(group.name, style: theme.textTheme.titleSmall),
                    for (final o in group.options) _option(context, l10n, group, o, feature: true),
                  ],
                ],
                if (_error != null) ...[
                  const SizedBox(height: 12),
                  Text(_error!, style: TextStyle(color: theme.colorScheme.error)),
                ],
                if (data.addOns.isNotEmpty || data.features.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  FormSaveButton(saving: _saving, saved: _savedSignature == _signature(), onPressed: _save),
                ],
              ],
            ),
    );
  }
}

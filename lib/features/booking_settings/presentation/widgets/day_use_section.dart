import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../l10n/app_localizations.dart';
import '../../application/booking_settings_controller.dart';
import '../../data/models/room_models.dart';

/// «خدمة Day use للحجز في الفنادق» — this room type also sold through the day, no night: a time window and a flat
/// price. The guest picks only a date; one room of the type is held for that window.
class DayUseSection extends ConsumerStatefulWidget {
  final int itemId;
  const DayUseSection({super.key, required this.itemId});

  @override
  ConsumerState<DayUseSection> createState() => _DayUseSectionState();
}

class _DayUseSectionState extends ConsumerState<DayUseSection> {
  final _price = TextEditingController();
  DayUseSettings _settings = const DayUseSettings();
  bool _loaded = false;
  bool _failed = false;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _price.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final settings = await ref.read(bookingSettingsApiProvider).dayUse(widget.itemId);
      if (!mounted) return;
      setState(() {
        _settings = settings;
        _price.text = settings.price == null ? '' : settings.price!.toStringAsFixed(settings.price! % 1 == 0 ? 0 : 2);
        _loaded = true;
      });
    } catch (_) {
      if (mounted) setState(() => _failed = true);
    }
  }

  Future<void> _pick({required bool isFrom}) async {
    final current = isFrom ? _settings.from : _settings.to;
    final parts = current.split(':');
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: int.tryParse(parts[0]) ?? 9, minute: int.tryParse(parts.length > 1 ? parts[1] : '0') ?? 0),
    );
    if (picked == null) return;
    final text = '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
    setState(() => _settings = DayUseSettings(enabled: _settings.enabled, from: isFrom ? text : _settings.from, to: isFrom ? _settings.to : text, price: _settings.price));
  }

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context)!;
    setState(() => _busy = true);
    try {
      final price = double.tryParse(_price.text.trim().replaceAll(',', '.'));
      final saved = await ref.read(bookingSettingsApiProvider).saveDayUse(
        widget.itemId,
        DayUseSettings(enabled: _settings.enabled, from: _settings.from, to: _settings.to, price: price),
      );
      if (!mounted) return;
      setState(() => _settings = saved);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.dayUseSaved)));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e is ApiException ? e.message : l10n.commonSomethingWentWrong)));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    if (_failed) return const SizedBox.shrink();
    if (!_loaded) return const Padding(padding: EdgeInsets.all(16), child: Center(child: CircularProgressIndicator()));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.dayUseSettingsTitle, style: theme.textTheme.titleMedium),
        const SizedBox(height: 4),
        Text(l10n.dayUseSettingsHint, style: theme.textTheme.bodySmall),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(l10n.dayUseEnable),
          value: _settings.enabled,
          onChanged: _busy
              ? null
              : (v) => setState(() => _settings = DayUseSettings(enabled: v, from: _settings.from, to: _settings.to, price: _settings.price)),
        ),
        if (_settings.enabled) ...[
          Row(
            children: [
              Expanded(
                child: OutlinedButton(onPressed: _busy ? null : () => _pick(isFrom: true), child: Text('${l10n.dayUseFrom} ${_settings.from}')),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton(onPressed: _busy ? null : () => _pick(isFrom: false), child: Text('${l10n.dayUseTo} ${_settings.to}')),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _price,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(labelText: l10n.dayUsePrice),
          ),
        ],
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: _busy ? null : _save,
            child: _busy ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2)) : Text(l10n.dayUseSave),
          ),
        ),
      ],
    );
  }
}

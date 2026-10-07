import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';
import '../../data/models/room_models.dart';

/// «خدمة Day use للحجز في الفنادق» — this room type also sold through the day, no night: a time window and a flat
/// price. The guest picks only a date; one room of the type is held for that window.
///
/// Fields only: the room type's one save bar saves them together with the rest of the unit.
class DayUseFields extends StatelessWidget {
  final DayUseSettings value;
  final TextEditingController price;
  final ValueChanged<DayUseSettings> onChanged;
  const DayUseFields({super.key, required this.value, required this.price, required this.onChanged});

  DayUseSettings _with({bool? enabled, String? from, String? to}) =>
      DayUseSettings(enabled: enabled ?? value.enabled, from: from ?? value.from, to: to ?? value.to, price: value.price);

  Future<void> _pick(BuildContext context, {required bool isFrom}) async {
    final parts = (isFrom ? value.from : value.to).split(':');
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: int.tryParse(parts[0]) ?? 9, minute: int.tryParse(parts.length > 1 ? parts[1] : '0') ?? 0),
    );
    if (picked == null) return;
    final text = '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
    onChanged(isFrom ? _with(from: text) : _with(to: text));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.dayUseSettingsTitle, style: theme.textTheme.titleMedium),
        const SizedBox(height: 4),
        Text(l10n.dayUseSettingsHint, style: theme.textTheme.bodySmall),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(l10n.dayUseEnable),
          value: value.enabled,
          onChanged: (v) => onChanged(_with(enabled: v)),
        ),
        if (value.enabled) ...[
          Row(
            children: [
              Expanded(child: OutlinedButton(onPressed: () => _pick(context, isFrom: true), child: Text('${l10n.dayUseFrom} ${value.from}'))),
              const SizedBox(width: 8),
              Expanded(child: OutlinedButton(onPressed: () => _pick(context, isFrom: false), child: Text('${l10n.dayUseTo} ${value.to}'))),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: price,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(labelText: l10n.dayUsePrice),
          ),
        ],
      ],
    );
  }
}

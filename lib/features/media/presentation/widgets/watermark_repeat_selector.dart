import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../application/watermark_service.dart';

/// The owner's choice of how many times the watermark repeats — one of
/// [kWatermarkRepeatCounts], never a free-typed number (an uneven count
/// can't tile cleanly across the fixed 2-column grid WatermarkService uses).
class WatermarkRepeatSelector extends StatelessWidget {
  final int value;
  final ValueChanged<int> onChanged;

  const WatermarkRepeatSelector({super.key, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      children: kWatermarkRepeatCounts.map((count) {
        final selected = count == value;
        return ChoiceChip(
          label: Text('$count'),
          selected: selected,
          onSelected: (_) => onChanged(count),
          selectedColor: AppColors.accentGold,
          labelStyle: TextStyle(
            color: selected ? AppColors.primaryNavy : null,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
          ),
        );
      }).toList(),
    );
  }
}

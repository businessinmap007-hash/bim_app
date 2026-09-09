import 'package:flutter/material.dart';

/// A single button that shows the OTHER view's icon and name — tapping it
/// while looking at a list shows a grid icon (tap to switch TO grid), and
/// vice versa. Replaces a two-segment List/Grid control that always showed
/// both options at once; naming the one tap away reads faster at a glance
/// and takes half the width.
class ViewModeToggle extends StatelessWidget {
  final bool isGrid;
  final ValueChanged<bool> onChanged;
  final String listLabel;
  final String gridLabel;
  const ViewModeToggle({
    super.key,
    required this.isGrid,
    required this.onChanged,
    required this.listLabel,
    required this.gridLabel,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final targetIsGrid = !isGrid;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => onChanged(targetIsGrid),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: theme.dividerColor),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(targetIsGrid ? Icons.grid_view_outlined : Icons.view_list_outlined, size: 17),
              const SizedBox(width: 6),
              Text(targetIsGrid ? gridLabel : listLabel, style: theme.textTheme.labelMedium),
            ],
          ),
        ),
      ),
    );
  }
}

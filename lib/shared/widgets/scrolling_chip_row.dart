import 'package:flutter/material.dart';

/// «اذا زادت الاختيارات عن العرض لا تنزل للسطر التالي ولكن تتحول لاسكرول أفقي» — المالك، 2026-10-06. A row of
/// chips that stays ONE line: when the choices are wider than the screen it scrolls sideways instead of wrapping.
class ScrollingChipRow extends StatelessWidget {
  final List<Widget> children;
  final double spacing;
  const ScrollingChipRow({super.key, required this.children, this.spacing = 8});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (var i = 0; i < children.length; i++) ...[
            if (i > 0) SizedBox(width: spacing),
            children[i],
          ],
        ],
      ),
    );
  }
}

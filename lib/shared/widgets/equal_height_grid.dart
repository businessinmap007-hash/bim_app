import 'package:flutter/material.dart';

/// A grid whose every ROW is exactly as tall as its tallest cell — and no taller. A
/// fixed-extent grid has to guess the height of the biggest possible card, so the cards
/// that need less keep an empty band at the bottom; here each row measures its own cells
/// and stretches the shorter ones to match, so nothing is left over.
///
/// Meant for a short grid that sits inside another scroll view (it lays every row out, so
/// do not use it for hundreds of cells).
class EqualHeightGrid extends StatelessWidget {
  final int columns;
  final double crossAxisSpacing;
  final double mainAxisSpacing;
  final List<Widget> children;
  const EqualHeightGrid({
    super.key,
    required this.columns,
    this.crossAxisSpacing = 10,
    this.mainAxisSpacing = 10,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    final rows = <Widget>[];
    for (var start = 0; start < children.length; start += columns) {
      final cells = <Widget>[];
      for (var i = 0; i < columns; i++) {
        if (i > 0) cells.add(SizedBox(width: crossAxisSpacing));
        final index = start + i;
        // A missing cell in the last row keeps its column's width.
        cells.add(Expanded(child: index < children.length ? children[index] : const SizedBox.shrink()));
      }
      if (rows.isNotEmpty) rows.add(SizedBox(height: mainAxisSpacing));
      rows.add(IntrinsicHeight(child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: cells)));
    }
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: rows);
  }
}

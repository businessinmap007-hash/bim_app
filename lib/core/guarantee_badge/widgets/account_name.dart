import 'package:flutter/material.dart';

import 'guarantee_badge.dart';

/// An account's name with the guarantee level it wears beside it (the BIM coin) — the one way a screen shows who the
/// other side of a deal is. The name shrinks first when the row is tight; the coin keeps its place.
class AccountName extends StatelessWidget {
  final String text;
  final int? userId;
  final TextStyle? style;
  final int maxLines;
  final double badgeSize;

  const AccountName({super.key, required this.text, required this.userId, this.style, this.maxLines = 1, this.badgeSize = 18});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(child: Text(text, maxLines: maxLines, overflow: TextOverflow.ellipsis, style: style)),
        GuaranteeBadge(userId: userId, size: badgeSize),
      ],
    );
  }
}

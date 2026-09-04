import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';

/// Sent (single, muted check) vs read-by-the-other-side (double, gold check —
/// sized up so it actually reads at a glance, not a tiny corner mark) for my
/// own message. Sits outside the bubble: the sent bubble itself is gold, so a
/// gold check drawn on top of it would be invisible.
class MessageReadReceipt extends StatelessWidget {
  final bool isRead;
  const MessageReadReceipt({super.key, required this.isRead});

  @override
  Widget build(BuildContext context) {
    return Icon(
      isRead ? Icons.done_all : Icons.done,
      size: isRead ? 18 : 14,
      color: isRead ? AppColors.accentGold : Theme.of(context).hintColor,
    );
  }
}

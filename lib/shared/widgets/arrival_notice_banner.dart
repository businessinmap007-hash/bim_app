import 'package:flutter/material.dart';

/// «يجب التواجد قبل الموعد بـ ١٥ دقيقة» — the notice a business attaches to its bookings, as a soft strip. Draws
/// nothing when the business said nothing.
class ArrivalNoticeBanner extends StatelessWidget {
  final String? message;
  const ArrivalNoticeBanner({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final text = message?.trim() ?? '';
    if (text.isEmpty) return const SizedBox.shrink();

    final cs = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: cs.secondary.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cs.secondary.withValues(alpha: 0.5)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.schedule_rounded, size: 20, color: cs.onSurface),
          const SizedBox(width: 10),
          Expanded(child: Text(text, style: Theme.of(context).textTheme.bodyMedium)),
        ],
      ),
    );
  }
}

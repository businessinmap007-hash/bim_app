import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';
import '../../data/models/service_chair.dart';

/// A round photo of a person (or the chair's initial when there is none) — the face of a chair.
class ChairAvatar extends StatelessWidget {
  final ServiceChair? chair;
  final double size;
  const ChairAvatar({super.key, required this.chair, this.size = 56});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final photo = chair?.photoUrl;
    final initial = (chair?.title ?? '').isNotEmpty ? chair!.title.characters.first : '?';

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, color: cs.primary.withValues(alpha: 0.1)),
      clipBehavior: Clip.antiAlias,
      alignment: Alignment.center,
      child: chair == null
          ? Icon(Icons.groups_2_outlined, size: size * 0.5, color: cs.primary)
          : photo != null
          ? Image.network(
              photo,
              width: size,
              height: size,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Text(initial, style: TextStyle(fontSize: size * 0.4, fontWeight: FontWeight.w700, color: cs.primary)),
            )
          : Text(initial, style: TextStyle(fontSize: size * 0.4, fontWeight: FontWeight.w700, color: cs.primary)),
    );
  }
}

/// «اختر الحلاق»: one round face per chair after «أي حلاق متاح» — the customer books with that person, or with whoever
/// is free.
class ChairPicker extends StatelessWidget {
  final List<ServiceChair> chairs;
  final int? selected;
  final ValueChanged<int?> onPick;

  const ChairPicker({super.key, required this.chairs, required this.selected, required this.onPick});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    Widget face({required ServiceChair? chair, required String label, required bool on, required VoidCallback onTap}) {
      return Padding(
        padding: const EdgeInsetsDirectional.only(end: 12),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: SizedBox(
            width: 78,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: on ? cs.secondary : Colors.transparent, width: 2.5)),
                  child: ChairAvatar(chair: chair, size: 58),
                ),
                const SizedBox(height: 6),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.labelMedium?.copyWith(fontWeight: on ? FontWeight.w800 : FontWeight.w500),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return SizedBox(
      height: 100,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          face(chair: null, label: l10n.chairAnyone, on: selected == null, onTap: () => onPick(null)),
          for (final c in chairs) face(chair: c, label: c.title, on: selected == c.id, onTap: () => onPick(c.id)),
        ],
      ),
    );
  }
}

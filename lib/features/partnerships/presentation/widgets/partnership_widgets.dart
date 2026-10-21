import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../../data/models/partnership.dart';

String partnershipKindLabel(AppLocalizations l10n, String kind) {
  switch (kind) {
    case PartnershipKind.agency:
      return l10n.pshKindAgency;
    case PartnershipKind.reseller:
      return l10n.pshKindReseller;
    case PartnershipKind.supplier:
      return l10n.pshKindSupplier;
    case PartnershipKind.corporate:
      return l10n.pshKindCorporate;
    case PartnershipKind.hotelAllotment:
      return l10n.pshKindAllotment;
  }
  return kind;
}

(String, Color) partnershipStatusLabel(AppLocalizations l10n, String status) {
  switch (status) {
    case PartnershipStatus.active:
      return (l10n.pshStatusActive, AppColors.success);
    case PartnershipStatus.pending:
      return (l10n.pshStatusPending, AppColors.warning);
    case PartnershipStatus.paused:
      return (l10n.pshStatusPaused, AppColors.warning);
    case PartnershipStatus.rejected:
      return (l10n.pshStatusRejected, AppColors.error);
  }
  return (l10n.pshStatusEnded, AppColors.error);
}

String money(double v, String currency) => '${v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toStringAsFixed(2)} $currency';

/// A room as a card: photo, what it is, what it carries. The thing a tour company places into a trip programme — it never holds a price.
class RoomCardView extends StatelessWidget {
  final RoomCard room;
  final Widget? footer;

  const RoomCardView({super.key, required this.room, this.footer});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final facts = <String>[
      if ((room.kind ?? '').isNotEmpty) room.kind!,
      if (room.capacity != null) '${room.capacity}',
    ];

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: SizedBox(
            width: 84,
            height: 76,
            child: room.images.isEmpty
                ? ColoredBox(color: theme.colorScheme.surfaceContainerHighest, child: Icon(Icons.bed_outlined, color: theme.hintColor))
                : Image.network(
                    room.images.first,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => ColoredBox(color: theme.colorScheme.surfaceContainerHighest, child: Icon(Icons.bed_outlined, color: theme.hintColor)),
                  ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(room.label, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
              if (facts.isNotEmpty) Text(facts.join(' · '), style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor)),
              if (room.features.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(room.features.join(' · '), style: theme.textTheme.bodySmall, maxLines: 2, overflow: TextOverflow.ellipsis),
                ),
              if (footer != null) Padding(padding: const EdgeInsets.only(top: 6), child: footer),
            ],
          ),
        ),
      ],
    );
  }
}

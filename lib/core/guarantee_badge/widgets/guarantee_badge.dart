import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../l10n/app_localizations.dart';
import '../guarantee_badge_info.dart';
import '../guarantee_badge_providers.dart';
import 'bim_coin.dart';

/// The guarantee level of an account, as a BIM coin beside its name — «عملة فضية مكتوب عليها BIM للمستوى الفضي».
/// Hover or long-press says the level and what it covers up to; a tap opens it larger, with a sentence — so the
/// other side of a deal knows which level of customer or business it is dealing with.
///
/// It draws nothing while loading, for an account with no guarantee, or without an id: a badge is decoration and
/// never holds a screen back. Any number of them on one screen ride one batched request.
class GuaranteeBadge extends ConsumerWidget {
  final int? userId;
  final double size;

  const GuaranteeBadge({super.key, required this.userId, this.size = 20});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final id = userId;
    if (id == null || id <= 0) return const SizedBox.shrink();

    final info = ref.watch(guaranteeBadgeProvider(id)).valueOrNull;
    if (info == null) return const SizedBox.shrink();

    return GuaranteeBadgeCoin(info: info, size: size);
  }
}

/// The coin of an already-known level, with its tooltip and its sheet.
class GuaranteeBadgeCoin extends StatelessWidget {
  final GuaranteeBadgeInfo info;
  final double size;

  const GuaranteeBadgeCoin({super.key, required this.info, this.size = 20});

  static String amount(BuildContext context, double v) =>
      NumberFormat.decimalPattern(Localizations.localeOf(context).toString()).format(v.round());

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final arabic = Localizations.localeOf(context).languageCode == 'ar';
    final level = info.name(arabic);
    final message = l10n.guaranteeBadgeTooltip(level, amount(context, info.coversUpTo));

    return Tooltip(
      message: message,
      triggerMode: TooltipTriggerMode.longPress,
      child: Semantics(
        label: message,
        button: true,
        child: InkResponse(
          onTap: () => _open(context, l10n, level),
          radius: size,
          child: Padding(
            padding: const EdgeInsetsDirectional.only(start: 4),
            child: BimCoin(code: info.code, size: size),
          ),
        ),
      ),
    );
  }

  void _open(BuildContext context, AppLocalizations l10n, String level) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheet) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 4, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              BimCoin(code: info.code, size: 84),
              const SizedBox(height: 12),
              Text(
                l10n.guaranteeBadgeTitle(level),
                style: Theme.of(sheet).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                l10n.guaranteeBadgeBody(amount(sheet, info.coversUpTo)),
                style: Theme.of(sheet).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

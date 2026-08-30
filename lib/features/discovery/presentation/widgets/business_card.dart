import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../../data/models/business_summary.dart';

class BusinessCard extends StatelessWidget {
  final BusinessSummary business;
  final VoidCallback onTap;

  const BusinessCard({super.key, required this.business, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Card(
      margin: EdgeInsets.zero,
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: SizedBox(
            width: 48,
            height: 48,
            child: business.logoUrl != null
                ? CachedNetworkImage(
                    imageUrl: business.logoUrl!,
                    fit: BoxFit.cover,
                    errorWidget: (context, url, error) => const _LogoPlaceholder(),
                  )
                : const _LogoPlaceholder(),
          ),
        ),
        title: Text(business.name, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: !business.hasPrices ? Text(l10n.businessCallForPrice) : null,
        trailing: _OpenBadge(isOpenNow: business.isOpenNow),
      ),
    );
  }
}

class _LogoPlaceholder extends StatelessWidget {
  const _LogoPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.primaryNavy.withValues(alpha: 0.08),
      child: const Icon(Icons.storefront_outlined, color: AppColors.primaryNavy),
    );
  }
}

class _OpenBadge extends StatelessWidget {
  final bool isOpenNow;
  const _OpenBadge({required this.isOpenNow});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final color = isOpenNow ? AppColors.success : AppColors.error;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        isOpenNow ? l10n.businessOpenNow : l10n.businessClosedNow,
        style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600),
      ),
    );
  }
}

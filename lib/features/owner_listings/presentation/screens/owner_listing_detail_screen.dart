import '../../../moderation/presentation/widgets/report_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/env/env.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/time/local_format.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/widgets/async_value_view.dart';
import '../../../../shared/widgets/full_screen_gallery.dart';
import '../../application/owner_listings_providers.dart';
import '../../data/owner_listings_api.dart';
import '../widgets/owner_listing_card.dart';
import '../widgets/owner_listing_photo.dart';
import 'my_owner_listings_screen.dart';
import 'owner_listing_chat_screen.dart';
import 'owner_listing_form_screen.dart';

/// One owner listing in full. A buyer sees the item, the person (never the number) and a «راسل المالك» button; its owner
/// sees how it stands (live, hidden by reports, finished, expired) and can change it, finish it, renew it or delete it.
class OwnerListingDetailScreen extends ConsumerStatefulWidget {
  final int listingId;

  const OwnerListingDetailScreen({super.key, required this.listingId});

  @override
  ConsumerState<OwnerListingDetailScreen> createState() =>
      _OwnerListingDetailScreenState();
}

class _OwnerListingDetailScreenState
    extends ConsumerState<OwnerListingDetailScreen> {
  bool _busy = false;

  Future<void> _guard(Future<void> Function() action) async {
    final l10n = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _busy = true);
    try {
      await action();
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            e is ApiException ? e.message : l10n.commonSomethingWentWrong,
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _contact(OwnerListing l) => _guard(() async {
    final inquiry = await ref.read(ownerListingsApiProvider).inquire(l.id);
    ref.invalidate(myOwnerInquiriesProvider);
    ref.invalidate(ownerListingProvider(l.id));
    if (!mounted) return;
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) =>
            OwnerListingChatScreen(inquiryId: inquiry.id, title: l.title),
      ),
    );
  });

  Future<void> _report(OwnerListing l) =>
      showReportSheet(context, type: 'owner_listing', id: l.id);

  Future<void> _finish(OwnerListing l) async {
    final l10n = AppLocalizations.of(context)!;
    final reasons = switch (l.deal) {
      'rent' => [('rented', l10n.olFinishRented)],
      'swap' => [('swapped', l10n.olFinishSwapped)],
      _ => [('sold', l10n.olFinishSold)],
    };

    final reason = await showModalBottomSheet<String>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                l10n.olFinishHint,
                style: Theme.of(ctx).textTheme.bodyMedium,
              ),
            ),
            for (final r in [...reasons, ('withdrawn', l10n.olFinishWithdrawn)])
              ListTile(
                title: Text(r.$2),
                onTap: () => Navigator.of(ctx).pop(r.$1),
              ),
          ],
        ),
      ),
    );
    if (reason == null || !mounted) return;

    await _guard(() async {
      await ref.read(ownerListingsApiProvider).finish(l.id, reason);
      ref.invalidate(ownerListingProvider(l.id));
      ref.invalidate(myOwnerListingsProvider);
    });
  }

  Future<void> _delete(OwnerListing l) async {
    final l10n = AppLocalizations.of(context)!;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        content: Text(l10n.olDeleteConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l10n.commonCancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(l10n.commonDelete),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;

    await _guard(() async {
      await ref.read(ownerListingsApiProvider).delete(l.id);
      ref.invalidate(myOwnerListingsProvider);
      if (mounted) Navigator.of(context).pop();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final listing = ref.watch(ownerListingProvider(widget.listingId));

    return Scaffold(
      appBar: AppBar(
        title: Text(listing.valueOrNull?.title ?? l10n.olTitle),
        actions: [
          if (listing.valueOrNull != null && !listing.valueOrNull!.mine)
            PopupMenuButton<String>(
              onSelected: (_) => _report(listing.valueOrNull!),
              itemBuilder: (_) => [
                PopupMenuItem(value: 'report', child: Text(l10n.olReport)),
              ],
            ),
        ],
      ),
      body: AsyncValueView<OwnerListing>(
        value: listing,
        onRetry: () => ref.invalidate(ownerListingProvider(widget.listingId)),
        builder: (context, l) => _body(context, l),
      ),
    );
  }

  Widget _body(BuildContext context, OwnerListing l) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final urls = [
      for (final i in l.images) Env.assetUrl(i.image),
    ].whereType<String>().toList();

    return ListView(
      padding: const EdgeInsets.only(bottom: 32),
      children: [
        // swipe through the photos (a counter says how many); a tap opens them full screen with thumbnails
        _PhotoCarousel(images: l.images, urls: urls),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l.title, style: theme.textTheme.titleLarge),
              const SizedBox(height: 4),
              Text(
                ownerPriceText(l10n, l),
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  Chip(
                    label: Text(ownerDealLabel(l10n, l.deal)),
                    visualDensity: VisualDensity.compact,
                  ),
                  Chip(
                    label: Text(l.categoryName),
                    visualDensity: VisualDensity.compact,
                  ),
                  if (l.place.isNotEmpty)
                    Chip(
                      avatar: const Icon(Icons.place_outlined, size: 16),
                      label: Text(l.place),
                      visualDensity: VisualDensity.compact,
                    ),
                ],
              ),
              if (l.mine) ..._ownerPanel(context, l),
              if (l.attributes.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(l10n.olDetails, style: theme.textTheme.titleSmall),
                const SizedBox(height: 4),
                for (final a in l.attributes)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            a.label,
                            style: theme.textTheme.bodySmall,
                          ),
                        ),
                        Text(a.value),
                      ],
                    ),
                  ),
              ],
              if ((l.description ?? '').isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(l.description!),
              ],
              if (!l.mine) ...[
                const SizedBox(height: 16),
                Text(
                  l10n.olOwnerIs(l.ownerName ?? ''),
                  style: theme.textTheme.bodySmall,
                ),
                const SizedBox(height: 4),
                Text(l10n.olNoPhoneNote, style: theme.textTheme.bodySmall),
                const SizedBox(height: 12),
                FilledButton.icon(
                  onPressed: _busy || !l.isLive ? null : () => _contact(l),
                  icon: const Icon(Icons.chat_bubble_outline),
                  label: Text(l10n.olContact),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  List<Widget> _ownerPanel(BuildContext context, OwnerListing l) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final date = LocalFormat.date(context);

    final status = switch (l.status) {
      'flagged' => l10n.olStatusFlagged,
      'done' => l10n.olStatusDone,
      'expired' => l10n.olStatusExpired,
      _ => l.imagesCount == 0 ? l10n.olNoPhotoHidden : l10n.olStatusActive,
    };
    final when = l.isFinished
        ? (l.purgeAt == null ? null : l10n.olDeletesOn(date.format(l.purgeAt!)))
        : (l.expiresAt == null
              ? null
              : l10n.olExpiresOn(date.format(l.expiresAt!)));

    return [
      const SizedBox(height: 12),
      Card(
        margin: EdgeInsets.zero,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(status, style: theme.textTheme.titleSmall),
              if (l.visibility != 'all')
                Text(
                  l.visibility == 'city'
                      ? l10n.olVisBadgeCity
                      : l10n.olVisBadgeGovernorate,
                  style: theme.textTheme.bodySmall,
                ),
              if (when != null) Text(when, style: theme.textTheme.bodySmall),
              if (l.depositAmount != null && l.depositAmount! > 0)
                Text(
                  l.depositState == 'held'
                      ? l10n.olDepositHeld(l.depositAmount!.toStringAsFixed(0))
                      : l10n.olDepositReleased(
                          l.depositAmount!.toStringAsFixed(0),
                        ),
                  style: theme.textTheme.bodySmall,
                ),
              if ((l.inquiriesCount ?? 0) > 0)
                TextButton.icon(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) =>
                          const MyOwnerListingsScreen(initialTab: 1),
                    ),
                  ),
                  icon: const Icon(Icons.forum_outlined),
                  label: Text(l10n.olInquiriesCount(l.inquiriesCount!)),
                ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  if (!l.isFinished)
                    OutlinedButton.icon(
                      onPressed: _busy
                          ? null
                          : () async {
                              final changed = await Navigator.of(context)
                                  .push<bool>(
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          OwnerListingFormScreen(listing: l),
                                    ),
                                  );
                              if (changed == true) {
                                ref.invalidate(ownerListingProvider(l.id));
                              }
                            },
                      icon: const Icon(Icons.edit_outlined),
                      label: Text(l10n.olEdit),
                    ),
                  if (!l.isFinished)
                    FilledButton.icon(
                      onPressed: _busy ? null : () => _finish(l),
                      icon: const Icon(Icons.check_circle_outline),
                      label: Text(l10n.olFinish),
                    ),
                  if (l.status == 'active' || l.status == 'expired')
                    OutlinedButton.icon(
                      onPressed: _busy
                          ? null
                          : () => _guard(() async {
                              await ref
                                  .read(ownerListingsApiProvider)
                                  .renew(l.id);
                              ref.invalidate(ownerListingProvider(l.id));
                              ref.invalidate(myOwnerListingsProvider);
                            }),
                      icon: const Icon(Icons.autorenew),
                      label: Text(l10n.olRenew),
                    ),
                  TextButton.icon(
                    onPressed: _busy ? null : () => _delete(l),
                    icon: Icon(
                      Icons.delete_outline,
                      color: theme.colorScheme.error,
                    ),
                    label: Text(
                      l10n.olDelete,
                      style: TextStyle(color: theme.colorScheme.error),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ];
  }
}

/// The listing's photos, one per page, with «2 / 5» over the corner when there is more than one.
class _PhotoCarousel extends StatefulWidget {
  final List<OwnerImage> images;
  final List<String> urls;

  const _PhotoCarousel({required this.images, required this.urls});

  @override
  State<_PhotoCarousel> createState() => _PhotoCarouselState();
}

class _PhotoCarouselState extends State<_PhotoCarousel> {
  int _page = 0;

  @override
  Widget build(BuildContext context) {
    if (widget.urls.isEmpty) {
      return const OwnerListingPhoto(path: null, height: 260);
    }

    return SizedBox(
      height: 260,
      child: Stack(
        children: [
          PageView.builder(
            itemCount: widget.urls.length,
            onPageChanged: (i) => setState(() => _page = i),
            itemBuilder: (context, i) => GestureDetector(
              onTap: () => FullScreenGallery.show(
                context,
                urls: widget.urls,
                initialIndex: i,
              ),
              child: SizedBox.expand(
                child: OwnerListingPhoto(
                  path: widget.images[i].image,
                  height: 260,
                ),
              ),
            ),
          ),
          if (widget.urls.length > 1)
            PositionedDirectional(
              bottom: 8,
              end: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${_page + 1} / ${widget.urls.length}',
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

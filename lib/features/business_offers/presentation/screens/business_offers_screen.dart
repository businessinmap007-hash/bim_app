import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../../core/network/api_exception.dart';
import '../../../offers/data/models/commercial_offer.dart';
import '../../application/business_offers_providers.dart';
import '../../data/models/offers_usage.dart';
import 'boost_purchases_screen.dart';
import 'offer_form_screen.dart';
import 'offer_performance_screen.dart';

const _statuses = <String?>[null, 'active', 'paused', 'expired', 'cancelled'];

/// Api\V2\BusinessOfferController — a business's own commercial offers
/// (create/edit/pause/delete), plus a way into OfferBoostController's paid
/// promotion for any one of them. Completes the loop with the consumer-side
/// offers/offer-comparison screens, which can display offers but had no way
/// for a business to ever create one from the app.
class BusinessOffersScreen extends ConsumerStatefulWidget {
  const BusinessOffersScreen({super.key});

  @override
  ConsumerState<BusinessOffersScreen> createState() => _BusinessOffersScreenState();
}

class _BusinessOffersScreenState extends ConsumerState<BusinessOffersScreen> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      ref.read(businessOffersControllerProvider.notifier).loadMore();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _openCreate() async {
    final created = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => const OfferFormScreen()),
    );
    if (created == true) {
      ref.read(businessOffersControllerProvider.notifier).load();
    }
  }

  Future<void> _openEdit(CommercialOffer offer) async {
    final updated = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => OfferFormScreen(existing: offer)),
    );
    if (updated == true) {
      ref.read(businessOffersControllerProvider.notifier).load();
    }
  }

  Future<void> _toggle(CommercialOffer offer) async {
    final l10n = AppLocalizations.of(context)!;
    try {
      await ref.read(businessOffersControllerProvider.notifier).toggle(offer.id);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e is ApiException ? e.message : l10n.commonSomethingWentWrong)));
      }
    }
  }

  Future<void> _delete(CommercialOffer offer) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        content: Text(l10n.businessOfferDeleteConfirm),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text(l10n.commonCancel)),
          TextButton(onPressed: () => Navigator.pop(context, true), child: Text(l10n.commonDelete)),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await ref.read(businessOffersControllerProvider.notifier).delete(offer.id);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e is ApiException ? e.message : l10n.commonSomethingWentWrong)));
      }
    }
  }

  Future<void> _boost(CommercialOffer offer) async {
    final l10n = AppLocalizations.of(context)!;
    final packagesAsync = ref.read(boostPackagesProvider);
    final packages = await packagesAsync.when(
      data: (value) async => value,
      loading: () => ref.read(boostPackagesProvider.future),
      error: (_, _) => Future.value(const []),
    );
    if (!mounted) return;
    if (packages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.commonSomethingWentWrong)));
      return;
    }
    final chosen = await showModalBottomSheet<int>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(l10n.businessOfferBoostTitle, style: Theme.of(sheetContext).textTheme.titleMedium),
            ),
            for (final package in packages)
              ListTile(
                title: Text(package.displayName()),
                subtitle: Text(l10n.businessOfferBoostDuration(package.durationDays)),
                trailing: Text('${package.price.toStringAsFixed(2)} ${package.currency}'),
                onTap: () => Navigator.pop(sheetContext, package.id),
              ),
          ],
        ),
      ),
    );
    if (chosen == null || !mounted) return;
    try {
      await ref.read(businessOffersApiProvider).activateBoost(offer.id, chosen);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.businessOfferBoosted)));
        ref.read(businessOffersControllerProvider.notifier).load();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e is ApiException ? e.message : l10n.commonSomethingWentWrong)));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final state = ref.watch(businessOffersControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.businessOffersTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.bar_chart_outlined),
            tooltip: l10n.offerPerformanceTitle,
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const OfferPerformanceScreen()),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.bolt_outlined),
            tooltip: l10n.businessOfferBoostPurchasesTitle,
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const BoostPurchasesScreen()),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openCreate,
        icon: const Icon(Icons.add),
        label: Text(l10n.businessOfferAdd),
      ),
      body: Column(
        children: [
          if (state.usage != null) _UsageBanner(usage: state.usage!),
          _StatusFilterBar(
            selected: state.status,
            onChanged: (status) => ref.read(businessOffersControllerProvider.notifier).setStatus(status),
          ),
          Expanded(
            child: state.isLoading
                ? const Center(child: CircularProgressIndicator())
                : state.error != null
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(l10n.commonSomethingWentWrong),
                        const SizedBox(height: 8),
                        OutlinedButton(
                          onPressed: () => ref.read(businessOffersControllerProvider.notifier).load(),
                          child: Text(l10n.commonRetry),
                        ),
                      ],
                    ),
                  )
                : state.items.isEmpty
                ? Center(child: Text(l10n.businessOffersEmpty))
                : RefreshIndicator(
                    onRefresh: () => ref.read(businessOffersControllerProvider.notifier).load(),
                    child: ListView.separated(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(16),
                      itemCount: state.items.length + (state.isLoadingMore ? 1 : 0),
                      separatorBuilder: (context, index) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        if (index >= state.items.length) {
                          return const Padding(
                            padding: EdgeInsets.symmetric(vertical: 16),
                            child: Center(child: CircularProgressIndicator()),
                          );
                        }
                        final offer = state.items[index];
                        return _OfferCard(
                          offer: offer,
                          onTap: () => _openEdit(offer),
                          onToggle: () => _toggle(offer),
                          onDelete: () => _delete(offer),
                          onBoost: () => _boost(offer),
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _UsageBanner extends StatelessWidget {
  final OffersUsage usage;
  const _UsageBanner({required this.usage});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Text(
        l10n.businessOffersUsage(usage.activeOffers, usage.maxActiveOffers),
        style: Theme.of(context).textTheme.bodySmall,
      ),
    );
  }
}

class _StatusFilterBar extends StatelessWidget {
  final String? selected;
  final ValueChanged<String?> onChanged;
  const _StatusFilterBar({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    String label(String? s) => switch (s) {
      null => l10n.businessOffersFilterAll,
      'active' => l10n.businessOfferStatusActive,
      'paused' => l10n.businessOfferStatusPaused,
      'expired' => l10n.businessOfferStatusExpired,
      'cancelled' => l10n.businessOfferStatusCancelled,
      _ => s,
    };
    return SizedBox(
      height: 44,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        children: [
          for (final status in _statuses)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text(label(status)),
                selected: selected == status,
                onSelected: (_) => onChanged(status),
              ),
            ),
        ],
      ),
    );
  }
}

class _OfferCard extends StatelessWidget {
  final CommercialOffer offer;
  final VoidCallback onTap;
  final VoidCallback onToggle;
  final VoidCallback onDelete;
  final VoidCallback onBoost;

  const _OfferCard({
    required this.offer,
    required this.onTap,
    required this.onToggle,
    required this.onDelete,
    required this.onBoost,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isActive = offer.status == 'active';
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InkWell(
              onTap: onTap,
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          offer.title(Localizations.localeOf(context).languageCode),
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                        const SizedBox(height: 2),
                        if (offer.basePrice != null)
                          Text(
                            '${offer.basePrice!.toStringAsFixed(2)} → ${offer.finalPrice.toStringAsFixed(2)} ${offer.currency}',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                      ],
                    ),
                  ),
                  if (offer.isFeatured) const Icon(Icons.bolt, color: Colors.amber),
                ],
              ),
            ),
            const SizedBox(height: 4),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                OutlinedButton(
                  onPressed: onToggle,
                  child: Text(isActive ? l10n.businessOfferPause : l10n.businessOfferActivate),
                ),
                OutlinedButton(onPressed: onBoost, child: Text(l10n.businessOfferBoostAction)),
                IconButton(icon: const Icon(Icons.delete_outline), onPressed: onDelete),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

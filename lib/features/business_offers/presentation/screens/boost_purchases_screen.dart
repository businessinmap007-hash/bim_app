import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../l10n/app_localizations.dart';
import '../../application/business_offers_providers.dart';
import '../../data/models/offer_boost_purchase.dart';

/// Api\V2\OfferBoostController::myPurchases — history of a business's paid
/// offer boosts.
class BoostPurchasesScreen extends ConsumerStatefulWidget {
  const BoostPurchasesScreen({super.key});

  @override
  ConsumerState<BoostPurchasesScreen> createState() => _BoostPurchasesScreenState();
}

class _BoostPurchasesScreenState extends ConsumerState<BoostPurchasesScreen> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
        ref.read(boostPurchasesControllerProvider.notifier).loadMore();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final state = ref.watch(boostPurchasesControllerProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.businessOfferBoostPurchasesTitle)),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : state.error != null
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(l10n.commonSomethingWentWrong),
                  const SizedBox(height: 8),
                  OutlinedButton(
                    onPressed: () => ref.read(boostPurchasesControllerProvider.notifier).load(),
                    child: Text(l10n.commonRetry),
                  ),
                ],
              ),
            )
          : state.items.isEmpty
          ? Center(child: Text(l10n.businessOfferBoostPurchasesEmpty))
          : ListView.separated(
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
                return _PurchaseTile(purchase: state.items[index]);
              },
            ),
    );
  }
}

class _PurchaseTile extends StatelessWidget {
  final OfferBoostPurchase purchase;
  const _PurchaseTile({required this.purchase});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: ListTile(
        title: Text(purchase.offerTitle ?? '#${purchase.offerId}'),
        subtitle: Text(purchase.package?.displayName() ?? purchase.status),
        trailing: Text('${purchase.price.toStringAsFixed(2)} ${purchase.currency}'),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../l10n/app_localizations.dart';
import '../../application/service_requests_providers.dart';
import 'ride_request_screen.dart';
import 'service_request_detail_screen.dart';

/// My requests, newest first, each with how many offers it has — the way back to a request after leaving the screen.
class MyRequestsScreen extends ConsumerWidget {
  const MyRequestsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final async = ref.watch(myServiceRequestsProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.rideAllRequestsTitle)),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (_) => const RideRequestScreen())),
        icon: const Icon(Icons.add),
        label: Text(l10n.rideRequestTitle),
      ),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                e is ApiException ? e.message : l10n.commonSomethingWentWrong,
              ),
              TextButton(
                onPressed: () => ref.invalidate(myServiceRequestsProvider),
                child: Text(l10n.commonRetry),
              ),
            ],
          ),
        ),
        data: (items) => RefreshIndicator(
          onRefresh: () async => ref.refresh(myServiceRequestsProvider.future),
          child: items.isEmpty
              ? ListView(
                  children: [
                    const SizedBox(height: 120),
                    Center(child: Text(l10n.requestsEmpty)),
                  ],
                )
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
                  itemCount: items.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 8),
                  itemBuilder: (context, i) {
                    final r = items[i];
                    return Card(
                      margin: EdgeInsets.zero,
                      clipBehavior: Clip.antiAlias,
                      child: ListTile(
                        title: Text(RequestSummaryCard.title(r)),
                        subtitle: Text(
                          '${RequestSummaryCard.statusLabel(l10n, r.status)} · ${l10n.requestOffersCount(r.offersCount)}',
                        ),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) =>
                                ServiceRequestDetailScreen(requestId: r.id),
                          ),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ),
    );
  }
}

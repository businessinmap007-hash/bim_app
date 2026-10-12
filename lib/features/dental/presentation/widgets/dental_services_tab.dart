import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../l10n/app_localizations.dart';
import '../../application/dental_providers.dart';
import 'dental_widgets.dart';

/// The «خدمات الأسنان» tab of a dental clinic's page: what it does — cleaning, fillings, root canals, implants, braces —
/// each with the clinic's own price (or «السعر بعد الكشف»). Read-only: the visit is booked the ordinary way.
class DentalServicesTab extends ConsumerWidget {
  final int clinicId;
  const DentalServicesTab({super.key, required this.clinicId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final async = ref.watch(dentalServicesProvider(clinicId));

    return async.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, _) => Center(child: Text(l10n.commonSomethingWentWrong)),
      data: (sections) {
        if (sections.isEmpty) return Center(child: Text(l10n.dentalNoneOffered));

        return Builder(
          builder: (context) => CustomScrollView(
            slivers: [
              SliverOverlapInjector(handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context)),
              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    for (final s in sections) ...[
                      Padding(
                        padding: const EdgeInsets.only(top: 8, bottom: 6),
                        child: Text(
                          dentalKindLabel(l10n, s.kind),
                          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                        ),
                      ),
                      for (final p in s.services)
                        Card(
                          margin: const EdgeInsets.only(bottom: 6),
                          child: ListTile(
                            title: Text(p.name),
                            trailing: Text(
                              dentalPriceText(l10n, p.price),
                              style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
                            ),
                          ),
                        ),
                    ],
                  ]),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../l10n/app_localizations.dart';
import '../../application/discovery_providers.dart';

/// The priced rows behind a specialty, across every shop — «كشف عظام — 300 —
/// مستشفى BIM». The chips are the «line — modifiers» combinations the specialty
/// sells; tapping one narrows the list, tapping a row opens the shop.
class ChildOfferingsScreen extends ConsumerStatefulWidget {
  final int childId;
  final String title;

  const ChildOfferingsScreen({super.key, required this.childId, required this.title});

  @override
  ConsumerState<ChildOfferingsScreen> createState() => _ChildOfferingsScreenState();
}

class _ChildOfferingsScreenState extends ConsumerState<ChildOfferingsScreen> {
  String _optionKey = '';

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final lines = ref.watch(offeringLinesProvider(widget.childId));
    final rows = ref.watch(childOfferingsProvider((childId: widget.childId, optionKey: _optionKey)));

    return Scaffold(
      appBar: AppBar(title: Text('${l10n.childOfferingsTitle} · ${widget.title}')),
      body: Column(
        children: [
          SizedBox(
            height: 52,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.all(8),
              children: [
                Padding(
                  padding: const EdgeInsetsDirectional.only(end: 8),
                  child: ChoiceChip(
                    label: Text(l10n.childOfferingsAll),
                    selected: _optionKey.isEmpty,
                    onSelected: (_) => setState(() => _optionKey = ''),
                  ),
                ),
                ...lines.maybeWhen(
                  data: (items) => [
                    for (final line in items)
                      Padding(
                        padding: const EdgeInsetsDirectional.only(end: 8),
                        child: ChoiceChip(
                          label: Text('${line.label} (${line.offerings})'),
                          selected: _optionKey == line.optionIds.join(','),
                          onSelected: (_) => setState(() => _optionKey = line.optionIds.join(',')),
                        ),
                      ),
                  ],
                  orElse: () => const <Widget>[],
                ),
              ],
            ),
          ),
          Expanded(
            child: rows.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, _) => Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(l10n.commonSomethingWentWrong),
                    const SizedBox(height: 8),
                    OutlinedButton(
                      onPressed: () => ref.invalidate(childOfferingsProvider),
                      child: Text(l10n.commonRetry),
                    ),
                  ],
                ),
              ),
              data: (items) => items.isEmpty
                  ? Center(child: Text(l10n.childOfferingsEmpty))
                  : ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: items.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final o = items[index];
                        return Card(
                          margin: EdgeInsets.zero,
                          child: ListTile(
                            onTap: () => context.push('/business/${o.businessId}'),
                            leading: CircleAvatar(
                              backgroundImage: o.businessLogoUrl != null ? NetworkImage(o.businessLogoUrl!) : null,
                              child: o.businessLogoUrl == null ? const Icon(Icons.storefront_outlined) : null,
                            ),
                            title: Text(o.label),
                            subtitle: Text(o.businessName),
                            trailing: Text(
                              '${o.price.toStringAsFixed(o.price == o.price.roundToDouble() ? 0 : 2)} ${o.currency}',
                              style: Theme.of(context).textTheme.titleSmall,
                            ),
                          ),
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

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../l10n/app_localizations.dart';
import '../../application/disputes_providers.dart';

typedef DisputeReasonResult = ({String reasonCode, String? reasonText});

/// The reason-code + free-text sheet shown before opening a dispute — used
/// from the order/booking/trip-reservation detail sheets (see
/// Api\V2\DisputeController::REASON_CODES, a fixed vocabulary the app needs
/// stable keys for).
Future<DisputeReasonResult?> showDisputeReasonPicker(BuildContext context, WidgetRef ref) {
  return showModalBottomSheet<DisputeReasonResult>(
    context: context,
    isScrollControlled: true,
    builder: (_) => const _DisputeReasonSheet(),
  );
}

class _DisputeReasonSheet extends ConsumerStatefulWidget {
  const _DisputeReasonSheet();

  @override
  ConsumerState<_DisputeReasonSheet> createState() => _DisputeReasonSheetState();
}

class _DisputeReasonSheetState extends ConsumerState<_DisputeReasonSheet> {
  final _detailsController = TextEditingController();
  String? _selected;

  @override
  void dispose() {
    _detailsController.dispose();
    super.dispose();
  }

  String _label(String code, AppLocalizations l10n) => switch (code) {
    'not_delivered' => l10n.disputeReasonNotDelivered,
    'not_as_described' => l10n.disputeReasonNotAsDescribed,
    'quality' => l10n.disputeReasonQuality,
    'late' => l10n.disputeReasonLate,
    'cancelled_by_business' => l10n.disputeReasonCancelledByBusiness,
    'no_show' => l10n.disputeReasonNoShow,
    'overcharged' => l10n.disputeReasonOvercharged,
    'damage' => l10n.disputeReasonDamage,
    'other' => l10n.disputeReasonOther,
    _ => code,
  };

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final codesAsync = ref.watch(disputeReasonCodesProvider);

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.disputeOpenTitle, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 12),
              Text(l10n.disputeReasonLabel, style: Theme.of(context).textTheme.labelMedium),
              const SizedBox(height: 6),
              codesAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (_, _) => Text(l10n.commonSomethingWentWrong),
                data: (codes) => Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: codes
                      .map(
                        (c) => ChoiceChip(
                          label: Text(_label(c, l10n)),
                          selected: _selected == c,
                          onSelected: (_) => setState(() => _selected = c),
                        ),
                      )
                      .toList(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _detailsController,
                minLines: 2,
                maxLines: 4,
                decoration: InputDecoration(hintText: l10n.disputeDetailsHint),
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: _selected == null
                    ? null
                    : () => Navigator.of(context).pop((
                        reasonCode: _selected!,
                        reasonText: _detailsController.text.trim(),
                      )),
                child: Text(l10n.commonSubmit),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

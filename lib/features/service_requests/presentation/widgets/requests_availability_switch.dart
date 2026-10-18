import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../l10n/app_localizations.dart';
import '../../application/service_requests_providers.dart';

/// «استراحة»: the business says whether it is taking customers' requests. Off, no new request is sent to it, it cannot
/// answer one and a limousine driver's «راجع فاضي» offers are hidden — see Api\V2\ServiceRequestController::setAvailability.
class RequestsAvailabilitySwitch extends ConsumerWidget {
  /// Where it sits: the default suits a screen of full-width children, a padded list passes its own.
  final EdgeInsetsGeometry margin;

  const RequestsAvailabilitySwitch({
    super.key,
    this.margin = const EdgeInsets.fromLTRB(16, 12, 16, 0),
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final available = ref.watch(requestsAvailableProvider);

    // until it is known the card is simply not drawn: a wrong state must never be shown
    final on = available.valueOrNull;
    if (on == null) return const SizedBox.shrink();

    return Card(
      margin: margin,
      child: SwitchListTile(
        value: on,
        title: Text(l10n.requestsAvailableTitle),
        subtitle: Text(
          on ? l10n.requestsAvailableOn : l10n.requestsAvailableOff,
        ),
        secondary: Icon(
          on ? Icons.local_taxi_outlined : Icons.bedtime_outlined,
        ),
        onChanged: (value) async {
          final messenger = ScaffoldMessenger.of(context);
          try {
            await ref.read(serviceRequestsApiProvider).setAvailable(value);
            ref.invalidate(requestsAvailableProvider);
          } catch (e) {
            messenger.showSnackBar(
              SnackBar(
                content: Text(
                  e is ApiException ? e.message : l10n.commonSomethingWentWrong,
                ),
              ),
            );
          }
        },
      ),
    );
  }
}

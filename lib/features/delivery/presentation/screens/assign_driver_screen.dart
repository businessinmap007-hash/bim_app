import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/widgets/async_value_view.dart';
import '../../application/delivery_providers.dart';
import '../../data/models/roster_driver.dart';
import 'token_qr_screen.dart';

/// "من يوصّل هذا الطلب؟" — opened right after the merchant marks a delivery
/// order ready. Lists the business's OWN roster, nearest-first when a driver
/// has a fresh location, and hands the order straight to whoever is tapped
/// (DeliveryDispatchService::assignDriver) — the driver never has to notice
/// and self-select it from the open pool. On success, shows the pickup QR
/// for the driver to scan in person.
///
/// A driver's live position IS shown (sorted list), but there is no
/// interactive map here — flutter_map/OSRM integration was researched, not
/// built, for this app (see [[free-maps-routing-options]]); "nearest first"
/// in a plain list delivers the same practical choice without that cost.
class AssignDriverScreen extends ConsumerStatefulWidget {
  final int orderId;
  final int? businessId;
  const AssignDriverScreen({super.key, required this.orderId, this.businessId});

  @override
  ConsumerState<AssignDriverScreen> createState() => _AssignDriverScreenState();
}

class _AssignDriverScreenState extends ConsumerState<AssignDriverScreen> {
  int? _assigningDriverId;

  Future<void> _assign(RosterDriver driver) async {
    final l10n = AppLocalizations.of(context)!;
    setState(() => _assigningDriverId = driver.id);
    try {
      await ref.read(deliveryApiProvider).assignDriver(orderId: widget.orderId, driverId: driver.id, businessId: widget.businessId);
      final token = await ref.read(deliveryApiProvider).issuePickupToken(widget.orderId, businessId: widget.businessId);
      if (!mounted) return;
      await Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => TokenQrScreen(
            title: l10n.deliveryPickupQrTitle,
            subtitle: l10n.deliveryPickupQrHint(driver.name ?? ''),
            token: token,
          ),
        ),
      );
    } catch (e) {
      if (mounted) {
        final message = e is ApiException ? e.message : l10n.commonSomethingWentWrong;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
      }
    } finally {
      if (mounted) setState(() => _assigningDriverId = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final rosterAsync = ref.watch(businessRosterProvider(widget.businessId));

    return Scaffold(
      appBar: AppBar(title: Text(l10n.deliveryAssignDriverTitle)),
      body: AsyncValueView<List<RosterDriver>>(
        value: rosterAsync,
        onRetry: () => ref.invalidate(businessRosterProvider(widget.businessId)),
        builder: (context, drivers) {
          if (drivers.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(l10n.deliveryNoDriversYet, textAlign: TextAlign.center),
              ),
            );
          }

          // Who is NOT already on a job comes first — the whole point of
          // opening this screen is picking someone free, not just nearest.
          final sorted = [...drivers]..sort((a, b) {
            if (a.busy != b.busy) return a.busy ? 1 : -1;
            if (a.distanceKm == null && b.distanceKm == null) return 0;
            if (a.distanceKm == null) return 1;
            if (b.distanceKm == null) return -1;
            return a.distanceKm!.compareTo(b.distanceKm!);
          });

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: sorted.length,
            separatorBuilder: (context, index) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final driver = sorted[index];
              final busy = _assigningDriverId == driver.id;

              return Card(
                margin: EdgeInsets.zero,
                child: ListTile(
                  enabled: driver.isActive && _assigningDriverId == null,
                  leading: CircleAvatar(
                    backgroundColor: driver.isActive ? AppColors.accentGold.withValues(alpha: 0.15) : null,
                    child: Icon(
                      Icons.delivery_dining_outlined,
                      color: driver.isActive ? AppColors.accentGold : Theme.of(context).hintColor,
                    ),
                  ),
                  title: Text(driver.name ?? '#${driver.userId}'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (driver.vehicleLabel != null) Text(driver.vehicleLabel!),
                      Row(
                        children: [
                          Text(
                            driver.isActive ? l10n.deliveryDriverOnDuty : l10n.deliveryDriverOffDuty,
                            style: TextStyle(
                              color: driver.isActive ? AppColors.success : Theme.of(context).hintColor,
                              fontSize: 12,
                            ),
                          ),
                          if (driver.busy) ...[
                            const Text(' · '),
                            Text(
                              l10n.deliveryDriverBusy(driver.activeOrderCount),
                              style: TextStyle(color: Theme.of(context).hintColor, fontSize: 12),
                            ),
                          ],
                          if (driver.distanceKm != null) ...[
                            const Text(' · '),
                            Text(
                              l10n.deliveryDriverDistance(driver.distanceKm!.toStringAsFixed(1)),
                              style: TextStyle(color: Theme.of(context).hintColor, fontSize: 12),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                  trailing: busy
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                      : FilledButton(
                          onPressed: driver.isActive && _assigningDriverId == null ? () => _assign(driver) : null,
                          child: Text(l10n.deliveryAssign),
                        ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

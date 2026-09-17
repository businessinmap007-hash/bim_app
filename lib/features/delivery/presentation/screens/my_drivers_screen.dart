import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/widgets/async_value_view.dart';
import '../../application/delivery_providers.dart';
import '../../data/delivery_api.dart';
import '../../data/models/nearby_freelancer.dart';
import '../../data/models/roster_driver.dart';

/// "موصّليّ" — the business's own private driver roster, mirroring the web
/// panel's screen: take a driver off duty instead of trying to delete them
/// (their history stays attributable, see DeliveryDispatchService's own
/// note), plus a read-only look at nearby freelance drivers for when the
/// team is busy — they self-accept from the open pool, never a direct
/// assignment (nearbyFreelanceDrivers()'s own doc explains why).
class MyDriversScreen extends ConsumerStatefulWidget {
  const MyDriversScreen({super.key});

  @override
  ConsumerState<MyDriversScreen> createState() => _MyDriversScreenState();
}

class _MyDriversScreenState extends ConsumerState<MyDriversScreen> {
  final Set<int> _togglingDriverIds = {};

  Future<void> _toggle(RosterDriver driver) async {
    final l10n = AppLocalizations.of(context)!;
    setState(() => _togglingDriverIds.add(driver.id));
    try {
      await ref.read(deliveryApiProvider).setDriverActive(driver.id, !driver.isActive);
      ref.invalidate(businessRosterFullProvider);
    } catch (e) {
      if (mounted) {
        final message = e is ApiException ? e.message : l10n.commonSomethingWentWrong;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
      }
    } finally {
      if (mounted) setState(() => _togglingDriverIds.remove(driver.id));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final rosterAsync = ref.watch(businessRosterFullProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.deliveryMyDriversTitle)),
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(businessRosterFullProvider),
        child: AsyncValueView<BusinessRoster>(
          value: rosterAsync,
          onRetry: () => ref.invalidate(businessRosterFullProvider),
          builder: (context, roster) {
            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                if (roster.drivers.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: Center(child: Text(l10n.deliveryNoDriversYet)),
                  )
                else
                  ...roster.drivers.map(
                    (driver) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: _DriverCard(
                        driver: driver,
                        busy: _togglingDriverIds.contains(driver.id),
                        onToggle: () => _toggle(driver),
                      ),
                    ),
                  ),
                const Divider(height: 32),
                Text(l10n.deliveryNearbyFreelancersSection, style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(height: 4),
                Text(
                  l10n.deliveryNearbyFreelancersHint,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).hintColor),
                ),
                const SizedBox(height: 12),
                if (roster.nearbyFreelancers.isEmpty)
                  Text(l10n.deliveryNoNearbyFreelancers, style: TextStyle(color: Theme.of(context).hintColor))
                else
                  ...roster.nearbyFreelancers.map((f) => _FreelancerTile(freelancer: f)),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _DriverCard extends StatelessWidget {
  final RosterDriver driver;
  final bool busy;
  final VoidCallback onToggle;
  const _DriverCard({required this.driver, required this.busy, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Card(
      margin: EdgeInsets.zero,
      child: ListTile(
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
              ],
            ),
            Text(
              '${l10n.deliveryDeliveredCount}: ${driver.deliveredCount}'
              '${driver.fastDeliveryCount > 0 ? ' · ${l10n.deliveryFastDeliveryCount}: ${driver.fastDeliveryCount}' : ''}',
              style: TextStyle(color: Theme.of(context).hintColor, fontSize: 12),
            ),
          ],
        ),
        trailing: busy
            ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
            : OutlinedButton(
                onPressed: onToggle,
                child: Text(driver.isActive ? l10n.deliveryTakeOffDuty : l10n.deliveryTakeOnDuty),
              ),
      ),
    );
  }
}

class _FreelancerTile extends StatelessWidget {
  final NearbyFreelancer freelancer;
  const _FreelancerTile({required this.freelancer});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: const CircleAvatar(child: Icon(Icons.delivery_dining_outlined)),
        title: Text(freelancer.name ?? '#${freelancer.userId}'),
        subtitle: freelancer.vehicleLabel != null ? Text(freelancer.vehicleLabel!) : null,
        trailing: Text(
          l10n.deliveryDriverDistance(freelancer.distanceKm.toStringAsFixed(1)),
          style: TextStyle(color: Theme.of(context).hintColor, fontSize: 12),
        ),
      ),
    );
  }
}

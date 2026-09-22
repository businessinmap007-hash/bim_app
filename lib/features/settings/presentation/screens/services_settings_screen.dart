import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../booking/presentation/screens/business_bookings_screen.dart';
import '../../../booking_settings/presentation/screens/booking_settings_screen.dart';
import '../../../delivery/application/delivery_providers.dart';
import '../../../auth/application/auth_controller.dart';
import '../../../delivery/presentation/screens/delivery_fee_settings_screen.dart';
import '../../../delivery/presentation/screens/driver_dashboard_screen.dart';
import '../../../delivery/presentation/screens/my_drivers_screen.dart';
import '../../../shipping/presentation/screens/shipping_orders_screen.dart';
import '../../../shipping/presentation/screens/shipping_rates_screen.dart';
import '../../../business_offers/presentation/screens/business_offers_screen.dart';
import '../../../business_prices/presentation/screens/business_prices_screen.dart';
import '../../../business_menu/presentation/screens/menu_items_screen.dart';
import '../../../clinic_management/presentation/screens/clinic_management_screen.dart';
import '../../../menu_bundles/presentation/screens/menu_bundles_screen.dart';
import '../../../merchant_account/presentation/screens/merchant_account_screen.dart';
import '../../../orders/presentation/screens/business_order_reports_screen.dart';
import '../../../orders/presentation/screens/business_orders_screen.dart';
import '../../../prescriptions/presentation/screens/issued_prescriptions_screen.dart';
import '../../../prescriptions/presentation/screens/pharmacy_queue_screen.dart';
import '../../../projects/presentation/screens/projects_screen.dart';
import '../../../retail_listings/presentation/screens/retail_listings_screen.dart';
import '../../../retail_variant_groups/presentation/screens/retail_variant_groups_screen.dart';
import '../../../schedules/presentation/screens/my_trip_schedules_screen.dart';
import '../../../staff/application/staff_providers.dart';
import '../../../staff/presentation/screens/attendance_verification_settings_screen.dart';
import '../../../staff/presentation/screens/staff_activity_screen.dart';
import '../../../staff/presentation/screens/staff_groups_screen.dart';
import '../../../staff/presentation/screens/staff_screen.dart';
import '../../../table/presentation/screens/table_calls_screen.dart';
import '../../../training/presentation/screens/my_training_clients_screen.dart';
import '../../../training_templates/presentation/screens/training_templates_screen.dart';

/// A business's own service-management screens, one per capability it may
/// hold — split out of the general [SettingsScreen] (language/appearance/
/// account are everyone's concern; these are a business's alone, and the
/// combined list had grown long enough to bury both halves in one scroll).
/// Reached from the drawer's "إعدادات الخدمات" entry, business accounts only.
///
/// Tiles tied to a real platform service (menu/retail/clinic/prescriptions/
/// training/bookings/schedules/projects) only show once
/// [myServiceKeysProvider] confirms the business's own category actually
/// offers that service — a hotel stops seeing "Training & Nutrition Plans"
/// just because the tile used to be unconditional. Staff/Merchant account
/// have no capability of their own (owner-only account management) and
/// always show, same as before. A failed fetch shows every tile rather than
/// none — a transient network error shouldn't look like lost functionality.
class ServicesSettingsScreen extends ConsumerWidget {
  const ServicesSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final keysAsync = ref.watch(myServiceKeysProvider);
    final authState = ref.watch(authControllerProvider);
    final isCarrier = authState is AuthSignedIn && authState.user.isShippingCarrier;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settingsServicesSection)),
      body: keysAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        // Fail open: every tile, same as before this screen filtered at all.
        error: (_, _) => _ServiceList(keys: null, isCarrier: isCarrier),
        data: (keys) => _ServiceList(keys: keys, isCarrier: isCarrier),
      ),
    );
  }
}

class _ServiceList extends StatelessWidget {
  /// null means "don't filter — show everything" (loading fallback / error).
  final Set<String>? keys;

  /// Shipping & Delivery accounts run deliveries from here (and only they do).
  final bool isCarrier;
  const _ServiceList({required this.keys, required this.isCarrier});

  bool _has(String key) => keys == null || keys!.contains(key);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final tiles = <_Tile>[
      _Tile(
        show: _has('menu'),
        leading: Icons.restaurant_menu_outlined,
        title: l10n.menuManagementTitle,
        builder: (_) => const MenuItemsScreen(),
      ),
      _Tile(
        show: _has('menu'),
        leading: Icons.fastfood_outlined,
        title: l10n.menuBundlesTitle,
        builder: (_) => const MenuBundlesScreen(),
      ),
      _Tile(
        show: _has('orders'),
        leading: Icons.receipt_long_outlined,
        title: l10n.businessOrdersTitle,
        builder: (_) => const BusinessOrdersScreen(),
      ),
      _Tile(
        show: _has('orders'),
        leading: Icons.bar_chart_outlined,
        title: l10n.businessReportsTitle,
        builder: (_) => const BusinessOrderReportsScreen(),
      ),
      _Tile(
        show: _has('retail'),
        leading: Icons.inventory_2_outlined,
        title: l10n.retailListingsTitle,
        builder: (_) => const RetailListingsScreen(),
      ),
      _Tile(
        show: _has('retail'),
        leading: Icons.checkroom_outlined,
        title: l10n.retailVariantGroupsTitle,
        builder: (_) => const RetailVariantGroupsScreen(),
      ),
      _Tile(
        show: _has('clinic'),
        leading: Icons.local_hospital_outlined,
        title: l10n.clinicManagementTitle,
        builder: (_) => const ClinicManagementScreen(),
      ),
      _Tile(
        show: _has('prescriptions'),
        leading: Icons.receipt_long_outlined,
        title: l10n.prescriptionsIssuedTitle,
        builder: (_) => const IssuedPrescriptionsScreen(),
      ),
      _Tile(
        show: _has('prescriptions'),
        leading: Icons.local_pharmacy_outlined,
        title: l10n.pharmacyQueueTitle,
        builder: (_) => const PharmacyQueueScreen(),
      ),
      _Tile(
        show: _has('training'),
        leading: Icons.fitness_center_outlined,
        title: l10n.trainingTemplatesTitle,
        builder: (_) => const TrainingTemplatesScreen(),
      ),
      _Tile(
        show: _has('training'),
        leading: Icons.groups_outlined,
        title: l10n.myTrainingClientsTitle,
        builder: (_) => const MyTrainingClientsScreen(),
      ),
      _Tile(
        show: _has('prices'),
        leading: Icons.sell_outlined,
        title: l10n.businessPricesTitle,
        builder: (_) => const BusinessPricesScreen(),
      ),
      _Tile(
        show: _has('offers'),
        leading: Icons.local_offer_outlined,
        title: l10n.businessOffersTitle,
        builder: (_) => const BusinessOffersScreen(),
      ),
      _Tile(
        show: _has('bookings'),
        leading: Icons.event_available_outlined,
        title: l10n.bookingSettingsTitle,
        builder: (_) => const BookingSettingsScreen(),
      ),
      _Tile(
        show: _has('bookings'),
        leading: Icons.event_note_outlined,
        title: l10n.businessBookingsTitle,
        builder: (_) => const BusinessBookingsScreen(),
      ),
      _Tile(
        show: _has('drivers'),
        leading: Icons.delivery_dining_outlined,
        title: l10n.deliveryMyDriversTitle,
        builder: (_) => const MyDriversScreen(),
      ),
      _Tile(
        show: isCarrier,
        leading: Icons.local_shipping_outlined,
        title: l10n.shippingOrdersTitle,
        builder: (_) => const ShippingOrdersScreen(),
      ),
      _Tile(
        show: isCarrier,
        leading: Icons.price_change_outlined,
        title: l10n.shippingRatesTitle,
        builder: (_) => const ShippingRatesScreen(),
      ),
      _Tile(
        show: isCarrier,
        leading: Icons.delivery_dining_outlined,
        title: l10n.deliveryDashboardTitle,
        builder: (_) => const DriverDashboardScreen(),
      ),
      _Tile(
        show: _has('orders'),
        leading: Icons.local_shipping_outlined,
        title: l10n.deliveryFeeSettingsTitle,
        builder: (context) => Consumer(
          builder: (context, ref, _) {
            final api = ref.read(deliveryApiProvider);
            return DeliveryFeeSettingsScreen(
              hint: l10n.deliveryFeeBusinessHint,
              load: api.businessDeliveryFee,
              save: api.setBusinessDeliveryFee,
            );
          },
        ),
      ),
      _Tile(
        show: true, // account management — no capability of its own.
        leading: Icons.badge_outlined,
        title: l10n.staffTitle,
        builder: (_) => const StaffScreen(),
      ),
      _Tile(
        show: true, // account management — no capability of its own.
        leading: Icons.fact_check_outlined,
        title: l10n.staffActivityTitle,
        builder: (_) => const StaffActivityScreen(),
      ),
      _Tile(
        show: true, // account management — no capability of its own.
        leading: Icons.groups_outlined,
        title: l10n.staffGroupsTitle,
        builder: (_) => const StaffGroupsScreen(),
      ),
      _Tile(
        show: true, // account management — no capability of its own.
        leading: Icons.qr_code_2_outlined,
        title: l10n.attendanceVerificationSettingsTitle,
        builder: (_) => const AttendanceVerificationSettingsScreen(),
      ),
      _Tile(
        show: _has('orders'),
        leading: Icons.room_service_outlined,
        title: l10n.tableCallsTitle,
        builder: (_) => const TableCallsScreen(),
      ),
      _Tile(
        show: _has('projects'),
        leading: Icons.timeline_outlined,
        title: l10n.projectsTitle,
        builder: (_) => const ProjectsScreen(),
      ),
      _Tile(
        show: _has('schedules'),
        leading: Icons.local_shipping_outlined,
        title: l10n.myTripSchedulesTitle,
        builder: (_) => const MyTripSchedulesScreen(),
      ),
      _Tile(
        show: true, // account management — no capability of its own.
        leading: Icons.account_balance_outlined,
        title: l10n.merchantAccountTitle,
        builder: (_) => const MerchantAccountScreen(),
      ),
    ].where((t) => t.show).toList();

    if (tiles.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            l10n.settingsNoServicesForCategory,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).hintColor),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _OptionCard(
          children: [
            for (var i = 0; i < tiles.length; i++) ...[
              if (i > 0) const Divider(height: 1),
              ListTile(
                leading: Icon(tiles[i].leading),
                title: Text(tiles[i].title),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: tiles[i].builder)),
              ),
            ],
          ],
        ),
      ],
    );
  }
}

class _Tile {
  final bool show;
  final IconData leading;
  final String title;
  final WidgetBuilder builder;
  const _Tile({required this.show, required this.leading, required this.title, required this.builder});
}

class _OptionCard extends StatelessWidget {
  final List<Widget> children;
  const _OptionCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: Column(children: children),
    );
  }
}

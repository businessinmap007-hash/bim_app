import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../booking_settings/presentation/screens/booking_settings_screen.dart';
import '../../../business_offers/presentation/screens/business_offers_screen.dart';
import '../../../business_prices/presentation/screens/business_prices_screen.dart';
import '../../../business_menu/presentation/screens/menu_items_screen.dart';
import '../../../clinic_management/presentation/screens/clinic_management_screen.dart';
import '../../../merchant_account/presentation/screens/merchant_account_screen.dart';
import '../../../prescriptions/presentation/screens/issued_prescriptions_screen.dart';
import '../../../prescriptions/presentation/screens/pharmacy_queue_screen.dart';
import '../../../projects/presentation/screens/projects_screen.dart';
import '../../../retail_listings/presentation/screens/retail_listings_screen.dart';
import '../../../schedules/presentation/screens/my_trip_schedules_screen.dart';
import '../../../staff/presentation/screens/staff_screen.dart';
import '../../../training/presentation/screens/my_training_clients_screen.dart';
import '../../../training_templates/presentation/screens/training_templates_screen.dart';

/// A business's own service-management screens, one per capability it may
/// hold — split out of the general [SettingsScreen] (language/appearance/
/// account are everyone's concern; these are a business's alone, and the
/// combined list had grown long enough to bury both halves in one scroll).
/// Reached from the drawer's "إعدادات الخدمات" entry, business accounts only.
class ServicesSettingsScreen extends StatelessWidget {
  const ServicesSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settingsServicesSection)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _OptionCard(
            children: [
              ListTile(
                leading: const Icon(Icons.restaurant_menu_outlined),
                title: Text(l10n.menuManagementTitle),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const MenuItemsScreen()),
                ),
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.inventory_2_outlined),
                title: Text(l10n.retailListingsTitle),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const RetailListingsScreen()),
                ),
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.local_hospital_outlined),
                title: Text(l10n.clinicManagementTitle),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const ClinicManagementScreen()),
                ),
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.receipt_long_outlined),
                title: Text(l10n.prescriptionsIssuedTitle),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const IssuedPrescriptionsScreen()),
                ),
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.local_pharmacy_outlined),
                title: Text(l10n.pharmacyQueueTitle),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const PharmacyQueueScreen()),
                ),
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.fitness_center_outlined),
                title: Text(l10n.trainingTemplatesTitle),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const TrainingTemplatesScreen()),
                ),
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.groups_outlined),
                title: Text(l10n.myTrainingClientsTitle),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const MyTrainingClientsScreen()),
                ),
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.sell_outlined),
                title: Text(l10n.businessPricesTitle),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const BusinessPricesScreen()),
                ),
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.local_offer_outlined),
                title: Text(l10n.businessOffersTitle),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const BusinessOffersScreen()),
                ),
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.event_available_outlined),
                title: Text(l10n.bookingSettingsTitle),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const BookingSettingsScreen()),
                ),
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.badge_outlined),
                title: Text(l10n.staffTitle),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const StaffScreen()),
                ),
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.timeline_outlined),
                title: Text(l10n.projectsTitle),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const ProjectsScreen()),
                ),
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.local_shipping_outlined),
                title: Text(l10n.myTripSchedulesTitle),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const MyTripSchedulesScreen()),
                ),
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.account_balance_outlined),
                title: Text(l10n.merchantAccountTitle),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const MerchantAccountScreen()),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
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

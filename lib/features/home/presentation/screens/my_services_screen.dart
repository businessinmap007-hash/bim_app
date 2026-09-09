import 'package:flutter/material.dart';

import '../../../../core/responsive/breakpoints.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/widgets/app_drawer.dart';
import '../../../addresses/presentation/screens/addresses_screen.dart';
import '../../../agenda/presentation/screens/agenda_screen.dart';
import '../../../clinic/presentation/screens/my_clinic_appointments_screen.dart';
import '../../../deposits/presentation/screens/deposits_screen.dart';
import '../../../disputes/presentation/screens/disputes_screen.dart';
import '../../../fines/presentation/screens/fines_screen.dart';
import '../../../general_chat/presentation/screens/chats_list_screen.dart';
import '../../../guarantee/presentation/screens/guarantee_screen.dart';
import '../../../orders/presentation/screens/orders_and_bookings_screen.dart';
import '../../../prescriptions/presentation/screens/prescriptions_screen.dart';
import '../../../retail_discovery/presentation/screens/shop_products_screen.dart';
import '../../../schedules/presentation/screens/trip_search_screen.dart';
import '../../../table/presentation/screens/table_scan_screen.dart';
import '../../../training/presentation/screens/training_plans_screen.dart';
import '../../../wallet/presentation/screens/wallet_screen.dart';

/// Every service a person has actually USED on the platform, one primary
/// destination instead of buried 15 items deep in the drawer — table
/// ordering, chats, orders/bookings, prescriptions, a clinic visit, a
/// training plan, wallet, and so on. Same for a business or a customer
/// account: using a service as a customer isn't a business-vs-customer
/// concern, unlike the business's own "Service settings" (what IT offers),
/// which stays business-only inside My Account.
class MyServicesScreen extends StatelessWidget {
  /// Lets [HomeShell] close this tab's own drawer before switching away from
  /// it — an [IndexedStack] tab never disposes, so a drawer left open would
  /// otherwise still be open the next time this tab comes back on screen.
  final GlobalKey<ScaffoldState>? scaffoldKey;
  const MyServicesScreen({super.key, this.scaffoldKey});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(title: Text(l10n.drawerSectionMyServices)),
      drawer: const AppDrawer(),
      body: ResponsiveCenter(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _OptionCard(
              children: [
                ListTile(
                  leading: const Icon(Icons.qr_code_outlined),
                  title: Text(l10n.tableScanTitle),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const TableScanScreen()),
                  ),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.chat_bubble_outline),
                  title: Text(l10n.chatsListTitle),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const ChatsListScreen()),
                  ),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.receipt_long_outlined),
                  title: Text(l10n.ordersBookingsTitle),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const OrdersAndBookingsScreen(),
                    ),
                  ),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.receipt_long_outlined),
                  title: Text(l10n.prescriptionsTitle),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const PrescriptionsScreen(),
                    ),
                  ),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.local_hospital_outlined),
                  title: Text(l10n.myClinicAppointmentsTitle),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const MyClinicAppointmentsScreen(),
                    ),
                  ),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.fitness_center_outlined),
                  title: Text(l10n.trainingPlansTitle),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const TrainingPlansScreen(),
                    ),
                  ),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.storefront_outlined),
                  title: Text(l10n.shopProductsTitle),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const ShopProductsScreen(),
                    ),
                  ),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.account_balance_wallet_outlined),
                  title: Text(l10n.walletTitle),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const WalletScreen()),
                  ),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.calendar_month_outlined),
                  title: Text(l10n.agendaTitle),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const AgendaScreen()),
                  ),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.local_shipping_outlined),
                  title: Text(l10n.tripSearchTitle),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const TripSearchScreen()),
                  ),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.lock_outline),
                  title: Text(l10n.depositsTitle),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const DepositsScreen()),
                  ),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.verified_user_outlined),
                  title: Text(l10n.guaranteeTitle),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const GuaranteeScreen()),
                  ),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.gavel_outlined),
                  title: Text(l10n.finesTitle),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const FinesScreen()),
                  ),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.gavel_outlined),
                  title: Text(l10n.disputesTitle),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const DisputesScreen()),
                  ),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.location_on_outlined),
                  title: Text(l10n.addressesTitle),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const AddressesScreen()),
                  ),
                ),
              ],
            ),
          ],
        ),
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

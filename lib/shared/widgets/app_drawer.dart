import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme/app_colors.dart';
import '../../features/addresses/presentation/screens/addresses_screen.dart';
import '../../features/agenda/presentation/screens/agenda_screen.dart';
import '../../features/auth/application/auth_controller.dart';
import '../../features/disputes/presentation/screens/disputes_screen.dart';
import '../../features/clinic/presentation/screens/my_clinic_appointments_screen.dart';
import '../../features/deposits/presentation/screens/deposits_screen.dart';
import '../../features/general_chat/presentation/screens/chats_list_screen.dart';
import '../../features/fines/presentation/screens/fines_screen.dart';
import '../../features/guarantee/presentation/screens/guarantee_screen.dart';
import '../../features/jobs/presentation/screens/jobs_screen.dart';
import '../../features/offers/presentation/screens/my_offer_follows_screen.dart';
import '../../features/offers/presentation/screens/offers_screen.dart';
import '../../features/orders/presentation/screens/orders_and_bookings_screen.dart';
import '../../features/posts/presentation/screens/my_follows_screen.dart';
import '../../features/prescriptions/presentation/screens/prescriptions_screen.dart';
import '../../features/retail_discovery/presentation/screens/shop_products_screen.dart';
import '../../features/schedules/presentation/screens/trip_search_screen.dart';
import '../../features/settings/presentation/screens/services_settings_screen.dart';
import '../../features/training/presentation/screens/training_plans_screen.dart';
import '../../features/wallet/presentation/screens/wallet_screen.dart';
import '../../l10n/app_localizations.dart';

/// The app's account menu — reached via the AppBar's automatic hamburger
/// icon (Scaffold shows it whenever `drawer:` is set). Settings and logout
/// live here, not as loose AppBar icons or bottom-nav tabs: neither is a
/// "primary destination" the way Home is.
///
/// Grouped into four sections rather than one flat list of 15+ items: profile
/// & account settings, jobs/posts-adjacent follows, the business's own
/// service-management screens (business accounts only), and everything else
/// that's a customer's own activity/history ("My Services"). Posts
/// management itself isn't here — it's Home's own tabs now (see
/// [BusinessHomeScreen]/[CustomerHomeScreen]), with `+` in the AppBar to
/// create one, so it never belonged in an account-utility menu either.
class AppDrawer extends ConsumerWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final authState = ref.watch(authControllerProvider);
    final user = authState is AuthSignedIn ? authState.user : null;
    final isBusiness = authState is AuthSignedIn && authState.user.isBusiness;

    void close() => Navigator.of(context).pop();

    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(color: AppColors.primaryNavy),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const Icon(Icons.push_pin_rounded, color: AppColors.accentGold, size: 32),
                  const SizedBox(height: 8),
                  if (user != null)
                    Text(
                      user.name,
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 16),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  if (user != null)
                    Text(
                      user.email,
                      style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 13),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  _SectionHeader(l10n.drawerSectionProfile),
                  ListTile(
                    leading: const Icon(Icons.settings_outlined),
                    title: Text(l10n.settingsTitle),
                    onTap: () {
                      close();
                      context.push('/settings');
                    },
                  ),

                  _SectionHeader(l10n.drawerSectionJobsPosts),
                  ListTile(
                    leading: const Icon(Icons.work_outline),
                    title: Text(l10n.jobsTitle),
                    onTap: () {
                      close();
                      Navigator.of(context).push(MaterialPageRoute(builder: (_) => const JobsScreen()));
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.people_outline),
                    title: Text(l10n.myFollowsTitle),
                    onTap: () {
                      close();
                      Navigator.of(context).push(MaterialPageRoute(builder: (_) => const MyFollowsScreen()));
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.local_offer_outlined),
                    title: Text(l10n.offersTitle),
                    onTap: () {
                      close();
                      Navigator.of(context).push(MaterialPageRoute(builder: (_) => const OffersScreen()));
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.notifications_none),
                    title: Text(l10n.myOfferFollowsTitle),
                    onTap: () {
                      close();
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const MyOfferFollowsScreen()),
                      );
                    },
                  ),

                  if (isBusiness) ...[
                    _SectionHeader(l10n.settingsServicesSection),
                    ListTile(
                      leading: const Icon(Icons.storefront_outlined),
                      title: Text(l10n.settingsServicesSection),
                      onTap: () {
                        close();
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const ServicesSettingsScreen()),
                        );
                      },
                    ),
                  ],

                  _SectionHeader(l10n.drawerSectionMyServices),
                  ListTile(
                    leading: const Icon(Icons.chat_bubble_outline),
                    title: Text(l10n.chatsListTitle),
                    onTap: () {
                      close();
                      Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ChatsListScreen()));
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.receipt_long_outlined),
                    title: Text(l10n.ordersBookingsTitle),
                    onTap: () {
                      close();
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const OrdersAndBookingsScreen()),
                      );
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.receipt_long_outlined),
                    title: Text(l10n.prescriptionsTitle),
                    onTap: () {
                      close();
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const PrescriptionsScreen()),
                      );
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.local_hospital_outlined),
                    title: Text(l10n.myClinicAppointmentsTitle),
                    onTap: () {
                      close();
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const MyClinicAppointmentsScreen()),
                      );
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.fitness_center_outlined),
                    title: Text(l10n.trainingPlansTitle),
                    onTap: () {
                      close();
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const TrainingPlansScreen()),
                      );
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.storefront_outlined),
                    title: Text(l10n.shopProductsTitle),
                    onTap: () {
                      close();
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const ShopProductsScreen()),
                      );
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.account_balance_wallet_outlined),
                    title: Text(l10n.walletTitle),
                    onTap: () {
                      close();
                      Navigator.of(context).push(MaterialPageRoute(builder: (_) => const WalletScreen()));
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.calendar_month_outlined),
                    title: Text(l10n.agendaTitle),
                    onTap: () {
                      close();
                      Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AgendaScreen()));
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.local_shipping_outlined),
                    title: Text(l10n.tripSearchTitle),
                    onTap: () {
                      close();
                      Navigator.of(context).push(MaterialPageRoute(builder: (_) => const TripSearchScreen()));
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.lock_outline),
                    title: Text(l10n.depositsTitle),
                    onTap: () {
                      close();
                      Navigator.of(context).push(MaterialPageRoute(builder: (_) => const DepositsScreen()));
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.verified_user_outlined),
                    title: Text(l10n.guaranteeTitle),
                    onTap: () {
                      close();
                      Navigator.of(context).push(MaterialPageRoute(builder: (_) => const GuaranteeScreen()));
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.gavel_outlined),
                    title: Text(l10n.finesTitle),
                    onTap: () {
                      close();
                      Navigator.of(context).push(MaterialPageRoute(builder: (_) => const FinesScreen()));
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.gavel_outlined),
                    title: Text(l10n.disputesTitle),
                    onTap: () {
                      close();
                      Navigator.of(context).push(MaterialPageRoute(builder: (_) => const DisputesScreen()));
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.location_on_outlined),
                    title: Text(l10n.addressesTitle),
                    onTap: () {
                      close();
                      Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AddressesScreen()));
                    },
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            ListTile(
              leading: Icon(Icons.logout, color: Theme.of(context).colorScheme.error),
              title: Text(l10n.authLogout, style: TextStyle(color: Theme.of(context).colorScheme.error)),
              onTap: () {
                Navigator.of(context).pop();
                ref.read(authControllerProvider.notifier).logout();
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String label;
  const _SectionHeader(this.label);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Text(
        label,
        style: Theme.of(
          context,
        ).textTheme.labelMedium?.copyWith(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.w700),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme/app_colors.dart';
import '../../features/addresses/presentation/screens/addresses_screen.dart';
import '../../features/agenda/presentation/screens/agenda_screen.dart';
import '../../features/auth/application/auth_controller.dart';
import '../../features/disputes/presentation/screens/disputes_screen.dart';
import '../../features/clinic/presentation/screens/my_clinic_appointments_screen.dart';
import '../../features/fines/presentation/screens/fines_screen.dart';
import '../../features/offers/presentation/screens/my_offer_follows_screen.dart';
import '../../features/offers/presentation/screens/offers_screen.dart';
import '../../features/orders/presentation/screens/orders_and_bookings_screen.dart';
import '../../features/posts/presentation/screens/my_posts_screen.dart';
import '../../features/prescriptions/presentation/screens/prescriptions_screen.dart';
import '../../features/schedules/presentation/screens/trip_search_screen.dart';
import '../../features/training/presentation/screens/training_plans_screen.dart';
import '../../features/wallet/presentation/screens/wallet_screen.dart';
import '../../l10n/app_localizations.dart';

/// The app's account menu — reached via the AppBar's automatic hamburger
/// icon (Scaffold shows it whenever `drawer:` is set). Settings and logout
/// live here, not as loose AppBar icons or bottom-nav tabs: neither is a
/// "primary destination" the way Home is.
class AppDrawer extends ConsumerWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final authState = ref.watch(authControllerProvider);
    final user = authState is AuthSignedIn ? authState.user : null;

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
                  ListTile(
                    leading: const Icon(Icons.dynamic_feed_outlined),
                    title: Text(l10n.postsMyPostsTitle),
                    onTap: () {
                      Navigator.of(context).pop();
                      Navigator.of(context).push(MaterialPageRoute(builder: (_) => const MyPostsScreen()));
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.receipt_long_outlined),
                    title: Text(l10n.ordersBookingsTitle),
                    onTap: () {
                      Navigator.of(context).pop();
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const OrdersAndBookingsScreen()),
                      );
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.account_balance_wallet_outlined),
                    title: Text(l10n.walletTitle),
                    onTap: () {
                      Navigator.of(context).pop();
                      Navigator.of(context).push(MaterialPageRoute(builder: (_) => const WalletScreen()));
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.calendar_month_outlined),
                    title: Text(l10n.agendaTitle),
                    onTap: () {
                      Navigator.of(context).pop();
                      Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AgendaScreen()));
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.gavel_outlined),
                    title: Text(l10n.finesTitle),
                    onTap: () {
                      Navigator.of(context).pop();
                      Navigator.of(context).push(MaterialPageRoute(builder: (_) => const FinesScreen()));
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.local_shipping_outlined),
                    title: Text(l10n.tripSearchTitle),
                    onTap: () {
                      Navigator.of(context).pop();
                      Navigator.of(context).push(MaterialPageRoute(builder: (_) => const TripSearchScreen()));
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.local_hospital_outlined),
                    title: Text(l10n.myClinicAppointmentsTitle),
                    onTap: () {
                      Navigator.of(context).pop();
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const MyClinicAppointmentsScreen()),
                      );
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.fitness_center_outlined),
                    title: Text(l10n.trainingPlansTitle),
                    onTap: () {
                      Navigator.of(context).pop();
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const TrainingPlansScreen()),
                      );
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.receipt_long_outlined),
                    title: Text(l10n.prescriptionsTitle),
                    onTap: () {
                      Navigator.of(context).pop();
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const PrescriptionsScreen()),
                      );
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.local_offer_outlined),
                    title: Text(l10n.offersTitle),
                    onTap: () {
                      Navigator.of(context).pop();
                      Navigator.of(context).push(MaterialPageRoute(builder: (_) => const OffersScreen()));
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.notifications_none),
                    title: Text(l10n.myOfferFollowsTitle),
                    onTap: () {
                      Navigator.of(context).pop();
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const MyOfferFollowsScreen()),
                      );
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.gavel_outlined),
                    title: Text(l10n.disputesTitle),
                    onTap: () {
                      Navigator.of(context).pop();
                      Navigator.of(context).push(MaterialPageRoute(builder: (_) => const DisputesScreen()));
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.location_on_outlined),
                    title: Text(l10n.addressesTitle),
                    onTap: () {
                      Navigator.of(context).pop();
                      Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AddressesScreen()));
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.settings_outlined),
                    title: Text(l10n.settingsTitle),
                    onTap: () {
                      Navigator.of(context).pop();
                      context.push('/settings');
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

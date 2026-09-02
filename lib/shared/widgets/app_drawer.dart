import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme/app_colors.dart';
import '../../features/auth/application/auth_controller.dart';
import '../../features/orders/presentation/screens/orders_and_bookings_screen.dart';
import '../../features/posts/presentation/screens/my_posts_screen.dart';
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
              leading: const Icon(Icons.settings_outlined),
              title: Text(l10n.settingsTitle),
              onTap: () {
                Navigator.of(context).pop();
                context.push('/settings');
              },
            ),
            const Spacer(),
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

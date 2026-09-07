import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../business/presentation/screens/business_detail_screen.dart';
import '../../cart/application/shared_cart_providers.dart';
import '../../cart/presentation/screens/shared_cart_screen.dart';
import '../../jobs/presentation/screens/job_detail_screen.dart';
import '../../offers/presentation/screens/offer_detail_screen.dart';
import '../../orders/presentation/screens/business_orders_screen.dart';
import '../../wallet/presentation/screens/wallet_screen.dart';
import '../data/models/app_notification.dart';

/// Routes a notification tap to whatever it's actually about, keyed on
/// `action_type` — the stable, deliberately-chosen vocabulary every
/// `NotificationDispatcherService::dispatch()` caller already picks from
/// (see NotificationChannelRule/AppNotification.php on the backend), not
/// `action_url` (a backend/admin path this app has no matching route for).
///
/// Only the action_types with a real bim_app screen to land on are handled;
/// an unhandled one is a silent no-op (the tap still marks the notification
/// read) rather than a dead link — `open_business_products`,
/// `open_shared_cart` (needs a share token, not an id) and
/// `open_table_calls` (no dedicated screen yet) aren't wired up.
Future<void> openNotificationTarget(BuildContext context, WidgetRef ref, AppNotification notification) async {
  final id = notification.notifiableId;

  switch (notification.actionType) {
    case 'open_wallet':
      Navigator.of(context).push(MaterialPageRoute(builder: (_) => const WalletScreen()));
    case 'open_business_order':
      if (id != null) {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => BusinessOrderDetailScreen(orderId: id)),
        );
      }
    case 'open_job':
      if (id != null) {
        Navigator.of(context).push(MaterialPageRoute(builder: (_) => JobDetailScreen(jobId: id)));
      }
    case 'open_offer':
      if (id != null) {
        Navigator.of(context).push(MaterialPageRoute(builder: (_) => OfferDetailScreen(offerId: id)));
      }
    case 'open_business':
      if (id != null) {
        Navigator.of(context).push(MaterialPageRoute(builder: (_) => BusinessDetailScreen(businessId: id)));
      }
    // The recipient isn't a participant yet — unlike `open_shared_cart_member_joined`- ish notifications
    // sent to the host, who already is one. Join on the same token a shared
    // link or QR would use, then land on the cart like any other joiner.
    case 'open_shared_cart_invite':
      final token = notification.meta['share_token'] as String?;
      if (token == null || token.isEmpty) return;
      try {
        final cart = await ref.read(sharedCartApiProvider).join(token);
        if (context.mounted) {
          Navigator.of(context).push(MaterialPageRoute(builder: (_) => SharedCartScreen(orderId: cart.id)));
        }
      } catch (_) {
        // The cart may have been cancelled/checked out since the invite was
        // sent — a failed join here is not worth surfacing as an error.
      }
  }
}

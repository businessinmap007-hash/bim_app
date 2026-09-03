import 'package:flutter/material.dart';

import '../../business/presentation/screens/business_detail_screen.dart';
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
void openNotificationTarget(BuildContext context, AppNotification notification) {
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
  }
}

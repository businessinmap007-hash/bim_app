import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/application/auth_controller.dart';
import '../../booking/presentation/screens/business_bookings_screen.dart';
import '../../business/presentation/screens/business_detail_screen.dart';
import '../../cart/application/shared_cart_providers.dart';
import '../../cart/presentation/screens/shared_cart_screen.dart';
import '../../delivery/presentation/screens/available_orders_screen.dart';
import '../../delivery/presentation/screens/driver_order_loader_screen.dart';
import '../../shipping/presentation/screens/shipping_orders_screen.dart';
import '../../jobs/presentation/screens/job_detail_screen.dart';
import '../../offers/presentation/screens/offer_detail_screen.dart';
import '../../orders/presentation/screens/business_orders_screen.dart';
import '../../orders/presentation/screens/customer_order_detail_screen.dart';
import '../../orders/presentation/screens/orders_and_bookings_screen.dart';
import '../../staff/presentation/screens/staff_invitation_dialog.dart';
import '../../training/presentation/screens/training_plan_detail_screen.dart';
import '../../training/presentation/screens/training_plan_manage_screen.dart';
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
          MaterialPageRoute(
            builder: (_) => BusinessOrderDetailScreen(
              orderId: id,
              businessId: (notification.meta['business_id'] as num?)?.toInt(),
            ),
          ),
        );
      }
    case 'open_shipping_order':
      Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ShippingOrdersScreen()));
    case 'open_driver_order':
      if (id != null) {
        Navigator.of(context).push(MaterialPageRoute(builder: (_) => DriverOrderLoaderScreen(orderId: id)));
      }
    case 'open_available_orders':
      Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AvailableOrdersScreen()));
    case 'open_customer_order':
      if (id != null) {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => CustomerOrderDetailScreen(orderId: id)),
        );
      }
    // The trainer's side of a plan: a client accepted/declined it or finished
    // a day's workout.
    case 'open_training_plan_manage':
      if (id != null) {
        Navigator.of(context).push(MaterialPageRoute(builder: (_) => TrainingPlanManageScreen(planId: id)));
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
    // Not the business's page — the one thing this tap is for is
    // accepting/declining, so it opens straight onto that instead.
    case 'open_staff_invitation':
      if (id != null) {
        await showStaffInvitationDialog(
          context,
          ref,
          businessId: id,
          businessName: notification.actor?.name ?? '',
          businessLogoUrl: notification.actor?.imageUrl,
        );
      }
    // The client's own copy of a plan the trainer assigned — the trainer's
    // accept/decline confirmation uses its own `open_training_plan_manage`
    // (not wired here yet), so this is always the client-facing screen.
    case 'open_training_plan':
      if (id != null) {
        Navigator.of(context).push(MaterialPageRoute(builder: (_) => TrainingPlanDetailScreen(planId: id)));
      }
    // Every booking.* event (see ServiceEventKeys.php) notifies whichever
    // side isn't the actor, with the booking as the notification's subject —
    // same routing regardless of which one fired: business lands on its own
    // incoming-booking screen, client lands on the same detail sheet its own
    // "My bookings" tab opens.
    case 'booking.requested':
    case 'booking.accepted':
    case 'booking.rejected':
    case 'booking.cancelled':
    case 'booking.rescheduled':
    case 'booking.started':
    case 'booking.completed':
    case 'booking.client_confirmed':
    case 'booking.business_confirmed':
    case 'booking.reminder_24h':
    case 'booking.reminder_1h':
    case 'booking.deposit_frozen':
    case 'booking.deposit_released':
    case 'booking.deposit_refunded':
    case 'booking.dispute_opened':
      if (id != null) {
        final authState = ref.read(authControllerProvider);
        final isBusiness = authState is AuthSignedIn && authState.user.isBusiness;
        if (isBusiness) {
          Navigator.of(context).push(MaterialPageRoute(builder: (_) => BusinessBookingDetailScreen(bookingId: id)));
        } else {
          await openBookingDetailSheet(context, ref, id);
        }
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

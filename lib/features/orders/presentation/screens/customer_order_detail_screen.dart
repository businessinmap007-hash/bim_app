import 'package:flutter/material.dart';

import 'orders_and_bookings_screen.dart';

/// Landing spot for a customer-facing order notification tap (`open_customer_order`)
/// — the order detail itself only exists as [OrderDetailSheet], a modal meant
/// to be opened from the orders list. Rather than duplicate that UI in a
/// second, route-able widget, this pushes the full Orders & Bookings screen
/// and pops the same sheet open on top of it as soon as the frame settles:
/// dismissing the sheet leaves the customer on their normal order list.
class CustomerOrderDetailScreen extends StatefulWidget {
  final int orderId;
  const CustomerOrderDetailScreen({super.key, required this.orderId});

  @override
  State<CustomerOrderDetailScreen> createState() => _CustomerOrderDetailScreenState();
}

class _CustomerOrderDetailScreenState extends State<CustomerOrderDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (_) => OrderDetailSheet(orderId: widget.orderId),
      );
    });
  }

  @override
  Widget build(BuildContext context) => const OrdersAndBookingsScreen();
}

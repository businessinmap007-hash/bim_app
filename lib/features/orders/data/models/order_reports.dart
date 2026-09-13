/// Mirrors `OrderController::businessReports()` — aggregates only, never raw
/// order rows (those already live in `PlacedOrder`/the incoming-orders queue).
class OrderReportsSummary {
  final int totalOrders;
  final int completedOrders;
  final int cancelledOrders;
  final int pendingOrders;
  final double totalRevenue;
  final double averageOrderValue;

  const OrderReportsSummary({
    required this.totalOrders,
    required this.completedOrders,
    required this.cancelledOrders,
    required this.pendingOrders,
    required this.totalRevenue,
    required this.averageOrderValue,
  });

  factory OrderReportsSummary.fromJson(Map<String, dynamic> json) => OrderReportsSummary(
    totalOrders: (json['total_orders'] as num?)?.toInt() ?? 0,
    completedOrders: (json['completed_orders'] as num?)?.toInt() ?? 0,
    cancelledOrders: (json['cancelled_orders'] as num?)?.toInt() ?? 0,
    pendingOrders: (json['pending_orders'] as num?)?.toInt() ?? 0,
    totalRevenue: (json['total_revenue'] as num?)?.toDouble() ?? 0,
    averageOrderValue: (json['average_order_value'] as num?)?.toDouble() ?? 0,
  );
}

class OrderReportsDailyPoint {
  final DateTime date;
  final int ordersCount;
  final double revenue;

  const OrderReportsDailyPoint({required this.date, required this.ordersCount, required this.revenue});

  factory OrderReportsDailyPoint.fromJson(Map<String, dynamic> json) => OrderReportsDailyPoint(
    date: DateTime.parse(json['date'] as String),
    ordersCount: (json['orders_count'] as num?)?.toInt() ?? 0,
    revenue: (json['revenue'] as num?)?.toDouble() ?? 0,
  );
}

class OrderReports {
  final DateTime from;
  final DateTime to;
  final OrderReportsSummary summary;
  final List<OrderReportsDailyPoint> daily;
  final int deliveryCount;
  final int pickupCount;
  final int dineInCount;

  const OrderReports({
    required this.from,
    required this.to,
    required this.summary,
    required this.daily,
    required this.deliveryCount,
    required this.pickupCount,
    required this.dineInCount,
  });

  factory OrderReports.fromJson(Map<String, dynamic> json) {
    final byType = json['by_fulfillment_type'] as Map<String, dynamic>? ?? const {};
    return OrderReports(
      from: DateTime.parse(json['from'] as String),
      to: DateTime.parse(json['to'] as String),
      summary: OrderReportsSummary.fromJson(json['summary'] as Map<String, dynamic>),
      daily: (json['daily'] as List<dynamic>? ?? const [])
          .map((e) => OrderReportsDailyPoint.fromJson(e as Map<String, dynamic>))
          .toList(),
      deliveryCount: (byType['delivery'] as num?)?.toInt() ?? 0,
      pickupCount: (byType['pickup'] as num?)?.toInt() ?? 0,
      dineInCount: (byType['dine_in'] as num?)?.toInt() ?? 0,
    );
  }
}

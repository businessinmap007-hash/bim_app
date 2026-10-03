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

/// The cash view of a business that also sells on instalments.
class OrderReportsCash {
  final OrderReportsSummary summary;
  final List<OrderReportsDailyPoint> daily;
  const OrderReportsCash({required this.summary, required this.daily});

  factory OrderReportsCash.fromJson(Map<String, dynamic> json) => OrderReportsCash(
    summary: OrderReportsSummary.fromJson(json['summary'] as Map<String, dynamic>),
    daily: (json['daily'] as List<dynamic>? ?? const [])
        .map((e) => OrderReportsDailyPoint.fromJson(e as Map<String, dynamic>))
        .toList(),
  );
}

/// One payment still to collect.
class InstallmentDue {
  final int orderId;
  final int seq;
  final int count;
  final DateTime dueOn;
  final double amount;
  final String customer;
  final bool overdue;
  const InstallmentDue({
    required this.orderId,
    required this.seq,
    required this.count,
    required this.dueOn,
    required this.amount,
    required this.customer,
    required this.overdue,
  });

  factory InstallmentDue.fromJson(Map<String, dynamic> json) => InstallmentDue(
    orderId: (json['order_id'] as num).toInt(),
    seq: (json['seq'] as num).toInt(),
    count: (json['count'] as num?)?.toInt() ?? 0,
    dueOn: DateTime.parse(json['due_on'] as String),
    amount: (json['amount'] as num?)?.toDouble() ?? 0,
    customer: json['customer'] as String? ?? '',
    overdue: json['overdue'] as bool? ?? false,
  );
}

class InstallmentMonth {
  final String month; // yyyy-MM
  final int count;
  final double amount;
  const InstallmentMonth({required this.month, required this.count, required this.amount});

  factory InstallmentMonth.fromJson(Map<String, dynamic> json) => InstallmentMonth(
    month: json['month'] as String? ?? '',
    count: (json['count'] as num?)?.toInt() ?? 0,
    amount: (json['amount'] as num?)?.toDouble() ?? 0,
  );
}

/// «تقسيط»: what is owed to the business, what is collected, and what is still to come.
class InstallmentReport {
  final int ordersCount;
  final double contractTotal;
  final double collected;
  final double remaining;
  final double overdue;
  final List<InstallmentMonth> byMonth;
  final List<InstallmentDue> upcoming;
  const InstallmentReport({
    required this.ordersCount,
    required this.contractTotal,
    required this.collected,
    required this.remaining,
    required this.overdue,
    required this.byMonth,
    required this.upcoming,
  });

  factory InstallmentReport.fromJson(Map<String, dynamic> json) {
    final t = json['totals'] as Map<String, dynamic>? ?? const {};
    return InstallmentReport(
      ordersCount: (t['orders_count'] as num?)?.toInt() ?? 0,
      contractTotal: (t['contract_total'] as num?)?.toDouble() ?? 0,
      collected: (t['collected'] as num?)?.toDouble() ?? 0,
      remaining: (t['remaining'] as num?)?.toDouble() ?? 0,
      overdue: (t['overdue'] as num?)?.toDouble() ?? 0,
      byMonth: (json['by_month'] as List<dynamic>? ?? const [])
          .map((e) => InstallmentMonth.fromJson(e as Map<String, dynamic>))
          .toList(),
      upcoming: (json['upcoming'] as List<dynamic>? ?? const [])
          .map((e) => InstallmentDue.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class OrderReports {
  final DateTime from;
  final DateTime to;
  final OrderReportsSummary summary;
  final List<OrderReportsDailyPoint> daily;
  final int deliveryCount;
  final int pickupCount;
  final int dineInCount;
  /// Only a business that sells on instalments has the two views.
  final OrderReportsCash? cash;
  final InstallmentReport? installments;
  bool get hasInstallments => installments != null;

  const OrderReports({
    required this.from,
    required this.to,
    required this.summary,
    required this.daily,
    required this.deliveryCount,
    required this.pickupCount,
    required this.dineInCount,
    this.cash,
    this.installments,
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
      cash: json['cash'] is Map ? OrderReportsCash.fromJson(json['cash'] as Map<String, dynamic>) : null,
      installments: json['installments'] is Map
          ? InstallmentReport.fromJson(json['installments'] as Map<String, dynamic>)
          : null,
    );
  }
}

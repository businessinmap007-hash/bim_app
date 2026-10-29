import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/core_providers.dart';
import '../data/inventory_api.dart';
import '../data/inventory_models.dart';

/// Straight to the API on the phone; the desktop app overrides it with its offline / office-network transport.
final inventoryTransportProvider = Provider<InventoryTransport>((ref) => DirectInventoryTransport(ref.watch(apiClientProvider)));

final inventoryApiProvider = Provider<InventoryApi>((ref) => InventoryApi(ref.watch(inventoryTransportProvider)));

final invSettingsProvider = FutureProvider.autoDispose<InvSettings>((ref) => ref.watch(inventoryApiProvider).settings());

final invDashboardProvider = FutureProvider.autoDispose<InvDashboard>((ref) => ref.watch(inventoryApiProvider).dashboard());

final invCoverageProvider = FutureProvider.autoDispose<List<InvCoverage>>((ref) => ref.watch(inventoryApiProvider).coverage());

final invItemProvider = FutureProvider.autoDispose.family<({InvItem item, List<InvMove> moves, InvCoverage? coverage}), int>(
  (ref, id) => ref.watch(inventoryApiProvider).item(id),
);

/// Orders waiting for the owner's (or an approver's) yes.
final invPendingApprovalsProvider = FutureProvider.autoDispose<List<InvPurchaseOrder>>(
  (ref) => ref.watch(inventoryApiProvider).purchaseOrders(status: 'pending_approval'),
);

final invPurchaseOrderProvider = FutureProvider.autoDispose.family<InvPurchaseOrderDetail, int>(
  (ref, id) => ref.watch(inventoryApiProvider).purchaseOrder(id),
);

/// The supplier side: orders other businesses sent to this one.
final invIncomingOrdersProvider = FutureProvider.autoDispose<List<InvPurchaseOrder>>(
  (ref) => ref.watch(inventoryApiProvider).incomingPurchaseOrders(),
);

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/core_providers.dart';
import '../data/investigations_api.dart';
import '../data/models/investigation.dart';

final investigationsApiProvider = Provider<InvestigationsApi>((ref) => InvestigationsApi(ref.watch(apiClientProvider)));

/// The platform's own lists of tests and exams — what a doctor picks from.
final investigationCatalogProvider = FutureProvider.autoDispose<InvestigationCatalog>((ref) => ref.watch(investigationsApiProvider).catalog());

/// The caller's orders as a patient.
final myInvestigationOrdersProvider = FutureProvider.autoDispose<List<InvestigationOrder>>((ref) => ref.watch(investigationsApiProvider).myOrders());

/// The orders a doctor issued.
final issuedInvestigationOrdersProvider = FutureProvider.autoDispose<List<InvestigationOrder>>((ref) => ref.watch(investigationsApiProvider).issued());

final investigationOrderProvider = FutureProvider.autoDispose.family<InvestigationOrder, int>((ref, id) => ref.watch(investigationsApiProvider).order(id));

/// The registered centres and what each charges for this whole order.
final investigationCentersProvider = FutureProvider.autoDispose.family<List<InvestigationCenter>, int>((ref, orderId) => ref.watch(investigationsApiProvider).centers(orderId));

/// A centre's orders by tab: `incoming`, `accepted`, `done`.
final centerInvestigationOrdersProvider = FutureProvider.autoDispose.family<List<InvestigationOrder>, String>((ref, tab) => ref.watch(investigationsApiProvider).centerOrders(tab));

/// What a centre does and charges, for its page.
final centerTestsProvider = FutureProvider.autoDispose.family<List<CenterTest>, int>((ref, centerId) => ref.watch(investigationsApiProvider).centerTests(centerId));

/// A centre's own price list.
final centerPriceListProvider = FutureProvider.autoDispose<List<CenterTest>>((ref) => ref.watch(investigationsApiProvider).priceList());

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/core_providers.dart';
import '../data/customer_project_api.dart';
import '../data/models/customer_project_view.dart';

final customerProjectApiProvider = Provider<CustomerProjectApi>((ref) {
  return CustomerProjectApi(ref.watch(apiClientProvider));
});

class OperationKey {
  final String type;
  final int id;
  const OperationKey(this.type, this.id);

  @override
  bool operator ==(Object other) => other is OperationKey && other.type == type && other.id == id;

  @override
  int get hashCode => Object.hash(type, id);
}

final customerProjectViewProvider =
    FutureProvider.family<CustomerProjectView?, OperationKey>((ref, key) {
      return ref.watch(customerProjectApiProvider).show(key.type, key.id);
    });

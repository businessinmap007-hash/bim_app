import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/core_providers.dart';
import '../data/table_api.dart';

final tableApiProvider = Provider<TableApi>((ref) {
  return TableApi(ref.watch(apiClientProvider));
});

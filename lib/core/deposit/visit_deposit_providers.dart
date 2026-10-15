import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/core_providers.dart';
import 'visit_deposit_api.dart';

final visitDepositApiProvider = Provider<VisitDepositApi>((ref) => VisitDepositApi(ref.watch(apiClientProvider)));

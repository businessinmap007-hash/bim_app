import 'package:intl/intl.dart';

import '../../../core/network/api_client.dart';
import 'models/staff_activity.dart';

/// /business/staff-activity — the owner's end-of-shift review, as JSON.
/// See Api\V2\BusinessStaffController::activity(); owner-only (the backend
/// rejects a staff caller here regardless, via the `business` middleware).
class StaffActivityApi {
  final ApiClient _client;
  const StaffActivityApi(this._client);

  static final _dateFormat = DateFormat('yyyy-MM-dd');

  Future<StaffActivityPage> fetch({
    required DateTime from,
    required DateTime to,
    int? userId,
    int page = 1,
  }) async {
    final data =
        await _client.get(
              '/business/staff-activity',
              query: {
                'from': _dateFormat.format(from),
                'to': _dateFormat.format(to),
                'user_id': ?userId,
                'page': page,
              },
            )
            as Map<String, dynamic>;
    return StaffActivityPage.fromJson(data);
  }
}

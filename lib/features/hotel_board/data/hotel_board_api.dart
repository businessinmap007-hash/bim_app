import '../../../core/network/api_client.dart';
import 'models/occupancy_board.dart';

/// GET /business/occupancy — the hotel's month board.
class HotelBoardApi {
  final ApiClient _client;
  const HotelBoardApi(this._client);

  Future<OccupancyBoardData> month(DateTime month) async {
    final m = '${month.year}-${month.month.toString().padLeft(2, '0')}';
    final data = await _client.get('/business/occupancy', query: {'month': m}) as Map<String, dynamic>;

    return OccupancyBoardData.fromJson(data);
  }
}

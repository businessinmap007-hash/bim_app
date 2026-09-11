import '../../../core/network/api_client.dart';
import 'models/business_group.dart';

/// /business-groups — a business's own named groups of OTHER businesses,
/// targets for wholesale/retail offers. See Api\V2\BusinessGroupController.
class BusinessGroupsApi {
  final ApiClient _client;
  const BusinessGroupsApi(this._client);

  Future<List<BusinessGroup>> list() async {
    final data = await _client.get('/business-groups') as Map<String, dynamic>;
    return (data['groups'] as List<dynamic>? ?? [])
        .map((e) => BusinessGroup.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<BusinessGroup> create(String name) async {
    final data = await _client.post('/business-groups', data: {'name': name}) as Map<String, dynamic>;
    return BusinessGroup.fromJson(data['group'] as Map<String, dynamic>);
  }

  Future<BusinessGroup> rename(int groupId, String name) async {
    final data = await _client.patch('/business-groups/$groupId', data: {'name': name}) as Map<String, dynamic>;
    return BusinessGroup.fromJson(data['group'] as Map<String, dynamic>);
  }

  Future<void> delete(int groupId) => _client.delete('/business-groups/$groupId');

  Future<BusinessGroup> addMember(int groupId, int businessId) async {
    final data =
        await _client.post('/business-groups/$groupId/members', data: {'business_id': businessId})
            as Map<String, dynamic>;
    return BusinessGroup.fromJson(data['group'] as Map<String, dynamic>);
  }

  Future<BusinessGroup> removeMember(int groupId, int memberId) async {
    final data = await _client.delete('/business-groups/$groupId/members/$memberId') as Map<String, dynamic>;
    return BusinessGroup.fromJson(data['group'] as Map<String, dynamic>);
  }
}

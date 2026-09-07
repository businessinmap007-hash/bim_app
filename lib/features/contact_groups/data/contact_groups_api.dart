import '../../../core/network/api_client.dart';
import 'models/contact_group.dart';

/// /contact-groups — a user's own named circles of already-registered
/// friends. See Api\V2\ContactGroupController.
class ContactGroupsApi {
  final ApiClient _client;
  const ContactGroupsApi(this._client);

  Future<List<ContactGroup>> list() async {
    final data = await _client.get('/contact-groups') as Map<String, dynamic>;
    return (data['groups'] as List<dynamic>? ?? [])
        .map((e) => ContactGroup.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<ContactGroup> create(String name) async {
    final data = await _client.post('/contact-groups', data: {'name': name}) as Map<String, dynamic>;
    return ContactGroup.fromJson(data['group'] as Map<String, dynamic>);
  }

  Future<ContactGroup> rename(int groupId, String name) async {
    final data = await _client.patch('/contact-groups/$groupId', data: {'name': name}) as Map<String, dynamic>;
    return ContactGroup.fromJson(data['group'] as Map<String, dynamic>);
  }

  Future<void> delete(int groupId) => _client.delete('/contact-groups/$groupId');

  /// Adds an already-registered user (found by phone or email) to the group.
  Future<ContactGroup> addMember(int groupId, String identifier) async {
    final data =
        await _client.post('/contact-groups/$groupId/members', data: {'identifier': identifier})
            as Map<String, dynamic>;
    return ContactGroup.fromJson(data['group'] as Map<String, dynamic>);
  }

  Future<ContactGroup> removeMember(int groupId, int memberId) async {
    final data = await _client.delete('/contact-groups/$groupId/members/$memberId') as Map<String, dynamic>;
    return ContactGroup.fromJson(data['group'] as Map<String, dynamic>);
  }
}

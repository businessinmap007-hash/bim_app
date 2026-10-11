import '../../../../core/env/env.dart';

/// A chair of a salon with the person at it — what a customer picks («احجز مع أحمد») and what the business manages.
class ServiceChair {
  final int id;
  final String? name;
  final String? personName;
  final String? photoUrl;
  final bool isActive;

  /// The account of the business's own staff sitting at this chair (its name and photo are the person's).
  final int? staffUserId;

  const ServiceChair({
    required this.id,
    this.name,
    this.personName,
    this.photoUrl,
    this.isActive = true,
    this.staffUserId,
  });

  /// The person if the business wrote one, else the chair's own name.
  String get title {
    final p = personName?.trim() ?? '';
    if (p.isNotEmpty) return p;

    return (name?.trim().isNotEmpty ?? false) ? name!.trim() : '#$id';
  }

  /// The chair's own label under the person («كرسي ٢»), when both were written.
  String? get subtitle {
    final p = personName?.trim() ?? '';
    final n = name?.trim() ?? '';

    return p.isNotEmpty && n.isNotEmpty ? n : null;
  }

  factory ServiceChair.fromJson(Map<String, dynamic> json) => ServiceChair(
    id: (json['id'] as num).toInt(),
    name: json['name'] as String?,
    personName: json['person_name'] as String?,
    photoUrl: Env.assetUrl(json['photo'] as String?),
    isActive: json['is_active'] as bool? ?? true,
    staffUserId: (json['staff_user_id'] as num?)?.toInt(),
  );
}

/// A staff member of the business who may sit at a chair — their own name and photo.
class ChairStaffMember {
  final int userId;
  final String name;
  final String? photoUrl;
  final String? title;

  const ChairStaffMember({required this.userId, required this.name, this.photoUrl, this.title});

  factory ChairStaffMember.fromJson(Map<String, dynamic> json) => ChairStaffMember(
    userId: (json['user_id'] as num).toInt(),
    name: json['name'] as String? ?? '',
    photoUrl: Env.assetUrl(json['photo'] as String?),
    title: json['title'] as String?,
  );
}

/// One live turn of the day in the business's own queue screen.
class QueueItem {
  final int id;
  final int? turn;
  final String status; // pending | accepted | in_progress
  final DateTime? calledAt;
  final DateTime? startsAt;
  final DateTime? endsAt;
  final int? chairId;
  final String customerName;
  final String? customerPhone;
  final String title;
  final bool walkIn;

  const QueueItem({
    required this.id,
    this.turn,
    required this.status,
    this.calledAt,
    this.startsAt,
    this.endsAt,
    this.chairId,
    this.customerName = '',
    this.customerPhone,
    this.title = '',
    this.walkIn = false,
  });

  bool get isServing => status == 'in_progress';
  bool get isCalled => calledAt != null && !isServing;

  factory QueueItem.fromJson(Map<String, dynamic> json) {
    final customer = json['customer'] as Map<String, dynamic>?;

    return QueueItem(
      id: (json['id'] as num).toInt(),
      turn: (json['turn'] as num?)?.toInt(),
      status: json['status'] as String? ?? 'accepted',
      calledAt: DateTime.tryParse(json['called_at'] as String? ?? '')?.toLocal(),
      startsAt: DateTime.tryParse((json['starts_at'] as String? ?? '').replaceFirst(' ', 'T')),
      endsAt: DateTime.tryParse((json['ends_at'] as String? ?? '').replaceFirst(' ', 'T')),
      chairId: (json['chair_id'] as num?)?.toInt(),
      customerName: customer?['name'] as String? ?? '',
      customerPhone: customer?['phone'] as String?,
      title: json['title'] as String? ?? '',
      walkIn: json['walk_in'] as bool? ?? false,
    );
  }
}

class BusinessQueue {
  final DateTime date;
  final List<ServiceChair> chairs;
  final List<QueueItem> items;

  /// Customers already served today (on these chairs).
  final int served;

  const BusinessQueue({required this.date, this.chairs = const [], this.items = const [], this.served = 0});

  factory BusinessQueue.fromJson(Map<String, dynamic> json) => BusinessQueue(
    date: DateTime.tryParse(json['date'] as String? ?? '') ?? DateTime.now(),
    chairs: (json['chairs'] as List<dynamic>? ?? [])
        .map((e) => ServiceChair.fromJson(e as Map<String, dynamic>))
        .toList(),
    items: (json['items'] as List<dynamic>? ?? []).map((e) => QueueItem.fromJson(e as Map<String, dynamic>)).toList(),
    served: (json['served'] as num?)?.toInt() ?? 0,
  );
}

/// Who the dispute is against/from, on whichever side the viewer isn't.
class DisputeCounterparty {
  final int id;
  final String? name;
  const DisputeCounterparty({required this.id, this.name});

  factory DisputeCounterparty.fromJson(Map<String, dynamic> json) =>
      DisputeCounterparty(id: json['id'] as int, name: json['name'] as String?);
}

class DisputeOperation {
  final String? kind;
  final int? id;
  const DisputeOperation({this.kind, this.id});

  factory DisputeOperation.fromJson(Map<String, dynamic> json) => DisputeOperation(
    kind: json['kind'] as String?,
    id: (json['id'] as num?)?.toInt(),
  );
}

class DisputeCooperation {
  final DateTime? clientAt;
  final DateTime? businessAt;
  const DisputeCooperation({this.clientAt, this.businessAt});

  factory DisputeCooperation.fromJson(Map<String, dynamic> json) => DisputeCooperation(
    clientAt: json['client_at'] != null ? DateTime.tryParse(json['client_at'] as String) : null,
    businessAt: json['business_at'] != null ? DateTime.tryParse(json['business_at'] as String) : null,
  );
}

class DisputeSettlementState {
  final DateTime? clientAgreedAt;
  final DateTime? businessAgreedAt;
  final bool complete;
  const DisputeSettlementState({this.clientAgreedAt, this.businessAgreedAt, this.complete = false});

  factory DisputeSettlementState.fromJson(Map<String, dynamic> json) => DisputeSettlementState(
    clientAgreedAt: json['client_agreed_at'] != null
        ? DateTime.tryParse(json['client_agreed_at'] as String)
        : null,
    businessAgreedAt: json['business_agreed_at'] != null
        ? DateTime.tryParse(json['business_agreed_at'] as String)
        : null,
    complete: json['complete'] as bool? ?? false,
  );
}

class DisputePurgeState {
  final DateTime? clientConfirmedAt;
  final DateTime? businessConfirmedAt;
  final DateTime? purgedAt;
  const DisputePurgeState({this.clientConfirmedAt, this.businessConfirmedAt, this.purgedAt});

  factory DisputePurgeState.fromJson(Map<String, dynamic> json) => DisputePurgeState(
    clientConfirmedAt: json['client_confirmed_at'] != null
        ? DateTime.tryParse(json['client_confirmed_at'] as String)
        : null,
    businessConfirmedAt: json['business_confirmed_at'] != null
        ? DateTime.tryParse(json['business_confirmed_at'] as String)
        : null,
    purgedAt: json['purged_at'] != null ? DateTime.tryParse(json['purged_at'] as String) : null,
  );
}

class DisputeResolution {
  final double clientPercent;
  final double businessPercent;
  const DisputeResolution({required this.clientPercent, required this.businessPercent});

  factory DisputeResolution.fromJson(Map<String, dynamic> json) => DisputeResolution(
    clientPercent: (json['client_percent'] as num?)?.toDouble() ?? 0,
    businessPercent: (json['business_percent'] as num?)?.toDouble() ?? 0,
  );
}

/// Mirrors `DisputeResource`. `myRole` says whether the caller opened it or
/// it was opened against them; `mySide` (client/business) comes separately
/// from `show()`'s top-level field, not this resource.
class Dispute {
  final int id;
  final String status;
  final String? type;
  final String myRole;
  final String? reasonCode;
  final String? reasonText;
  final DisputeCounterparty? counterparty;
  final DisputeOperation operation;
  final DisputeCooperation cooperation;
  final DisputeSettlementState settlement;
  final DateTime? openedAt;
  final DateTime? mutualResolutionDeadlineAt;
  final int warningCount;
  final String? resolutionType;
  final DisputeResolution? resolution;
  final DateTime? resolvedAt;
  final DateTime? closedAt;
  final String? closedReason;
  final DisputePurgeState purge;
  final DateTime? createdAt;

  const Dispute({
    required this.id,
    required this.status,
    this.type,
    required this.myRole,
    this.reasonCode,
    this.reasonText,
    this.counterparty,
    required this.operation,
    required this.cooperation,
    required this.settlement,
    this.openedAt,
    this.mutualResolutionDeadlineAt,
    this.warningCount = 0,
    this.resolutionType,
    this.resolution,
    this.resolvedAt,
    this.closedAt,
    this.closedReason,
    required this.purge,
    this.createdAt,
  });

  bool get isOpener => myRole == 'opener';
  bool get isSettled => status == 'resolved' || status == 'closed';
  bool get canAct => status == 'mutual_resolution' || status == 'under_review';

  factory Dispute.fromJson(Map<String, dynamic> json) => Dispute(
    id: json['id'] as int,
    status: json['status'] as String? ?? 'mutual_resolution',
    type: json['type'] as String?,
    myRole: json['my_role'] as String? ?? 'opener',
    reasonCode: json['reason_code'] as String?,
    reasonText: json['reason_text'] as String?,
    counterparty: json['counterparty'] != null
        ? DisputeCounterparty.fromJson(json['counterparty'] as Map<String, dynamic>)
        : null,
    operation: DisputeOperation.fromJson(json['operation'] as Map<String, dynamic>? ?? const {}),
    cooperation: DisputeCooperation.fromJson(json['cooperation'] as Map<String, dynamic>? ?? const {}),
    settlement: DisputeSettlementState.fromJson(json['settlement'] as Map<String, dynamic>? ?? const {}),
    openedAt: json['opened_at'] != null ? DateTime.tryParse(json['opened_at'] as String) : null,
    mutualResolutionDeadlineAt: json['mutual_resolution_deadline_at'] != null
        ? DateTime.tryParse(json['mutual_resolution_deadline_at'] as String)
        : null,
    warningCount: (json['warning_count'] as num?)?.toInt() ?? 0,
    resolutionType: json['resolution_type'] as String?,
    resolution: json['resolution'] != null
        ? DisputeResolution.fromJson(json['resolution'] as Map<String, dynamic>)
        : null,
    resolvedAt: json['resolved_at'] != null ? DateTime.tryParse(json['resolved_at'] as String) : null,
    closedAt: json['closed_at'] != null ? DateTime.tryParse(json['closed_at'] as String) : null,
    closedReason: json['closed_reason'] as String?,
    purge: DisputePurgeState.fromJson(json['purge'] as Map<String, dynamic>? ?? const {}),
    createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at'] as String) : null,
  );
}

class DisputeObligation {
  final int id;
  final int disputeId;
  final String type;
  final double amount;
  final String status;
  final DateTime? dueAt;
  final bool isDue;

  const DisputeObligation({
    required this.id,
    required this.disputeId,
    required this.type,
    required this.amount,
    required this.status,
    this.dueAt,
    this.isDue = false,
  });

  factory DisputeObligation.fromJson(Map<String, dynamic> json) => DisputeObligation(
    id: json['id'] as int,
    disputeId: (json['dispute_id'] as num?)?.toInt() ?? 0,
    type: json['type'] as String? ?? '',
    amount: (json['amount'] as num?)?.toDouble() ?? 0,
    status: json['status'] as String? ?? 'pending',
    dueAt: json['due_at'] != null ? DateTime.tryParse(json['due_at'] as String) : null,
    isDue: json['is_due'] as bool? ?? false,
  );
}

class ArbitrationReadiness {
  final double fee;
  final double balance;
  final bool sufficient;
  const ArbitrationReadiness({required this.fee, required this.balance, required this.sufficient});

  factory ArbitrationReadiness.fromJson(Map<String, dynamic> json) => ArbitrationReadiness(
    fee: (json['fee'] as num?)?.toDouble() ?? 0,
    balance: (json['balance'] as num?)?.toDouble() ?? 0,
    sufficient: json['sufficient'] as bool? ?? false,
  );
}

/// The full `show()` payload: the dispute plus the three fields only that
/// endpoint pays the query for.
class DisputeDetail {
  final Dispute dispute;
  final String? mySide;
  final ArbitrationReadiness arbitration;
  final List<DisputeObligation> myObligations;

  const DisputeDetail({
    required this.dispute,
    this.mySide,
    required this.arbitration,
    this.myObligations = const [],
  });

  factory DisputeDetail.fromJson(Map<String, dynamic> json) => DisputeDetail(
    dispute: Dispute.fromJson(json['data'] as Map<String, dynamic>),
    mySide: json['my_side'] as String?,
    arbitration: ArbitrationReadiness.fromJson(json['arbitration'] as Map<String, dynamic>? ?? const {}),
    myObligations: (json['my_obligations'] as List<dynamic>? ?? [])
        .map((e) => DisputeObligation.fromJson(e as Map<String, dynamic>))
        .toList(),
  );
}

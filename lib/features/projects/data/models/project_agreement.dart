/// One quantity of a work («عدد الأعمدة — 24 عمود»): the agreed amount and what has been executed.
class QuantityItem {
  final int id;
  final String name;
  final String? unit;
  final double planned;
  final double done;

  const QuantityItem({required this.id, required this.name, this.unit, required this.planned, required this.done});

  factory QuantityItem.fromJson(Map<String, dynamic> json) => QuantityItem(
    id: (json['id'] as num).toInt(),
    name: json['name'] as String? ?? '',
    unit: json['unit'] as String?,
    planned: (json['planned'] as num?)?.toDouble() ?? 0,
    done: (json['done'] as num?)?.toDouble() ?? 0,
  );

  double get ratio => planned > 0 ? (done / planned).clamp(0, 1).toDouble() : 0;

  /// «18 / 24 عمود»
  String line() => '${_n(done)} / ${_n(planned)}${unit == null || unit!.isEmpty ? '' : ' $unit'}';

  static String _n(double v) => v == v.roundToDouble() ? v.round().toString() : v.toStringAsFixed(2);
}

/// A version of the agreed plan — the delivery date, the end of the grace, and who agreed when.
class AgreementInfo {
  final int version;
  final String status; // proposed | agreed | superseded | rejected
  final String? startsOn;
  final String dueOn;
  final String graceUntil;
  final DateTime? businessAgreedAt;
  final DateTime? customerAgreedAt;
  final String? customerNote;
  final String contentHash;

  const AgreementInfo({
    required this.version,
    required this.status,
    this.startsOn,
    required this.dueOn,
    required this.graceUntil,
    this.businessAgreedAt,
    this.customerAgreedAt,
    this.customerNote,
    this.contentHash = '',
  });

  bool get isAgreed => status == 'agreed';
  bool get isProposed => status == 'proposed';

  factory AgreementInfo.fromJson(Map<String, dynamic> json) => AgreementInfo(
    version: (json['version'] as num).toInt(),
    status: json['status'] as String? ?? 'proposed',
    startsOn: json['starts_on'] as String?,
    dueOn: json['due_on'] as String? ?? '',
    graceUntil: json['grace_until'] as String? ?? '',
    businessAgreedAt: DateTime.tryParse(json['business_agreed_at'] as String? ?? '')?.toLocal(),
    customerAgreedAt: DateTime.tryParse(json['customer_agreed_at'] as String? ?? '')?.toLocal(),
    customerNote: json['customer_note'] as String?,
    contentHash: json['content_hash'] as String? ?? '',
  );
}

/// More time or a change of scope, waiting for (or answered by) the customer.
class ChangeRequestInfo {
  final int id;
  final String type; // extension | scope | shift
  final bool requestedByBusiness;
  final Map<String, dynamic> payload;
  final String? note;
  final String status; // pending | approved | rejected
  final String? decisionNote;

  const ChangeRequestInfo({required this.id, required this.type, this.requestedByBusiness = true, required this.payload, this.note, required this.status, this.decisionNote});

  bool get isPending => status == 'pending';
  bool get isExtension => type == 'extension';
  bool get isShift => type == 'shift';

  factory ChangeRequestInfo.fromJson(Map<String, dynamic> json) => ChangeRequestInfo(
    id: (json['id'] as num).toInt(),
    type: json['type'] as String? ?? 'scope',
    requestedByBusiness: json['requested_by_business'] as bool? ?? true,
    payload: (json['payload'] as Map<String, dynamic>?) ?? const {},
    note: json['note'] as String?,
    status: json['status'] as String? ?? 'pending',
    decisionNote: json['decision_note'] as String?,
  );
}

/// One line of the history of quantities.
class QuantityLogEntry {
  final String? task;
  final String field;
  final String? oldValue;
  final String? newValue;
  final String? reason;
  final String? by;
  final DateTime? at;
  final bool viaRequest;

  const QuantityLogEntry({this.task, required this.field, this.oldValue, this.newValue, this.reason, this.by, this.at, this.viaRequest = false});

  factory QuantityLogEntry.fromJson(Map<String, dynamic> json) => QuantityLogEntry(
    task: json['task'] as String?,
    field: json['field'] as String? ?? '',
    oldValue: json['old']?.toString(),
    newValue: json['new']?.toString(),
    reason: json['reason'] as String?,
    by: json['by'] as String?,
    at: DateTime.tryParse(json['at'] as String? ?? '')?.toLocal(),
    viaRequest: json['via_request'] != null,
  );
}

/// The guarantee level the business asks of the customer before work begins, and whether he already holds it.
class GuaranteeRequirement {
  final String code;
  final String name;
  final bool? customerOk;

  const GuaranteeRequirement({required this.code, required this.name, this.customerOk});

  factory GuaranteeRequirement.fromJson(Map<String, dynamic> json) => GuaranteeRequirement(
    code: json['code'] as String? ?? '',
    name: json['name'] as String? ?? '',
    customerOk: json['customer_ok'] as bool?,
  );
}

/// What both sides read about the agreement of a project: the version in force (or waiting), the requests, the history.
class AgreementBlock {
  final AgreementInfo? agreement;
  final bool agreed;
  final int versions;
  final List<ChangeRequestInfo> requests;
  final List<QuantityLogEntry> log;
  final GuaranteeRequirement? requirement;

  const AgreementBlock({this.agreement, this.agreed = false, this.versions = 0, this.requests = const [], this.log = const [], this.requirement});

  List<ChangeRequestInfo> get pendingRequests => requests.where((r) => r.isPending).toList();

  factory AgreementBlock.fromJson(Map<String, dynamic> json) => AgreementBlock(
    agreement: json['agreement'] is Map<String, dynamic> ? AgreementInfo.fromJson(json['agreement'] as Map<String, dynamic>) : null,
    agreed: json['agreed'] as bool? ?? false,
    versions: (json['versions'] as List<dynamic>? ?? const []).length,
    requests: [
      for (final r in (json['change_requests'] as List<dynamic>? ?? const [])) ChangeRequestInfo.fromJson(r as Map<String, dynamic>),
    ],
    requirement: json['guarantee_requirement'] is Map<String, dynamic> ? GuaranteeRequirement.fromJson(json['guarantee_requirement'] as Map<String, dynamic>) : null,
    log: [
      for (final l in (json['quantity_log'] as List<dynamic>? ?? const [])) QuantityLogEntry.fromJson(l as Map<String, dynamic>),
    ],
  );
}

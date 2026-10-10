import '../../../../core/env/env.dart';

/// One test or exam of an order; [price] is the centre's price once the order has been sent to it.
class InvestigationItem {
  final int id;
  final String kind; // 'lab' | 'radiology'
  final String name;
  final double? price;

  /// The result as TEXT, written by the centre beside this test (null until it is in).
  final String? result;

  const InvestigationItem({required this.id, required this.kind, required this.name, this.price, this.result});

  bool get isLab => kind == 'lab';
  bool get hasResult => (result ?? '').trim().isNotEmpty;

  factory InvestigationItem.fromJson(Map<String, dynamic> json) => InvestigationItem(
    id: (json['id'] as num?)?.toInt() ?? 0,
    kind: json['kind'] as String? ?? 'lab',
    name: json['name'] as String? ?? '',
    price: (json['price'] as num?)?.toDouble(),
    result: json['result'] as String?,
  );
}

class InvestigationParty {
  final int id;
  final String name;

  const InvestigationParty({required this.id, required this.name});

  static InvestigationParty? from(dynamic json) => json is Map<String, dynamic>
      ? InvestigationParty(id: (json['id'] as num).toInt(), name: json['name'] as String? ?? '')
      : null;
}

/// A doctor's list of lab tests and radiology exams for a patient — or a patient's own request to a centre.
/// `issued` → `sent` → `accepted` → `ready`; or `declined` / `cancelled`.
class InvestigationOrder {
  static const issued = 'issued';
  static const sent = 'sent';
  static const accepted = 'accepted';
  static const ready = 'ready';
  static const declined = 'declined';
  static const cancelled = 'cancelled';

  final int id;
  final String status;
  final InvestigationParty? doctor;
  final InvestigationParty? patient;
  final InvestigationParty? center;
  final List<InvestigationItem> items;
  final double? total;
  final String? notes;
  final String? centerNote;
  final DateTime? appointmentAt;
  final DateTime? issuedAt;
  final List<String> requestFiles;
  final List<String> resultFiles;

  const InvestigationOrder({
    required this.id,
    required this.status,
    this.doctor,
    this.patient,
    this.center,
    this.items = const [],
    this.total,
    this.notes,
    this.centerNote,
    this.appointmentAt,
    this.issuedAt,
    this.requestFiles = const [],
    this.resultFiles = const [],
  });

  bool get canSend => status == issued;
  bool get canCancel => status == issued || status == sent;
  bool get hasResults => resultFiles.isNotEmpty || items.any((i) => i.hasResult);
  bool get hasTextResults => items.any((i) => i.hasResult);

  /// the step of the 4-step line the order stands on (1 = issued … 4 = ready), 0 when it ended
  int get step {
    switch (status) {
      case issued:
        return 1;
      case sent:
        return 2;
      case accepted:
        return 3;
      case ready:
        return 4;
      default:
        return 0;
    }
  }

  factory InvestigationOrder.fromJson(Map<String, dynamic> json) {
    List<String> files(String key) => (json[key] as List<dynamic>? ?? [])
        .map((e) => Env.assetUrl((e as Map<String, dynamic>)['image'] as String?))
        .whereType<String>()
        .toList();

    return InvestigationOrder(
      id: (json['id'] as num).toInt(),
      status: json['status'] as String? ?? issued,
      doctor: InvestigationParty.from(json['doctor']),
      patient: InvestigationParty.from(json['patient']),
      center: InvestigationParty.from(json['center']),
      items: (json['items'] as List<dynamic>? ?? [])
          .map((e) => InvestigationItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      total: (json['total'] as num?)?.toDouble(),
      notes: json['notes'] as String?,
      centerNote: json['center_note'] as String?,
      appointmentAt: DateTime.tryParse(json['appointment_at'] as String? ?? '')?.toLocal(),
      issuedAt: DateTime.tryParse(json['issued_at'] as String? ?? '')?.toLocal(),
      requestFiles: files('request_files'),
      resultFiles: files('result_files'),
    );
  }
}

/// A test or an exam of the platform's lists — what a doctor picks from.
class CatalogTest {
  final int id;
  final String name;
  final String kind;

  const CatalogTest({required this.id, required this.name, required this.kind});
}

class InvestigationCatalog {
  final List<CatalogTest> lab;
  final List<CatalogTest> radiology;

  const InvestigationCatalog({this.lab = const [], this.radiology = const []});

  factory InvestigationCatalog.fromJson(Map<String, dynamic> json) {
    List<CatalogTest> list(String key, String kind) => (json[key] as List<dynamic>? ?? [])
        .map((e) => CatalogTest(id: ((e as Map<String, dynamic>)['id'] as num).toInt(), name: e['name'] as String? ?? '', kind: kind))
        .toList();

    return InvestigationCatalog(lab: list('lab', 'lab'), radiology: list('radiology', 'radiology'));
  }
}

/// A registered centre and what it would charge for the whole order.
class InvestigationCenter {
  final int id;
  final String name;
  final int covers;
  final int of;
  final double total;
  final List<String> missing;

  const InvestigationCenter({
    required this.id,
    required this.name,
    required this.covers,
    required this.of,
    required this.total,
    this.missing = const [],
  });

  bool get coversAll => covers >= of;

  factory InvestigationCenter.fromJson(Map<String, dynamic> json) => InvestigationCenter(
    id: (json['id'] as num).toInt(),
    name: json['name'] as String? ?? '',
    covers: (json['covers'] as num?)?.toInt() ?? 0,
    of: (json['of'] as num?)?.toInt() ?? 0,
    total: (json['total'] as num?)?.toDouble() ?? 0,
    missing: (json['missing'] as List<dynamic>? ?? []).map((e) => e.toString()).toList(),
  );
}

/// A test a centre does, with its price — on the centre's page, and in its own price list (price null = it does not do it).
class CenterTest {
  final int optionId;
  final String kind;
  final String name;
  final double? price;

  const CenterTest({required this.optionId, required this.kind, required this.name, this.price});

  factory CenterTest.fromJson(Map<String, dynamic> json) => CenterTest(
    optionId: (json['option_id'] as num).toInt(),
    kind: json['kind'] as String? ?? 'lab',
    name: json['name'] as String? ?? '',
    price: (json['price'] as num?)?.toDouble(),
  );
}

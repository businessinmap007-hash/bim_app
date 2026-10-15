import '../../../../core/deposit/visit_deposit.dart';
import '../../../../core/env/env.dart';
import '../../../../core/time/egypt_time.dart';

/// One test or exam of an order; [price] is the centre's price once the order has been sent to it.
class InvestigationItem {
  final int id;
  final String kind; // 'lab' | 'radiology'
  final String name;
  final double? price;

  /// The result as TEXT, written by the centre beside this test (null until it is in).
  final String? result;

  /// A package names what it includes (a test has none).
  final String? details;

  const InvestigationItem({required this.id, required this.kind, required this.name, this.price, this.result, this.details});

  bool get isLab => kind == 'lab';
  bool get isPackage => kind == 'package';
  bool get hasResult => (result ?? '').trim().isNotEmpty;

  factory InvestigationItem.fromJson(Map<String, dynamic> json) => InvestigationItem(
    id: (json['id'] as num?)?.toInt() ?? 0,
    kind: json['kind'] as String? ?? 'lab',
    name: json['name'] as String? ?? '',
    price: (json['price'] as num?)?.toDouble(),
    result: json['result'] as String?,
    details: (json['details'] as String?)?.trim().isEmpty ?? true ? null : (json['details'] as String).trim(),
  );
}

class InvestigationParty {
  final int id;
  final String name;
  final String? title;

  const InvestigationParty({required this.id, required this.name, this.title});

  /// «د. فلان — استشاري باطنة»
  String get line => (title ?? '').isEmpty ? name : '$name — $title';

  static InvestigationParty? from(dynamic json) => json is Map<String, dynamic>
      ? InvestigationParty(id: (json['id'] as num).toInt(), name: json['name'] as String? ?? '', title: json['title'] as String?)
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

  /// the physician working for the hospital who ordered it (never sent to the centre)
  final InvestigationParty? physician;
  final InvestigationParty? patient;
  final InvestigationParty? center;
  final List<InvestigationItem> items;
  final double? total;
  final String? notes;
  final String? centerNote;
  final DateTime? appointmentAt;
  final DateTime? issuedAt;

  /// The day and time the patient asked for, and whether the lab takes the sample at his home (its fee is in the total).
  final DateTime? requestedAt;
  final bool homeCollection;
  final double? homeFee;
  final List<String> requestFiles;
  final List<String> resultFiles;

  /// Printed reports (PDF) the centre attached — opened outside the app, kept like the photos.
  final List<String> resultDocuments;

  /// Scans (DICOM) the centre attached — the app does not draw them: they are handed to a viewer on the phone.
  final List<String> resultDicoms;

  /// The server deleted the result photos (they were kept on the patient's phone, or expired).
  final bool filesPurged;
  final bool patientSaved;

  /// When the photos will go if nobody keeps them (null once kept or deleted).
  final DateTime? filesExpireAt;

  /// «عربون الجدية» the centre's terms ask of this order and where it stands (null: asks none).
  final VisitDeposit? deposit;

  const InvestigationOrder({
    required this.id,
    required this.status,
    this.doctor,
    this.physician,
    this.patient,
    this.center,
    this.items = const [],
    this.total,
    this.notes,
    this.centerNote,
    this.appointmentAt,
    this.issuedAt,
    this.requestedAt,
    this.homeCollection = false,
    this.homeFee,
    this.requestFiles = const [],
    this.resultFiles = const [],
    this.resultDocuments = const [],
    this.resultDicoms = const [],
    this.filesPurged = false,
    this.patientSaved = false,
    this.filesExpireAt,
    this.deposit,
  });

  bool get canSend => status == issued;
  bool get canCancel => status == issued || status == sent;
  bool get hasResults =>
      resultFiles.isNotEmpty || resultDocuments.isNotEmpty || resultDicoms.isNotEmpty || items.any((i) => i.hasResult);
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
    // `type` is `pdf` for a printed report, `dicom` for a scan and `image` (or absent, on older servers) for a photo
    List<String> files(String key, {String kind = 'image'}) => (json[key] as List<dynamic>? ?? [])
        .where((e) => (((e as Map<String, dynamic>)['type'] as String?) ?? 'image') == kind)
        .map((e) => Env.assetUrl((e as Map<String, dynamic>)['image'] as String?))
        .whereType<String>()
        .toList();

    return InvestigationOrder(
      id: (json['id'] as num).toInt(),
      status: json['status'] as String? ?? issued,
      doctor: InvestigationParty.from(json['doctor']),
      physician: InvestigationParty.from(json['physician']),
      patient: InvestigationParty.from(json['patient']),
      center: InvestigationParty.from(json['center']),
      items: (json['items'] as List<dynamic>? ?? [])
          .map((e) => InvestigationItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      total: (json['total'] as num?)?.toDouble(),
      notes: json['notes'] as String?,
      centerNote: json['center_note'] as String?,
      appointmentAt: EgyptTime.tryParse(json['appointment_at'] as String? ?? '')?.toLocal(),
      issuedAt: EgyptTime.tryParse(json['issued_at'] as String? ?? '')?.toLocal(),
      requestedAt: EgyptTime.tryParse(json['requested_at'] as String? ?? '')?.toLocal(),
      homeCollection: json['home_collection'] as bool? ?? false,
      homeFee: (json['home_fee'] as num?)?.toDouble(),
      requestFiles: files('request_files'),
      resultFiles: files('result_files'),
      resultDocuments: files('result_files', kind: 'pdf'),
      resultDicoms: files('result_files', kind: 'dicom'),
      filesPurged: json['files_purged'] as bool? ?? false,
      patientSaved: json['patient_saved'] as bool? ?? false,
      filesExpireAt: EgyptTime.tryParse(json['files_expire_at'] as String? ?? '')?.toLocal(),
      deposit: VisitDeposit.fromJsonOrNull(json['deposit']),
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

/// «باقة»: a named set of a centre's tests at ONE price.
class CenterPackage {
  final int id;
  final String name;
  final String? note;
  final double price;
  final bool isActive;
  final List<int> optionIds;
  final List<String> tests;

  const CenterPackage({
    required this.id,
    required this.name,
    this.note,
    required this.price,
    this.isActive = true,
    this.optionIds = const [],
    this.tests = const [],
  });

  factory CenterPackage.fromJson(Map<String, dynamic> json) => CenterPackage(
    id: (json['id'] as num).toInt(),
    name: json['name'] as String? ?? '',
    note: (json['note'] as String?)?.trim().isEmpty ?? true ? null : (json['note'] as String).trim(),
    price: (json['price'] as num?)?.toDouble() ?? 0,
    isActive: json['is_active'] as bool? ?? true,
    optionIds: (json['option_ids'] as List<dynamic>? ?? []).map((e) => (e as num).toInt()).toList(),
    tests: (json['tests'] as List<dynamic>? ?? []).map((e) => e.toString()).toList(),
  );
}

/// What a centre's page offers: its tests, its packages, and (a lab) the fee of taking the sample at home.
class CenterOffer {
  final List<CenterTest> tests;
  final List<CenterPackage> packages;
  final double? homeFee;

  const CenterOffer({this.tests = const [], this.packages = const [], this.homeFee});

  factory CenterOffer.fromJson(Map<String, dynamic> json) => CenterOffer(
    tests: (json['tests'] as List<dynamic>? ?? []).map((e) => CenterTest.fromJson(e as Map<String, dynamic>)).toList(),
    packages: (json['packages'] as List<dynamic>? ?? []).map((e) => CenterPackage.fromJson(e as Map<String, dynamic>)).toList(),
    homeFee: (json['home_fee'] as num?)?.toDouble(),
  );
}

/// The centre's own packages screen: all of them (hidden too), and whether this centre may take samples at home.
class CenterPackages {
  final List<CenterPackage> packages;
  final double? homeFee;
  final bool canHome;

  const CenterPackages({this.packages = const [], this.homeFee, this.canHome = false});

  factory CenterPackages.fromJson(Map<String, dynamic> json) => CenterPackages(
    packages: (json['packages'] as List<dynamic>? ?? []).map((e) => CenterPackage.fromJson(e as Map<String, dynamic>)).toList(),
    homeFee: (json['home_fee'] as num?)?.toDouble(),
    canHome: json['can_home'] as bool? ?? false,
  );
}

/// The times a patient may ask for on one day.
class CenterTimes {
  final bool closed;
  final List<String> times;

  const CenterTimes({this.closed = false, this.times = const []});

  factory CenterTimes.fromJson(Map<String, dynamic> json) => CenterTimes(
    closed: json['closed'] as bool? ?? false,
    times: (json['times'] as List<dynamic>? ?? []).map((e) => e.toString()).toList(),
  );
}

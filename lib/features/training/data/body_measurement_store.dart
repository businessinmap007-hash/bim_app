import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../domain/body_metrics.dart';

/// What the calculator remembers between visits: the person's own data (sex, birth year, height, tape measures, activity,
/// goal) so only the weight changes from one time to the next.
class BodyProfile {
  final BodySex sex;

  /// Kept as a year, not an age, so it keeps growing on its own.
  final int? birthYear;
  final double? heightCm;
  final double? waistCm;
  final double? neckCm;
  final double? hipCm;
  final ActivityLevel activity;
  final BodyGoal goal;

  const BodyProfile({
    this.sex = BodySex.male,
    this.birthYear,
    this.heightCm,
    this.waistCm,
    this.neckCm,
    this.hipCm,
    this.activity = ActivityLevel.light,
    this.goal = BodyGoal.maintain,
  });

  Map<String, dynamic> toJson() => {
    'sex': sex.name,
    'birth_year': birthYear,
    'height': heightCm,
    'waist': waistCm,
    'neck': neckCm,
    'hip': hipCm,
    'activity': activity.name,
    'goal': goal.name,
  };

  factory BodyProfile.fromJson(Map<String, dynamic> json) => BodyProfile(
    sex: BodySex.values.firstWhere(
      (s) => s.name == json['sex'],
      orElse: () => BodySex.male,
    ),
    birthYear: (json['birth_year'] as num?)?.toInt(),
    heightCm: (json['height'] as num?)?.toDouble(),
    waistCm: (json['waist'] as num?)?.toDouble(),
    neckCm: (json['neck'] as num?)?.toDouble(),
    hipCm: (json['hip'] as num?)?.toDouble(),
    activity: ActivityLevel.values.firstWhere(
      (a) => a.name == json['activity'],
      orElse: () => ActivityLevel.light,
    ),
    goal: BodyGoal.values.firstWhere(
      (g) => g.name == json['goal'],
      orElse: () => BodyGoal.maintain,
    ),
  );
}

/// One saved measurement (one per day: saving again the same day replaces it).
class BodyEntry {
  /// `yyyy-mm-dd`
  final String date;
  final double weightKg;
  final double bmi;
  final double? fatPercent;
  final double? waistCm;

  const BodyEntry({
    required this.date,
    required this.weightKg,
    required this.bmi,
    this.fatPercent,
    this.waistCm,
  });

  Map<String, dynamic> toJson() => {
    'date': date,
    'weight': weightKg,
    'bmi': bmi,
    'fat': fatPercent,
    'waist': waistCm,
  };

  factory BodyEntry.fromJson(Map<String, dynamic> json) => BodyEntry(
    date: json['date'] as String? ?? '',
    weightKg: (json['weight'] as num?)?.toDouble() ?? 0,
    bmi: (json['bmi'] as num?)?.toDouble() ?? 0,
    fatPercent: (json['fat'] as num?)?.toDouble(),
    waistCm: (json['waist'] as num?)?.toDouble(),
  );
}

/// The calculator's memory on THIS phone, one per account that signs in here. Nothing of it goes to the server.
class BodyMeasurementStore {
  String _profileKey(int userId) => 'bim_body_profile_v1_$userId';
  String _historyKey(int userId) => 'bim_body_history_v1_$userId';

  Future<BodyProfile> readProfile(int userId) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_profileKey(userId));
    if (raw == null || raw.isEmpty) return const BodyProfile();

    try {
      return BodyProfile.fromJson(
        Map<String, dynamic>.from(jsonDecode(raw) as Map),
      );
    } catch (_) {
      return const BodyProfile();
    }
  }

  Future<void> writeProfile(int userId, BodyProfile profile) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_profileKey(userId), jsonEncode(profile.toJson()));
  }

  /// Newest first.
  Future<List<BodyEntry>> readHistory(int userId) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_historyKey(userId));
    if (raw == null || raw.isEmpty) return const [];

    try {
      final list = [
        for (final e in jsonDecode(raw) as List)
          BodyEntry.fromJson(Map<String, dynamic>.from(e as Map)),
      ];
      list.sort((a, b) => b.date.compareTo(a.date));

      return list;
    } catch (_) {
      return const [];
    }
  }

  Future<void> _writeHistory(int userId, List<BodyEntry> entries) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _historyKey(userId),
      jsonEncode([for (final e in entries) e.toJson()]),
    );
  }

  /// Adds the entry, replacing one of the same day; keeps the latest 365.
  Future<List<BodyEntry>> save(int userId, BodyEntry entry) async {
    final all = [
      entry,
      ...(await readHistory(userId)).where((e) => e.date != entry.date),
    ]..sort((a, b) => b.date.compareTo(a.date));
    final kept = all.take(365).toList();
    await _writeHistory(userId, kept);

    return kept;
  }

  Future<List<BodyEntry>> remove(int userId, String date) async {
    final kept = (await readHistory(
      userId,
    )).where((e) => e.date != date).toList();
    await _writeHistory(userId, kept);

    return kept;
  }
}

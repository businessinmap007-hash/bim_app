/// «حاسبة الوزن المناسب»: from sex, age, height and weight — body-mass index, the healthy weight range for that
/// height, an ideal weight, and the calories that keep the weight steady. Pure maths on the phone, nothing stored.
enum BodySex { male, female }

enum ActivityLevel {
  sedentary(1.2),
  light(1.375),
  moderate(1.55),
  active(1.725),
  veryActive(1.9);

  final double factor;
  const ActivityLevel(this.factor);
}

/// WHO adult bands.
enum BmiBand { underweight, normal, overweight, obese }

class BodyMetrics {
  final BodySex sex;
  final int ageYears;
  final double heightCm;
  final double weightKg;
  final ActivityLevel activity;

  const BodyMetrics({
    required this.sex,
    required this.ageYears,
    required this.heightCm,
    required this.weightKg,
    this.activity = ActivityLevel.light,
  });

  /// Anything outside this is a typing slip, not a body.
  static bool plausible({
    required int ageYears,
    required double heightCm,
    required double weightKg,
  }) =>
      ageYears >= 5 &&
      ageYears <= 110 &&
      heightCm >= 100 &&
      heightCm <= 250 &&
      weightKg >= 20 &&
      weightKg <= 300;

  double get _m => heightCm / 100;

  /// kg / m².
  double get bmi => weightKg / (_m * _m);

  /// The adult tables do not describe a growing child or teenager.
  bool get adultTablesApply => ageYears >= 18;

  BmiBand get band {
    final v = bmi;
    if (v < 18.5) return BmiBand.underweight;
    if (v < 25) return BmiBand.normal;
    if (v < 30) return BmiBand.overweight;
    return BmiBand.obese;
  }

  /// The weights that put BMI between 18.5 and 24.9 at this height.
  double get healthyMinKg => 18.5 * _m * _m;
  double get healthyMaxKg => 24.9 * _m * _m;

  /// Devine: 50 kg (45.5 for a woman) plus 2.3 kg for every inch over 5 feet.
  double get idealKgDevine {
    final inchesOver = (heightCm / 2.54 - 60).clamp(0, double.infinity);
    return (sex == BodySex.male ? 50.0 : 45.5) + 2.3 * inchesOver;
  }

  /// Kilograms to lose (negative = to gain) to be inside the healthy range; 0 when already inside.
  double get kgToHealthyRange {
    if (weightKg > healthyMaxKg) return weightKg - healthyMaxKg;
    if (weightKg < healthyMinKg) return weightKg - healthyMinKg;
    return 0;
  }

  /// Mifflin–St Jeor: what the body burns at rest, per day.
  double get bmr {
    final base = 10 * weightKg + 6.25 * heightCm - 5 * ageYears;
    return base + (sex == BodySex.male ? 5 : -161);
  }

  /// Calories per day that keep today's weight steady at the chosen activity.
  double get maintenanceKcal => bmr * activity.factor;
}

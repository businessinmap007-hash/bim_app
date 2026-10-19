import 'dart:math' as math;

/// «حاسبة الوزن المناسب»: from sex, age, height and weight (and, if given, waist / neck / hip and a goal) — body-mass
/// index, the healthy weight range for that height, an ideal weight, body-fat estimate, and the daily calories, protein
/// and water that suit the goal. Pure maths on the phone, nothing is sent anywhere.
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

enum BodyGoal { lose, maintain, gain }

/// ACE bands for the body-fat percentage.
enum FatBand { essential, athletic, fitness, average, high }

class BodyMetrics {
  final BodySex sex;
  final int ageYears;
  final double heightCm;
  final double weightKg;
  final ActivityLevel activity;
  final BodyGoal goal;

  /// Tape measures, all optional: waist at the navel, neck below the larynx, hips at the widest.
  final double? waistCm;
  final double? neckCm;
  final double? hipCm;

  /// A body-fat percentage somebody already measured (a trainer's monthly report) — used when the tape measures are not given.
  final double? recordedFatPercent;

  const BodyMetrics({
    required this.sex,
    required this.ageYears,
    required this.heightCm,
    required this.weightKg,
    this.activity = ActivityLevel.light,
    this.goal = BodyGoal.maintain,
    this.waistCm,
    this.neckCm,
    this.hipCm,
    this.recordedFatPercent,
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

  /// Calories for the goal: about 500 below to lose slowly (never under the resting burn), 300 above to gain.
  double get targetKcal => switch (goal) {
    BodyGoal.lose => math.max(maintenanceKcal - 500, bmr),
    BodyGoal.maintain => maintenanceKcal,
    BodyGoal.gain => maintenanceKcal + 300,
  };

  /// Grams of protein a day, as a range that suits the goal.
  ({double min, double max}) get proteinGrams => switch (goal) {
    BodyGoal.lose => (min: weightKg * 1.8, max: weightKg * 2.2),
    BodyGoal.maintain => (min: weightKg * 1.2, max: weightKg * 1.6),
    BodyGoal.gain => (min: weightKg * 1.6, max: weightKg * 2.0),
  };

  /// Litres of water a day (about 35 ml per kg).
  double get waterLitres => weightKg * 0.035;

  /// US Navy estimate of body fat, from the tape measures — null when they are not given or do not make sense.
  double? get bodyFatNavy {
    final waist = waistCm;
    final neck = neckCm;
    if (waist == null || neck == null) return null;

    final double value;
    if (sex == BodySex.male) {
      if (waist <= neck) return null;
      value =
          495 /
              (1.0324 -
                  0.19077 * _log10(waist - neck) +
                  0.15456 * _log10(heightCm)) -
          450;
    } else {
      final hip = hipCm;
      if (hip == null || waist + hip <= neck) return null;
      value =
          495 /
              (1.29579 -
                  0.35004 * _log10(waist + hip - neck) +
                  0.22100 * _log10(heightCm)) -
          450;
    }

    return value.isFinite && value > 2 && value < 60 ? value : null;
  }

  /// The tape-measure estimate when there is one, else the percentage somebody recorded.
  double? get bodyFatPercent => bodyFatNavy ?? recordedFatPercent;

  bool get fatIsFromTape => bodyFatNavy != null;

  double? get leanMassKg =>
      bodyFatPercent == null ? null : weightKg * (1 - bodyFatPercent! / 100);

  FatBand? get fatBand {
    final f = bodyFatPercent;
    if (f == null) return null;

    final cuts = sex == BodySex.male
        ? const [6.0, 14.0, 18.0, 25.0]
        : const [14.0, 21.0, 25.0, 32.0];
    if (f < cuts[0]) return FatBand.essential;
    if (f < cuts[1]) return FatBand.athletic;
    if (f < cuts[2]) return FatBand.fitness;
    if (f < cuts[3]) return FatBand.average;
    return FatBand.high;
  }

  /// Waist ÷ height: under 0.5 is the usual advice.
  double? get waistToHeight => waistCm == null ? null : waistCm! / heightCm;

  /// Waist ÷ hip: WHO flags above 0.90 (men) and 0.85 (women).
  double? get waistToHip =>
      waistCm == null || hipCm == null ? null : waistCm! / hipCm!;

  bool? get waistToHipHigh {
    final r = waistToHip;
    if (r == null) return null;
    return r > (sex == BodySex.male ? 0.90 : 0.85);
  }

  static double _log10(double v) => math.log(v) / math.ln10;
}

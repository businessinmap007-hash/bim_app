import 'package:flutter_test/flutter_test.dart';

import 'package:bim_app/features/training/domain/body_metrics.dart';

void main() {
  const man = BodyMetrics(
    sex: BodySex.male,
    ageYears: 30,
    heightCm: 175,
    weightKg: 80,
    activity: ActivityLevel.moderate,
  );

  test('BMI, its band and the healthy range at this height', () {
    expect(man.bmi, closeTo(26.12, 0.01));
    expect(man.band, BmiBand.overweight);
    expect(man.healthyMinKg, closeTo(56.66, 0.01));
    expect(man.healthyMaxKg, closeTo(76.26, 0.01));
    expect(man.kgToHealthyRange, closeTo(3.74, 0.01));
  });

  test('ideal weight (Devine) differs by sex', () {
    expect(man.idealKgDevine, closeTo(70.47, 0.05));
    const woman = BodyMetrics(
      sex: BodySex.female,
      ageYears: 30,
      heightCm: 175,
      weightKg: 60,
    );
    expect(woman.idealKgDevine, closeTo(65.97, 0.05));
    expect(
      woman.kgToHealthyRange,
      0,
      reason: 'already inside the healthy range',
    );
  });

  test('a short person never gets an ideal weight below the base', () {
    const short = BodyMetrics(
      sex: BodySex.female,
      ageYears: 30,
      heightCm: 140,
      weightKg: 45,
    );
    expect(short.idealKgDevine, 45.5);
  });

  test('resting burn and maintenance calories', () {
    expect(man.bmr, closeTo(1748.75, 0.01));
    expect(man.maintenanceKcal, closeTo(1748.75 * 1.55, 0.01));
    const woman = BodyMetrics(
      sex: BodySex.female,
      ageYears: 30,
      heightCm: 165,
      weightKg: 60,
    );
    expect(woman.bmr, closeTo(1320.25, 0.01));
  });

  test(
    'under weight reads as negative kilograms to gain, and the adult tables stop at 18',
    () {
      const thin = BodyMetrics(
        sex: BodySex.male,
        ageYears: 16,
        heightCm: 180,
        weightKg: 52,
      );
      expect(thin.band, BmiBand.underweight);
      expect(thin.kgToHealthyRange, lessThan(0));
      expect(thin.adultTablesApply, isFalse);
      expect(man.adultTablesApply, isTrue);
    },
  );

  test('typing slips are rejected', () {
    expect(
      BodyMetrics.plausible(ageYears: 30, heightCm: 175, weightKg: 80),
      isTrue,
    );
    expect(
      BodyMetrics.plausible(ageYears: 30, heightCm: 17, weightKg: 80),
      isFalse,
    );
    expect(
      BodyMetrics.plausible(ageYears: 3, heightCm: 175, weightKg: 80),
      isFalse,
    );
    expect(
      BodyMetrics.plausible(ageYears: 30, heightCm: 175, weightKg: 8),
      isFalse,
    );
  });

  test('body fat from the tape (US Navy), its band, the ratios', () {
    const m = BodyMetrics(
      sex: BodySex.male,
      ageYears: 30,
      heightCm: 180,
      weightKg: 85,
      waistCm: 90,
      neckCm: 38,
    );

    expect(m.bodyFatNavy, closeTo(19.8, 0.1));
    expect(m.fatIsFromTape, isTrue);
    expect(m.fatBand, FatBand.average);
    expect(m.leanMassKg, closeTo(85 * (1 - m.bodyFatPercent! / 100), 0.001));
    expect(m.waistToHeight, closeTo(0.5, 0.001));

    const woman = BodyMetrics(
      sex: BodySex.female,
      ageYears: 30,
      heightCm: 165,
      weightKg: 62,
      waistCm: 75,
      neckCm: 32,
      hipCm: 98,
    );
    expect(woman.bodyFatNavy, closeTo(28, 3));
    expect(woman.waistToHip, closeTo(75 / 98, 0.001));
    expect(woman.waistToHipHigh, isFalse);
  });

  test(
    'a woman without hips, or a waist under the neck, has no tape estimate; a recorded fat is used instead',
    () {
      const noHip = BodyMetrics(
        sex: BodySex.female,
        ageYears: 30,
        heightCm: 165,
        weightKg: 62,
        waistCm: 75,
        neckCm: 32,
      );
      expect(noHip.bodyFatNavy, isNull);
      expect(noHip.bodyFatPercent, isNull);

      const odd = BodyMetrics(
        sex: BodySex.male,
        ageYears: 30,
        heightCm: 180,
        weightKg: 85,
        waistCm: 30,
        neckCm: 38,
        recordedFatPercent: 21,
      );
      expect(odd.bodyFatNavy, isNull);
      expect(odd.bodyFatPercent, 21);
      expect(odd.fatIsFromTape, isFalse);
    },
  );

  test('calories, protein and water follow the goal', () {
    const base = BodyMetrics(
      sex: BodySex.male,
      ageYears: 30,
      heightCm: 175,
      weightKg: 80,
      activity: ActivityLevel.moderate,
    );
    final maintain = base.maintenanceKcal;
    expect(base.targetKcal, closeTo(maintain, 0.001));

    const lose = BodyMetrics(
      sex: BodySex.male,
      ageYears: 30,
      heightCm: 175,
      weightKg: 80,
      activity: ActivityLevel.moderate,
      goal: BodyGoal.lose,
    );
    expect(lose.targetKcal, closeTo(maintain - 500, 0.001));
    expect(lose.proteinGrams.min, closeTo(144, 0.001));
    expect(lose.proteinGrams.max, closeTo(176, 0.001));

    const gain = BodyMetrics(
      sex: BodySex.male,
      ageYears: 30,
      heightCm: 175,
      weightKg: 80,
      activity: ActivityLevel.moderate,
      goal: BodyGoal.gain,
    );
    expect(gain.targetKcal, closeTo(maintain + 300, 0.001));
    expect(base.waterLitres, closeTo(2.8, 0.001));

    // never below the resting burn, however low the maintenance
    const small = BodyMetrics(
      sex: BodySex.female,
      ageYears: 60,
      heightCm: 150,
      weightKg: 45,
      activity: ActivityLevel.sedentary,
      goal: BodyGoal.lose,
    );
    expect(small.targetKcal, small.bmr);
  });
}

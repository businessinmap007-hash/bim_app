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
}

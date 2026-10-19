import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/body_measurement_store.dart';
import 'training_providers.dart';

final bodyMeasurementStoreProvider = Provider<BodyMeasurementStore>(
  (ref) => BodyMeasurementStore(),
);

/// What the account already has on record from its training: the latest weight (a progress check-in or a trainer's monthly
/// report, whichever is newer) and the body-fat / muscle / water the trainer measured.
class RecordedBodyData {
  final double? weightKg;
  final DateTime? weightOn;
  final double? fatPercent;
  final double? muscleKg;
  final double? waterPercent;
  final DateTime? reportOn;

  const RecordedBodyData({
    this.weightKg,
    this.weightOn,
    this.fatPercent,
    this.muscleKg,
    this.waterPercent,
    this.reportOn,
  });

  bool get isEmpty => weightKg == null && fatPercent == null;
}

/// Reads my training plans' check-ins and body reports. A person with no plan (or no connection) simply has nothing recorded.
final recordedBodyDataProvider = FutureProvider.autoDispose<RecordedBodyData>((
  ref,
) async {
  final api = ref.watch(trainingApiProvider);

  try {
    final plans = await api.myPlans();
    double? weight;
    DateTime? weightOn;
    double? fat;
    double? muscle;
    double? water;
    DateTime? reportOn;

    void offerWeight(double? w, DateTime? on) {
      if (w == null || on == null) return;
      if (weightOn == null || on.isAfter(weightOn!)) {
        weight = w;
        weightOn = on;
      }
    }

    for (final summary in plans.items.take(3)) {
      final plan = await api.plan(summary.id);
      for (final log in plan.progress ?? const []) {
        offerWeight(log.weight, log.loggedOn);
      }

      for (final report in await api.bodyReports(summary.id)) {
        final on = report.measuredOn;
        offerWeight(report.weightKg, on);
        if (on != null &&
            report.fatPercent != null &&
            (reportOn == null || on.isAfter(reportOn))) {
          reportOn = on;
          fat = report.fatPercent;
          muscle = report.muscleMassKg;
          water = report.waterPercent;
        }
      }
    }

    return RecordedBodyData(
      weightKg: weight,
      weightOn: weightOn,
      fatPercent: fat,
      muscleKg: muscle,
      waterPercent: water,
      reportOn: reportOn,
    );
  } catch (_) {
    return const RecordedBodyData();
  }
});

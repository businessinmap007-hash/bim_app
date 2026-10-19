import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';
import '../../domain/body_metrics.dart';

/// «حاسبة الوزن المناسب»: type sex, age, height and weight; the result updates as you type. Nothing is sent anywhere.
class BodyCalculatorScreen extends StatefulWidget {
  /// Pre-fills the weight (e.g. the client's last check-in), when known.
  final double? initialWeightKg;

  const BodyCalculatorScreen({super.key, this.initialWeightKg});

  @override
  State<BodyCalculatorScreen> createState() => _BodyCalculatorScreenState();
}

class _BodyCalculatorScreenState extends State<BodyCalculatorScreen> {
  late final TextEditingController _age = TextEditingController();
  late final TextEditingController _height = TextEditingController();
  late final TextEditingController _weight = TextEditingController(
    text: widget.initialWeightKg?.toStringAsFixed(1) ?? '',
  );
  BodySex _sex = BodySex.male;
  ActivityLevel _activity = ActivityLevel.light;

  @override
  void dispose() {
    _age.dispose();
    _height.dispose();
    _weight.dispose();
    super.dispose();
  }

  double? _num(TextEditingController c) =>
      double.tryParse(c.text.trim().replaceAll(',', '.'));

  BodyMetrics? get _metrics {
    final age = _num(_age)?.round();
    final height = _num(_height);
    final weight = _num(_weight);
    if (age == null || height == null || weight == null) return null;
    if (!BodyMetrics.plausible(
      ageYears: age,
      heightCm: height,
      weightKg: weight,
    )) {
      return null;
    }

    return BodyMetrics(
      sex: _sex,
      ageYears: age,
      heightCm: height,
      weightKg: weight,
      activity: _activity,
    );
  }

  String _kg(double v) => v.toStringAsFixed(1);

  String _activityLabel(AppLocalizations l10n, ActivityLevel a) => switch (a) {
    ActivityLevel.sedentary => l10n.bodyCalcActSedentary,
    ActivityLevel.light => l10n.bodyCalcActLight,
    ActivityLevel.moderate => l10n.bodyCalcActModerate,
    ActivityLevel.active => l10n.bodyCalcActActive,
    ActivityLevel.veryActive => l10n.bodyCalcActVery,
  };

  String _bandLabel(AppLocalizations l10n, BmiBand b) => switch (b) {
    BmiBand.underweight => l10n.bodyCalcUnderweight,
    BmiBand.normal => l10n.bodyCalcNormal,
    BmiBand.overweight => l10n.bodyCalcOverweight,
    BmiBand.obese => l10n.bodyCalcObese,
  };

  Color _bandColor(BmiBand b) => switch (b) {
    BmiBand.normal => Colors.green.shade700,
    BmiBand.overweight => Colors.orange.shade800,
    _ => Colors.red.shade700,
  };

  Widget _field(
    TextEditingController c,
    String label, {
    bool decimal = false,
  }) => TextField(
    controller: c,
    keyboardType: TextInputType.numberWithOptions(decimal: decimal),
    decoration: InputDecoration(labelText: label),
    onChanged: (_) => setState(() {}),
  );

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final m = _metrics;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.bodyCalcTitle)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SegmentedButton<BodySex>(
            segments: [
              ButtonSegment(
                value: BodySex.male,
                label: Text(l10n.bodyCalcMale),
              ),
              ButtonSegment(
                value: BodySex.female,
                label: Text(l10n.bodyCalcFemale),
              ),
            ],
            selected: {_sex},
            onSelectionChanged: (s) => setState(() => _sex = s.first),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _field(_age, l10n.bodyCalcAge)),
              const SizedBox(width: 12),
              Expanded(
                child: _field(_height, l10n.bodyCalcHeight, decimal: true),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _field(_weight, l10n.bodyCalcWeight, decimal: true),
              ),
            ],
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<ActivityLevel>(
            initialValue: _activity,
            decoration: InputDecoration(labelText: l10n.bodyCalcActivity),
            items: [
              for (final a in ActivityLevel.values)
                DropdownMenuItem(
                  value: a,
                  child: Text(_activityLabel(l10n, a)),
                ),
            ],
            onChanged: (a) => setState(() => _activity = a ?? _activity),
          ),
          const SizedBox(height: 16),
          if (m == null)
            Text(l10n.bodyCalcEnter, style: theme.textTheme.bodyMedium)
          else ...[
            Card(
              margin: EdgeInsets.zero,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l10n.bodyCalcBmi, style: theme.textTheme.labelLarge),
                    Text(
                      m.bmi.toStringAsFixed(1),
                      style: theme.textTheme.displaySmall?.copyWith(
                        color: m.adultTablesApply ? _bandColor(m.band) : null,
                      ),
                    ),
                    if (m.adultTablesApply)
                      Text(
                        _bandLabel(l10n, m.band),
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: _bandColor(m.band),
                        ),
                      )
                    else
                      Text(
                        l10n.bodyCalcMinor,
                        style: theme.textTheme.bodyMedium,
                      ),
                  ],
                ),
              ),
            ),
            if (m.adultTablesApply) ...[
              const SizedBox(height: 12),
              Card(
                margin: EdgeInsets.zero,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.bodyCalcHealthyRange(
                          _kg(m.healthyMinKg),
                          _kg(m.healthyMaxKg),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(l10n.bodyCalcIdeal(_kg(m.idealKgDevine))),
                      const SizedBox(height: 6),
                      Text(
                        m.kgToHealthyRange == 0
                            ? l10n.bodyCalcInRange
                            : m.kgToHealthyRange > 0
                            ? l10n.bodyCalcLose(_kg(m.kgToHealthyRange))
                            : l10n.bodyCalcGain(_kg(-m.kgToHealthyRange)),
                        style: theme.textTheme.titleSmall,
                      ),
                    ],
                  ),
                ),
              ),
            ],
            const SizedBox(height: 12),
            Card(
              margin: EdgeInsets.zero,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l10n.bodyCalcBmr(m.bmr.round().toString())),
                    const SizedBox(height: 6),
                    Text(
                      l10n.bodyCalcMaintain(
                        m.maintenanceKcal.round().toString(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
          const SizedBox(height: 16),
          Text(l10n.bodyCalcDisclaimer, style: theme.textTheme.bodySmall),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/time/egypt_time.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../auth/application/auth_controller.dart';
import '../../application/body_calculator_providers.dart';
import '../../data/body_measurement_store.dart';
import '../../domain/body_metrics.dart';

/// «حاسبة الوزن المناسب»: sex, age, height and weight (and, if you like, waist / neck / hip and a goal) — the result updates
/// as you type. It reads what the account already has on record (the last weight from training check-ins and the trainer's
/// monthly reports), remembers your own data on this phone, and keeps a history of the measurements you save. Nothing is
/// sent anywhere.
class BodyCalculatorScreen extends ConsumerStatefulWidget {
  const BodyCalculatorScreen({super.key});

  @override
  ConsumerState<BodyCalculatorScreen> createState() =>
      _BodyCalculatorScreenState();
}

class _BodyCalculatorScreenState extends ConsumerState<BodyCalculatorScreen> {
  final _age = TextEditingController();
  final _height = TextEditingController();
  final _weight = TextEditingController();
  final _waist = TextEditingController();
  final _neck = TextEditingController();
  final _hip = TextEditingController();
  BodySex _sex = BodySex.male;
  ActivityLevel _activity = ActivityLevel.light;
  BodyGoal _goal = BodyGoal.maintain;
  List<BodyEntry> _history = const [];
  bool _weightFromRecord = false;
  bool _loaded = false;

  int get _userId {
    final auth = ref.read(authControllerProvider);

    return auth is AuthSignedIn ? auth.user.id : 0;
  }

  @override
  void initState() {
    super.initState();
    _restore();
  }

  Future<void> _restore() async {
    final store = ref.read(bodyMeasurementStoreProvider);
    final profile = await store.readProfile(_userId);
    final history = await store.readHistory(_userId);
    if (!mounted) return;

    setState(() {
      _sex = profile.sex;
      _activity = profile.activity;
      _goal = profile.goal;
      if (profile.birthYear != null) {
        _age.text = '${EgyptTime.now().year - profile.birthYear!}';
      }
      _fill(_height, profile.heightCm);
      _fill(_waist, profile.waistCm);
      _fill(_neck, profile.neckCm);
      _fill(_hip, profile.hipCm);
      _history = history;
      // the last weight saved here, until the recorded one (if any) arrives
      if (history.isNotEmpty) _fill(_weight, history.first.weightKg);
      _loaded = true;
    });
  }

  void _fill(TextEditingController c, double? v) {
    if (v != null) c.text = _trim(v);
  }

  String _trim(double v) =>
      v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toStringAsFixed(1);

  @override
  void dispose() {
    for (final c in [_age, _height, _weight, _waist, _neck, _hip]) {
      c.dispose();
    }
    super.dispose();
  }

  double? _num(TextEditingController c) =>
      double.tryParse(c.text.trim().replaceAll(',', '.'));

  BodyMetrics? _metrics(RecordedBodyData? recorded) {
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
      goal: _goal,
      waistCm: _num(_waist),
      neckCm: _num(_neck),
      hipCm: _num(_hip),
      recordedFatPercent: recorded?.fatPercent,
    );
  }

  /// Remember the person's own data (not the weight, which changes) so next time only the weight is typed.
  Future<void> _rememberProfile() async {
    final age = _num(_age)?.round();

    await ref
        .read(bodyMeasurementStoreProvider)
        .writeProfile(
          _userId,
          BodyProfile(
            sex: _sex,
            birthYear: age == null ? null : EgyptTime.now().year - age,
            heightCm: _num(_height),
            waistCm: _num(_waist),
            neckCm: _num(_neck),
            hipCm: _num(_hip),
            activity: _activity,
            goal: _goal,
          ),
        );
  }

  void _changed() {
    setState(() => _weightFromRecord = false);
    _rememberProfile();
  }

  Future<void> _save(BodyMetrics m) async {
    final l10n = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.of(context);
    final today = EgyptTime.now().toIso8601String().substring(0, 10);

    final history = await ref
        .read(bodyMeasurementStoreProvider)
        .save(
          _userId,
          BodyEntry(
            date: today,
            weightKg: m.weightKg,
            bmi: m.bmi,
            fatPercent: m.bodyFatNavy,
            waistCm: m.waistCm,
          ),
        );
    await _rememberProfile();
    if (!mounted) return;

    setState(() => _history = history);
    messenger.showSnackBar(SnackBar(content: Text(l10n.bodyCalcSaved)));
  }

  Future<void> _delete(BodyEntry e) async {
    final history = await ref
        .read(bodyMeasurementStoreProvider)
        .remove(_userId, e.date);
    if (mounted) setState(() => _history = history);
  }

  String _kg(double v) => v.toStringAsFixed(1);

  String _activityLabel(AppLocalizations l10n, ActivityLevel a) => switch (a) {
    ActivityLevel.sedentary => l10n.bodyCalcActSedentary,
    ActivityLevel.light => l10n.bodyCalcActLight,
    ActivityLevel.moderate => l10n.bodyCalcActModerate,
    ActivityLevel.active => l10n.bodyCalcActActive,
    ActivityLevel.veryActive => l10n.bodyCalcActVery,
  };

  String _goalLabel(AppLocalizations l10n, BodyGoal g) => switch (g) {
    BodyGoal.lose => l10n.bodyCalcGoalLose,
    BodyGoal.maintain => l10n.bodyCalcGoalMaintain,
    BodyGoal.gain => l10n.bodyCalcGoalGain,
  };

  String _bandLabel(AppLocalizations l10n, BmiBand b) => switch (b) {
    BmiBand.underweight => l10n.bodyCalcUnderweight,
    BmiBand.normal => l10n.bodyCalcNormal,
    BmiBand.overweight => l10n.bodyCalcOverweight,
    BmiBand.obese => l10n.bodyCalcObese,
  };

  String _fatBandLabel(AppLocalizations l10n, FatBand b) => switch (b) {
    FatBand.essential => l10n.bodyCalcFatEssential,
    FatBand.athletic => l10n.bodyCalcFatAthletic,
    FatBand.fitness => l10n.bodyCalcFatFitness,
    FatBand.average => l10n.bodyCalcFatAverage,
    FatBand.high => l10n.bodyCalcFatHigh,
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
    onChanged: (_) => _changed(),
  );

  Widget _card(List<Widget> children) => Card(
    margin: EdgeInsets.zero,
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final recorded = ref.watch(recordedBodyDataProvider).valueOrNull;

    // the newest recorded weight fills an empty box once; the person can still type over it
    if (_loaded &&
        recorded?.weightKg != null &&
        (_weight.text.isEmpty || _weightFromRecord)) {
      final text = _trim(recorded!.weightKg!);
      if (_weight.text != text) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            setState(() {
              _weight.text = text;
              _weightFromRecord = true;
            });
          }
        });
      }
    }

    final m = _metrics(recorded);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.bodyCalcTitle)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (recorded?.weightKg != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  const Icon(Icons.history_toggle_off, size: 18),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      l10n.bodyCalcRecorded(
                        _kg(recorded!.weightKg!),
                        recorded.weightOn!.toIso8601String().substring(0, 10),
                      ),
                      style: theme.textTheme.bodySmall,
                    ),
                  ),
                ],
              ),
            ),
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
            onSelectionChanged: (s) {
              _sex = s.first;
              _changed();
            },
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
            isExpanded: true,
            decoration: InputDecoration(labelText: l10n.bodyCalcActivity),
            items: [
              for (final a in ActivityLevel.values)
                DropdownMenuItem(
                  value: a,
                  child: Text(
                    _activityLabel(l10n, a),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
            ],
            onChanged: (a) {
              _activity = a ?? _activity;
              _changed();
            },
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<BodyGoal>(
            initialValue: _goal,
            decoration: InputDecoration(labelText: l10n.bodyCalcGoal),
            items: [
              for (final g in BodyGoal.values)
                DropdownMenuItem(value: g, child: Text(_goalLabel(l10n, g))),
            ],
            onChanged: (g) {
              _goal = g ?? _goal;
              _changed();
            },
          ),
          ExpansionTile(
            tilePadding: EdgeInsets.zero,
            title: Text(l10n.bodyCalcTape),
            subtitle: Text(l10n.bodyCalcTapeHint),
            children: [
              Row(
                children: [
                  Expanded(
                    child: _field(_waist, l10n.bodyCalcWaist, decimal: true),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _field(_neck, l10n.bodyCalcNeck, decimal: true),
                  ),
                  if (_sex == BodySex.female) ...[
                    const SizedBox(width: 12),
                    Expanded(
                      child: _field(_hip, l10n.bodyCalcHip, decimal: true),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 8),
            ],
          ),
          const SizedBox(height: 8),
          if (m == null)
            Text(l10n.bodyCalcEnter, style: theme.textTheme.bodyMedium)
          else ...[
            _card([
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
                Text(l10n.bodyCalcMinor, style: theme.textTheme.bodyMedium),
            ]),
            if (m.adultTablesApply) ...[
              const SizedBox(height: 12),
              _card([
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
              ]),
            ],
            if (m.bodyFatPercent != null ||
                m.waistToHeight != null ||
                m.waistToHip != null) ...[
              const SizedBox(height: 12),
              _card([
                Text(
                  l10n.bodyCalcComposition,
                  style: theme.textTheme.labelLarge,
                ),
                const SizedBox(height: 6),
                if (m.bodyFatPercent != null) ...[
                  Text(
                    '${l10n.bodyCalcFat(_kg(m.bodyFatPercent!))}'
                    '${m.fatBand == null ? '' : ' · ${_fatBandLabel(l10n, m.fatBand!)}'}',
                  ),
                  Text(
                    m.fatIsFromTape
                        ? l10n.bodyCalcFatFromTape
                        : l10n.bodyCalcFatFromReport,
                    style: theme.textTheme.bodySmall,
                  ),
                  if (m.leanMassKg != null)
                    Text(l10n.bodyCalcLean(_kg(m.leanMassKg!))),
                  if (recorded?.muscleKg != null)
                    Text(l10n.bodyCalcMuscle(_kg(recorded!.muscleKg!))),
                ],
                if (m.waistToHeight != null)
                  Text(
                    l10n.bodyCalcWht(
                      m.waistToHeight!.toStringAsFixed(2),
                      m.waistToHeight! < 0.5
                          ? l10n.bodyCalcWhtOk
                          : l10n.bodyCalcWhtHigh,
                    ),
                  ),
                if (m.waistToHip != null)
                  Text(
                    l10n.bodyCalcWhr(
                      m.waistToHip!.toStringAsFixed(2),
                      m.waistToHipHigh == true
                          ? l10n.bodyCalcWhtHigh
                          : l10n.bodyCalcWhtOk,
                    ),
                  ),
              ]),
            ],
            const SizedBox(height: 12),
            _card([
              Text(l10n.bodyCalcNeeds, style: theme.textTheme.labelLarge),
              const SizedBox(height: 6),
              Text(l10n.bodyCalcBmr(m.bmr.round().toString())),
              Text(l10n.bodyCalcMaintain(m.maintenanceKcal.round().toString())),
              Text(
                l10n.bodyCalcTarget(
                  _goalLabel(l10n, _goal),
                  m.targetKcal.round().toString(),
                ),
                style: theme.textTheme.titleSmall,
              ),
              Text(
                l10n.bodyCalcProtein(
                  m.proteinGrams.min.round().toString(),
                  m.proteinGrams.max.round().toString(),
                ),
              ),
              Text(l10n.bodyCalcWater(m.waterLitres.toStringAsFixed(1))),
            ]),
            const SizedBox(height: 12),
            FilledButton.icon(
              icon: const Icon(Icons.save_outlined),
              onPressed: () => _save(m),
              label: Text(l10n.bodyCalcSave),
            ),
          ],
          if (_history.isNotEmpty) ...[
            const SizedBox(height: 20),
            Text(l10n.bodyCalcHistory, style: theme.textTheme.titleSmall),
            Text(l10n.bodyCalcHistoryHint, style: theme.textTheme.bodySmall),
            const SizedBox(height: 8),
            for (var i = 0; i < _history.length; i++)
              _historyTile(
                l10n,
                _history[i],
                i + 1 < _history.length ? _history[i + 1] : null,
              ),
          ],
          const SizedBox(height: 16),
          Text(l10n.bodyCalcDisclaimer, style: theme.textTheme.bodySmall),
        ],
      ),
    );
  }

  Widget _historyTile(AppLocalizations l10n, BodyEntry e, BodyEntry? before) {
    final delta = before == null ? null : e.weightKg - before.weightKg;

    return ListTile(
      contentPadding: EdgeInsets.zero,
      dense: true,
      title: Text(
        '${e.date} · ${l10n.bodyCalcKgUnit(_kg(e.weightKg))} · BMI ${e.bmi.toStringAsFixed(1)}'
        '${e.fatPercent == null ? '' : ' · ${l10n.bodyCalcFat(_kg(e.fatPercent!))}'}',
      ),
      subtitle: delta == null || delta == 0
          ? null
          : Text(
              '${delta > 0 ? '+' : ''}${_kg(delta)} ${l10n.bodyCalcSinceBefore}',
            ),
      trailing: IconButton(
        icon: const Icon(Icons.delete_outline, size: 20),
        onPressed: () => _delete(e),
      ),
    );
  }
}

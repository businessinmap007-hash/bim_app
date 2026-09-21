import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';
import '../../data/models/set_log.dart';

/// What the trainee typed for one set. Both numbers are optional.
class SetEntry {
  final int? reps;
  final double? weight;

  const SetEntry({this.reps, this.weight});
}

/// The leading number of a prescription like "10" or "10-12" — what the reps
/// box starts with, so the usual case is one tap on Save.
int? firstNumber(String? text) {
  final match = RegExp(r'\d+').firstMatch(text ?? '');
  return match == null ? null : int.tryParse(match.group(0)!);
}

/// Asks for the reps done and the weight used in a set. Returns null when
/// dismissed; [SetEntry] with no numbers when "confirm without details" is
/// chosen ([allowSkip]) — a set can still be counted without them.
Future<SetEntry?> showSetLogSheet(
  BuildContext context, {
  required String title,
  int? initialReps,
  double? initialWeight,
  bool allowSkip = true,
}) {
  return showModalBottomSheet<SetEntry>(
    context: context,
    isScrollControlled: true,
    builder: (_) => _SetLogSheet(title: title, initialReps: initialReps, initialWeight: initialWeight, allowSkip: allowSkip),
  );
}

class _SetLogSheet extends StatefulWidget {
  final String title;
  final int? initialReps;
  final double? initialWeight;
  final bool allowSkip;

  const _SetLogSheet({required this.title, this.initialReps, this.initialWeight, required this.allowSkip});

  @override
  State<_SetLogSheet> createState() => _SetLogSheetState();
}

class _SetLogSheetState extends State<_SetLogSheet> {
  late final _reps = TextEditingController(text: widget.initialReps?.toString() ?? '');
  late final _weight = TextEditingController(text: formatWeight(widget.initialWeight) ?? '');

  @override
  void dispose() {
    _reps.dispose();
    _weight.dispose();
    super.dispose();
  }

  void _save() {
    Navigator.of(context).pop(
      SetEntry(
        reps: int.tryParse(_reps.text.trim()),
        weight: double.tryParse(_weight.text.trim().replaceAll(',', '.')),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Padding(
      padding: EdgeInsets.fromLTRB(20, 20, 20, 20 + MediaQuery.of(context).viewInsets.bottom),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _reps,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(labelText: l10n.trainingSetReps),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _weight,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(labelText: l10n.trainingSetWeight),
                    onSubmitted: (_) => _save(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            FilledButton(onPressed: _save, child: Text(l10n.commonSave)),
            if (widget.allowSkip)
              TextButton(
                onPressed: () => Navigator.of(context).pop(const SetEntry()),
                child: Text(l10n.trainingSetSkipDetails),
              ),
          ],
        ),
      ),
    );
  }
}

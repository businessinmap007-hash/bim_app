import 'package:flutter/material.dart';

import '../../core/network/api_exception.dart';
import '../../l10n/app_localizations.dart';

/// A desktop page: a title row with its actions, then the content in a padded scroll area.
class SuitePage extends StatelessWidget {
  final String title;
  final List<Widget> actions;
  final Widget child;
  final bool scroll;

  const SuitePage({super.key, required this.title, this.actions = const [], required this.child, this.scroll = true});

  @override
  Widget build(BuildContext context) {
    final header = Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 12),
      child: Row(
        children: [
          Expanded(child: Text(title, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800))),
          Wrap(spacing: 8, runSpacing: 8, children: actions),
        ],
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        header,
        Expanded(
          child: scroll
              ? SingleChildScrollView(padding: const EdgeInsets.fromLTRB(24, 0, 24, 24), child: child)
              : Padding(padding: const EdgeInsets.fromLTRB(24, 0, 24, 24), child: child),
        ),
      ],
    );
  }
}

class SuiteStat extends StatelessWidget {
  final String label;
  final String value;
  final String? sub;
  final Color? color;

  const SuiteStat({super.key, required this.label, required this.value, this.sub, this.color});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 4),
            Text(value, style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: color)),
            if (sub != null) Text(sub!, style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}

class SuiteSection extends StatelessWidget {
  final String title;
  final Widget child;
  final List<Widget> actions;

  const SuiteSection({super.key, required this.title, required this.child, this.actions = const []});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(children: [Expanded(child: Text(title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800))), ...actions]),
            const SizedBox(height: 10),
            child,
          ],
        ),
      ),
    );
  }
}

/// Runs a write and tells the user how it went: saved, kept on this computer for later, or why it was refused.
Future<T?> suiteRun<T>(BuildContext context, Future<T> Function() action, {bool queueable = true}) async {
  final l10n = AppLocalizations.of(context)!;
  final messenger = ScaffoldMessenger.of(context);
  try {
    final result = await action();
    messenger.showSnackBar(SnackBar(content: Text(result == null && queueable ? l10n.suiteQueued : l10n.stkSaved)));
    return result;
  } on ApiException catch (e) {
    final details = e.fieldErrors.values.expand((v) => v).join('\n');
    messenger.showSnackBar(SnackBar(content: Text(details.isEmpty ? e.message : details)));
    return null;
  }
}

double? parseNum(String text) => double.tryParse(text.trim().replaceAll('٫', '.').replaceAll(',', ''));

/// A short labelled number field for dialogs and tables.
class NumField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final double width;

  const NumField({super.key, required this.controller, required this.label, this.width = 110});

  @override
  Widget build(BuildContext context) => SizedBox(
        width: width,
        child: TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(labelText: label, isDense: true),
        ),
      );
}

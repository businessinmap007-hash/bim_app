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
          Expanded(
            child: Text(title, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
          ),
          Wrap(spacing: 8, runSpacing: 8, children: actions),
        ],
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        header,
        Expanded(
          child: scroll ? SingleChildScrollView(padding: const EdgeInsets.fromLTRB(24, 0, 24, 24), child: child) : Padding(padding: const EdgeInsets.fromLTRB(24, 0, 24, 24), child: child),
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
    // one height for every card of a row and a gap between them — side by side they used to touch and sit at
    // different heights (owner, 2026-10-30)
    return Card(
      margin: const EdgeInsets.all(6),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 112),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(label, style: Theme.of(context).textTheme.bodySmall),
              const SizedBox(height: 4),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: AlignmentDirectional.centerStart,
                child: Text(
                  value,
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: color),
                ),
              ),
              Text(sub ?? '', style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
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
      margin: const EdgeInsets.all(6),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
                ),
                ...actions,
              ],
            ),
            const SizedBox(height: 10),
            child,
          ],
        ),
      ),
    );
  }
}

/// Runs a write and tells the user how it went: saved (a small card in the middle of the screen), kept on this computer
/// for later, or why it was refused.
Future<T?> suiteRun<T>(BuildContext context, Future<T> Function() action, {bool queueable = true}) async {
  final l10n = AppLocalizations.of(context)!;
  final messenger = ScaffoldMessenger.of(context);
  final overlay = Overlay.maybeOf(context, rootOverlay: true);
  try {
    final result = await action();
    final queued = result == null && queueable;
    if (overlay != null && overlay.mounted) {
      suiteToastOn(overlay, queued ? l10n.suiteQueued : l10n.stkSaved, icon: queued ? Icons.cloud_upload_outlined : Icons.check_circle);
    } else {
      messenger.showSnackBar(SnackBar(content: Text(queued ? l10n.suiteQueued : l10n.stkSaved)));
    }
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

/// Status colours for text drawn straight on a card. The fixed shades were chosen for a light page and turn unreadable
/// on the dark theme (owner, 2026-10-30) — on a dark surface each takes its lighter twin.
class Tone {
  const Tone._();

  static bool _dark(BuildContext c) => Theme.of(c).brightness == Brightness.dark;

  static Color good(BuildContext c) => _dark(c) ? const Color(0xFF7DD3A0) : const Color(0xFF1F7A44);
  static Color bad(BuildContext c) => _dark(c) ? const Color(0xFFF4A091) : const Color(0xFFB93A22);
  static Color warn(BuildContext c) => _dark(c) ? const Color(0xFFF2C879) : const Color(0xFF7A5200);
}

/// «تم الحفظ» as a small card in the MIDDLE of the screen that fades away by itself (owner, 2026-10-30: «تكون شاشة
/// منبثقة صغيرة فى منتصف الشاشة بدل من السناك بار»). It never takes a click — the work goes on under it.
void suiteToast(BuildContext context, String text, {IconData icon = Icons.check_circle}) {
  final overlay = Overlay.maybeOf(context, rootOverlay: true);
  if (overlay == null) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
    return;
  }
  suiteToastOn(overlay, text, icon: icon);
}

void suiteToastOn(OverlayState overlay, String text, {IconData icon = Icons.check_circle}) {
  late final OverlayEntry entry;
  entry = OverlayEntry(
    builder: (_) => _SuiteToast(text: text, icon: icon, onDone: () => entry.remove()),
  );
  overlay.insert(entry);
}

class _SuiteToast extends StatefulWidget {
  final String text;
  final IconData icon;
  final VoidCallback onDone;
  const _SuiteToast({required this.text, required this.icon, required this.onDone});

  @override
  State<_SuiteToast> createState() => _SuiteToastState();
}

class _SuiteToastState extends State<_SuiteToast> with SingleTickerProviderStateMixin {
  late final _fade = AnimationController(vsync: this, duration: const Duration(milliseconds: 180))..forward();

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 1400), () async {
      if (!mounted) return;
      await _fade.reverse();
      widget.onDone();
    });
  }

  @override
  void dispose() {
    _fade.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return IgnorePointer(
      child: Center(
        child: FadeTransition(
          opacity: _fade,
          child: ScaleTransition(
            scale: Tween(begin: 0.92, end: 1.0).animate(CurvedAnimation(parent: _fade, curve: Curves.easeOut)),
            child: Material(
              elevation: 10,
              color: scheme.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(18),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(widget.icon, size: 42, color: Tone.good(context)),
                    const SizedBox(height: 8),
                    Text(
                      widget.text,
                      style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: scheme.onSurface),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

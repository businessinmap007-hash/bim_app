import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../l10n/app_localizations.dart';
import '../../application/booking_settings_controller.dart';

/// «خطط الأسعار»: beside the flexible rate, the cheaper «غير قابل للاسترداد» — a percentage off. The guest pays the hotel in full outside
/// the app and cannot move the dates; the app confiscates nothing.
class RatePlansScreen extends ConsumerStatefulWidget {
  const RatePlansScreen({super.key});

  @override
  ConsumerState<RatePlansScreen> createState() => _RatePlansScreenState();
}

class _RatePlansScreenState extends ConsumerState<RatePlansScreen> {
  final _percent = TextEditingController();
  bool _on = false;
  bool _loaded = false;
  bool _failed = false;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _percent.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final p = await ref.read(bookingSettingsApiProvider).nonRefundablePercent();
      if (!mounted) return;
      setState(() {
        _on = p != null;
        _percent.text = p == null ? '10' : p.toStringAsFixed(p % 1 == 0 ? 0 : 2);
        _loaded = true;
      });
    } catch (_) {
      if (mounted) setState(() => _failed = true);
    }
  }

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _saving = true);
    try {
      await ref.read(bookingSettingsApiProvider).saveNonRefundablePercent(_on ? double.tryParse(_percent.text.trim().replaceAll(',', '.')) : null);
      messenger.showSnackBar(SnackBar(content: Text(l10n.ratePlansSaved)));
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(e is ApiException && e.message.isNotEmpty ? e.message : l10n.commonSomethingWentWrong)));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.ratePlansTitle)),
      body: _failed
          ? Center(child: Text(l10n.commonSomethingWentWrong))
          : !_loaded
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text(l10n.ratePlansIntro, style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor)),
                const SizedBox(height: 12),
                ListTile(contentPadding: EdgeInsets.zero, leading: const Icon(Icons.event_repeat_outlined), title: Text(l10n.ratePlanFlexible), subtitle: Text(l10n.ratePlanFlexibleHint)),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  secondary: const Icon(Icons.lock_clock_outlined),
                  title: Text(l10n.ratePlanNonRefundable),
                  subtitle: Text(l10n.ratePlanNonRefundableHint),
                  value: _on,
                  onChanged: (v) => setState(() => _on = v),
                ),
                if (_on)
                  TextField(
                    controller: _percent,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(labelText: l10n.ratePlanDiscount, suffixText: '%', helperText: l10n.ratePlanDiscountHint),
                  ),
                const SizedBox(height: 16),
                FilledButton(onPressed: _saving ? null : _save, child: Text(l10n.commonSave)),
              ],
            ),
    );
  }
}

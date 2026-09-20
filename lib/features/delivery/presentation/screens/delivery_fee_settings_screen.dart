import 'package:flutter/material.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../l10n/app_localizations.dart';

/// One flat delivery-fee field, shared by the business (its own rate,
/// applied at checkout) and a freelance driver (fallback rate) - the two
/// differ only in where the value is loaded from / saved to.
class DeliveryFeeSettingsScreen extends StatefulWidget {
  final String hint;
  final Future<double?> Function() load;
  final Future<double?> Function(double? amount) save;
  const DeliveryFeeSettingsScreen({super.key, required this.hint, required this.load, required this.save});

  @override
  State<DeliveryFeeSettingsScreen> createState() => _DeliveryFeeSettingsScreenState();
}

class _DeliveryFeeSettingsScreenState extends State<DeliveryFeeSettingsScreen> {
  final _controller = TextEditingController();
  bool _loading = true;
  bool _saving = false;
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _format(double? v) => v == null ? '' : (v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toString());

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _failed = false;
    });
    try {
      final v = await widget.load();
      if (mounted) _controller.text = _format(v);
    } catch (_) {
      if (mounted) setState(() => _failed = true);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _save({bool clear = false}) async {
    final l10n = AppLocalizations.of(context)!;
    final text = _controller.text.trim();
    double? amount;
    if (!clear && text.isNotEmpty) {
      amount = double.tryParse(text);
      if (amount == null || amount < 0) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.deliveryFeeInvalid)));
        return;
      }
    }

    setState(() => _saving = true);
    try {
      final saved = await widget.save(amount);
      if (!mounted) return;
      _controller.text = _format(saved);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.deliveryFeeSaved)));
    } catch (e) {
      if (mounted) {
        final message = e is ApiException ? e.message : l10n.commonSomethingWentWrong;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.deliveryFeeSettingsTitle)),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _failed
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(l10n.commonSomethingWentWrong),
                  const SizedBox(height: 8),
                  OutlinedButton(onPressed: _load, child: Text(l10n.commonRetry)),
                ],
              ),
            )
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text(widget.hint, style: Theme.of(context).textTheme.bodyMedium),
                const SizedBox(height: 16),
                TextField(
                  controller: _controller,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(labelText: l10n.deliveryFeeAmountLabel),
                ),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: _saving ? null : _save,
                  child: _saving
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                      : Text(l10n.commonSave),
                ),
                const SizedBox(height: 8),
                OutlinedButton(onPressed: _saving ? null : () => _save(clear: true), child: Text(l10n.deliveryFeeClear)),
              ],
            ),
    );
  }
}

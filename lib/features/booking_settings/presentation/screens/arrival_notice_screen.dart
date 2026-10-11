import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/widgets/arrival_notice_banner.dart';
import '../../../../shared/widgets/form_save_button.dart';
import '../../application/booking_settings_controller.dart';

/// «تنبيه الحضور» — what the business asks of whoever it books («يجب التواجد قبل الموعد بـ ١٥ دقيقة») and a sentence of
/// its own. The customer reads it on the booking form and on the booking, and the reminder repeats it.
class ArrivalNoticeScreen extends ConsumerStatefulWidget {
  const ArrivalNoticeScreen({super.key});

  @override
  ConsumerState<ArrivalNoticeScreen> createState() => _ArrivalNoticeScreenState();
}

class _ArrivalNoticeScreenState extends ConsumerState<ArrivalNoticeScreen> {
  static const _presets = [0, 10, 15, 20, 30, 45, 60];

  final _text = TextEditingController();
  int _minutes = 0;
  String? _savedSignature;
  String? _preview;
  bool _loaded = false;
  bool _saving = false;
  String? _error;

  String get _signature => '$_minutes|${_text.text.trim()}';

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final n = await ref.read(bookingSettingsApiProvider).arrivalNotice();
      if (!mounted) return;
      setState(() {
        _minutes = n.minutes ?? 0;
        _text.text = n.text ?? '';
        _preview = n.message;
        _savedSignature = _signature;
        _loaded = true;
      });
    } catch (_) {
      if (mounted) setState(() => _error = AppLocalizations.of(context)!.commonSomethingWentWrong);
    }
  }

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context)!;
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      final n = await ref.read(bookingSettingsApiProvider).saveArrivalNotice(minutes: _minutes, text: _text.text.trim());
      if (!mounted) return;
      setState(() {
        _preview = n.message;
        _savedSignature = _signature;
      });
    } catch (e) {
      if (mounted) setState(() => _error = e is ApiException && e.message.isNotEmpty ? e.message : l10n.commonSomethingWentWrong);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.arrivalNoticeTitle)),
      body: !_loaded
          ? Center(child: _error != null ? Text(_error!) : const CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text(l10n.arrivalNoticeIntro, style: theme.textTheme.bodyMedium),
                const SizedBox(height: 16),
                Text(l10n.arrivalNoticeMinutes, style: theme.textTheme.titleSmall),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final m in _presets)
                      ChoiceChip(
                        label: Text(m == 0 ? l10n.arrivalNoticeNone : l10n.bookingMinutes(m)),
                        selected: _minutes == m,
                        onSelected: (_) => setState(() => _minutes = m),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _text,
                  maxLength: 255,
                  maxLines: 2,
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(labelText: l10n.arrivalNoticeText, alignLabelWithHint: true),
                ),
                if ((_preview ?? '').isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(l10n.arrivalNoticePreview, style: theme.textTheme.labelMedium?.copyWith(color: theme.hintColor)),
                  const SizedBox(height: 6),
                  ArrivalNoticeBanner(message: _preview),
                ],
                if (_error != null) Padding(padding: const EdgeInsets.only(top: 8), child: Text(_error!, style: TextStyle(color: theme.colorScheme.error))),
                const SizedBox(height: 20),
                FormSaveButton(saving: _saving, saved: _savedSignature == _signature, onPressed: _save),
              ],
            ),
    );
  }
}

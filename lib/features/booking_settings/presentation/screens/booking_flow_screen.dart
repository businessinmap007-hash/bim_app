import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/widgets/form_save_button.dart';
import '../../application/booking_settings_controller.dart';

/// «طريقة الحجز» — how this business takes its appointments: the customer picks a time, or is given the next turn of
/// the day and the time it should come to.
class BookingFlowScreen extends ConsumerStatefulWidget {
  const BookingFlowScreen({super.key});

  @override
  ConsumerState<BookingFlowScreen> createState() => _BookingFlowScreenState();
}

class _BookingFlowScreenState extends ConsumerState<BookingFlowScreen> {
  String _flow = 'slots';
  String? _saved;
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final flow = await ref.read(bookingSettingsApiProvider).bookingFlow();
      if (mounted) {
        setState(() {
          _flow = flow;
          _saved = flow;
        });
      }
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
      final flow = await ref.read(bookingSettingsApiProvider).saveBookingFlow(_flow);
      if (mounted) {
        setState(() {
          _flow = flow;
          _saved = flow;
        });
      }
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

    Widget option(String value, String title, String sub, IconData icon) {
      final on = _flow == value;

      return Card(
        margin: const EdgeInsets.only(bottom: 10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(color: on ? theme.colorScheme.secondary : Colors.transparent, width: 2),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () => setState(() => _flow = value),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Icon(icon, size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
                      const SizedBox(height: 2),
                      Text(sub, style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor)),
                    ],
                  ),
                ),
                Icon(on ? Icons.radio_button_checked : Icons.radio_button_unchecked, color: on ? theme.colorScheme.secondary : theme.hintColor),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(l10n.bookingFlowTitle)),
      body: _saved == null
          ? Center(child: _error != null ? Text(_error!) : const CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text(l10n.bookingFlowIntro, style: theme.textTheme.bodyMedium),
                const SizedBox(height: 16),
                option('slots', l10n.bookingFlowSlots, l10n.bookingFlowSlotsSub, Icons.event_available_outlined),
                option('queue', l10n.bookingFlowQueue, l10n.bookingFlowQueueSub, Icons.format_list_numbered_rounded),
                if (_error != null) Padding(padding: const EdgeInsets.only(top: 4), child: Text(_error!, style: TextStyle(color: theme.colorScheme.error))),
                const SizedBox(height: 16),
                FormSaveButton(saving: _saving, saved: _saved == _flow, onPressed: _save),
              ],
            ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/app_localizations.dart';
import '../network/api_exception.dart';
import '../providers/core_providers.dart';

/// «اكتمل العدد اليوم» — the business's OPTIONAL button, one for every business that takes dated bookings (a clinic, a
/// hotel, a salon…). It closes NEW bookings for today; reopened by the same switch. Never automatic: a doctor may rather
/// add working hours. When it closes a day the deposits still held for no-shows of that day go back by themselves.
class DayClosureTile extends ConsumerStatefulWidget {
  const DayClosureTile({super.key});

  @override
  ConsumerState<DayClosureTile> createState() => _DayClosureTileState();
}

class _DayClosureTileState extends ConsumerState<DayClosureTile> {
  bool _loaded = false;
  bool _failed = false;
  bool _busy = false;
  String? _closedDate;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final data = await ref.read(apiClientProvider).get('/business/booking-day-closure') as Map<String, dynamic>;
      if (!mounted) return;
      setState(() {
        _closedDate = data['closed_date'] as String?;
        _loaded = true;
      });
    } catch (_) {
      if (mounted) setState(() => _failed = true);
    }
  }

  Future<void> _set(bool closed) async {
    setState(() => _busy = true);

    try {
      final data = await ref.read(apiClientProvider).put('/business/booking-day-closure', data: {'closed': closed}) as Map<String, dynamic>;
      if (mounted) setState(() => _closedDate = data['closed_date'] as String?);
    } catch (e) {
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e is ApiException && e.message.isNotEmpty ? e.message : l10n.commonSomethingWentWrong)),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    if (_failed) return Text(l10n.commonSomethingWentWrong);
    if (!_loaded) return const Padding(padding: EdgeInsets.all(16), child: Center(child: CircularProgressIndicator()));

    return SwitchListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(l10n.clinicDayClosureTitle),
      subtitle: Text(_closedDate != null ? l10n.clinicDayClosureClosedOn(_closedDate!) : l10n.clinicDayClosureBody),
      value: _closedDate != null,
      onChanged: _busy ? null : _set,
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../l10n/app_localizations.dart';
import '../../application/stay_requests_providers.dart';
import '../../data/models/stay_request.dart';

/// «اضف به الخدمات التي ممكن يتم طلبها» — the hotel's own list of what a guest may order during a stay. Until the
/// hotel writes a row the platform's starting list is what guests see; the first thing added makes the list the
/// hotel's, with everything the starting list had still there to switch off.
class StayServicesScreen extends ConsumerStatefulWidget {
  const StayServicesScreen({super.key});

  @override
  ConsumerState<StayServicesScreen> createState() => _StayServicesScreenState();
}

class _StayServicesScreenState extends ConsumerState<StayServicesScreen> {
  final _input = TextEditingController();
  bool _busy = false;

  @override
  void dispose() {
    _input.dispose();
    super.dispose();
  }

  Future<void> _run(Future<StayServicesPayload> Function() call) async {
    final l10n = AppLocalizations.of(context)!;
    setState(() => _busy = true);
    try {
      await call();
      ref.invalidate(stayServicesProvider);
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e is ApiException ? e.message : l10n.commonSomethingWentWrong)));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _add() async {
    final titles = _input.text.split(RegExp(r'[,،;\n]+')).map((t) => t.trim()).where((t) => t.isNotEmpty).toList();
    if (titles.isEmpty) return;
    await _run(() => ref.read(stayRequestsApiProvider).addServices(titles));
    if (mounted) _input.clear();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final async = ref.watch(stayServicesProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.stayReqManageServices)),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => Center(child: Text(l10n.commonSomethingWentWrong)),
        data: (payload) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(l10n.stayReqServicesIntro, style: theme.textTheme.bodyMedium),
            if (!payload.custom) ...[
              const SizedBox(height: 8),
              Text(l10n.stayReqServicesStarting, style: theme.textTheme.bodySmall),
            ],
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: TextField(controller: _input, decoration: InputDecoration(hintText: l10n.stayReqAddServiceHint), onSubmitted: (_) => _add())),
                const SizedBox(width: 8),
                FilledButton(onPressed: _busy ? null : _add, child: Text(l10n.stayReqAdd)),
              ],
            ),
            const SizedBox(height: 12),
            for (final s in payload.services)
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(s.title),
                value: s.isActive,
                // the starting list has no ids yet — the first addition turns it into the hotel's own
                onChanged: _busy || s.id == null ? null : (v) => _run(() => ref.read(stayRequestsApiProvider).setServiceActive(s.id!, v)),
                secondary: s.id == null
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.delete_outline),
                        onPressed: _busy ? null : () => _run(() => ref.read(stayRequestsApiProvider).removeService(s.id!)),
                      ),
              ),
          ],
        ),
      ),
    );
  }
}

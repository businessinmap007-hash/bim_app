import '../../../../shared/widgets/app_bar_tab_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../l10n/app_localizations.dart';
import '../../application/stay_requests_providers.dart';
import '../../data/models/stay_request.dart';
import '../widgets/stay_request_sheet.dart';
import 'stay_services_screen.dart';

/// «تصل لشاشة البزنس برقم الغرفة والطلب» — what the hotel's guests ask during their stays, oldest first, each with
/// the room number the hotel gave the stay and the buttons to work it through.
class StayRequestsScreen extends ConsumerWidget {
  const StayRequestsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.stayReqScreenTitle),
          actions: [
            IconButton(
              tooltip: l10n.stayReqManageServices,
              icon: const Icon(Icons.room_service_outlined),
              onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const StayServicesScreen())),
            ),
          ],
          bottom: AppBarTabBar(tabs: [Tab(text: l10n.stayReqTabOpen), Tab(text: l10n.stayReqTabDone)]),
        ),
        body: const TabBarView(children: [_RequestList(status: 'open'), _RequestList(status: 'done')]),
      ),
    );
  }
}

class _RequestList extends ConsumerWidget {
  final String status;
  const _RequestList({required this.status});

  Future<void> _move(BuildContext context, WidgetRef ref, StayRequest request, String next) async {
    final l10n = AppLocalizations.of(context)!;
    try {
      await ref.read(stayRequestsApiProvider).setStatus(request.id, next);
      ref.invalidate(hotelStayRequestsProvider('open'));
      ref.invalidate(hotelStayRequestsProvider('done'));
    } catch (e) {
      if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e is ApiException ? e.message : l10n.commonSomethingWentWrong)));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final async = ref.watch(hotelStayRequestsProvider(status));

    return async.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, _) => Center(child: Text(l10n.commonSomethingWentWrong)),
      data: (payload) {
        if (payload.requests.isEmpty) return Center(child: Text(l10n.stayReqEmpty));

        return RefreshIndicator(
          onRefresh: () async => ref.refresh(hotelStayRequestsProvider(status).future),
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: payload.requests.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (_, i) => _RequestCard(request: payload.requests[i], onMove: (next) => _move(context, ref, payload.requests[i], next)),
          ),
        );
      },
    );
  }
}

class _RequestCard extends StatelessWidget {
  final StayRequest request;
  final void Function(String next) onMove;
  const _RequestCard({required this.request, required this.onMove});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final room = request.roomNumber;
    final color = request.isIssue ? AppColors.error : theme.colorScheme.primary;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // the number is what the front desk reads first
                Expanded(
                  child: Text(
                    room != null ? l10n.stayReqRoom(room) : (request.unitTitle ?? l10n.stayReqNoRoom),
                    style: theme.textTheme.titleLarge,
                  ),
                ),
                Chip(
                  label: Text(request.isIssue ? l10n.stayReqKindIssue : l10n.stayReqKindService),
                  labelStyle: TextStyle(color: color, fontSize: 12),
                  side: BorderSide(color: color.withValues(alpha: 0.5)),
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(request.label, style: theme.textTheme.titleMedium),
            if (request.note != null && request.note!.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(request.note!, style: theme.textTheme.bodyMedium),
            ],
            const SizedBox(height: 8),
            Text(
              [if (request.guestName != null) request.guestName!, stayRequestStatusLabel(request.status, l10n)].join(' · '),
              style: theme.textTheme.bodySmall,
            ),
            if (request.isOpen) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  if (request.isNew) OutlinedButton(onPressed: () => onMove('in_progress'), child: Text(l10n.stayReqStart)),
                  FilledButton(onPressed: () => onMove('done'), child: Text(l10n.stayReqDone)),
                  TextButton(onPressed: () => onMove('cancelled'), child: Text(l10n.stayReqCannot)),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

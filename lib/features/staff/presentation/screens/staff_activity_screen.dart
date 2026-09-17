import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../../application/staff_activity_providers.dart';
import '../../data/models/staff_activity.dart';

/// The owner's end-of-shift review: every order/booking action a staff
/// member took, plus how many operations each of them ran in the selected
/// period. Owner-only — the backend rejects a staff caller here regardless
/// of capability, so this screen is reached only from the owner's own
/// Staff & permissions settings.
class StaffActivityScreen extends ConsumerStatefulWidget {
  const StaffActivityScreen({super.key});

  @override
  ConsumerState<StaffActivityScreen> createState() => _StaffActivityScreenState();
}

class _StaffActivityScreenState extends ConsumerState<StaffActivityScreen> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      ref.read(staffActivityControllerProvider.notifier).loadMore();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _pickDate({required bool isFrom}) async {
    final state = ref.read(staffActivityControllerProvider);
    final picked = await showDatePicker(
      context: context,
      initialDate: isFrom ? state.from : state.to,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked == null) return;
    final notifier = ref.read(staffActivityControllerProvider.notifier);
    await notifier.setRange(isFrom ? picked : state.from, isFrom ? state.to : picked);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final state = ref.watch(staffActivityControllerProvider);
    final dateFormat = DateFormat('yyyy-MM-dd');

    return Scaffold(
      appBar: AppBar(title: Text(l10n.staffActivityTitle)),
      body: RefreshIndicator(
        onRefresh: () => ref.read(staffActivityControllerProvider.notifier).load(),
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _DateField(
                            label: l10n.staffActivityFrom,
                            value: dateFormat.format(state.from),
                            onTap: () => _pickDate(isFrom: true),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _DateField(
                            label: l10n.staffActivityTo,
                            value: dateFormat.format(state.to),
                            onTap: () => _pickDate(isFrom: false),
                          ),
                        ),
                        const SizedBox(width: 8),
                        TextButton(
                          onPressed: () {
                            final now = DateTime.now();
                            ref.read(staffActivityControllerProvider.notifier).setRange(now, now);
                          },
                          child: Text(l10n.staffActivityToday),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<int?>(
                      initialValue: state.userId,
                      decoration: InputDecoration(
                        labelText: l10n.staffActivityStaffLabel,
                        isDense: true,
                      ),
                      items: [
                        DropdownMenuItem(value: null, child: Text(l10n.staffActivityAllStaff)),
                        for (final actor in state.summary)
                          DropdownMenuItem(
                            value: actor.userId,
                            child: Text(actor.isOwner ? '${actor.name} (${l10n.staffActivityOwnerBadge})' : actor.name),
                          ),
                      ],
                      onChanged: (value) => ref.read(staffActivityControllerProvider.notifier).setUserId(value),
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ),
            if (state.summary.isNotEmpty)
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    childAspectRatio: 1.9,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final entry = state.summary[index];
                      return _CountCard(
                        name: entry.name,
                        isOwner: entry.isOwner,
                        count: entry.count,
                        label: l10n.staffActivityOperationsCount(entry.count),
                      );
                    },
                    childCount: state.summary.length,
                  ),
                ),
              ),
            const SliverToBoxAdapter(child: SizedBox(height: 12)),
            if (state.isLoading && state.rows.isEmpty)
              const SliverFillRemaining(child: Center(child: CircularProgressIndicator()))
            else if (state.error != null && state.rows.isEmpty)
              SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(l10n.commonSomethingWentWrong),
                      const SizedBox(height: 8),
                      OutlinedButton(
                        onPressed: () => ref.read(staffActivityControllerProvider.notifier).load(),
                        child: Text(l10n.commonRetry),
                      ),
                    ],
                  ),
                ),
              )
            else if (state.rows.isEmpty)
              SliverFillRemaining(child: Center(child: Text(l10n.staffActivityEmpty)))
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                sliver: SliverList.separated(
                  itemCount: state.rows.length + (state.isLoadingMore ? 1 : 0),
                  separatorBuilder: (context, index) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    if (index >= state.rows.length) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }
                    return _ActivityTile(entry: state.rows[index]);
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _DateField extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback onTap;
  const _DateField({required this.label, required this.value, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: InputDecorator(
        decoration: InputDecoration(labelText: label, isDense: true),
        child: Text(value, style: const TextStyle(fontFeatures: [FontFeature.tabularFigures()])),
      ),
    );
  }
}

class _CountCard extends StatelessWidget {
  final String name;
  final bool isOwner;
  final int count;
  final String label;
  const _CountCard({required this.name, required this.isOwner, required this.count, required this.label});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Flexible(
                child: Text(
                  name,
                  style: Theme.of(context).textTheme.bodySmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (isOwner) ...[
                const SizedBox(width: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                  decoration: BoxDecoration(
                    color: AppColors.accentGold.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    l10n.staffActivityOwnerBadge,
                    style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.accentGold),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '$count',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
          ),
          Text(label, style: Theme.of(context).textTheme.bodySmall, maxLines: 1, overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }
}

class _ActivityTile extends StatelessWidget {
  final StaffActivityEntry entry;
  const _ActivityTile({required this.entry});

  static const _actionIcons = {
    'accepted': Icons.check_circle_outline,
    'rejected': Icons.cancel_outlined,
    'preparing': Icons.soup_kitchen_outlined,
    'ready': Icons.done_all,
    'completed': Icons.task_alt,
    'started': Icons.play_circle_outline,
    'confirmed': Icons.event_available_outlined,
    'item_unavailable': Icons.remove_shopping_cart_outlined,
  };

  String _singleActionLabel(AppLocalizations l10n, String action) => switch (action) {
    'accepted' => l10n.staffActivityActionAccepted,
    'rejected' => l10n.staffActivityActionRejected,
    'preparing' => l10n.staffActivityActionPreparing,
    'ready' => l10n.staffActivityActionReady,
    'completed' => l10n.staffActivityActionCompleted,
    'started' => l10n.staffActivityActionStarted,
    'confirmed' => l10n.staffActivityActionConfirmed,
    'item_unavailable' => l10n.staffActivityActionItemUnavailable,
    _ => action,
  };

  /// Every stage this one order/booking actually went through in the
  /// filtered window, chained in order — one order worked through
  /// accept → prepare → ready is one operation, not three separate cards.
  String _actionLabel(AppLocalizations l10n) =>
      entry.actions.map((a) => _singleActionLabel(l10n, a)).join(' ← ');

  String _subjectLabel(AppLocalizations l10n) =>
      entry.subjectType == 'order' ? l10n.staffActivitySubjectOrder : l10n.staffActivitySubjectBooking;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final timeFormat = DateFormat('yyyy-MM-dd HH:mm');

    return Card(
      margin: EdgeInsets.zero,
      child: ListTile(
        leading: Icon(_actionIcons[entry.actions.lastOrNull] ?? Icons.history),
        title: Row(
          children: [
            Flexible(child: Text(entry.userName, overflow: TextOverflow.ellipsis)),
            if (entry.isOwner) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                decoration: BoxDecoration(
                  color: AppColors.accentGold.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  l10n.staffActivityOwnerBadge,
                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.accentGold),
                ),
              ),
            ],
          ],
        ),
        subtitle: Text(_actionLabel(l10n)),
        trailing: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text('${_subjectLabel(l10n)} #${entry.subjectId}', style: Theme.of(context).textTheme.bodySmall),
            if (entry.createdAt != null)
              Text(timeFormat.format(entry.createdAt!), style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}

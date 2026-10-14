import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/app_localizations.dart';
import '../../network/api_exception.dart';
import '../assignee.dart';
import '../assignment_providers.dart';

/// What the picker returned: [assignee] null with [released] true = «بدون تعيين»; the sheet closed = no result at all.
class AssigneePick {
  final Assignee? assignee;
  const AssigneePick(this.assignee);

  bool get released => assignee == null;
}

/// «المسؤول: أحمد — حلاق أول» — one line, for any card of any business. Draws nothing when nobody is responsible.
class AssigneeLine extends StatelessWidget {
  final Assignee? assignee;
  const AssigneeLine(this.assignee, {super.key});

  @override
  Widget build(BuildContext context) {
    final who = assignee;
    if (who == null) return const SizedBox.shrink();
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Row(
      children: [
        Icon(Icons.badge_outlined, size: 16, color: theme.hintColor),
        const SizedBox(width: 6),
        Expanded(child: Text(l10n.assigneeLine(who.line), style: theme.textTheme.bodyMedium)),
      ],
    );
  }
}

/// The one control a business uses to hand a piece of work to someone: shows who is responsible (or that nobody is) and
/// opens the chooser. It never talks to a specific endpoint — [onAssign] does, so a booking, an order or anything
/// else uses the same widget:
///
///   AssigneeTile(
///     current: booking.assignee,
///     businessId: businessId,
///     onAssign: (id) => api.assignBooking(booking.id, id, businessId: businessId),
///     onChanged: reload,
///   )
///
/// Draws nothing when the business has no providers and nobody is assigned — a business that never marked a provider is
/// not asked about them.
class AssigneeTile extends ConsumerStatefulWidget {
  final Assignee? current;
  final int? businessId;

  /// Performs the assignment (null = release) and returns who is responsible afterwards.
  final Future<Assignee?> Function(int? assigneeId) onAssign;

  /// Called after a successful change — reload what shows the assignee.
  final VoidCallback? onChanged;

  const AssigneeTile({super.key, required this.current, required this.onAssign, this.businessId, this.onChanged});

  @override
  ConsumerState<AssigneeTile> createState() => _AssigneeTileState();
}

class _AssigneeTileState extends ConsumerState<AssigneeTile> {
  bool _busy = false;

  Future<void> _choose(List<Assignee> options) async {
    final pick = await showAssigneePicker(context, options: options, selectedId: widget.current?.id);
    if (pick == null || !mounted) return;
    if (pick.assignee?.id == widget.current?.id) return;

    final l10n = AppLocalizations.of(context)!;
    setState(() => _busy = true);
    try {
      await widget.onAssign(pick.assignee?.id);
      widget.onChanged?.call();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e is ApiException ? e.message : l10n.commonSomethingWentWrong)));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final providers = ref.watch(businessProvidersProvider(widget.businessId));
    final options = providers.valueOrNull ?? const <Assignee>[];
    final current = widget.current;

    if (options.isEmpty && current == null) return const SizedBox.shrink();

    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: const Icon(Icons.badge_outlined),
      title: Text(l10n.assigneeTitle),
      subtitle: Text(current?.line ?? l10n.assigneeNobody),
      trailing: _busy
          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
          : options.isEmpty
          ? null
          : TextButton(
              onPressed: () => _choose(options),
              child: Text(current == null ? l10n.assigneeAssign : l10n.assigneeChange),
            ),
    );
  }
}

/// The chooser: every provider with his title, plus «بدون تعيين». Returns null when the sheet is dismissed.
Future<AssigneePick?> showAssigneePicker(
  BuildContext context, {
  required List<Assignee> options,
  int? selectedId,
}) {
  return showModalBottomSheet<AssigneePick>(
    context: context,
    showDragHandle: true,
    builder: (context) {
      final l10n = AppLocalizations.of(context)!;
      return SafeArea(
        child: ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          children: [
            Text(l10n.assigneePickTitle, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            for (final option in options)
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: CircleAvatar(
                  backgroundImage: option.logoUrl != null ? NetworkImage(option.logoUrl!) : null,
                  child: option.logoUrl == null ? const Icon(Icons.person_outline) : null,
                ),
                title: Text(option.name),
                subtitle: option.title == null ? null : Text(option.title!),
                trailing: option.id == selectedId ? const Icon(Icons.check_rounded) : null,
                onTap: () => Navigator.of(context).pop(AssigneePick(option)),
              ),
            if (selectedId != null)
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.person_off_outlined),
                title: Text(l10n.assigneeRelease),
                onTap: () => Navigator.of(context).pop(const AssigneePick(null)),
              ),
          ],
        ),
      );
    },
  );
}

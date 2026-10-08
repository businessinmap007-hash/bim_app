import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/widgets/async_value_view.dart';
import '../../application/hospital_providers.dart';
import '../../data/models/hospital_department.dart';

/// The doctor's side of «الأطباء تحت الأقسام»: the hospitals that asked to list this doctor under a department (accept
/// or decline), and where the doctor is listed already (end it any time).
class HospitalInvitationsScreen extends ConsumerWidget {
  const HospitalInvitationsScreen({super.key});

  Future<void> _act(BuildContext context, WidgetRef ref, Future<Object?> Function() action) async {
    final l10n = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.of(context);
    try {
      await action();
      ref.invalidate(hospitalInvitationsProvider);
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(e is ApiException && e.message.isNotEmpty ? e.message : l10n.commonSomethingWentWrong)));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final api = ref.read(hospitalApiProvider);
    final async = ref.watch(hospitalInvitationsProvider);

    String line(HospitalInvitation i) => i.department.isEmpty ? i.hospitalName : '${i.hospitalName} — ${i.department}';

    return Scaffold(
      appBar: AppBar(title: Text(l10n.hospitalInvitationsTitle)),
      body: AsyncValueView(
        value: async,
        onRetry: () => ref.invalidate(hospitalInvitationsProvider),
        builder: (context, data) {
          if (data.pending.isEmpty && data.active.isEmpty) return Center(child: Text(l10n.hospitalInvitationsEmpty));

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (data.pending.isNotEmpty) ...[
                Text(l10n.hospitalInvitationPendingSection, style: theme.textTheme.titleSmall),
                const SizedBox(height: 8),
                for (final i in data.pending)
                  Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(line(i), style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600)),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Expanded(child: FilledButton(onPressed: () => _act(context, ref, () => api.accept(i.id)), child: Text(l10n.hospitalInvitationAccept))),
                              const SizedBox(width: 8),
                              OutlinedButton(onPressed: () => _act(context, ref, () => api.leave(i.id)), child: Text(l10n.hospitalInvitationDecline)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                const SizedBox(height: 12),
              ],
              if (data.active.isNotEmpty) ...[
                Text(l10n.hospitalInvitationActiveSection, style: theme.textTheme.titleSmall),
                const SizedBox(height: 8),
                for (final i in data.active)
                  Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: const Icon(Icons.local_hospital_outlined),
                      title: Text(line(i)),
                      trailing: TextButton(onPressed: () => _act(context, ref, () => api.leave(i.id)), child: Text(l10n.hospitalInvitationLeave)),
                    ),
                  ),
              ],
            ],
          );
        },
      ),
    );
  }
}

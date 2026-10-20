import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../staff/application/staff_providers.dart';
import '../../application/customer_project_providers.dart';
import '../screens/project_detail_screen.dart';
import '../screens/project_progress_screen.dart';
import '../screens/projects_screen.dart';

/// The project card at the top of an order's / booking's chat: where the work stands — percent, the stage in hand, who is
/// on it, and a nudge when a stage waits for the customer's approval. Tapping opens the full progress (the customer) or the
/// project itself (the business). A business that has no project for this operation yet and offers the service sees «ابدأ
/// مشروعًا»; everybody else sees nothing.
class ProjectChatCard extends ConsumerWidget {
  final String operationType;
  final int operationId;
  const ProjectChatCard({super.key, required this.operationType, required this.operationId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (operationType != 'order' && operationType != 'booking') return const SizedBox.shrink();

    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final key = OperationKey(operationType, operationId);
    final view = ref.watch(customerProjectViewProvider(key)).valueOrNull;

    if (view == null) {
      return _StartCard(operationType: operationType, operationId: operationId);
    }

    final stage = view.currentStage;
    final waiting = view.waitingForApproval;

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
      child: Material(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => view.viewerIsBusiness
                  ? ProjectDetailScreen(projectId: view.project.id)
                  : ProjectProgressScreen(operationType: operationType, operationId: operationId),
            ),
          ),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: theme.dividerColor),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(child: Text(view.project.title, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700))),
                    Text('${view.project.progress}%', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
                  ],
                ),
                const SizedBox(height: 6),
                LinearProgressIndicator(value: view.project.progress / 100),
                if (stage != null) ...[
                  const SizedBox(height: 6),
                  Text(
                    stage.assignee == null
                        ? l10n.projectCardStage(stage.title)
                        : l10n.projectCardStageBy(stage.title, stage.assignee!.name),
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
                if (waiting > 0 && !view.viewerIsBusiness)
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(l10n.projectCardWaiting(waiting), style: TextStyle(color: theme.colorScheme.secondary, fontWeight: FontWeight.w700)),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// «ابدأ مشروعًا» — only for the operation's business, and only when it offers the service.
class _StartCard extends ConsumerWidget {
  final String operationType;
  final int operationId;
  const _StartCard({required this.operationType, required this.operationId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final offers = ref.watch(myServiceKeysProvider).valueOrNull?.contains('projects') ?? false;
    if (!offers) return const SizedBox.shrink();

    final key = OperationKey(operationType, operationId);
    final viewer = ref.watch(operationViewerProvider(key)).valueOrNull;
    if (viewer != 'business') return const SizedBox.shrink();

    final l10n = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
      child: OutlinedButton.icon(
        icon: const Icon(Icons.account_tree_outlined, size: 18),
        onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => ProjectsScreen(linkTo: key))),
        label: Text(l10n.projectStartForOperation),
      ),
    );
  }
}

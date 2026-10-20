import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../l10n/app_localizations.dart';
import '../../application/projects_providers.dart';
import '../../data/models/project_showcase.dart';
import 'project_agreement_widgets.dart';

/// «موثَّق من العميل»: the results card a post carries — the percentage the customer confirmed, each main stage with its share and
/// the date he last approved inside it, and (if he agreed) the camera photos of what he approved. It names nobody and nothing.
class ShowcaseResultsCard extends StatelessWidget {
  final PostShowcase showcase;

  const ShowcaseResultsCard({super.key, required this.showcase});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.success.withValues(alpha: 0.07),
        border: Border.all(color: AppColors.success.withValues(alpha: 0.35)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.verified_outlined, size: 18, color: AppColors.success),
              const SizedBox(width: 6),
              Expanded(child: Text(l10n.showcaseVerifiedBadge, style: theme.textTheme.labelLarge?.copyWith(color: AppColors.success, fontWeight: FontWeight.w700))),
              Text('${showcase.progress}%', style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800)),
            ],
          ),
          const SizedBox(height: 6),
          LinearProgressIndicator(value: showcase.progress / 100, minHeight: 6, color: AppColors.success),
          const SizedBox(height: 8),
          for (final s in showcase.stages)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 3),
              child: Row(
                children: [
                  Expanded(child: Text(s.title, style: theme.textTheme.bodyMedium)),
                  if (s.confirmedOn != null) Text(projectDate(context, s.confirmedOn), style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor)),
                  const SizedBox(width: 8),
                  SizedBox(width: 44, child: Text('${s.progress}%', textAlign: TextAlign.end, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700))),
                ],
              ),
            ),
          if (showcase.photos.isNotEmpty) ...[
            const SizedBox(height: 8),
            SizedBox(
              height: 84,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: showcase.photos.length,
                separatorBuilder: (_, _) => const SizedBox(width: 6),
                itemBuilder: (context, i) => ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(showcase.photos[i].url, width: 112, height: 84, fit: BoxFit.cover, errorBuilder: (_, _, _) => const SizedBox(width: 112)),
                ),
              ),
            ),
          ],
          if (showcase.updatedOn != null) ...[
            const SizedBox(height: 6),
            Text(l10n.showcaseUpdatedOn(projectDate(context, showcase.updatedOn)), style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor)),
          ],
        ],
      ),
    );
  }
}

String _msg(Object e, AppLocalizations l10n) => e is ApiException && e.message.isNotEmpty ? e.message : l10n.commonSomethingWentWrong;

/// The business's side: ask the customer to let the project be shown, see where the request stands, take it down.
class BusinessShowcasePanel extends ConsumerWidget {
  final int projectId;

  const BusinessShowcasePanel({super.key, required this.projectId});

  Future<void> _ask(BuildContext context, WidgetRef ref, String projectTitle) async {
    final l10n = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.of(context);
    final title = TextEditingController(text: projectTitle);
    final note = TextEditingController();
    bool photos = false;

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: Text(l10n.showcaseAskTitle),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.showcaseAskHint, style: Theme.of(ctx).textTheme.bodySmall),
                const SizedBox(height: 8),
                TextField(controller: title, decoration: InputDecoration(labelText: l10n.showcasePublicTitle)),
                TextField(controller: note, minLines: 2, maxLines: 4, decoration: InputDecoration(labelText: l10n.showcaseNote)),
                SwitchListTile(contentPadding: EdgeInsets.zero, value: photos, onChanged: (v) => setState(() => photos = v), title: Text(l10n.showcaseShowPhotos)),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: Text(l10n.commonCancel)),
            FilledButton(onPressed: () => Navigator.of(ctx).pop(true), child: Text(l10n.commonSubmit)),
          ],
        ),
      ),
    );
    if (ok != true || title.text.trim().isEmpty) return;

    try {
      await ref.read(projectsApiProvider).requestShowcase(projectId, publicTitle: title.text.trim(), note: note.text.trim(), showPhotos: photos);
      ref.invalidate(projectShowcaseProvider(projectId));
      messenger.showSnackBar(SnackBar(content: Text(l10n.showcaseRequestSent)));
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(_msg(e, l10n))));
    }
  }

  Future<void> _withdraw(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.of(context);

    try {
      await ref.read(projectsApiProvider).withdrawShowcase(projectId);
      ref.invalidate(projectShowcaseProvider(projectId));
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(_msg(e, l10n))));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final project = ref.watch(projectDetailControllerProvider(projectId)).project;
    final async = ref.watch(projectShowcaseProvider(projectId));

    return async.when(
      loading: () => const SizedBox.shrink(),
      error: (_, _) => const SizedBox.shrink(),
      data: (s) {
        if (s == null || s.canAsk) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (s != null)
                Text(
                  s.status == 'declined' ? l10n.showcaseDeclined((s.decisionNote ?? '').isEmpty ? '—' : s.decisionNote!) : l10n.showcaseWithdrawn,
                  style: theme.textTheme.bodySmall?.copyWith(color: AppColors.error),
                ),
              OutlinedButton.icon(
                icon: const Icon(Icons.campaign_outlined),
                onPressed: () => _ask(context, ref, project?.title ?? ''),
                label: Text(l10n.showcaseAskAction),
              ),
            ],
          );
        }

        return Card(
          margin: EdgeInsets.zero,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(s.publicTitle, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
                Text(s.isLive ? l10n.showcaseLive : l10n.showcaseWaiting, style: TextStyle(color: s.isLive ? AppColors.success : AppColors.accentGold, fontWeight: FontWeight.w600)),
                const SizedBox(height: 6),
                OutlinedButton(onPressed: () => _withdraw(context, ref), child: Text(s.isLive ? l10n.showcaseTakeDown : l10n.showcaseCancelRequest)),
              ],
            ),
          ),
        );
      },
    );
  }
}

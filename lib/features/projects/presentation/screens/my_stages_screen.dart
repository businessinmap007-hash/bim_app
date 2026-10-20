import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../media/application/media_picker_service.dart';
import '../../application/projects_providers.dart';
import '../../data/models/project_template.dart';

/// «مراحلي» — the stages of projects that were handed to me at one business: what I do today. For each, the live camera
/// (the evidence the customer sees), the progress, and «تم» when it is finished. A stage the customer sent back shows
/// his note.
class MyStagesScreen extends ConsumerWidget {
  final int businessId;
  const MyStagesScreen({super.key, required this.businessId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final async = ref.watch(myStagesProvider(businessId));

    return Scaffold(
      appBar: AppBar(title: Text(l10n.myStagesTitle)),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(l10n.commonSomethingWentWrong),
              const SizedBox(height: 8),
              OutlinedButton(onPressed: () => ref.invalidate(myStagesProvider(businessId)), child: Text(l10n.commonRetry)),
            ],
          ),
        ),
        data: (stages) => RefreshIndicator(
          onRefresh: () async => ref.invalidate(myStagesProvider(businessId)),
          child: stages.isEmpty
              ? ListView(children: [const SizedBox(height: 120), Center(child: Text(l10n.myStagesEmpty))])
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: stages.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (_, i) => _StageCard(stage: stages[i], businessId: businessId),
                ),
        ),
      ),
    );
  }
}

class _StageCard extends ConsumerStatefulWidget {
  final MyStage stage;
  final int businessId;
  const _StageCard({required this.stage, required this.businessId});

  @override
  ConsumerState<_StageCard> createState() => _StageCardState();
}

class _StageCardState extends ConsumerState<_StageCard> {
  bool _busy = false;

  Future<void> _run(Future<void> Function() action) async {
    final messenger = ScaffoldMessenger.of(context);
    final fallback = AppLocalizations.of(context)!.commonSomethingWentWrong;
    setState(() => _busy = true);
    try {
      await action();
      ref.invalidate(myStagesProvider(widget.businessId));
    } on ApiException catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(e.message)));
    } catch (_) {
      messenger.showSnackBar(SnackBar(content: Text(fallback)));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _photo() => _run(() async {
    final shot = await MediaPickerService().pickFromCamera();
    if (shot == null) return;
    final bytes = await shot.file.readAsBytes();
    await ref.read(projectsApiProvider).uploadPhoto(widget.stage.projectId, widget.stage.id, bytes, businessId: widget.businessId);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.myStagesPhotoSaved)));
    }
  });

  Future<void> _done() => _run(() => ref.read(projectsApiProvider).updateTaskProgress(
    widget.stage.projectId,
    widget.stage.id,
    status: 'done',
    businessId: widget.businessId,
  ));

  Future<void> _progress(int value) => _run(() => ref.read(projectsApiProvider).updateTaskProgress(
    widget.stage.projectId,
    widget.stage.id,
    progress: value,
    businessId: widget.businessId,
  ));

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final s = widget.stage;

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(s.projectTitle, style: theme.textTheme.bodySmall),
            const SizedBox(height: 2),
            Text(s.title, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
            if (s.sentBack) ...[
              const SizedBox(height: 6),
              Text(
                l10n.approvalRejectedWithNote(s.approvalNote ?? ''),
                style: const TextStyle(color: AppColors.error, fontWeight: FontWeight.w600),
              ),
            ],
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(child: LinearProgressIndicator(value: s.progress / 100)),
                const SizedBox(width: 10),
                Text('${s.progress}%', style: theme.textTheme.titleSmall),
              ],
            ),
            if (s.endsOn != null) ...[
              const SizedBox(height: 4),
              Text(l10n.myStagesDue(s.endsOn!), style: theme.textTheme.bodySmall),
            ],
            const SizedBox(height: 10),
            if (_busy)
              const Center(child: Padding(padding: EdgeInsets.all(4), child: CircularProgressIndicator()))
            else
              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: [
                  FilledButton.icon(
                    icon: const Icon(Icons.photo_camera_outlined, size: 18),
                    onPressed: _photo,
                    label: Text(l10n.taskTakePhoto),
                  ),
                  OutlinedButton(onPressed: () => _progress((s.progress + 25).clamp(0, 99)), child: Text(l10n.myStagesPlus25)),
                  OutlinedButton(onPressed: _done, child: Text(l10n.taskMarkDone)),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

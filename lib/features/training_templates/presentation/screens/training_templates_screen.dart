import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../l10n/app_localizations.dart';
import '../../application/training_templates_providers.dart';
import '../../data/models/training_template.dart';
import 'training_template_edit_screen.dart';

/// Api\V2\TrainingTemplateController — a trainer's reusable plan library:
/// build once, edit anytime. Applying a template to a client isn't wired up
/// (needs a client_id with no picker anywhere in the app) — this is purely
/// build-and-maintain.
class TrainingTemplatesScreen extends ConsumerStatefulWidget {
  const TrainingTemplatesScreen({super.key});

  @override
  ConsumerState<TrainingTemplatesScreen> createState() => _TrainingTemplatesScreenState();
}

class _TrainingTemplatesScreenState extends ConsumerState<TrainingTemplatesScreen> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      ref.read(trainingTemplatesControllerProvider.notifier).loadMore();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _openCreate() async {
    final l10n = AppLocalizations.of(context)!;
    final titleController = TextEditingController();
    final goalController = TextEditingController();
    String? error;
    var saving = false;

    final createdId = await showModalBottomSheet<int>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) => StatefulBuilder(
        builder: (sheetContext, setSheetState) => Padding(
          padding: EdgeInsets.fromLTRB(20, 20, 20, 20 + MediaQuery.of(sheetContext).viewInsets.bottom),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.trainingTemplateAddTitle, style: Theme.of(sheetContext).textTheme.titleMedium),
                const SizedBox(height: 16),
                TextField(
                  controller: titleController,
                  decoration: InputDecoration(labelText: l10n.trainingTemplateTitleHint),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: goalController,
                  decoration: InputDecoration(labelText: l10n.trainingTemplateGoalHint),
                ),
                if (error != null) ...[
                  const SizedBox(height: 8),
                  Text(error!, style: TextStyle(color: Theme.of(sheetContext).colorScheme.error)),
                ],
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: saving
                      ? null
                      : () async {
                          if (titleController.text.trim().isEmpty) {
                            setSheetState(() => error = l10n.validationRequired);
                            return;
                          }
                          setSheetState(() => saving = true);
                          try {
                            final created = await ref
                                .read(trainingTemplatesApiProvider)
                                .create(title: titleController.text.trim(), goal: goalController.text.trim());
                            if (sheetContext.mounted) Navigator.of(sheetContext).pop(created.id);
                          } catch (e) {
                            setSheetState(() {
                              saving = false;
                              error = e is ApiException ? e.message : l10n.commonSomethingWentWrong;
                            });
                          }
                        },
                  child: saving
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                      : Text(l10n.commonSave),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    if (createdId != null && mounted) {
      ref.read(trainingTemplatesControllerProvider.notifier).load();
      await Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => TrainingTemplateEditScreen(templateId: createdId)),
      );
      if (mounted) ref.read(trainingTemplatesControllerProvider.notifier).load();
    }
  }

  Future<void> _delete(TrainingTemplate template) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        content: Text(l10n.trainingTemplateDeleteConfirm),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text(l10n.commonCancel)),
          TextButton(onPressed: () => Navigator.pop(context, true), child: Text(l10n.commonDelete)),
        ],
      ),
    );
    if (confirmed == true) {
      await ref.read(trainingTemplatesControllerProvider.notifier).delete(template.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final state = ref.watch(trainingTemplatesControllerProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.trainingTemplatesTitle)),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openCreate,
        icon: const Icon(Icons.add),
        label: Text(l10n.trainingTemplateAdd),
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : state.error != null
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(l10n.commonSomethingWentWrong),
                  const SizedBox(height: 8),
                  OutlinedButton(
                    onPressed: () => ref.read(trainingTemplatesControllerProvider.notifier).load(),
                    child: Text(l10n.commonRetry),
                  ),
                ],
              ),
            )
          : state.items.isEmpty
          ? Center(child: Text(l10n.trainingTemplatesEmpty))
          : RefreshIndicator(
              onRefresh: () => ref.read(trainingTemplatesControllerProvider.notifier).load(),
              child: ListView.separated(
                controller: _scrollController,
                padding: const EdgeInsets.all(16),
                itemCount: state.items.length + (state.isLoadingMore ? 1 : 0),
                separatorBuilder: (context, index) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  if (index >= state.items.length) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }
                  final template = state.items[index];
                  return Card(
                    margin: EdgeInsets.zero,
                    child: ListTile(
                      leading: const Icon(Icons.fitness_center_outlined),
                      title: Text(template.title),
                      subtitle: Text(
                        [
                          if (template.goal != null && template.goal!.isNotEmpty) template.goal,
                          '${template.exercisesCount ?? 0} · ${template.mealsCount ?? 0}',
                        ].whereType<String>().join(' · '),
                      ),
                      onTap: () async {
                        await Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => TrainingTemplateEditScreen(templateId: template.id)),
                        );
                        ref.read(trainingTemplatesControllerProvider.notifier).load();
                      },
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () => _delete(template),
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }
}

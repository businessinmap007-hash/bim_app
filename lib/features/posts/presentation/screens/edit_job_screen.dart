import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../l10n/app_localizations.dart';
import '../../application/posts_controller.dart';
import '../../data/models/job_post.dart';

/// Edits an existing vacancy (title/body/requirements/salary). The field
/// (category/child) is never shown here, same as [CreateJobScreen] — it's
/// the posting business's own field, not an editable choice.
class EditJobScreen extends ConsumerStatefulWidget {
  final JobPost job;

  const EditJobScreen({super.key, required this.job});

  @override
  ConsumerState<EditJobScreen> createState() => _EditJobScreenState();
}

class _EditJobScreenState extends ConsumerState<EditJobScreen> {
  late final _titleController = TextEditingController(text: widget.job.title);
  late final _bodyController = TextEditingController(text: widget.job.body ?? '');
  late final _requirementsController = TextEditingController(text: widget.job.requirements ?? '');
  late final _salaryController = TextEditingController(text: widget.job.salary ?? '');
  bool _busy = false;

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    _requirementsController.dispose();
    _salaryController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context)!;
    final title = _titleController.text.trim();
    final body = _bodyController.text.trim();
    if (title.isEmpty || body.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.validationRequired)));
      return;
    }

    setState(() => _busy = true);
    try {
      await ref.read(postsApiProvider).updateJob(
            widget.job.id,
            title: title,
            body: body,
            requirements: _requirementsController.text.trim(),
            salary: _salaryController.text.trim(),
          );
      ref.read(myJobsControllerProvider.notifier).load();
      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        final message = e is ApiException ? e.message : l10n.commonSomethingWentWrong;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.postsEdit),
        actions: [
          TextButton(
            onPressed: _busy ? null : _save,
            child: _busy
                ? const SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : Text(l10n.commonSave, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(controller: _titleController, decoration: InputDecoration(labelText: l10n.jobsTitleLabel)),
          const SizedBox(height: 12),
          TextField(
            controller: _bodyController,
            maxLines: 5,
            decoration: InputDecoration(labelText: l10n.jobsBodyLabel),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _requirementsController,
            maxLines: 3,
            decoration: InputDecoration(labelText: l10n.jobsRequirementsLabel),
          ),
          const SizedBox(height: 12),
          TextField(controller: _salaryController, decoration: InputDecoration(labelText: l10n.jobsSalaryLabel)),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: _busy ? null : _save,
            child: _busy
                ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2))
                : Text(l10n.commonSave),
          ),
        ],
      ),
    );
  }
}

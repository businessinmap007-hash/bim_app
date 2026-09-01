import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../categories/presentation/widgets/category_picker_field.dart';
import '../../application/posts_controller.dart';

/// A business advertises a vacancy — field (root + specialty), title, body,
/// plus optional requirements/salary. Mirrors CreatePostScreen's shape
/// (title/body + a publish action in the AppBar) since both write to the
/// same underlying `posts` table with `type` deciding which this is.
class CreateJobScreen extends ConsumerStatefulWidget {
  const CreateJobScreen({super.key});

  @override
  ConsumerState<CreateJobScreen> createState() => _CreateJobScreenState();
}

class _CreateJobScreenState extends ConsumerState<CreateJobScreen> {
  CategorySelection? _category;
  final _titleController = TextEditingController();
  final _bodyController = TextEditingController();
  final _requirementsController = TextEditingController();
  final _salaryController = TextEditingController();
  bool _busy = false;
  String? _categoryError;

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    _requirementsController.dispose();
    _salaryController.dispose();
    super.dispose();
  }

  Future<void> _publish() async {
    final l10n = AppLocalizations.of(context)!;
    final category = _category;
    final title = _titleController.text.trim();
    final body = _bodyController.text.trim();

    setState(() => _categoryError = category == null ? l10n.validationRequired : null);
    if (category == null || title.isEmpty || body.isEmpty) return;

    setState(() => _busy = true);
    try {
      await ref
          .read(postsApiProvider)
          .createJob(
            categoryId: category.rootId!,
            categoryChildId: category.childId,
            title: title,
            body: body,
            requirements: _requirementsController.text.trim(),
            salary: _salaryController.text.trim(),
          );
      if (mounted) Navigator.of(context).pop(true);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.commonSomethingWentWrong)));
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
        title: Text(l10n.jobsCreateTitle),
        actions: [
          TextButton(
            onPressed: _busy ? null : _publish,
            child: _busy
                ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : Text(l10n.postsPublish, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          CategoryPickerField(
            value: _category,
            errorText: _categoryError,
            onChanged: (selection) => setState(() {
              _category = selection;
              _categoryError = null;
            }),
          ),
          const SizedBox(height: 12),
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
        ],
      ),
    );
  }
}

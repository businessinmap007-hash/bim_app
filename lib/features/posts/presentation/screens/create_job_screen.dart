import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../auth/application/auth_controller.dart';
import '../../application/posts_controller.dart';

/// A business advertises a vacancy — title, body, plus optional
/// requirements/salary. Mirrors CreatePostScreen's shape (title/body + a
/// publish action in the AppBar) since both write to the same underlying
/// `posts` table with `type` deciding which this is.
///
/// The job's field (root + specialty) is the posting business's own
/// category — every business has one (required to become a business at
/// all, see ProfileController::update's self-upgrade check on the
/// backend) — not a separate choice on this screen. A vacancy IS what that
/// business does; there's nothing to ask.
class CreateJobScreen extends ConsumerStatefulWidget {
  const CreateJobScreen({super.key});

  @override
  ConsumerState<CreateJobScreen> createState() => _CreateJobScreenState();
}

class _CreateJobScreenState extends ConsumerState<CreateJobScreen> {
  final _titleController = TextEditingController();
  final _bodyController = TextEditingController();
  final _requirementsController = TextEditingController();
  final _salaryController = TextEditingController();
  bool _busy = false;

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
    final title = _titleController.text.trim();
    final body = _bodyController.text.trim();
    if (title.isEmpty || body.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.validationRequired)));
      return;
    }

    final authState = ref.read(authControllerProvider);
    final me = authState is AuthSignedIn ? authState.user : null;
    final categoryId = me?.categoryId;
    if (categoryId == null) {
      // Can't happen for a real business account (see class doc), but
      // fail loudly rather than send an invalid categoryId to the server.
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.commonSomethingWentWrong)));
      return;
    }

    setState(() => _busy = true);
    try {
      await ref
          .read(postsApiProvider)
          .createJob(
            categoryId: categoryId,
            categoryChildId: me?.categoryChildId,
            title: title,
            body: body,
            requirements: _requirementsController.text.trim(),
            salary: _salaryController.text.trim(),
          );
      if (mounted) Navigator.of(context).pop(true);
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
        title: Text(l10n.jobsCreateTitle),
        actions: [
          TextButton(
            onPressed: _busy ? null : _publish,
            child: _busy
                ? SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Theme.of(context).appBarTheme.foregroundColor,
                    ),
                  )
                : Text(
                    l10n.postsPublish,
                    style: TextStyle(
                      color: Theme.of(context).appBarTheme.foregroundColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
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
            onPressed: _busy ? null : _publish,
            child: _busy
                ? const SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(l10n.jobsPublishAction),
          ),
        ],
      ),
    );
  }
}

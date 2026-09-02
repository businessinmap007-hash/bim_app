import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../l10n/app_localizations.dart';
import '../../application/jobs_providers.dart';

class JobDetailScreen extends ConsumerStatefulWidget {
  final int jobId;
  const JobDetailScreen({super.key, required this.jobId});

  @override
  ConsumerState<JobDetailScreen> createState() => _JobDetailScreenState();
}

class _JobDetailScreenState extends ConsumerState<JobDetailScreen> {
  bool _busy = false;
  bool _applied = false;

  Future<void> _apply() async {
    final l10n = AppLocalizations.of(context)!;
    setState(() => _busy = true);
    try {
      await ref.read(jobsApiProvider).apply(widget.jobId);
      if (mounted) {
        setState(() {
          _applied = true;
          _busy = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.jobApplied)));
      }
    } catch (e) {
      if (mounted) {
        setState(() => _busy = false);
        final message = e is ApiException ? e.message : l10n.commonSomethingWentWrong;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final async = ref.watch(jobDetailProvider(widget.jobId));

    return async.when(
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (_, _) => Scaffold(
        appBar: AppBar(),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(l10n.commonSomethingWentWrong),
              const SizedBox(height: 8),
              OutlinedButton(
                onPressed: () => ref.invalidate(jobDetailProvider(widget.jobId)),
                child: Text(l10n.commonRetry),
              ),
            ],
          ),
        ),
      ),
      data: (job) => Scaffold(
        appBar: AppBar(title: Text(job.title)),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: CircleAvatar(
                backgroundImage: job.business?.logoUrl != null ? NetworkImage(job.business!.logoUrl!) : null,
                child: job.business?.logoUrl == null ? const Icon(Icons.storefront_outlined) : null,
              ),
              title: Text(job.business?.name ?? ''),
              subtitle: Text(job.categoryChild?.name ?? job.category?.name ?? ''),
            ),
            const SizedBox(height: 8),
            if (job.salary != null && job.salary!.isNotEmpty)
              Text('${l10n.jobSalaryLabel}: ${job.salary}'),
            if (job.interviewStartsAt != null)
              Text('${l10n.jobInterviewLabel}: ${_formatDate(job.interviewStartsAt!)}'),
            Text('${job.applicantsCount} ${l10n.jobApplicantsLabel}'),
            if (job.body != null && job.body!.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(job.body!),
            ],
            if (job.requirements != null && job.requirements!.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(l10n.jobRequirementsLabel, style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 4),
              Text(job.requirements!),
            ],
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _busy || _applied ? null : _apply,
              child: _busy
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                  : Text(_applied ? l10n.jobApplied : l10n.jobApply),
            ),
          ],
        ),
      ),
    );
  }
}

String _formatDate(DateTime dt) {
  final d = dt.toLocal();
  return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')} '
      '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
}

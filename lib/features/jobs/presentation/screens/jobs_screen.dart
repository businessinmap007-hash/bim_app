import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../posts/data/models/job_post.dart';
import '../../application/jobs_providers.dart';
import 'job_detail_screen.dart';
import 'job_follows_screen.dart';

/// Browse open vacancies (public GET /jobs) and apply. Posting a job,
/// reviewing applicants, and closing a job are the business's own actions —
/// already wired elsewhere (PostsApi.createJob/mineJobs) — out of scope here.
class JobsScreen extends ConsumerStatefulWidget {
  const JobsScreen({super.key});

  @override
  ConsumerState<JobsScreen> createState() => _JobsScreenState();
}

class _JobsScreenState extends ConsumerState<JobsScreen> {
  final _scrollController = ScrollController();
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      ref.read(jobsControllerProvider.notifier).loadMore();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final state = ref.watch(jobsControllerProvider);
    final categoriesAsync = ref.watch(jobCategoriesProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.jobsTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none),
            tooltip: l10n.jobFollowsTitle,
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const JobFollowsScreen()),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: l10n.jobsSearchHint,
                prefixIcon: const Icon(Icons.search),
                isDense: true,
                suffixIcon: IconButton(
                  icon: const Icon(Icons.arrow_forward),
                  onPressed: () => ref.read(jobsControllerProvider.notifier).setQuery(_searchController.text),
                ),
              ),
              textInputAction: TextInputAction.search,
              onSubmitted: (q) => ref.read(jobsControllerProvider.notifier).setQuery(q),
            ),
          ),
          categoriesAsync.when(
            loading: () => const SizedBox.shrink(),
            error: (_, _) => const SizedBox.shrink(),
            data: (categories) => SizedBox(
              height: 44,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(l10n.jobsAllCategories),
                      selected: state.categoryId == null,
                      onSelected: (_) => ref.read(jobsControllerProvider.notifier).filterByCategory(),
                    ),
                  ),
                  for (final cat in categories)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text('${cat.name ?? ''} (${cat.jobsCount})'),
                        selected: state.categoryId == cat.id && state.categoryChildId == null,
                        onSelected: (_) =>
                            ref.read(jobsControllerProvider.notifier).filterByCategory(categoryId: cat.id),
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: state.isLoading
                ? const Center(child: CircularProgressIndicator())
                : state.error != null
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(l10n.commonSomethingWentWrong),
                        const SizedBox(height: 8),
                        OutlinedButton(
                          onPressed: () => ref.read(jobsControllerProvider.notifier).load(),
                          child: Text(l10n.commonRetry),
                        ),
                      ],
                    ),
                  )
                : state.items.isEmpty
                ? Center(child: Text(l10n.jobsEmpty))
                : RefreshIndicator(
                    onRefresh: () => ref.read(jobsControllerProvider.notifier).load(),
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
                        final job = state.items[index];
                        return _JobTile(
                          job: job,
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => JobDetailScreen(jobId: job.id)),
                          ),
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _JobTile extends StatelessWidget {
  final JobPost job;
  final VoidCallback onTap;
  const _JobTile({required this.job, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Card(
      margin: EdgeInsets.zero,
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          backgroundImage: job.business?.logoUrl != null ? NetworkImage(job.business!.logoUrl!) : null,
          child: job.business?.logoUrl == null ? const Icon(Icons.work_outline) : null,
        ),
        title: Text(job.title, maxLines: 1, overflow: TextOverflow.ellipsis),
        subtitle: Text(
          [
            job.business?.name,
            job.categoryChild?.name ?? job.category?.name,
            if (job.salary != null && job.salary!.isNotEmpty) job.salary,
          ].whereType<String>().join(' · '),
        ),
        trailing: Text('${job.applicantsCount} ${l10n.jobApplicantsLabel}'),
      ),
    );
  }
}

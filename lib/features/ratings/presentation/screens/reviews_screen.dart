import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../business/data/models/rating_summary.dart';
import '../../application/ratings_providers.dart';
import '../../data/models/operation_review.dart';

/// The star reviews a business (or any user) has received — reached by
/// tapping the stars+count on the business page. [summary] is what
/// BusinessProfile already carried (BusinessRatingRow's own data), passed
/// through rather than re-fetched so the header renders instantly.
class ReviewsScreen extends ConsumerStatefulWidget {
  final int userId;
  final String name;
  final RatingSummary summary;

  const ReviewsScreen({super.key, required this.userId, required this.name, required this.summary});

  @override
  ConsumerState<ReviewsScreen> createState() => _ReviewsScreenState();
}

class _ReviewsScreenState extends ConsumerState<ReviewsScreen> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      ref.read(reviewsControllerProvider(widget.userId).notifier).loadMore();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final state = ref.watch(reviewsControllerProvider(widget.userId));

    return Scaffold(
      appBar: AppBar(title: Text(widget.name)),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Icon(Icons.star_rounded, color: AppColors.accentGold, size: 28),
                const SizedBox(width: 8),
                Text(
                  widget.summary.starsAverage.toStringAsFixed(1),
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(width: 8),
                Text(
                  '${l10n.ratingsReviewsTitle} (${widget.summary.reviewCount})',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).hintColor),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: Builder(
              builder: (context) {
                if (state.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (state.error != null) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(l10n.commonSomethingWentWrong),
                        const SizedBox(height: 8),
                        OutlinedButton(
                          onPressed: () =>
                              ref.read(reviewsControllerProvider(widget.userId).notifier).load(),
                          child: Text(l10n.commonRetry),
                        ),
                      ],
                    ),
                  );
                }
                if (state.items.isEmpty) {
                  return Center(child: Text(l10n.ratingsEmpty));
                }
                return RefreshIndicator(
                  onRefresh: () => ref.read(reviewsControllerProvider(widget.userId).notifier).load(),
                  child: ListView.separated(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: state.items.length + (state.isLoadingMore ? 1 : 0),
                    separatorBuilder: (context, index) => const Divider(height: 24),
                    itemBuilder: (context, index) {
                      if (index >= state.items.length) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }
                      return _ReviewTile(review: state.items[index]);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ReviewTile extends StatelessWidget {
  final OperationReview review;
  const _ReviewTile({required this.review});

  @override
  Widget build(BuildContext context) {
    final rater = review.rater;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          backgroundImage: rater?.imageUrl != null ? NetworkImage(rater!.imageUrl!) : null,
          child: rater?.imageUrl == null ? const Icon(Icons.person_outline) : null,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      rater?.name ?? '',
                      style: Theme.of(context).textTheme.titleSmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  _StarsRow(stars: review.stars, size: 16),
                ],
              ),
              if (review.comment != null && review.comment!.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(review.comment!, style: Theme.of(context).textTheme.bodyMedium),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _StarsRow extends StatelessWidget {
  final int stars;
  final double size;
  const _StarsRow({required this.stars, this.size = 20});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(
        5,
        (i) => Icon(
          i < stars ? Icons.star_rounded : Icons.star_border_rounded,
          color: AppColors.accentGold,
          size: size,
        ),
      ),
    );
  }
}

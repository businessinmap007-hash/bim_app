import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../business/data/models/offering_item.dart';
import '../../../course/application/course_providers.dart';
import '../../../course/data/models/course.dart';
import '../../data/models/unit_discovery.dart';
import '../screens/booking_screen.dart';
import 'booking_grid_widgets.dart';
import 'booking_shape_tab.dart';

/// «كورس»: the course, its level, and the groups that run it — each with when it meets, when it starts and how many
/// seats are left — then «التحق بالكورس». A business with no group open keeps the page it always had.
class CourseBoardTab extends ConsumerStatefulWidget {
  final int businessId;
  final UnitShape shape;
  final Widget fallback;

  const CourseBoardTab({
    super.key,
    required this.businessId,
    required this.shape,
    required this.fallback,
  });

  @override
  ConsumerState<CourseBoardTab> createState() => _CourseBoardTabState();
}

class _CourseBoardTabState extends ConsumerState<CourseBoardTab> {
  String? _level;
  int? _groupId;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final locale = Localizations.localeOf(context).toString();
    final async = ref.watch(courseDiscoveryProvider(widget.businessId));

    return async.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, _) => widget.fallback,
      data: (courses) {
        if (courses.isEmpty) return widget.fallback;

        final levels = {
          for (final c in courses)
            for (final g in c.groups)
              if (g.level != null) g.level!,
        }.toList();

        CourseInfo? chosenCourse;
        CourseGroup? chosen;
        for (final c in courses) {
          for (final g in c.groups) {
            if (g.id == _groupId && !g.isFull) {
              chosenCourse = c;
              chosen = g;
            }
          }
        }

        final fmt = DateFormat.yMMMd(locale);

        return BoardScaffold(
          bottom: BookingSummaryBar(
            summary: chosen == null
                ? l10n.courseHint
                : '${chosenCourse!.name} — ${chosen.name}',
            price: chosen == null ? null : chosenCourse!.price,
            label: l10n.courseEnroll,
            onPressed: chosen == null
                ? null
                : () {
                    final course = chosenCourse!;
                    final group = chosen!;
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => BookingScreen(
                          businessId: widget.businessId,
                          shape: widget.shape,
                          courseGroupId: group.id,
                          initialStartsAt: group.startsOn,
                          initialEndsAt: group.endsOn ?? group.startsOn,
                          offering: OfferingItem(
                            id: course.id,
                            source: 'price',
                            label: course.name,
                            price: course.price,
                            currency: course.currency,
                            serviceId: course.serviceId,
                            itemType: 'book_a_course',
                            action: 'book',
                          ),
                        ),
                      ),
                    );
                  },
          ),
          children: [
            if (levels.isNotEmpty) ...[
              BookingSectionCard(
                title: l10n.courseLevelTitle,
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final level in [null, ...levels])
                      IntrinsicWidth(
                        child: SizedBox(
                          height: 40,
                          child: BookingPickChip(
                            selected: _level == level,
                            onTap: () => setState(() {
                              _level = level;
                              _groupId = null;
                            }),
                            builder: (ink) => Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              child: Text(
                                level ?? l10n.courseLevelAll,
                                style: TextStyle(
                                  color: ink,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
            ],
            for (final course in courses) ...[
              Text(
                course.name,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                l10n.courseGroupsTitle,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.hintColor,
                ),
              ),
              const SizedBox(height: 8),
              for (final g in course.groups.where(
                (g) => _level == null || g.level == _level,
              ))
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _GroupCard(
                    group: g,
                    course: course,
                    startsText: g.startsOn == null
                        ? null
                        : l10n.courseStartsOn(fmt.format(g.startsOn!)),
                    selected: g.id == _groupId,
                    onTap: g.isFull
                        ? null
                        : () => setState(() => _groupId = g.id),
                  ),
                ),
              if (course.groups
                  .where((g) => _level == null || g.level == _level)
                  .isEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Text(
                    l10n.courseNoGroups,
                    style: theme.textTheme.bodyMedium,
                  ),
                ),
              const SizedBox(height: 6),
            ],
          ],
        );
      },
    );
  }
}

class _GroupCard extends StatelessWidget {
  final CourseGroup group;
  final CourseInfo course;
  final String? startsText;
  final bool selected;
  final VoidCallback? onTap;

  const _GroupCard({
    required this.group,
    required this.course,
    required this.startsText,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final full = group.isFull;

    return Opacity(
      opacity: full ? 0.55 : 1,
      child: Card(
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(
            color: selected ? cs.secondary : Colors.transparent,
            width: 2,
          ),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        group.name,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      if ((group.scheduleText ?? '').isNotEmpty)
                        Text(
                          group.scheduleText!,
                          style: theme.textTheme.bodyMedium,
                        ),
                      const SizedBox(height: 2),
                      Text(
                        [
                          ?startsText,
                          full
                              ? l10n.courseSeatsFull
                              : l10n.courseSeatsLeft(group.seatsLeft),
                        ].join(' · '),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: full ? cs.error : theme.hintColor,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      course.price.toStringAsFixed(
                        course.price % 1 == 0 ? 0 : 2,
                      ),
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      l10n.coursePerCourse,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.hintColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

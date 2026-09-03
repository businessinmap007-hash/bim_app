import 'package:flutter/material.dart';

/// Wraps a [TabBar] so it can pin inside a [NestedScrollView]'s
/// `headerSliverBuilder` — the header above it (a cover photo, a profile
/// summary) scrolls away with the rest of the page, this stays put once it
/// reaches the top.
class SliverTabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;
  const SliverTabBarDelegate(this.tabBar);

  @override
  double get minExtent => tabBar.preferredSize.height;
  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return ColoredBox(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: tabBar,
    );
  }

  @override
  bool shouldRebuild(covariant SliverTabBarDelegate oldDelegate) => tabBar != oldDelegate.tabBar;
}

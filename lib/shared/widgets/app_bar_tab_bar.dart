import 'package:flutter/material.dart';

import '../../app/theme/app_theme.dart';

/// A [TabBar] for an `AppBar.bottom`. The page's top is the dark brand navy with white ink («اعلى الصفحة اللون
/// الداكن والخط ابيض»), so the tabs on it are gold (the open one) and white (the rest) — the default tab colours,
/// navy on cream, would vanish there.
class AppBarTabBar extends StatelessWidget implements PreferredSizeWidget {
  final List<Widget> tabs;
  final TabController? controller;
  final bool isScrollable;
  final ValueChanged<int>? onTap;

  const AppBarTabBar({super.key, required this.tabs, this.controller, this.isScrollable = false, this.onTap});

  @override
  Size get preferredSize => const Size.fromHeight(kTextTabBarHeight);

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(tabBarTheme: AppTheme.onBarTabBarTheme()),
      child: TabBar(controller: controller, isScrollable: isScrollable, onTap: onTap, tabs: tabs),
    );
  }
}

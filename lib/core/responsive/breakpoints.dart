import 'package:flutter/widgets.dart';

/// Screen-size tiers, matching common tablet/desktop breakpoints. Mobile
/// stays the design baseline — tablet/desktop only get MORE room, never a
/// cramped mobile layout stretched wide.
enum ScreenSize { mobile, tablet, desktop }

class Breakpoints {
  const Breakpoints._();

  static const tablet = 600.0;
  static const desktop = 1024.0;

  /// A sane max content width on very wide screens so a grid/list doesn't
  /// stretch edge-to-edge into unreadable row lengths.
  static const maxContentWidth = 1200.0;

  static ScreenSize of(BuildContext context) =>
      sizeFor(MediaQuery.sizeOf(context).width);

  static ScreenSize sizeFor(double width) {
    if (width >= desktop) return ScreenSize.desktop;
    if (width >= tablet) return ScreenSize.tablet;
    return ScreenSize.mobile;
  }

  /// Column count for a category/grid-style list — grows with screen size
  /// instead of a fixed count everywhere. 4 on mobile (not 3): with ~21 root
  /// categories, 4 columns is what lets the whole grid fit one screen
  /// without scrolling on a typical phone.
  static int gridColumnsFor(double width) {
    switch (sizeFor(width)) {
      case ScreenSize.desktop:
        return 8;
      case ScreenSize.tablet:
        return 6;
      case ScreenSize.mobile:
        return 4;
    }
  }
}

/// Centers its child with [Breakpoints.maxContentWidth] on wide screens;
/// full-width (no-op) on mobile/tablet. Wrap a screen's scrollable body in
/// this once instead of hand-checking width on every screen.
class ResponsiveCenter extends StatelessWidget {
  final Widget child;
  final double maxWidth;

  const ResponsiveCenter({
    super.key,
    required this.child,
    this.maxWidth = Breakpoints.maxContentWidth,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: child,
      ),
    );
  }
}

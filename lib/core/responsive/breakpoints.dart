import 'package:flutter/widgets.dart';
import 'package:responsive_framework/responsive_framework.dart';

/// Screen-size tiers, matching common tablet/desktop breakpoints. Mobile
/// stays the design baseline — tablet/desktop only get MORE room, never a
/// cramped mobile layout stretched wide.
enum ScreenSize { mobile, tablet, desktop }

/// Thin wrapper around `responsive_framework`'s `ResponsiveBreakpoints` —
/// every existing call site (`Breakpoints.of(context)`, `ResponsiveCenter`)
/// keeps this exact API, so adopting the package didn't require touching
/// the screens that were already using it.
class Breakpoints {
  const Breakpoints._();

  static const tablet = 600.0;
  static const desktop = 1024.0;

  /// A sane max content width on very wide screens so a grid/list doesn't
  /// stretch edge-to-edge into unreadable row lengths.
  static const maxContentWidth = 1200.0;

  /// Registered once at the app root (see `BimApp`'s `builder:`) — this is
  /// what makes `ResponsiveBreakpoints.of(context)` (used below, and
  /// available directly to any screen that wants its `ResponsiveValue`/
  /// `ResponsiveRowColumn`/etc. widgets) resolvable anywhere in the tree.
  static Widget builder(BuildContext context, Widget? child) {
    return ResponsiveBreakpoints.builder(
      child: child!,
      breakpoints: [
        const Breakpoint(start: 0, end: tablet - 1, name: MOBILE),
        const Breakpoint(start: tablet, end: desktop - 1, name: TABLET),
        const Breakpoint(start: desktop, end: double.infinity, name: DESKTOP),
      ],
    );
  }

  static ScreenSize of(BuildContext context) {
    final data = ResponsiveBreakpoints.of(context);
    if (data.isDesktop) return ScreenSize.desktop;
    if (data.isTablet) return ScreenSize.tablet;
    return ScreenSize.mobile;
  }

  static ScreenSize sizeFor(double width) {
    if (width >= desktop) return ScreenSize.desktop;
    if (width >= tablet) return ScreenSize.tablet;
    return ScreenSize.mobile;
  }

  /// Column count for a category/grid-style list — grows with screen size
  /// instead of a fixed count everywhere.
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

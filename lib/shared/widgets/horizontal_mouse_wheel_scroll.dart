import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

/// Lets a horizontal-scrolling list respond to an ordinary vertical mouse
/// wheel on desktop/web, not just touch-drag or a horizontal wheel/trackpad
/// gesture. Flutter's [Scrollable] only reads [PointerScrollEvent.scrollDelta]'s
/// `dx` for a horizontal axis — a plain mouse wheel only ever sends `dy`, so
/// without this a horizontal row simply never moves for a desktop mouse user,
/// even though drag and a real horizontal wheel both work fine.
class MouseWheelHorizontalScroll extends StatefulWidget {
  final Widget Function(BuildContext context, ScrollController controller) builder;

  const MouseWheelHorizontalScroll({super.key, required this.builder});

  @override
  State<MouseWheelHorizontalScroll> createState() => _MouseWheelHorizontalScrollState();
}

class _MouseWheelHorizontalScrollState extends State<MouseWheelHorizontalScroll> {
  final _controller = ScrollController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onPointerSignal(PointerSignalEvent event) {
    if (event is! PointerScrollEvent || !_controller.hasClients) return;

    // Claim the signal exclusively — without this, an ancestor Scrollable
    // (the page behind a category row, say) sees the same event and scrolls
    // vertically at the same time as this row scrolls horizontally.
    GestureBinding.instance.pointerSignalResolver.register(event, _handleScroll);
  }

  void _handleScroll(PointerSignalEvent event) {
    if (event is! PointerScrollEvent || !_controller.hasClients) return;

    // A trackpad/shift-wheel already sends a real dx — prefer whichever axis
    // actually moved so this doesn't fight a gesture that already works.
    final delta = event.scrollDelta.dx.abs() > event.scrollDelta.dy.abs()
        ? event.scrollDelta.dx
        : event.scrollDelta.dy;
    final target = (_controller.offset + delta).clamp(0.0, _controller.position.maxScrollExtent);
    _controller.jumpTo(target);
  }

  @override
  Widget build(BuildContext context) {
    return Listener(onPointerSignal: _onPointerSignal, child: widget.builder(context, _controller));
  }
}

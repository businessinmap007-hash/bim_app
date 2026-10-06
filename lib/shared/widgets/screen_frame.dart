import 'package:flutter/material.dart';

/// A screen's own frame: a Scaffold with an app bar when opened by itself, or — [embedded], as one tab of a
/// bigger page — just its body with the app-bar actions moved onto a thin row above it (the page already has the
/// bar). It lets the same screen live on its own and inside «الأمور المالية» without being written twice.
class ScreenFrame extends StatelessWidget {
  final bool embedded;
  final String title;
  final List<Widget> actions;
  final Widget body;

  const ScreenFrame({super.key, required this.embedded, required this.title, this.actions = const [], required this.body});

  @override
  Widget build(BuildContext context) {
    if (!embedded) {
      return Scaffold(appBar: AppBar(title: Text(title), actions: actions), body: body);
    }
    return Column(
      children: [
        if (actions.isNotEmpty) Align(alignment: AlignmentDirectional.centerEnd, child: Row(mainAxisSize: MainAxisSize.min, children: actions)),
        Expanded(child: body),
      ],
    );
  }
}

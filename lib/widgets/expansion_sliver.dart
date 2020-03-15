import 'dart:math';

import 'package:Messedaglia/screens/menu_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class ExpansionSliver extends StatelessWidget {
  final ExpansionSliverDelegate delegate;
  ExpansionSliver(this.delegate);

  @override
  Widget build(BuildContext context) => SliverPersistentHeader(
        delegate: delegate,
        pinned: true,
      );
}

class ExpansionSliverDelegate extends SliverPersistentHeaderDelegate {
  final String title;
  final ResizableWidget body;
  final dynamic value;
  final IconData leading, action;
  final Function leadingCallback, actionCallback;
  BuildContext _context;

  ExpansionSliverDelegate(this._context,
      {@required this.title,
      this.body,
      this.value,
      this.leading,
      this.action,
      this.leadingCallback,
      this.actionCallback});

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    _context = context;
    return CustomPaint(
      painter: BackgroundPainter(Theme.of(context)),
      child: Column(children: [
        Container(
          margin: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
          height: kToolbarHeight,
          child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
            if (leading != null || action != null)
              IconButton(
                  icon: Icon(
                    leading ?? Icons.adb,
                    color: leading == null
                        ? Colors.transparent
                        : Theme.of(context).brightness == Brightness.dark
                            ? Colors.white54
                            : Colors.black54,
                  ),
                  onPressed: leadingCallback),
            Expanded(
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: Theme.of(context).brightness == Brightness.light
                        ? Colors.black
                        : Colors.white,
                    fontSize: 30,
                    fontWeight: FontWeight.bold),
              ),
            ),
            if (leading != null || action != null)
              IconButton(
                  icon: Icon(
                    action ?? Icons.adb,
                    color: action == null
                        ? Colors.transparent
                        : Theme.of(context).brightness == Brightness.dark
                            ? Colors.white54
                            : Colors.black54,
                  ),
                  onPressed: actionCallback)
          ]),
        ),
        if (body != null)
          body.build(
              context, max(1 - shrinkOffset / (maxExtent - minExtent), 0)),
        SizedBox(
          height: MediaQuery.of(context).size.width / 8,
        )
      ]),
    );
  }

  @override
  double get maxExtent =>
      MediaQuery.of(_context).padding.top +
      kToolbarHeight +
      MediaQuery.of(_context).size.width / 8 +
      (body?.maxExtent(_context) ?? 0);

  @override
  double get minExtent =>
      MediaQuery.of(_context).padding.top +
      kToolbarHeight +
      MediaQuery.of(_context).size.width / 8 +
      (body?.minExtent(_context) ?? 0);

  @override
  bool shouldRebuild(ExpansionSliverDelegate oldDelegate) =>
      value != oldDelegate.value;
}

abstract class ResizableWidget {
  double maxExtent(BuildContext context);
  double minExtent(BuildContext context);
  Widget build(BuildContext context, [double heigthFactor]);

  dynamic interpolate(dynamic start, dynamic end, double factor) {
    if (start is double && end is double) return (end - start) * factor + start;
    if (start is int && end is int)
      return ((end - start) * factor + start).truncate();
    if (start is Color && end is Color)
      return Color.fromARGB(
          interpolate(start.alpha, end.alpha, factor),
          interpolate(start.red, end.red, factor),
          interpolate(start.green, end.green, factor),
          interpolate(start.blue, end.blue, factor));
  }
}

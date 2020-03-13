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
        floating: true,
      );
}

class ExpansionSliverDelegate extends SliverPersistentHeaderDelegate {
  final String title;
  final ResizableWidget body;
  final dynamic value;
  final FloatingHeaderSnapConfiguration
      _snapConfiguration; //FIXME: come funziona lo snap ?!?!?!
  BuildContext _context;

  ExpansionSliverDelegate(this._context,
      {@required this.title,
      @required TickerProvider vsync,
      this.body,
      this.value})
      : _snapConfiguration = FloatingHeaderSnapConfiguration(
          vsync: vsync,
          curve: Curves.easeOut,
          duration: const Duration(milliseconds: 200),
        );

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
          child: Center(
            child: Text(
              title,
              style: TextStyle(
                  color: Theme.of(context).brightness == Brightness.light
                      ? Colors.black
                      : Colors.white,
                  fontSize: 30,
                  fontWeight: FontWeight.bold),
            ),
          ),
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

  @override
  FloatingHeaderSnapConfiguration get snapConfiguration => _snapConfiguration;
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

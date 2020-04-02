import 'dart:math';

import 'package:flutter/material.dart';
import 'package:preload_page_view/preload_page_view.dart';

class CardsManager extends StatefulWidget {
  final Widget Function(BuildContext context, int index) builder;
  final int pagesCount;
  final EdgeInsets padding;

  CardsManager({@required this.builder, this.pagesCount, this.padding});

  @override
  _CardsManagerState createState() => _CardsManagerState();
}

class _CardsManagerState extends State<CardsManager> {
  final PreloadPageController _controller =
      PreloadPageController(initialPage: 0);
  double _currentPage = 0.0;

  @override
  void initState() {
    _controller
        .addListener(() => setState(() => _currentPage = _controller.page));
    super.initState();
  }

  @override
  Widget build(BuildContext context) => PreloadPageView.builder(
        controller: _controller,
        preloadPagesCount: 2,
        itemBuilder: _pageBuilder,
        itemCount: widget.pagesCount,
      );

  Widget _pageBuilder(BuildContext context, int index) {
    Widget page = widget.builder(context, index);
    double padding = 35.0;

    double delta = index - _currentPage;
    double start = padding * 10 * delta.abs();
    double startPrev = index > 0
        ? padding * 10 * (index - 1 - _currentPage).abs() + widget.padding.right
        : start;
    startPrev = min(start, startPrev);
    // TODO
    return Transform.translate(
      offset: Offset(-startPrev, 0),
      child: ClipRect(
        child: Transform.translate(
          offset: Offset(-start + startPrev, 0),
          child: Transform.scale(
            scale: pow(0.8, max(delta, 0)),
            child: Padding(
              padding: widget.padding,
              child: page,
            ),
          ),
        ),
      ),
    );
  }
}

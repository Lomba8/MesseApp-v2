// PS: è un copia incolla

import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

const Duration _kExpand = Duration(milliseconds: 200);

class CustomExpansionTile extends StatefulWidget {
  const CustomExpansionTile({
    Key key,
    this.leading,
    @required this.title,
    this.subtitle,
    this.backgroundColor,
    this.onExpansionChanged,
    this.child,
    this.trailing,
  }) : super(key: key);

  final Widget leading;
  final Widget title;
  final Widget subtitle;
  final ValueChanged<bool> onExpansionChanged;
  final Widget child;

  final Color backgroundColor;
  final Widget trailing;

  @override
  _ExpansionTileState createState() => _ExpansionTileState();
}

class _ExpansionTileState extends State<CustomExpansionTile>
    with SingleTickerProviderStateMixin {
  static final Animatable<double> _easeOutTween =
      CurveTween(curve: Curves.easeOut);
  static final Animatable<double> _easeInTween =
      CurveTween(curve: Curves.easeIn);
  final ColorTween _backgroundColorTween = ColorTween();

  AnimationController _controller;
  Animation<double> _heightFactor;
  Animation<Color> _backgroundColor;

  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: _kExpand, vsync: this);
    _heightFactor = _controller.drive(_easeInTween);
    _backgroundColor =
        _controller.drive(_backgroundColorTween.chain(_easeOutTween));

    _isExpanded = PageStorage.of(context)?.readState(context) as bool ?? false;
    if (_isExpanded) _controller.value = 1.0;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() {
    if (widget.child == null) return;
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded)
        _controller.forward();
      else
        _controller.reverse().then<void>((void value) {
          if (mounted) setState(() {});
        });
      PageStorage.of(context)?.writeState(context, _isExpanded);
    });
    if (widget.onExpansionChanged != null)
      widget.onExpansionChanged(_isExpanded);
  }

  Widget _buildChildren(BuildContext context, Widget child) {
    return Container(
      decoration: BoxDecoration(
        color: _backgroundColor.value ?? Colors.transparent,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          ListTileTheme.merge(
            child: Container(
              color: Colors.white10,
              margin: EdgeInsets.only(left: 15.0, right: 15.0, bottom: 1.0),
              child: ListTile(
                onTap: _handleTap,
                leading: widget.leading,
                title: widget.title,
                subtitle: widget.subtitle,
                trailing: widget.trailing ??
                    AnimatedCrossFade(
                      duration: Duration(milliseconds: 200),
                      crossFadeState: !_isExpanded
                          ? CrossFadeState.showFirst
                          : CrossFadeState.showSecond,
                      firstCurve: Curves.easeInQuad,
                      secondCurve: Curves.decelerate,
                      firstChild: Icon(MdiIcons.eye),
                      secondChild: Icon(MdiIcons.eyeOffOutline),
                    ),
              ),
            ),
          ),
          ClipRect(
            child: Align(
              heightFactor: _heightFactor.value,
              child: child,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void didChangeDependencies() {
    _backgroundColorTween.end = widget.backgroundColor;
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    final bool closed = !_isExpanded && _controller.isDismissed;
    return AnimatedBuilder(
      animation: _controller.view,
      builder: _buildChildren,
      child: closed ? null : widget.child,
    );
  }
}

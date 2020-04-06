import 'package:Messedaglia/widgets/CustomConnectionStatusBar.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flare_flutter/flare_actor.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Menuitem {
  final String name;
  final Color color;
  Color lightColor;
  final double x;

  Menuitem({
    this.name,
    this.color,
    this.lightColor,
    this.x,
  }) {
    lightColor ??= color;
  }
}

final List items = [
  Menuitem(
      x: -1,
      name: 'Orari.flr' /*per orario*/,
      color: Color.fromRGBO(240, 141, 52, 1)), // rgb(240, 141, 52)
  Menuitem(
      x: -0.5,
      name: 'Agenda.flr' /*per lagenda*/,
      color: Color.fromRGBO(88, 190, 120, 1)), // rgb(88, 190, 120)
  Menuitem(
      x: 0.0,
      name: 'Home.flr' /*per home*/,
      color: Color.fromRGBO(235, 235, 240, 1),
      lightColor: Color.fromRGBO(20, 20, 15, 1)), // rgb(235,235,240)
  Menuitem(
      x: 0.5,
      name: 'Voti.flr' /*per voti*/,
      color: Color.fromRGBO(236, 77, 69, 1)), //  rgb(236, 77, 69)
  Menuitem(
      x: 1,
      name: 'AreaStudenti.flr' /*per area studenti*/,
      color: Color.fromRGBO(91, 34, 196, 1)) // rgb(91, 34, 196)
];

class NavBarSotto extends StatefulWidget {
  final Function(int index) onTap;
  NavBarSotto(this.onTap);

  @override
  _NavBarSottoState createState() => _NavBarSottoState();
}

class _NavBarSottoState extends State<NavBarSotto>
    with SingleTickerProviderStateMixin {
  int active = 2;
  bool _connected = true;
  AnimationController _animationController;
  Animation<double> _heightAnimation;
  Animation<double> _widthAnimation;
  Animation<double> _cornerAnimation;

  @override
  void initState() {
    _animationController =
        AnimationController(vsync: this, duration: Duration(seconds: 1));
    _heightAnimation = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(
      parent: _animationController,
      curve: Interval(0, 0.3),
    ));
    _widthAnimation = Tween<double>(begin: 3, end: 1).animate(CurvedAnimation(
      parent: _animationController,
      curve: Interval(0.3, 1),
    ));
    _cornerAnimation = Tween<double>(begin: 12.5, end: 0).animate(CurvedAnimation(
      parent: _animationController,
      curve: Interval(0.8, 1),
    ));

    Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
      if (result == ConnectivityResult.none) {
        _animationController.forward();
        _connected = false;
      } else {
        _animationController.reverse();
        _connected = true;
      }
      if (mounted) setState(() {});
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) => Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            child,
            AnimatedContainer(
              //color: Theme.of(context).backgroundColor,
              duration: Duration(milliseconds: 200),
              alignment: Alignment(items[active].x, -1),
              child: AnimatedContainer(
                duration: Duration(milliseconds: 500),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    color: Theme.of(context).brightness == Brightness.dark
                        ? items[active].color
                        : items[active].lightColor),
                height: 8,
                width: MediaQuery.of(context).size.width * 0.2,
              ),
            ),
            ClipRect(
              child: Align(
                alignment: Alignment.topCenter,
                heightFactor: _heightAnimation.value,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(_cornerAnimation.value),
                    color: _connected ? Colors.green : Colors.redAccent,
                  ),
                  width:
                      MediaQuery.of(context).size.width / _widthAnimation.value,
                  height: 25,
                  child: Center(
                    child: Text(
                      _connected ? 'Online' : 'Offline',
                      style: TextStyle(color: Colors.white, fontSize: 14),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        child: Row(
          children: items.map((item) => _flare(item)).toList(),
        ),
      );

  Widget _flare(Menuitem item) => Expanded(
        child: GestureDetector(
          child: Container(
            height: MediaQuery.of(context).size.height / 13,
            padding: EdgeInsets.symmetric(vertical: 3),
            child: FlareActor(
              'flare/${item.name}',
              alignment: Alignment.center,
              color: Theme.of(context).brightness == Brightness.dark
                  ? item.color
                  : item.lightColor,
              fit: BoxFit.contain,
              animation: item.name == items[active].name ? 'Go' : 'idle',
            ),
          ),
          onTap: () => widget.onTap(active = items.indexOf(item)),
        ),
      );
}

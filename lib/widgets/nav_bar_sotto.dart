import 'package:flare_flutter/flare_actor.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Menuitem {
  final String name;
  final Color color;
  final double x;

  Menuitem({
    this.name,
    this.color,
    this.x,
  });
}

class NavBarSotto extends StatefulWidget {
  final Function(int index) onTap;
  NavBarSotto(this.onTap);

  @override
  _NavBarSottoState createState() => _NavBarSottoState();
}

class _NavBarSottoState extends State<NavBarSotto> {
  int active = 2;

  List items = [
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
        color: Color.fromRGBO(235, 235, 240, 1)), // rgb(235,235,240)
    Menuitem(
        x: 0.5,
        name: 'Voti.flr' /*per voti*/,
        color: Color.fromRGBO(236, 77, 69, 1)), //  rgb(236, 77, 69)
    Menuitem(
        x: 1,
        name: 'AreaStudenti.flr' /*per area studenti*/,
        color: Color.fromRGBO(91, 34, 196, 1)) // rgb(91, 34, 196)
  ];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double _quinto = MediaQuery.of(context).size.width / 5;
    double _x = _quinto * items[active].x;
    print(_x);
    return Stack(
      fit: StackFit.expand,
      overflow: Overflow.visible,
      children: <Widget>[
        Container(
          height: MediaQuery.of(context).size.height / 19,
          width: MediaQuery.of(context).size.width,
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: items.map((item) => _flare(item, context)).toList(),
          ),
        ),
        Positioned(
          bottom: 0, //_quinto * 5,
          child: Container(
            width: _quinto * 5,
            child: AnimatedContainer(
              color: Theme.of(context).backgroundColor,
              duration: Duration(milliseconds: 200),
              alignment: Alignment(items[active].x, -1),
              child: AnimatedContainer(
                duration: Duration(milliseconds: 500),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    color: items[active].color),
                height: 8,
                width: MediaQuery.of(context).size.width * 0.2,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _flare(Menuitem item, BuildContext contesto) {
    print(item.name);
    return Expanded(
      child: GestureDetector(
        child: AspectRatio(
          aspectRatio: 1,
          child: Padding(
            padding: EdgeInsets.only(top: 13, bottom: 13),
            child: FlareActor(
              'flare/${item.name}',
              alignment: Alignment.center,
              fit: BoxFit.contain,
              animation: item.name == items[active].name ? 'Go' : 'idle',
            ),
          ),
        ),
        onTap: () => widget.onTap(active = items.indexOf(item)),
      ),
    );
  }
}

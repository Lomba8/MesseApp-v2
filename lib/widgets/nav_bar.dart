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

class NavBar extends StatefulWidget {
  @override
  _NavBarState createState() => _NavBarState();
}

class _NavBarState extends State<NavBar> {
  List items = [
    Menuitem(
        x: -1.0,
        name: 'Orari.flr' /*per orario*/,
        color: Color.fromRGBO(240, 141, 52, 1)), // rgb(240, 141, 52)
    Menuitem(
        x: -0.5,
        name: 'Agenda.flr' /*per agenda*/,
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
        x: 1.0,
        name: 'AreaStudenti.flr' /*per area studenti*/,
        color: Color.fromRGBO(91, 34, 196, 1)) // rgb(91, 34, 196)
  ];

  Menuitem active;

  @override
  void initState() {
    super.initState();
    active = items[2];
  }

  @override
  Widget build(BuildContext context) {
    dynamic w = MediaQuery.of(context).size.width;
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        Container(
          height: 60,
          width: w,
          color: Theme.of(context).backgroundColor,
          child: Stack(
            clipBehavior: Clip.none,
            children: <Widget>[
              AnimatedContainer(
                duration: Duration(milliseconds: 200),
                alignment: Alignment(active.x, -1),
                child: AnimatedContainer(
                  duration: Duration(
                    milliseconds: 500,
                  ),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      color: active.color),
                  height: 8,
                  width: w * 0.2,
                ),
              ),
              Container(
                width: w,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: items.map((item) => _flare(item, context)).toList(),
                ),
              )
            ],
          ),
        ),
        SizedBox(
          height: 10,
        )
      ],
    );
  }

  Widget _flare(Menuitem item, BuildContext contesto) => Expanded(
        child: GestureDetector(
          child: AspectRatio(
            aspectRatio: 1,
            child: Padding(
              padding: EdgeInsets.only(top: 20),
              child: FlareActor(
                'flare/${item.name}',
                alignment: Alignment.center,
                fit: BoxFit.contain,
                animation: item.name == active.name ? 'Go' : 'idle',
              ),
            ),
          ),
          onTap: () {
            setState(() {
              active = item;
              dynamic name = item.name.split(".");
              Navigator.pushNamed(contesto, "/lib/screens/${name[0]}.id");
            });
          },
        ),
      );
}

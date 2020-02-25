import 'dart:async';
import 'dart:ui';

import 'package:Messedaglia/screens/menu_screen.dart';
import 'package:Messedaglia/screens/voti_details_screen.dart';
import 'package:Messedaglia/registro/registro.dart';
import 'package:Messedaglia/registro/voti_registro_data.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;

import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';

import '../registro/registro.dart';

class Voti extends StatefulWidget {
  static final String id = 'voti_screen';
  @override
  _VotiState createState() => _VotiState();
}

class _VotiState extends State<Voti> {
  @override
  void initState() {
    super.initState();
    RegistroApi.voti.getData().then((r) {
      if (r.ok) _setStateIfAlive();
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _setStateIfAlive() {
    if (mounted) setState(() {});
  }

  String _passedTime() {
    // FIXME: i temporizzatori per l'aggiornamento dell'ultimo controllo si accumulano
    if (RegistroApi.voti.lastUpdate == null) return 'mai aggiornato';
    Duration difference =
        DateTime.now().difference(RegistroApi.voti.lastUpdate);
    if (difference.inMinutes < 1) {
      Future.delayed(Duration(seconds: 15), _setStateIfAlive);
      return 'adesso';
    }
    if (difference.inHours < 1) {
      Future.delayed(Duration(minutes: 1), _setStateIfAlive);
      int mins = difference.inMinutes;
      return '$mins minut${mins == 1 ? 'o' : 'i'} fa';
    }
    if (difference.inDays < 1) {
      Future.delayed(Duration(hours: 1), _setStateIfAlive);
      int hours = difference.inHours;
      return '$hours or${hours == 1 ? 'a' : 'e'} fa';
    }
    return 'più di un giorno fa';
  }

  Future<void> _refresh() async {
    Result r = await RegistroApi.voti.getData();
    if (r.ok) _setStateIfAlive();
  }

  @override
  Widget build(BuildContext context) {
    int newVotiCount = RegistroApi.voti.newVotiPeriodCount;
    return LiquidPullToRefresh(
      onRefresh: () => _refresh(),
      showChildOpacityTransition: false,
      child: CustomScrollView(
        scrollDirection: Axis.vertical,
        slivers: <Widget>[
          SliverList(
            delegate: SliverChildListDelegate(
              [
                CustomPaint(
                  painter: BackgroundPainter(Theme.of(context)),
                  child: Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.only(
                            top: MediaQuery.of(context).padding.top + 8),
                        child: Text(
                          RegistroApi.voti.periods[0],
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: Theme.of(context).brightness ==
                                      Brightness.light
                                  ? Colors.black
                                  : Colors.white,
                              fontSize: 30,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          children: <Widget>[
                            Row(
                              //TODO: animare solo il periodo corrente e metterlo in primo piano + distinguere vari periodi
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                Expanded(
                                  flex: 1,
                                  child: Center(
                                    child: MarkView(
                                        RegistroApi.voti.averagePeriodo(0)),
                                  ),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10.0),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        AspectRatio(
                                            aspectRatio: 2,
                                            child: MaterialButton(
                                              onPressed: () => setState(() =>
                                                  RegistroApi.voti.period = 1),
                                              child: Text(
                                                RegistroApi.voti.periods[1],
                                                textAlign: TextAlign.center,
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                    fontSize: 20,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                              shape: Border(
                                                  bottom: BorderSide(
                                                      color: Voto.getColor(
                                                          RegistroApi.voti
                                                              .averagePeriodo(
                                                                  2)),
                                                      width: 5)),
                                            )),
                                        AspectRatio(
                                          aspectRatio: 2,
                                          child: MaterialButton(
                                            onPressed: () => setState(() =>
                                                RegistroApi.voti.period = 2),
                                            shape: Border(
                                                bottom: BorderSide(
                                                    color: Voto.getColor(
                                                        RegistroApi.voti
                                                            .averagePeriodo(2)),
                                                    width: 5)),
                                            child: Text(
                                              RegistroApi.voti.periods[2],
                                              textAlign: TextAlign.center,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                              ],
                            ),
                            Padding(
                              padding: EdgeInsets.only(
                                  top: 20.0,
                                  bottom:
                                      MediaQuery.of(context).size.width / 8),
                              child: ListTile(
                                title: Text(
                                  '${newVotiCount > 0 ? newVotiCount : 'nessun'} nuov${newVotiCount > 1 ? 'i' : 'o'} vot${newVotiCount > 1 ? 'i' : 'o'}\n${_passedTime()}',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      //fontFamily: 'CoreSans',
                                      ),
                                ),
                                leading: newVotiCount > 0
                                    ? Icon(
                                        Icons.warning,
                                        color: Colors.yellow,
                                      )
                                    : null,
                                trailing: newVotiCount > 0
                                    ? IconButton(
                                        icon: Icon(Icons.clear_all),
                                        onPressed: () => setState(
                                            () => RegistroApi.voti.allSeen()))
                                    : null,
                              ),
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                    padding: EdgeInsets.all(30.0 - 15.0),
                    child: Column(
                      children: RegistroApi.voti.sbjsWithMarks.expand((sbj) {
                        double average = RegistroApi.voti.average(sbj);
                        return [
                          ListTile(
                              onLongPress: () => null,
                              onTap: () => Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) => VotiDetails(
                                                  sbj['voti'],
                                                  sbj['subjectDesc'])))
                                      .then((value) {
                                    sbj['voti'].forEach((v) => v.seen());
                                    _setStateIfAlive();
                                  }),
                              leading: Stack(
                                children: [
                                  Text(
                                    '  ' + average.toStringAsPrecision(2),
                                    style: TextStyle(
                                      fontFamily: 'CoreSansRounded',
                                      fontWeight:
                                          RegistroApi.voti.hasNewMarks(sbj)
                                              ? FontWeight.bold
                                              : FontWeight.normal,
                                    ),
                                  ),
                                  RegistroApi.voti.hasNewMarks(sbj)
                                      ? Positioned(
                                          bottom: 6,
                                          left: 0,
                                          child: Icon(
                                            Icons.brightness_1,
                                            size: 10,
                                            color: Colors.yellow,
                                          ),
                                        )
                                      : SizedBox(),
                                ],
                              ),
                              trailing: Container(
                                width: MediaQuery.of(context).size.width / 10,
                                child: IconButton(
                                  icon: Icon(Icons.arrow_forward_ios),
                                  onPressed: () => Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) => VotiDetails(
                                                  sbj['voti'],
                                                  sbj['subjectDesc'])))
                                      .then((value) {
                                    sbj['voti'].forEach((v) => v.seen());
                                    _setStateIfAlive();
                                  }),
                                ),
                              ),
                              title: Text(
                                sbj['subjectDesc'],
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    letterSpacing: 1.0,
                                    fontWeight:
                                        RegistroApi.voti.hasNewMarks(sbj)
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                    fontSize: RegistroApi.voti.hasNewMarks(sbj)
                                        ? Theme.of(context)
                                                .textTheme
                                                .bodyText2
                                                .fontSize +
                                            1.0
                                        : Theme.of(context)
                                            .textTheme
                                            .bodyText2
                                            .fontSize),
                              )),
                          Row(
                            children: <Widget>[
                              Expanded(
                                flex: (average * 10).round(),
                                child: AnimatedContainer(
                                  duration: Duration(seconds: 1),
                                  decoration: BoxDecoration(
                                      border: Border(
                                          bottom: BorderSide(
                                              width: 2,
                                              color: average < 0 ||
                                                      average.isNaN
                                                  ? Colors.blue
                                                  : average < 6
                                                      ? Colors.deepOrange[900]
                                                      : Colors.green))),
                                ),
                              ),
                              Expanded(
                                flex: (100 - average * 10).round(),
                                child: AnimatedContainer(
                                  duration: Duration(seconds: 1),
                                  decoration: BoxDecoration(
                                      border: Border(
                                          bottom: BorderSide(
                                              width: 2,
                                              color: average < 0 ||
                                                      average.isNaN
                                                  ? Colors.blue.withAlpha(50)
                                                  : average < 6
                                                      ? Colors.deepOrange[900]
                                                          .withAlpha(50)
                                                      : Colors.green
                                                          .withAlpha(50)))),
                                ),
                              ),
                            ],
                          )
                        ];
                      }).toList(),
                    ))
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class MarkView extends StatefulWidget {
  final double _voto;

  MarkView([this._voto = -1]);

  @override
  MarkViewState createState() => MarkViewState();
}

class MarkViewState extends State<MarkView>
    with SingleTickerProviderStateMixin {
  AnimationController _controller;
  Animation animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        value: 0.0, vsync: this, duration: Duration(seconds: 1));
    animation =
        CurvedAnimation(parent: _controller, curve: Curves.easeInOutQuart);
    _controller.forward();
    animation.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: CustomPaint(
        painter: MarkPainter(Theme.of(context), widget._voto, animation.value),
      ),
    );
  }
}

class MarkPainter extends CustomPainter {
  final Paint p = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 10
    ..strokeCap = StrokeCap.round;
  Color startColor, endColor;
  double _mark;
  double _progress;
  ThemeData _theme;

  MarkPainter(this._theme, [this._mark = -1, this._progress = 1]) {
    if (_mark == null || _mark.isNaN)
      startColor = endColor = Colors.blue;
    else if (_mark < 6)
      startColor = endColor = Colors.deepOrange[900];
    else {
      startColor = Colors.deepOrange[900];
      endColor = Colors.green;
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    p.color = Color.fromARGB(
        255,
        ((endColor.red - startColor.red) * _progress + startColor.red).round(),
        ((endColor.green - startColor.green) * _progress + startColor.green)
            .round(),
        ((endColor.blue - startColor.blue) * _progress + startColor.blue)
            .round());
    if (_mark != null && !_mark.isNaN) {
      canvas.drawArc(
          Rect.fromLTWH(5, 5, size.width - 10, size.height - 10),
          -math.pi / 2,
          _progress * math.pi * (_mark == null || _mark.isNaN ? 10 : _mark) / 5,
          false,
          p);
    }
    p.color = p.color.withAlpha(50);
    canvas.drawCircle(size.center(Offset.zero),
        (math.min(size.width, size.height) - 10) / 2, p);

    TextPainter painter = TextPainter(
        text: TextSpan(
            text: _mark == null || _mark.isNaN
                ? 'N/D'
                : _mark.toStringAsPrecision(2),
            style: TextStyle(
                color: _theme.brightness == Brightness.light
                    ? Colors.black
                    : Colors.white, // FIXME: supporto tema chiaro
                fontSize: size.height / 3,
                fontWeight: FontWeight.bold,
                fontFamily: 'CoreSansRounded')),
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.center);
    painter
      ..layout(minWidth: size.width, maxWidth: size.width)
      ..paint(canvas, Offset(0, size.height / 3));
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    MarkPainter mv = oldDelegate as MarkPainter;
    if (mv._mark == _mark && mv._progress == _progress) return false;
    return true;
  }
}

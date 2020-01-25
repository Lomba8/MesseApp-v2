import 'dart:async';
import 'dart:ui';

import 'package:applicazione_prova/screens/menu_screen.dart';
import 'package:applicazione_prova/screens/voti_details_screen.dart';
import 'package:applicazione_prova/registro/registro.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;

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
      if (r.reload) _setStateIfAlive();
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
    int currentTime = DateTime.now().millisecondsSinceEpoch;
    int startTime = RegistroApi.voti.lastUpdate;
    if (startTime == null) return 'mai aggiornato';
    if (currentTime - startTime < 1000 * 60) {
      Future.delayed(Duration(seconds: 15), _setStateIfAlive);
      return 'adesso';
    }
    if (currentTime - startTime < 1000 * 60 * 60) {
      Future.delayed(Duration(minutes: 1), _setStateIfAlive);
      int mins = (currentTime - startTime) ~/ (60 * 1000);
      return '$mins minut${mins == 1 ? 'o' : 'i'} fa';
    }
    if (currentTime - startTime < 1000 * 60 * 60 * 24) {
      Future.delayed(Duration(hours: 1), _setStateIfAlive);
      int hours = (currentTime - startTime) ~/ (60 * 60 * 1000);
      return '$hours or${hours == 1 ? 'a' : 'e'} fa';
    }
    return 'più di un giorno fa';
  }

  @override
  Widget build(BuildContext context) {
    int newVotiCount = RegistroApi.voti.newVotiPeriodCount;
    return SingleChildScrollView(
      child: Column(
        children: <Widget>[
          CustomPaint(
            painter: BackgroundPainter(Theme.of(context)),
            child: Padding(
              padding: const EdgeInsets.all(30.0),
              child: Column(
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.only(
                        bottom: MediaQuery.of(context).size.height / 50,
                        top: MediaQuery.of(context).size.height / 40),
                    child: Text(
                      RegistroApi.voti.periods[0],
                      style: TextStyle(
                          color:
                              Theme.of(context).brightness == Brightness.light
                                  ? Colors.black
                                  : Colors.white,
                          fontSize: 30,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Expanded(
                        flex: 2,
                        child: Center(
                          child: MarkView(RegistroApi.voti.averagePeriodo(0)),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            GestureDetector(
                              onTap: () => setState(() => RegistroApi.voti.period = 1), // TODO: animazione del cambio periodo
                              child: MarkView(RegistroApi.voti.averagePeriodo(1)),
                            ),
                            GestureDetector(
                              onTap: () => setState(() => RegistroApi.voti.period = 2),
                              child: MarkView(RegistroApi.voti.averagePeriodo(2)),
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 15.0, bottom: 40),
                    child: ListTile(
                      dense: true,
                      leading: newVotiCount > 0
                          ? Icon(
                              Icons
                                  .warning, //FIXME: aggiornare il ['new'] della materia di cui si ė aperto il WillPopScope e si ritorno in voti_screen.dart
                              color: Colors.yellow,
                            )
                          : null,
                      trailing: IconButton(
                        icon: Icon(Icons.cached),
                        onPressed: () => RegistroApi.voti.getData().then((r) {
                          if (r.reload) _setStateIfAlive();
                        }),
                      ),
                      title: Text(
                        '${newVotiCount > 0 ? newVotiCount : 'nessun'} nuov${newVotiCount > 1 ? 'i' : 'o'} vot${newVotiCount > 1 ? 'i' : 'o'}\n${_passedTime()}',
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
          Padding(
              padding: EdgeInsets.all(30.0 - 15.0),
              child: Column(
                children: RegistroApi.voti.sbjsWithMarks.expand((sbj) {
                  double average = RegistroApi.voti.average(sbj);
                  return [
                    ListTile(
                        leading: Stack(
                          children: [
                            Text(
                              '  ' + average.toStringAsPrecision(2),
                              style: TextStyle(
                                fontFamily: 'CoreSansRounded',
                                fontWeight: RegistroApi.voti.hasNewMarks(sbj)
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
                                        builder: (context) =>
                                            VotiDetails(sbj, RegistroApi.voti.periods[0])))
                                .then((value) {
                              RegistroApi.voti.sbjVoti(sbj)
                                  .forEach((mark) => mark["new"] = false);
                              if (mounted) setState(() {});
                            }), // TODO: open details
                          ),
                        ),
                        title: Text(
                          sbj['subjectDesc'],
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontWeight: RegistroApi.voti.hasNewMarks(sbj)
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              fontSize: RegistroApi.voti.hasNewMarks(sbj)
                                  ? Theme.of(context).textTheme.body1.fontSize +
                                      1.0
                                  : Theme.of(context).textTheme.body1.fontSize),
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
                                        color: average < 0 || average.isNaN
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
                                        color: average < 0 || average.isNaN
                                            ? Colors.blue.withAlpha(50)
                                            : average < 6
                                                ? Colors.deepOrange[900]
                                                    .withAlpha(50)
                                                : Colors.green.withAlpha(50)))),
                          ),
                        ),
                      ],
                    )
                  ];
                }).toList(),
              ))
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

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        value: 0.0, vsync: this, duration: Duration(seconds: 1));
    _controller.addListener(() {
      print(_controller.value);
      if (mounted) setState(() {});
    });
    _controller.animateTo(1).then((v) {
      // FIXME
      if (mounted) setState(() {});
    });
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
        painter:
            MarkPainter(Theme.of(context), widget._voto, _controller.value),
      ),
    );
  }
}

class MarkPainter extends CustomPainter {
  final Paint p = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 10
    ..strokeCap = StrokeCap.round
    ..color = Colors.green;
  double _mark;
  double _progress;
  ThemeData _theme;

  MarkPainter(this._theme, [this._mark = -1, this._progress = 1]) {
    if (_mark == null || _mark.isNaN)
      p.color = Colors.blue;
    else if (_mark < 6) p.color = Colors.deepOrange[900];
  }

  @override
  void paint(Canvas canvas, Size size) {
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
    p.color = p.color.withAlpha(255);

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
    if (mv._mark == _mark) return false;
    return true;
  }
}

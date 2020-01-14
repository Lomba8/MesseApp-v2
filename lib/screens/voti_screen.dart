import 'dart:async';
import 'dart:ui';

import 'package:applicazione_prova/server/server.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;

class Voti extends StatefulWidget {
  static final String id = 'voti_screen';
  @override
  _VotiState createState() => _VotiState();
}

class _VotiState extends State<Voti> {
  List<String> periods = ["TOTALE", "TRIMESTRE", "PENTAMESTRE"];

  @override
  void initState() {
    super.initState();
    Server.getVoti().then((ok) {
      if (ok && mounted) setState(() {});
    });
  }

  void _setStateIfAlive() {
    if (mounted) setState(() {});
  }

  String _passedTime() {
    int currentTime = DateTime.now().millisecondsSinceEpoch;
    int startTime = Server.votiLastUpdate;
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

  double _average(List marks) {
    if (marks == null) return double.nan;
    int n = 0;
    return marks.fold<double>(0, (sum, m) {
          if (m['voto'] == null) return sum;
          n++;
          return sum += m['voto'];
        }) /
        n;
  }

  double _averagePeriodo(String periodo) {
    int n = 0;
    return Server.voti.values.where((sbj) => sbj[periodo] != null).fold(0,
            (sum, sbj) {
          double average = _average(sbj[periodo]);
          if (average.isNaN) return sum;
          n++;
          return sum + average.round();
        }) /
        n;
  }

  // TODO: see details

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: <Widget>[
          Card(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(30))),
            child: Padding(
              padding: const EdgeInsets.all(30.0),
              child: Column(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(bottom: 15),
                    child: Text(
                      periods[0],
                      style:
                          TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Row(
                    // FIXME: sostituire con una griglia?
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Expanded(
                        flex: 2,
                        child: Center(
                          child: CustomPaint(
                            painter: MarkView(_averagePeriodo(periods[0])),
                            size: Size.square(150),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            GestureDetector(
                              onTap: () => setState(() => periods = [
                                    periods[1],
                                    periods[0],
                                    periods[2]
                                  ]), // TODO: animazione del cambio periodo
                              child: CustomPaint(
                                painter: MarkView(_averagePeriodo(periods[1])),
                                size: Size.square(75),
                              ),
                            ),
                            GestureDetector(
                              onTap: () => setState(() => periods = [
                                    periods[2],
                                    periods[1],
                                    periods[0]
                                  ]),
                              child: CustomPaint(
                                painter: MarkView(_averagePeriodo(periods[2])),
                                size: Size.square(75),
                              ),
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 15.0),
                    child: ListTile(
                      dense: true,
                      leading: /*nuovo voto*/ true
                          ? Icon(
                              Icons.warning,
                              color: Colors.yellow,
                            )
                          : null, // TODO
                      trailing: IconButton(
                        icon: Icon(Icons.cached),
                        onPressed: () => Server.getVoti().then((ok) {
                          if (ok) setState(() {});
                        }),
                      ),
                      title: Text(
                        'n° di nuovi voti\n${_passedTime()}', // TODO
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
          Card(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(30))),
            child: Padding(
                padding: EdgeInsets.all(30.0 - 15.0),
                child: Column(
                  children: Server.voti.values
                      .where((sbj) => sbj[periods[0]] != null)
                      .expand((sbj) {
                    double average = _average(sbj[periods[0]]);
                    return [
                      Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: Text(
                          sbj['subjectDesc'],
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
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
                                              ? Colors.blue.withAlpha(100)
                                              : average < 6
                                                  ? Colors.deepOrange[900]
                                                      .withAlpha(100)
                                                  : Colors.green
                                                      .withAlpha(100)))),
                            ),
                          ),
                        ],
                      )
                    ];
                  }).toList(),
                )),
          )
        ],
      ),
    );
  }
}

class MarkView extends CustomPainter {
  final Paint p = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 10
    ..color = Colors.green;
  double _mark;
  bool _fill;

  MarkView([this._mark = -1, this._fill = false]) {
    if (_fill) p.style = PaintingStyle.fill;

    if (_mark == null || _mark.isNaN)
      p.color = Colors.blue;
    else if (_mark < 6) p.color = Colors.deepOrange[900];
  }

  @override
  void paint(Canvas canvas, Size size) {
    // TODO: animazione
    canvas.drawArc(
        Rect.fromLTWH(5, 5, size.width - 10, size.height - 10),
        -math.pi / 2,
        math.pi * (_mark == null || _mark.isNaN ? 10 : _mark) / 5,
        _fill,
        p);
    p.color = p.color.withAlpha(50);
    canvas.drawArc(
        Rect.fromLTWH(5, 5, size.width - 10, size.height - 10),
        -math.pi / 2,
        -math.pi * (_mark == null || _mark.isNaN ? 0 : 10 - _mark) / 5,
        _fill,
        p);
    p.color = p.color.withAlpha(255);

    TextPainter painter = TextPainter(
        text: TextSpan(
            text: _mark == null || _mark.isNaN
                ? 'N/D'
                : _mark.toStringAsPrecision(2),
            style: TextStyle(
                color: Colors.white, // FIXME: supporto tema chiaro
                fontSize: size.height / 3,
                fontWeight: FontWeight.bold)),
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.center);
    painter
      ..layout(minWidth: size.width, maxWidth: size.width)
      ..paint(canvas, Offset(0, size.height / 3));
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    MarkView mv = oldDelegate as MarkView;
    if (mv._mark == _mark) return false;
    return true;
  }
}

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

  double _average(Iterable marks) {
    if (marks == null) return double.nan;
    int n = 0;
    return marks.fold<double>(0, (sum, m) {
          if (m['voto'] == null) return sum;
          n++;
          return sum += m['voto'];
        }) /
        n;
  }

  int _countNewMarks(Map sbj) {
    if (sbj[periods[0]] == null) return 0;
    return sbj[periods[0]].values.fold(0, (sum, mark) {
      if (mark['new']) return sum + 1;
      return sum;
    });
  }

  bool _hasNewMarks(Map sbj) {
    if (sbj[periods[0]] == null) return false;
    return sbj[periods[0]].values.any((mark) => mark['new'] as bool);
  }

  double _averagePeriodo(String periodo) {
    int n = 0;
    return Server.voti.values.where((sbj) => sbj[periodo] != null).fold(0,
            (sum, sbj) {
          double average = _average(sbj[periodo].values);
          if (average.isNaN) return sum;
          n++;
          return sum + average.round();
        }) /
        n;
  }

  // TODO: see details

  @override
  Widget build(BuildContext context) {
    int votiCount = Server.voti.values.fold(0, (sum, sbj) {
      if (sbj[periods[0]] == null) return sum;
      return sum + _countNewMarks(sbj);
    });
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
                          child: MarkView(_averagePeriodo(periods[0])),
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
                              child: MarkView(_averagePeriodo(periods[1])),
                            ),
                            GestureDetector(
                              onTap: () => setState(() => periods = [
                                    periods[2],
                                    periods[1],
                                    periods[0]
                                  ]),
                              child: MarkView(_averagePeriodo(periods[2])),
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
                      leading: votiCount > 0
                          ? Icon(
                              Icons.warning,
                              color: Colors.yellow,
                            )
                          : null,
                      trailing: IconButton(
                        icon: Icon(Icons.cached),
                        onPressed: () => Server.getVoti().then((ok) {
                          if (ok) _setStateIfAlive();
                        }),
                      ),
                      title: Text(
                        '${votiCount > 0 ? votiCount : 'nessun'} nuov${votiCount > 1 ? 'i' : 'o'} vot${votiCount > 1 ? 'i' : 'o'}\n${_passedTime()}',
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
                    double average = _average(sbj[periods[0]].values);
                    return [
                      ListTile(
                        leading: _hasNewMarks(sbj)
                            ? Icon(
                                Icons.add_circle_outline,
                                color: Colors.yellow,
                              )
                            : null,
                        trailing: IconButton(
                          icon: Icon(Icons.arrow_forward_ios),
                          onPressed: null,  // TODO: open details
                        ),
                        title: Text(
                          sbj['subjectDesc'],
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
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
                )),
          )
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
        value: 0.0, vsync: this, duration: Duration(seconds: 2));
    _controller.addListener(() {
      if (mounted) setState(() {});
    });
    _controller.animateTo(2);
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: CustomPaint(
        painter: MarkPainter(widget._voto, _controller.value),
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

  MarkPainter([this._mark = -1, this._progress = 1]) {
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
    MarkPainter mv = oldDelegate as MarkPainter;
    if (mv._mark == _mark) return false;
    return true;
  }
}

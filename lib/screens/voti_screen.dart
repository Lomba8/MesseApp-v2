import 'dart:async';
import 'dart:ui';

import 'package:Messedaglia/main.dart';
import 'package:Messedaglia/screens/voti_details_screen.dart';
import 'package:Messedaglia/registro/registro.dart';
import 'package:Messedaglia/registro/voti_registro_data.dart';
import 'package:Messedaglia/widgets/background_painter.dart';
import 'package:Messedaglia/widgets/expansion_sliver.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;

import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:marquee/marquee.dart';

import '../registro/registro.dart';

class Voti extends StatefulWidget {
  static final String id = 'voti_screen';

  @override
  _VotiState createState() => _VotiState();
}

class _VotiState extends State<Voti> with SingleTickerProviderStateMixin {
  bool _value = false;

  @override
  void initState() {
    super.initState();
    session.voti.getData().then((r) {
      if (r.ok) _setStateIfAlive();
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _setStateIfAlive() {
    _value = !_value;
    if (mounted) setState(() {});
  }

  String _passedTime() {
    // FIXME: i temporizzatori per l'aggiornamento dell'ultimo controllo si accumulano
    if (session.voti.lastUpdate == null) return 'mai aggiornato';
    Duration difference = DateTime.now().difference(session.voti.lastUpdate);
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
    Result r = await session.voti.getData();
    if (r.ok) _setStateIfAlive();
    HapticFeedback.mediumImpact();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LiquidPullToRefresh(
          onRefresh: () => _refresh(),
          showChildOpacityTransition: false,
          child: CustomScrollView(scrollDirection: Axis.vertical, slivers: <
              Widget>[
            SliverAppBar(
              brightness: Theme.of(context).brightness,
              elevation: 0,
              backgroundColor: Colors.transparent,
              title: Column(
                children: <Widget>[
                  Text(
                    "VOTI",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: Theme.of(context).brightness == Brightness.light
                            ? Colors.black
                            : Colors.white,
                        fontSize: 30,
                        fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              bottom: PreferredSize(
                  child: Container(),
                  preferredSize:
                      Size.fromHeight(MediaQuery.of(context).size.width / 8)),
              pinned: true,
              centerTitle: true,
              flexibleSpace: CustomPaint(
                painter: BackgroundPainter(Theme.of(context)),
                size: Size.infinite,
              ),
            ),
            ExpansionSliver(
              ExpansionSliverDelegate(
                context,
                title: 'VOTI', //session.voti.periods[0],
                body: _Header(
                    (period) => setState(() {
                          _value = !_value;
                          session.voti.period = period;
                        }),
                    _passedTime),
                value: _value,
              ),
            ),
            SliverList(
              delegate: SliverChildListDelegate(
                [
                  Padding(
                      padding: EdgeInsets.all(30.0 - 15.0),
                      child: Column(
                        children: session.voti.sbjsWithMarks().expand((sbj) {
                          double average = session.voti.average(sbj);
                          return [
                            SizedBox(
                              height: 55,
                              child: ListTile(
                                  onLongPress: () => null,
                                  onTap: () => Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) => VotiDetails(
                                                  session.voti
                                                      .sbjVoti(sbj)
                                                      .toList(),
                                                  sbj))).then((value) async {
                                        session.voti.allSeen(sbj: sbj);
                                        _setStateIfAlive();
                                      }),
                                  leading: Stack(
                                    children: [
                                      Text(
                                        average.isNaN
                                            ? '  Blu'
                                            : '  ' +
                                                average.toStringAsPrecision(2),
                                        style: TextStyle(
                                          fontFamily: 'CoreSansRounded',
                                          fontWeight:
                                              session.voti.hasNewMarks(sbj)
                                                  ? FontWeight.bold
                                                  : FontWeight.normal,
                                        ),
                                      ),
                                      session.voti.hasNewMarks(sbj)
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
                                    width:
                                        MediaQuery.of(context).size.width / 10,
                                    child: IconButton(
                                      icon: Icon(Icons.arrow_forward_ios),
                                      onPressed: () => Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) => VotiDetails(
                                                  session.voti
                                                      .sbjVoti(sbj)
                                                      .toList(),
                                                  sbj))).then((value) {
                                        session.voti.allSeen(sbj: sbj);
                                        _setStateIfAlive();
                                      }),
                                    ),
                                  ),
                                  title: AutoSizeText(
                                    sbj,
                                    maxLines: 1,
                                    minFontSize: session.voti.hasNewMarks(sbj)
                                        ? Theme.of(context)
                                                .textTheme
                                                .bodyText2
                                                .fontSize +
                                            1.0
                                        : Theme.of(context)
                                            .textTheme
                                            .bodyText2
                                            .fontSize,
                                    overflowReplacement: Marquee(
                                      pauseAfterRound:
                                          Duration(milliseconds: 800),
                                      blankSpace: 20,
                                      velocity: 50,
                                      text: sbj,
                                      style: TextStyle(
                                          letterSpacing: 1.0,
                                          fontWeight:
                                              session.voti.hasNewMarks(sbj)
                                                  ? FontWeight.bold
                                                  : FontWeight.normal,
                                          fontSize:
                                              session.voti.hasNewMarks(sbj)
                                                  ? Theme.of(context)
                                                          .textTheme
                                                          .bodyText2
                                                          .fontSize +
                                                      1.0
                                                  : Theme.of(context)
                                                      .textTheme
                                                      .bodyText2
                                                      .fontSize),
                                    ),
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        letterSpacing: 1.0,
                                        fontWeight:
                                            session.voti.hasNewMarks(sbj)
                                                ? FontWeight.bold
                                                : FontWeight.normal,
                                        fontSize: session.voti.hasNewMarks(sbj)
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
                            ),
                            Container(
                                height: 2,
                                padding: EdgeInsets.symmetric(horizontal: 25.0),
                                child: LinearProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        average.isNaN
                                            ? Colors.blue[800]
                                            : Voto.getColor(average)),
                                    value: average.isNaN ? 10 : average / 10,
                                    backgroundColor: average.isNaN
                                        ? Colors.blue[800]
                                        : Voto.getColor(average)
                                            .withAlpha(50))),
                            SizedBox(
                              height: 20.0,
                            )
                          ];
                        }).toList(),
                      ))
                ],
              ),
            ),
          ])),
    );
  }
}

GlobalKey _key = GlobalKey();

class _Header extends ResizableWidget {
  final void Function(int) onPeriodChangedCallback;
  final String Function() passedTime;

  _Header(this.onPeriodChangedCallback, this.passedTime);

  @override
  Widget build(BuildContext context, [double heightFactor]) {
    double average = session.voti.averagePeriodo(0);
    int newVotiCount = session.voti.newVotiPeriodCount;
    return Container(
        height: (maxExtent(context) - minExtent(context)) * heightFactor +
            minExtent(context),
        child: Stack(overflow: Overflow.clip, children: <Widget>[
          Positioned(
              top: 20 * heightFactor,
              left: 20,
              width: interpolate(kToolbarHeight,
                  (MediaQuery.of(context).size.width - 40) / 2, heightFactor),
              height: interpolate(kToolbarHeight,
                  (MediaQuery.of(context).size.width - 40) / 2, heightFactor),
              child: MarkView(
                key: _key,
                voto: average,
                angle: interpolate(10.0, average, heightFactor),
                background: interpolate(
                    Voto.getColor(average), Colors.transparent, heightFactor),
              )),
          Positioned(
            top: 20 * heightFactor,
            right: 30,
            width: (MediaQuery.of(context).size.width - 40) / 2 - 20,
            height: interpolate(kToolbarHeight,
                (MediaQuery.of(context).size.width - 40) / 4, heightFactor),
            child: Opacity(
              opacity: heightFactor,
              child: MaterialButton(
                onPressed: () {
                  _key = GlobalKey();
                  onPeriodChangedCallback(1);
                },
                child: Text(
                  session.voti.periods[1],
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                shape: Border(
                    bottom: BorderSide(
                        color: Voto.getColor(session.voti.averagePeriodo(2)),
                        width: 5)),
              ),
            ),
          ),
          Positioned(
            bottom: interpolate(20.0, 20.0 + kToolbarHeight, heightFactor),
            right: 30,
            width: (MediaQuery.of(context).size.width - 40) / 2 - 20,
            height: interpolate(kToolbarHeight,
                (MediaQuery.of(context).size.width - 40) / 4, heightFactor),
            child: Opacity(
              opacity: heightFactor,
              child: MaterialButton(
                onPressed: () {
                  _key = GlobalKey();
                  onPeriodChangedCallback(2);
                },
                shape: Border(
                    bottom: BorderSide(
                        color: Voto.getColor(session.voti.averagePeriodo(2)),
                        width: 5)),
                child: Text(
                  session.voti.periods[2],
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 20,
            left: interpolate(40 + kToolbarHeight, 0.0, heightFactor),
            right: 0,
            height: kToolbarHeight,
            child: ListTile(
              title: Text(
                '${newVotiCount > 0 ? newVotiCount : 'nessun'} nuov${newVotiCount > 1 ? 'i' : 'o'} vot${newVotiCount > 1 ? 'i' : 'o'}\n${passedTime()}',
                textAlign: TextAlign.center,
                style: TextStyle(
                    //fontFamily: 'CoreSans',
                    ),
              ),
              leading: newVotiCount > 0
                  ? Icon(
                      Icons.brightness_1,
                      color: Colors.yellow,
                    )
                  : null,
              trailing: newVotiCount > 0
                  ? IconButton(
                      icon: Icon(Icons.clear_all),
                      onPressed: () {
                        session.voti.allSeen();
                        onPeriodChangedCallback(0);
                      })
                  : null,
            ),
          ),
        ]));
  }

  @override
  double maxExtent(BuildContext context) =>
      (MediaQuery.of(context).size.width - 40) / 2 + 40 + kToolbarHeight;

  @override
  double minExtent(BuildContext context) => kToolbarHeight + 20;
}

class MarkView extends StatefulWidget {
  final double _voto;
  final double _angle;
  final Color _background;

  MarkView({Key key, double voto, double angle, Color background})
      : _voto = voto ?? -1,
        _angle = angle ?? voto ?? -1,
        _background = background ?? Colors.transparent,
        super(key: key);

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
        painter: MarkPainter(Theme.of(context),
            mark: widget._voto,
            progress: animation.value,
            arcAngle: widget._angle,
            backgroundColor: widget._background),
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
  double _arcAngle;
  ThemeData _theme;
  Color _backgroundColor;

  MarkPainter(this._theme,
      {double mark, double progress, double arcAngle, Color backgroundColor})
      : _mark = mark ?? -1,
        _progress = progress ?? 1,
        _arcAngle = arcAngle ?? mark ?? -1,
        _backgroundColor = backgroundColor ?? Colors.transparent {
    if (_mark == null || _mark.isNaN)
      startColor = Colors.blue;
    else
      startColor = Colors.deepOrange[900];
    endColor = Voto.getColor(mark);
  }

  @override
  void paint(Canvas canvas, Size size) {
    p.color = _backgroundColor;
    p.style = PaintingStyle.fill;
    canvas.drawOval(Rect.fromLTRB(5, 5, size.width - 5, size.height - 5), p);
    p.style = PaintingStyle.stroke;
    p.color = Color.fromARGB(
        255,
        ((endColor.red - startColor.red) * _progress + startColor.red).round(),
        ((endColor.green - startColor.green) * _progress + startColor.green)
            .round(),
        ((endColor.blue - startColor.blue) * _progress + startColor.blue)
            .round());
    if (_arcAngle != null && !_arcAngle.isNaN) {
      if (_arcAngle != 10)
        canvas.drawArc(Rect.fromLTRB(5, 5, size.width - 5, size.height - 5),
            -math.pi / 2, _progress * math.pi * _arcAngle / 5, false, p);
      else
        canvas.drawOval(
            Rect.fromLTRB(5, 5, size.width - 5, size.height - 5), p);
    }
    p.color = p.color.withAlpha(50);
    canvas.drawOval(Rect.fromLTRB(5, 5, size.width - 5, size.height - 5), p);

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

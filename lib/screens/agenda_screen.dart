import 'dart:math';
import 'dart:ui';

import 'package:Messedaglia/preferences/globals.dart';
import 'package:Messedaglia/screens/menu_screen.dart';
import 'package:Messedaglia/registro/registro.dart';
import 'package:Messedaglia/widgets/calendar.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:flutter_calendar_carousel/flutter_calendar_carousel.dart'
    show EventList;
import 'package:flutter_dash/flutter_dash.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import '../registro/agenda_registro_data.dart';
import '../registro/registro.dart';

class Agenda extends StatefulWidget {
  static final String id = 'agenda_screen';
  @override
  _AgendaState createState() => _AgendaState();
}

class _AgendaState extends State<Agenda> {
  DateTime _currentDate;

  EventList<Evento> get e => RegistroApi.agenda.data;

  List<Evento> dayEvents = List<Evento>();

  double lunghezzaDash = 0;

  void initState() {
    _currentDate =
        DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
    dayEvents = e.events[_currentDate] ?? [];
    RegistroApi.agenda.getData().then((r) {
      if (!r.reload || !mounted) return;
      _currentDate = DateTime(
          DateTime.now().year, DateTime.now().month, DateTime.now().day);
      dayEvents = e.events[_currentDate] ?? [];
      setState(() {});
    });

    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _setStateIfAlive() {
    if (mounted) setState(() {});
  }

  String _passedTime() {
    if (RegistroApi.agenda.lastUpdate == null) return 'mai aggiornato';
    Duration difference =
        DateTime.now().difference(RegistroApi.agenda.lastUpdate);
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
    RegistroApi.agenda.getData().then((r) {
      if (r.ok) _setStateIfAlive();
    });
    return null;
  }

  static int timelineStart = 0;

  @override
  Widget build(BuildContext context) {
    List<Widget> orariList = _orariList();
    var size = MediaQuery.of(context).size;
    return LiquidPullToRefresh(
      backgroundColor: Color.fromRGBO(66, 66, 66, 1),
      color: Theme.of(context).accentColor,
      //key: _refreshIndicatorKey,	// key if you want to add
      onRefresh: _refresh,
      showChildOpacityTransition: false, // refresh callback
      child: CustomScrollView(
        scrollDirection: Axis.vertical,
        slivers: <Widget>[
          SliverList(
            delegate: SliverChildListDelegate(
              [
                CustomPaint(
                  painter: BackgroundPainter(Theme.of(context)),
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 50),
                    child: Padding(
                      padding: EdgeInsets.only(
                          bottom: size.height / 100, top: size.height / 18),
                      child: Column(
                        children: <Widget>[
                          Text(
                            "AGENDA",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: Theme.of(context).brightness ==
                                        Brightness.light
                                    ? Colors.black
                                    : Colors.white,
                                fontSize: 30,
                                fontWeight: FontWeight.bold),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Calendar((day, events) => setState(() {
                                if (dayEvents != null && dayEvents.isNotEmpty)
                                  dayEvents.forEach((event) => event.seen());
                                dayEvents = events ?? [];
                                _currentDate = day;
                                lunghezzaDash = 0;
                              })),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 15.0),
                            child: SizedBox(
                              width: size.width,
                              child: Text(
                                '\n${_passedTime()}',
                                textAlign: TextAlign.right,
                                style: TextStyle(
                                    color: Theme.of(context).brightness ==
                                            Brightness.light
                                        ? Colors.black
                                        : Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: dayEvents
                      .where((event) => event.giornaliero)
                      .map((evento) => Stack(
                            alignment: Alignment(-0.9, 0.0),
                            overflow: Overflow.visible,
                            children: [
                              Container(
                                margin: EdgeInsets.only(left: 8.0),
                                width: 34.0,
                                height: 38.0,
                                decoration:
                                    BoxDecoration(color: Colors.white10),
                                child: SizedBox(),
                              ),
                              Padding(
                                padding: (_currentDate.day < 10)
                                    ? EdgeInsets.only(left: 18.5, top: 12.0)
                                    : EdgeInsets.only(left: 12.5, top: 12.0),
                                child: Text(
                                  DateFormat.d().format(_currentDate),
                                  style: TextStyle(
                                      fontSize: 16.0,
                                      fontFamily: 'CoreSans',
                                      color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black),
                                ),
                              ),
                              Icon(
                                Icons.calendar_today,
                                size: 50.0,
                                color: Colors.green[200],
                              ),
                              Padding(
                                  padding: EdgeInsets.fromLTRB(
                                    size.width / 6.0,
                                    size.height / 50.0,
                                    size.width / 19.0,
                                    size.height / 50.0,
                                  ),
                                  child: EventCard(
                                    evento: evento,
                                  )),
                            ],
                          ))
                      .toList(),
                ),
                if (dayEvents.any((evento) => !evento.giornaliero))
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    mainAxisSize: MainAxisSize.max,
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.only(left: 33.0),
                        child: Text(
                          'Ora',
                          style: TextStyle(color: Colors.blueGrey),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(left: 50.0),
                        child: Text(
                          'Evento',
                          style: TextStyle(color: Colors.blueGrey),
                        ),
                      ),
                    ],
                  ),
                SizedBox(height: 30.0),
                Row(
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20.0),
                          child: Column(children: orariList)),
                    ),
                    Dash(
                      direction: Axis.vertical,
                      dashBorderRadius: 0.0,
                      dashColor: Theme.of(context).brightness == Brightness.dark ? Colors.white54 : Colors.black54,
                      dashGap: 2,
                      dashThickness: 1.0,
                      length: lunghezzaDash - 47,
                    ),
                    Expanded(
                      child: Container(
                        height: 70.0 * orariList.length,
                        child: Stack(
                          overflow: Overflow.clip,
                          // FIXME: sovrapposizione di eventi
                          children: dayEvents
                              .where((event) => !event.giornaliero)
                              .map<Widget>((oggi) => EventCard(
                                    evento: oggi,
                                  ))
                              .toList(),
                        ),
                      ),
                    )
                  ],
                ),
                if (dayEvents.isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Text(
                      'Nessun evento programmato per questa giornata!',
                      textAlign: TextAlign.center,
                    ),
                  )
              ],
            ),
          )
        ],
      ), // scroll view
    );
  }

  List<Widget> _orariList() {
    int inizio = 24 * 60, fine = 0;
    dayEvents.where((event) => !event.giornaliero).forEach((event) {
      inizio = min(inizio, event.inizio.hour * 60 + event.inizio.minute);
      fine = max(fine, event.fine.hour * 60 + event.fine.minute);
    });
    if (inizio >= 24 * 60) return [];
    timelineStart = inizio ~/ 60;
    List<Widget> tr = [];
    lunghezzaDash = 0;
    for (int i = inizio ~/ 60 * 2; i < (fine + 30) ~/ 30; i++) {
      lunghezzaDash += 70;
      tr.add(SizedBox(
        height: 70,
        child: Text(
          '${(i ~/ 2).toString().padLeft(2, '0')}:${(i % 2 * 30).toString().padLeft(2, '0')}',
          style: TextStyle(color: Theme.of(context).brightness == Brightness.dark ?Colors.white60 : Colors.black54),
        ),
      ));
    }
    return tr;
  }
}

class EventCard extends StatelessWidget {
  final Evento evento;
  const EventCard({
    Key key,
    @required this.evento,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(
        top: !evento.giornaliero
            ? 70 *
                ((evento.inizio.hour - _AgendaState.timelineStart) * 2 +
                    evento.inizio.minute / 30)
            : 0.0),
      padding: EdgeInsets.only(left: 20, right: 10, bottom: 4, top: 4),
      child: Container(
        height: !evento.giornaliero
          ? 70 * evento.fine.difference(evento.inizio).inMinutes / 30
          : MediaQuery.of(context).size.height / 5.5,
        decoration: BoxDecoration(
            borderRadius: BorderRadiusDirectional.circular(20),
            color: Theme.of(context).brightness == Brightness.dark ? Colors.white10 : Colors.black12),
        padding: const EdgeInsets.all(10.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              height: double.infinity,
              decoration: BoxDecoration(
                  color: RegistroApi.subjects.data[evento.autore] == null ||
                          RegistroApi.subjects.data[evento.autore] is String
                      ? (Globals.subjects[RegistroApi.subjects.data[evento.autore]] ??
                                  {})['colore']
                              ?.withOpacity(0.7) ??
                          (Theme.of(context).brightness == Brightness.dark ? Colors.white10 : Colors.black12)
                      : null,
                  gradient: RegistroApi.subjects.data[evento.autore] is List ? LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                          colors: RegistroApi.subjects.data[evento.autore].reversed
                              .map<Color>((sbj) =>
                                  (Globals.subjects[sbj]['colore'] as Color))
                              .toList()) : null,
                  borderRadius: BorderRadius.circular(10.0)),
              child: Row(
                children: <Widget>[
                  Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      mainAxisSize: MainAxisSize.max,
                      children: RegistroApi.subjects.data[evento.autore] is List
                        ? RegistroApi.subjects.data[evento.autore].map<Widget>((sbj) => 
                        Padding(
                          padding: EdgeInsets.all(8),
                          child: Icon(
                            Globals.subjects[sbj]['icona'] ??
                                MdiIcons.sleep,
                            size: 25.0,
                            color: Colors.black
                          ),
                        )).toList() : [Padding(
                          padding: EdgeInsets.all(8),
                          child: Icon(
                            (Globals.subjects[RegistroApi
                                        .subjects.data[evento.autore]] ??
                                    {})['icona'] ??
                                MdiIcons.sleep,
                            size: 25.0,
                            color: RegistroApi.subjects.data[evento.autore] !=
                                    null
                                ? Colors.black
                                : Colors.white,
                          ),
                        )]
                      ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(left: 12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    AutoSizeText(evento.autore,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        minFontSize: 10.0,
                        maxFontSize: 15.0,
                        softWrap: true,
                        style: TextStyle(
                          fontSize: 15.0,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'CoreSans',
                        )),
                    SizedBox(
                      height: 5.0,
                    ),
                    Expanded(
                      child: AutoSizeText(evento.info,
                          maxLines: 5,
                          overflow: TextOverflow.ellipsis,
                          minFontSize: 10.0,
                          maxFontSize: 13.0,
                          style: TextStyle(
                            color: Theme.of(context).brightness == Brightness.dark ?Colors.white54 : Colors.black54,
                          )),
                    ),
                    Padding(
                      padding: EdgeInsets.only(bottom: 2.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: <Widget>[
                          Icon(
                            Icons.access_time,
                            size: 14.0,
                          ),
                          SizedBox(width: 5.0),
                          Text(
                            !evento.giornaliero
                                ? '${DateFormat.Hm().format(evento.inizio)}-${DateFormat.Hm().format(evento.fine)}'
                                : 'Giornaliero',
                            style: TextStyle(fontSize: 11.0),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
            Center(
              child: evento.nuovo ?? true
                  ? Icon(
                      Icons.brightness_1,
                      color: Colors.yellow,
                      size: 15.0,
                    )
                  : SizedBox(),
            ),
          ],
        ),
      ),
    );
  }
}

DateTime getDayFromDT (DateTime dt) => DateTime(dt.year, dt.month, dt.day);

import 'dart:math';
import 'dart:ui';

import 'package:Messedaglia/preferences/globals.dart';
import 'package:Messedaglia/registro/lessons_registro_data.dart';
import 'package:Messedaglia/screens/menu_screen.dart';
import 'package:Messedaglia/registro/registro.dart';
import 'package:Messedaglia/widgets/calendar.dart';
import 'package:Messedaglia/widgets/expansion_sliver.dart';
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

class _AgendaState extends State<Agenda> with SingleTickerProviderStateMixin {
  DateTime _currentDate;

  EventList<Evento> get e => RegistroApi.agenda.data;

  List<Evento> dayEvents = List<Evento>();
  List<Lezione> dayLessons = List<Lezione>();
  Evento _onTop;

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
          ExpansionSliver(ExpansionSliverDelegate(
            context,
            title: 'AGENDA',
            vsync: this,
            body: Calendar((day, events) => setState(() {
                  if (dayEvents != null && dayEvents.isNotEmpty)
                    dayEvents.forEach((event) => event.seen());
                  dayEvents = events ?? [];
                  dayLessons = RegistroApi.lessons.data['date'][day];
                  _currentDate = day;
                  lunghezzaDash = 0;
                })),
          )),
          SliverList(
            delegate: SliverChildListDelegate(
              [
                if (dayLessons != null)
                  Column(
                    // TODO: per ora lo piazzo qui
                    children: dayLessons
                        .map((l) => ListTile(
                              title: Text(l.sbj),
                              subtitle: Text(
                                (RegistroApi.subjects.data[l.author] == l.sbj ||
                                            (RegistroApi.subjects.data[l.author]
                                                    ?.contains(l.sbj) ??
                                                false)
                                        ? ''
                                        : '(${l.author})\n') +
                                    l.lessonType,
                                style: Theme.of(context).textTheme.bodyText1,
                              ),
                              leading: CircleAvatar(
                                child: Text('${l.hour + 1}ª',
                                    style: TextStyle(
                                      color: Colors.white,
                                    )),
                                backgroundColor:
                                    (Globals.subjects[l.sbj] ?? {})['colore']
                                            ?.withOpacity(0.3) ??
                                        Colors.white24,
                              ),
                              trailing: CircleAvatar(
                                  child: Text('${l.duration.inHours} h',
                                      style: TextStyle(
                                        color: Colors.white,
                                      )),
                                  backgroundColor:
                                      (Globals.subjects[l.sbj] ?? {})['colore']
                                              ?.withOpacity(0.3) ??
                                          Colors.white24),
                            ))
                        .toList(),
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
                                      color: Theme.of(context).brightness ==
                                              Brightness.dark
                                          ? Colors.white
                                          : Colors.black),
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
                      dashColor: Theme.of(context).brightness == Brightness.dark
                          ? Colors.white54
                          : Colors.black54,
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
                              .where((event) =>
                                  !event.giornaliero && event != _onTop)
                              .map<Widget>((oggi) => EventCard(
                                    evento: oggi,
                                    onTap: () => setState(() => _onTop = oggi),
                                  ))
                              .followedBy([
                            if (_onTop != null && dayEvents.contains(_onTop))
                              EventCard(evento: _onTop)
                          ]).toList(),
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
          style: TextStyle(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white60
                  : Colors.black54),
        ),
      ));
    }
    return tr;
  }
}

class EventCard extends StatelessWidget {
  final Evento evento;
  final Function() onTap;
  const EventCard({Key key, @required this.evento, this.onTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onDoubleTap: () => showDialog(
        context: context,
        builder: (context) => Padding(
          padding: EdgeInsets.symmetric(
              horizontal: 10.0,
              vertical: MediaQuery.of(context).size.height / 6),
          child: Dialog(
              backgroundColor: Theme.of(context).brightness == Brightness.dark
                  ? Color(0xFF33333D)
                  : Colors.black12,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: _buildContent(context, true),
              )),
        ),
      ),
      child: Container(
        margin: EdgeInsets.only(
            top: !evento.giornaliero
                ? 70 *
                    ((evento.inizio.hour - _AgendaState.timelineStart) * 2 +
                        evento.inizio.minute / 30)
                : 0.0),
        height: !evento.giornaliero
            ? 70 * evento.fine.difference(evento.inizio).inMinutes / 30
            : MediaQuery.of(context).size.height / 5.5,
        padding: EdgeInsets.only(left: 20, right: 10, bottom: 4, top: 4),
        child: Container(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black26, blurRadius: 3.0, spreadRadius: 4.5)
                ],
                //border: Border.all(color: Colors.white24),
                color: Theme.of(context).brightness == Brightness.dark
                    ? Color(0xFF33333D)
                    : Colors
                        .black12), // TODO: fix light theme per avere sfondo opaco
            padding: const EdgeInsets.all(10.0),
            child: _buildContent(context, false)),
      ),
    );
  }

  Widget _buildContent(BuildContext context, bool grande) => Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Container(
            decoration: BoxDecoration(
                color: RegistroApi.subjects.data[evento.autore] == null ||
                        RegistroApi.subjects.data[evento.autore] is String
                    ? (Globals.subjects[RegistroApi.subjects.data[evento.autore]] ??
                                {})['colore']
                            ?.withOpacity(0.7) ??
                        (Theme.of(context).brightness == Brightness.dark
                            ? Colors.white10
                            : Colors.black12)
                    : null,
                gradient: RegistroApi.subjects.data[evento.autore] is List
                    ? LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: RegistroApi.subjects.data[evento.autore].reversed
                            .map<Color>(
                                (sbj) => (Globals.subjects[sbj]['colore'] as Color))
                            .toList())
                    : null,
                borderRadius: BorderRadius.circular(10.0)),
            child: Row(
              children: <Widget>[
                Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    mainAxisSize: MainAxisSize.max,
                    children: RegistroApi.subjects.data[evento.autore] is List
                        ? RegistroApi.subjects.data[evento.autore]
                            .map<Widget>((sbj) => Padding(
                                  padding: EdgeInsets.all(8),
                                  child: Icon(
                                      Globals.subjects[sbj]['icona'] ??
                                          MdiIcons.sleep,
                                      size: 25.0,
                                      color: Colors.black),
                                ))
                            .toList()
                        : [
                            Padding(
                              padding: EdgeInsets.all(8),
                              child: Icon(
                                (Globals.subjects[RegistroApi
                                            .subjects.data[evento.autore]] ??
                                        {})['icona'] ??
                                    MdiIcons.sleep,
                                size: 25.0,
                                color:
                                    RegistroApi.subjects.data[evento.autore] !=
                                            null
                                        ? Colors.black
                                        : Colors.white,
                              ),
                            )
                          ]),
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
                      style: TextStyle(
                        fontSize: 15.0,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'CoreSans',
                      )),
                  SizedBox(
                    height: 10.0,
                  ),
                  Expanded(
                    child: grande
                        ? SingleChildScrollView(
                            child: AutoSizeText(evento.info,
                                overflow: TextOverflow.ellipsis,
                                minFontSize: 13.0,
                                maxFontSize: 16.0,
                                maxLines: 100,
                                style: TextStyle(
                                  color: Theme.of(context).brightness ==
                                          Brightness.dark
                                      ? Colors.white54
                                      : Colors.black54,
                                )),
                          )
                        : AutoSizeText(evento.info,
                            overflow: TextOverflow.ellipsis,
                            minFontSize: 13.0,
                            maxFontSize: 15.0,
                            maxLines: 6,
                            style: TextStyle(
                              color: Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? Colors.white54
                                  : Colors.black54,
                            )),
                  ),
                  Padding(
                    padding:
                        EdgeInsets.only(bottom: 2.0, top: grande ? 10.0 : 0.0),
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
                          style: TextStyle(fontSize: grande ? 14 : 11.0),
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
      );
}

DateTime getDayFromDT(DateTime dt) => DateTime(dt.year, dt.month, dt.day);

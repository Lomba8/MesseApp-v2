import 'dart:math';

import 'package:applicazione_prova/screens/menu_screen.dart';
import 'package:applicazione_prova/registro/registro.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:flutter_calendar_carousel/flutter_calendar_carousel.dart'
    show CalendarCarousel, EventList;

import '../registro/agenda_registro_data.dart';
import '../registro/registro.dart';

class Agenda extends StatefulWidget {
  static final String id = 'agenda_screen';
  @override
  _AgendaState createState() => _AgendaState();
}

class _AgendaState extends State<Agenda> {
  DateTime _currentDate, _currentMonth = DateTime.now();

  EventList<Evento> get e => RegistroApi.agenda.data;

  List<Evento> dayEvents = List<Evento>();

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
    RegistroApi.agenda.getData().then((r) {
      if (r.reload) _setStateIfAlive();
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
                          bottom: size.height / 30, top: size.height / 18),
                      child: Text(
                        "Agenda",
                        textAlign: TextAlign
                            .center, //FIXME: _calendarController si inizializza solo dopo un secondo come fare ad aspettare la sua inizalizzazione?
                        style: TextStyle(
                            color:
                                Theme.of(context).brightness == Brightness.light
                                    ? Colors.black
                                    : Colors.white,
                            fontSize: 30,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
                CalendarCarousel<Evento>(
                  onDayPressed: (DateTime date, List<Evento> events) {
                    if (date.isAtSameMomentAs(_currentDate)) return;
                    setState(() {
                      if (dayEvents != null && dayEvents.isNotEmpty)
                        dayEvents.forEach((event) => event.seen());
                      dayEvents = events ?? [];
                      _currentDate = date;
                    });
                  },
                  // isScrollable: true,
                  scrollDirection: Axis.horizontal,
                  onCalendarChanged: (d) => setState(() => _currentMonth = d),

                  weekendTextStyle: TextStyle(
                    color: Theme.of(context).accentColor,
                  ),
                  // weekdayTextStyle: TextStyle(color: Colors.white60),
                  thisMonthDayBorderColor: Colors.transparent,
                  showWeekDays: true,
                  firstDayOfWeek: 1,
                  daysTextStyle: TextStyle(color: Colors.white70),
                  headerMargin: EdgeInsets.symmetric(
                      horizontal: MediaQuery.of(context).size.width / 8),
                  headerText: DateFormat.yMMMM().format(_currentMonth),
                  headerTextStyle: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontSize: 22.0,
                      fontFamily: 'CoreSansRounded'),
                  iconColor: Theme.of(context).primaryColor,
                  locale: 'it',
                  prevDaysTextStyle: TextStyle(color: Colors.white24),
                  nextDaysTextStyle: TextStyle(color: Colors.white24),
                  weekdayTextStyle: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'CoreSansRounded'),
                  showIconBehindDayText: true,
                  pageSnapping: false,

                  markedDatesMap: e,
                  todayButtonColor: Colors.transparent,
                  selectedDayBorderColor: Colors.blue,
                  selectedDayButtonColor: Colors.transparent,

                  /// for pass null when you do not want to render weekDays
                  //headerText: 'Custom Header',
                  weekFormat: false,
                  selectedDateTime: _currentDate,
                  height: 350,
                  daysHaveCircularBorder: true,
                  //markedDateIconBuilder: (event) => event.icon,

                  /// null for not rendering any border, true for circular border, false for rectangular border
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
                                decoration: BoxDecoration(
                                    color: Colors
                                        .white10 //Color.fromRGBO(22, 22, 31, 1),
                                    ),
                                child: SizedBox(),
                              ),
                              Padding(
                                padding: EdgeInsets.only(left: 12.5, top: 12.0),
                                child: Text(
                                  DateFormat.d().format(_currentDate),
                                  style: TextStyle(
                                      fontSize: 16.0,
                                      fontFamily: 'CoreSans',
                                      color: Colors.white),
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
                                  child: ConstrainedBox(
                                    constraints: BoxConstraints.tight(Size(
                                        double.infinity, size.height / 6.0)),
                                    child: EventCard(
                                      evento: evento,
                                    ),
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
                      decoration: BoxDecoration(
                          border: Border(
                              right:
                                  BorderSide(color: Colors.white54, width: 1))),
                      child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20.0),
                          child: Column(children: orariList)),
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
    for (int i = inizio ~/ 60 * 2; i < fine ~/ 30; i++)
      tr.add(SizedBox(
        height: 70,
        child: Text(
          '${(i ~/ 2).toString().padLeft(2, '0')}:${(i % 2 * 30).toString().padLeft(2, '0')}',
          style: TextStyle(color: Colors.white60),
        ),
      ));
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
    print(evento.inizio.hour);
    print(_AgendaState.timelineStart);
    return Padding(
      padding: EdgeInsets.only(
          top: !evento.giornaliero
              ? 70 *
                  ((evento.inizio.hour - _AgendaState.timelineStart) * 2 +
                      evento.inizio.minute / 30)
              : 0.0),
      child: Container(
        height: !evento.giornaliero
            ? 70 * evento.fine.difference(evento.inizio).inMinutes / 30
            : 140.0,
        child: Padding(
          padding: EdgeInsets.only(left: 20, right: 10, bottom: 4, top: 4),
          child: Container(
            decoration: BoxDecoration(
                borderRadius: BorderRadiusDirectional.circular(20),
                color: Colors.white10),
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    height: double.infinity,
                    decoration: BoxDecoration(
                        color: Colors.green[200],
                        borderRadius: BorderRadius.circular(10.0)),
                    child: Align(
                      alignment: Alignment.topCenter,
                      child: Padding(
                        padding: EdgeInsets.all(8),
                        child: Icon(
                          Icons.adb, // TODO: cosa ci mettiamo?
                          size: 25.0,
                          color: Colors.green[
                              600], //TODO: mappa in globals.dart con corrispondenza autore icona colore
                          //                se giornaliero cambiare colore a prescienere dalla materia
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(left: 12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(evento.autore,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              softWrap: true,
                              style: TextStyle(
                                fontSize: 10.0,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'CoreSans',
                              )),
                          Expanded(
                            child: Text(evento.info,
                                maxLines: 5,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 10.0,
                                  color: Colors.white54,
                                  fontFamily: 'CoreSans',
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
                    child: evento.nuovo
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
          ),
        ),
      ),
    );
  }
}

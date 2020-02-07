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
  var _currentDate, _currentMonth = DateTime.now();
  List<String> orari = [];

  EventList<Evento> get e => RegistroApi.agenda.data;

  List<Evento> e_day = List<Evento>();
  Evento e_day_giornaliero;
  bool esistono_eventi_giornalieri = false;

  void initState() {
    for (int i = 7; i < 17; i++) {
      // TODO: mettere solo l'intervallo orario di interesse
      orari.add('${i.toString().padLeft(2, '0')}:00');
      orari.add('${i.toString().padLeft(2, '0')}:30');
    }
    RegistroApi.agenda.getData().then((r) {
      var year = DateTime.now().year;
      var month = DateTime.now().month;
      var day = DateTime.now().day;
      _currentDate = DateTime(year, month, day);
      e_day = e.events[_currentDate];
      if (r.reload && mounted) setState(() {});
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

  @override
  Widget build(BuildContext context) {
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
                      if (e_day != null && e_day.isNotEmpty)
                        for (int i = 0; i < e_day.length; i++) e_day[i].seen();
                      esistono_eventi_giornalieri = false;
                      events.forEach((f) {
                        if (f.giornaliero) {
                          e_day_giornaliero = f;
                          esistono_eventi_giornalieri = true;
                        }
                      });
                      e_day = events;
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
                  customDayBuilder: (
                    /// you can provide your own build function to make custom day containers
                    bool isSelectable,
                    int index,
                    bool isSelectedDay,
                    bool isToday,
                    bool isPrevMonthDay,
                    TextStyle textStyle,
                    bool isNextMonthDay,
                    bool isThisMonthDay,
                    DateTime day,
                  ) {
                    /// If you return null, [CalendarCarousel] will build container for current [day] with default function.
                    /// This way you can build custom containers for specific days only, leaving rest as default.
                    //if (isSelectedDay) print(_currentDate.toIso8601String());
                    // Example: every 15th of month, we have a flight, we can place an icon in the container like that:
                    return null;
                  },
                  weekFormat: false,
                  selectedDateTime: _currentDate,
                  height: 350,
                  daysHaveCircularBorder: true,
                  //markedDateIconBuilder: (event) => event.icon,

                  /// null for not rendering any border, true for circular border, false for rectangular border
                ),
                if (e_day_giornaliero != null &&
                    esistono_eventi_giornalieri == true)
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 30.0,
                          vertical: 10.0), //TODO: dynamic values
                      child: ConstrainedBox(
                        constraints: BoxConstraints.tight(Size(
                            double.infinity, 100.0)), //TODO: dynamic values
                        child: EventCard(
                          evento: e_day_giornaliero,
                        ),
                      ),
                    ),
                  ),
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
                SingleChildScrollView(
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        decoration: BoxDecoration(
                            border: Border(
                                right: BorderSide(
                                    color: Colors.white54, width: 1))),
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20.0),
                          child: Column(
                              children: orari
                                  .map(
                                    (n) => SizedBox(
                                      height: 70,
                                      child: Text(
                                        n,
                                        style: TextStyle(color: Colors.white60),
                                      ),
                                    ),
                                  )
                                  .toList()),
                        ),
                      ),
                      if (e_day != null)
                        Expanded(
                          child: Container(
                            height: 140.0 * 10,
                            child: Stack(
                              overflow: Overflow.clip,
                              // FIXME: sovrapposizione di eventi
                              children: e_day.map<Widget>((oggi) {
                                if (!oggi.giornaliero) {
                                  return EventCard(
                                    evento: oggi,
                                  );
                                } else {
                                  return SizedBox();
                                }
                              }).toList(),
                            ),
                          ),
                        )
                    ],
                  ),
                ),
              ],
            ),
          )
        ],
      ), // scroll view
    );
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
    return Padding(
      padding: EdgeInsets.only(
          top: !evento.giornaliero
              ? 70 * ((evento.inizio.hour - 7) * 2 + evento.inizio.minute / 30)
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

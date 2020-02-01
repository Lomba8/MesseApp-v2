import 'package:applicazione_prova/registro/agenda_registro_data.dart';
import 'package:applicazione_prova/screens/eventi.dart';
import 'package:applicazione_prova/screens/menu_screen.dart';
import 'package:applicazione_prova/registro/registro.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_calendar_carousel/classes/event.dart';
import 'package:intl/intl.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:flutter_calendar_carousel/flutter_calendar_carousel.dart'
    show CalendarCarousel, EventList;

class Agenda extends StatefulWidget {
  static final String id = 'agenda_screen';
  @override
  _AgendaState createState() => _AgendaState();
}

class _AgendaState extends State<Agenda> {
  var _currentDate, _currentMonth = DateTime.now();

  String _formatMonth(DateTime date) {
    if (date != null) return DateFormat("MMMM").format(date).toString();
  }

  String _formatYear(DateTime date) {
    if (date != null) return DateFormat("y").format(date).toString();
  }

  var e, e_day;

  void initState() {
    RegistroApi.agenda.getData().then((r) {
      e = RegistroApi.agenda.events;
      var year = int.parse(DateFormat.y().format(DateTime.now()));
      var month = int.parse(DateFormat.M().format(DateTime.now()));
      var day = int.parse(DateFormat.d().format(DateTime.now()));
      e_day = e.events[DateTime(year, month, day)];
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
    Duration difference = DateTime.now()
        .difference((DateTime.parse(RegistroApi.voti.lastUpdate)));
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
                CalendarCarousel<Event>(
                  onDayPressed: (DateTime date, List<Event> events) {
                    setState(() {
                      e_day = events;
                      _currentDate = date;
                      print(date);
                      print(events);

                      var year = int.parse(DateFormat.y().format(date));
                      var month = int.parse(DateFormat.M().format(date));
                      var day = int.parse(DateFormat.d().format(date));

                      print(e.events[DateTime(year, month, day)][0].nuovo);

                      for (int i = 0; i < events.length; i++) {
                        //_nuovo = events[i].nuovo;
                        e.events[DateTime(year, month, day)][0].nuovo =
                            false; // TODO:gestire casi con piu eventi in una giornata

                        if (events.length > 1) {
                          // _info += events[i].title + '\n';
                          // _inizio +=
                          //     DateFormat.jm().format(events[i].getInizio()) +
                          //         '\n';
                          // _fine = DateFormat.jm().format(events[i].getFine());
                          // _autore = events[i].autore;
                          // _giornaliero = events[1].giornaliero;
                          // _nuovo = events[i].nuovo = false;
                        } else {
                          // _info = events[i].title;
                          // _inizio =
                          //     DateFormat.jm().format(events[i].getInizio());
                          // _fine = DateFormat.jm().format(events[i].getFine());
                          // _autore = events[i].autore;
                          // _giornaliero = events[1].giornaliero;
                          // _nuovo = events[i].nuovo = false;
                        }
                      }
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
                  height: 420,
                  daysHaveCircularBorder: true,
                  //markedDateIconBuilder: (event) => event.icon,

                  /// null for not rendering any border, true for circular border, false for rectangular border
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        decoration: BoxDecoration(
                            border: Border(
                                right: BorderSide(
                                    color: Colors.white54, width: 1))),
                        child: Padding(
                          padding: EdgeInsets.only(right: 20, left: 20.0),
                          child: Column(
                              children: [
                            ' 8:00',
                            ' 8:30',
                            ' 9:00',
                            ' 9:30',
                            '10:00',
                            '10:30',
                            '11:00',
                            '11:30',
                            '12:00',
                            '12:30',
                            '13:00'
                          ]
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
                        Column(
                          children: e_day.map<Widget>((oggi) {
                            print(oggi);
                            return EventCard(
                              evento: oggi,
                            );
                          }).toList(),
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
  final Event evento;
  const EventCard({
    Key key,
    @required this.evento,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Container(
            decoration: BoxDecoration(
                borderRadius: BorderRadiusDirectional.circular(20),
                color: Colors.white10),
            height: 140,
            width: 250,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                              color: Colors.green[200],
                              borderRadius: BorderRadius.circular(10.0)),
                          child: Align(
                            alignment: Alignment(0.5, -0.7),
                            child: SizedBox(
                              width: 40.0,
                              child: Icon(
                                Icons.adb,
                                size: 25.0,
                                color: Colors.green[600],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: 12.0, vertical: 2.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        RichText(
                          text: TextSpan(
                            text: 'Titolo evento\n',
                            style: TextStyle(
                              fontSize: 20.0,
                              fontWeight: FontWeight.bold,
                            ),
                            children: <TextSpan>[
                              TextSpan(
                                text: 'Descrizione',
                                style: TextStyle(
                                  fontSize: 15.0,
                                  fontWeight: FontWeight.normal,
                                  color: Colors.white54,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 2.0),
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
                                '8:00-9:00',
                                style: TextStyle(fontSize: 11.0),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: <Widget>[
                        Icon(
                          Icons.brightness_1,
                          color: Colors.green[600],
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}

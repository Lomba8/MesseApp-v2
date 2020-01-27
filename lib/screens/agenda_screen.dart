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
  String _info = ' ',
      _inizio = ' ',
      _fine = ' ',
      _autore = ' ',
      _classe = AgendaRegistroData.classe;
  bool _giornaliero;
  var _nuovo;
  var _currentDate, _currentMonth = DateTime.now();

  String _formatMonth(DateTime date) {
    if (date != null) return DateFormat("MMMM").format(date).toString();
  }

  String _formatYear(DateTime date) {
    if (date != null) return DateFormat("y").format(date).toString();
  }

  var e;

  void initState() {
    RegistroApi.agenda.getData().then((r) {
      e = RegistroApi.agenda.events;
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
                      _currentDate = date;
                      print(date);
                      print(events);

                      var year = int.parse(DateFormat.y().format(date));
                      var month = int.parse(DateFormat.M().format(date));
                      var day = int.parse(DateFormat.d().format(date));

                      print(e.events[DateTime(year, month, day)][0].nuovo);

                      for (int i = 0; i < events.length; i++) {
                        _nuovo = events[i].nuovo;
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
                Container(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      Flexible(
                        child: Text(
                          _info,
                          softWrap: true,
                          overflow: TextOverflow.visible,
                          style: TextStyle(fontSize: 10.0),
                        ),
                      ),
                      Flexible(
                        child: Text(
                          "$_inizio-$_fine $_nuovo",
                          softWrap: true,
                          overflow: TextOverflow.visible,
                          style: TextStyle(fontSize: 10.0),
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          )
        ],
      ), // scroll view
    );
  }
}

import 'dart:io';

import 'package:applicazione_prova/screens/menu_screen.dart';
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

  Future<void> _refresh() async {
    print('something');
    setState(() {});
  }

  String _formatMonth(DateTime date) {
    if (date != null) return DateFormat("MMMM").format(date).toString();
  }

  String _formatYear(DateTime date) {
    if (date != null) return DateFormat("y").format(date).toString();
  }

  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return LiquidPullToRefresh(
      //key: _refreshIndicatorKey,	// key if you want to add
      onRefresh: _refresh,
      showChildOpacityTransition: false, // refresh callback
      child: CustomScrollView(
        scrollDirection: Axis.vertical,
        slivers: <Widget>[
          SliverList(
            delegate: SliverChildListDelegate([
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
                  });
                },
                pageScrollPhysics: NeverScrollableScrollPhysics(),
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

                markedDatesMap: EventList<Event>(events: {
                  DateTime(2020, 1, 24): [
                    Event(
                        date: DateTime(2020, 1, 24),
                        title: 'test',
                        icon: Icon(
                          Icons.exposure,
                          size: 20.0,
                        ),
                        dot: Container(
                          margin: EdgeInsets.all(1.0),
                          height: 8.0,
                          width: 8.0,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10.0),
                            color: Color.fromRGBO(115, 187, 126, 1),
                          ),
                        ))
                  ]
                }),
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
                height: 420.0,
                selectedDateTime: _currentDate,
                daysHaveCircularBorder: true,
                //markedDateIconBuilder: (event) => event.icon,

                /// null for not rendering any border, true for circular border, false for rectangular border
              ),
            ]),
          )
        ],
      ), // scroll view
    );
  }
}

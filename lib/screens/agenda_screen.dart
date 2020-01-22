import 'dart:io';

import 'package:applicazione_prova/screens/menu_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:table_calendar/table_calendar.dart';

class Agenda extends StatefulWidget {
  static final String id = 'agenda_screen';
  @override
  _AgendaState createState() => _AgendaState();
}

class _AgendaState extends State<Agenda> {
  Future<void> _refresh() async {
    print(_formatMonth(_calendarController.focusedDay));
    setState(() {});
  }

  String _formatMonth(DateTime date) {
    if (date != null) return DateFormat("MMMM").format(date).toString();
  }

  String _formatYear(DateTime date) {
    if (date != null) return DateFormat("y").format(date).toString();
  }

  CalendarController _calendarController;

  void initState() {
    super.initState();
    _calendarController = CalendarController();
  }

  @override
  void dispose() {
    _calendarController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    _calendarController = CalendarController();
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
                  padding: const EdgeInsets.only(bottom: 50, right: 10),
                  child: Padding(
                    padding: EdgeInsets.only(
                        bottom: size.height / 30, top: size.height / 18),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          "Agenda ${DateTime.now().year}", //FIXME: _calendarController si inizializza solo dopo un secondo come fare ad aspettare la sua inizalizzazione?
                          style: TextStyle(
                              color: Theme.of(context).brightness ==
                                      Brightness.light
                                  ? Colors.black
                                  : Colors.white,
                              fontSize: 30,
                              fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              TableCalendar(
                locale: 'it_IT',
                calendarController: _calendarController,
                startingDayOfWeek: StartingDayOfWeek.monday,
                onUnavailableDaySelected: () => () {},
                startDay:
                    DateTime(DateTime.now().year.toInt(), DateTime.now().month),
                endDay: DateTime(DateTime.now().year.toInt(), 12, 31, 23, 59),
                weekendDays: [7],
                calendarStyle: CalendarStyle(
                  outsideDaysVisible: false,
                  weekendStyle: TextStyle(color: Theme.of(context).accentColor),
                  weekdayStyle: TextStyle(color: Colors.white70),
                ),
                daysOfWeekStyle: DaysOfWeekStyle(
                  weekendStyle: TextStyle(color: Theme.of(context).accentColor),
                  weekdayStyle: TextStyle(color: Colors.white70),
                ),
                availableGestures: AvailableGestures.horizontalSwipe,
                headerStyle: HeaderStyle(
                  formatButtonVisible: false,
                  centerHeaderTitle: true,
                  titleTextBuilder: (date, locale) =>
                      _formatMonth(date).toUpperCase(),
                  titleTextStyle: TextStyle(
                    fontSize: 23.0,
                    color: Theme.of(context).primaryColor,
                  ),
                  leftChevronIcon: Icon(
                    Icons.arrow_back_ios,
                    size: 20.0,
                    color:
                        (MediaQuery.platformBrightnessOf(context).toString() ==
                                "Brightness.dark")
                            ? Theme.of(context).primaryColor
                            : Colors.black,
                  ),
                  leftChevronMargin: EdgeInsets.only(left: size.width / 5),
                  rightChevronIcon: Icon(
                    Icons.arrow_forward_ios,
                    size: 20.0,
                    color:
                        (MediaQuery.platformBrightnessOf(context).toString() ==
                                "Brightness.dark")
                            ? Theme.of(context).primaryColor
                            : Colors.black,
                  ),
                  rightChevronMargin: EdgeInsets.only(right: size.width / 5),
                ),
              )
            ]),
          )
        ],
      ), // scroll view
    );
  }
}

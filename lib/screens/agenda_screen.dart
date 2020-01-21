import 'dart:io';

import 'package:applicazione_prova/screens/menu_screen.dart';
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
    _calendarController.setFocusedDay(DateTime.now());
    print("${_calendarController.focusedDay}");
  }

  @override
  void dispose() {
    _calendarController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    // print("${_calendarController.focusedDay.toString()}");

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
                        bottom: MediaQuery.of(context).size.height / 30,
                        top: MediaQuery.of(context).size.height / 18),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          "${_formatMonth(_calendarController.focusedDay) ?? _formatMonth(DateTime.now())} ${_formatYear(_calendarController.focusedDay) ?? DateTime.now().year}", //FIXME: _calendarController si inizializza solo dopo un secondo come fare ad aspettare la sua inizalizzazione?
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
              )
            ]),
          )
        ],
      ), // scroll view
    );
  }
}

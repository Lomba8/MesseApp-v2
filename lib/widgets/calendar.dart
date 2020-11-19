import 'dart:math';

import 'package:Messedaglia/main.dart';
import 'package:Messedaglia/registro/agenda_registro_data.dart';
import 'package:Messedaglia/screens/agenda_screen.dart';
import 'package:Messedaglia/widgets/expansion_sliver.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:Messedaglia/main.dart' as main;

Map<String, Calendar> _instances = {};
const int _pagesCount = 2000;

class Calendar extends ResizableWidget {
  final void Function(DateTime day, List<Evento> events) _onDayChanged;
  PageController _controller;
  int _page = 0;

  DateTime _currentDay; //= DateTime.now();
  static final Curve _curve = Curves.easeIn;
  final String Function() passedTime;

  set currentDay(DateTime currentDay) {
    _onDayChanged(
      _currentDay = currentDay,
      session.agenda.getEvents(currentDay),
    );
  }

  Calendar(
      [this._currentDay, this._onDayChanged, String key, this.passedTime]) {
    if (key != null) {
      _page = _instances[key]?._page ?? 0;
      _controller = PageController(
          initialPage: _currentDay.month > DateTime.now().month
              ? _pagesCount ~/ 2 + 1 /* + _page*/
              : _pagesCount ~/ 2 /* + _page*/);
      _instances[key] = this;
    } else {
      _page = 0;
      _controller = PageController(
          initialPage: _currentDay.month > DateTime.now().month
              ? _pagesCount ~/ 2 + 1
              : _pagesCount ~/ 2);
    }
    _currentDay ??= getDayFromDT(_currentDay ?? DateTime.now());
  }

  @override
  Widget build(BuildContext context, [double heightFactor]) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.symmetric(vertical: 8, horizontal: 30),
          child: Row(
            children: <Widget>[
              IconButton(
                  icon: Icon(
                    Icons.arrow_back_ios,
                    color: Theme.of(context).primaryColor,
                  ),
                  onPressed: () => _controller.previousPage(
                      duration: Duration(milliseconds: 200), curve: _curve)),
              Expanded(
                  child: Text(
                DateFormat.yMMMM('it')
                    .format(DateTime(
                        DateTime.now().year, DateTime.now().month + _page))
                    .toUpperCase(),
                textAlign: TextAlign.center,
                style: TextStyle(color: Theme.of(context).primaryColor),
              )),
              IconButton(
                  icon: Icon(
                    Icons.arrow_forward_ios,
                    color: Theme.of(context).primaryColor,
                  ),
                  onPressed: () => _controller.nextPage(
                      duration: Duration(milliseconds: 200), curve: _curve))
            ],
          ),
        ),
        Row(
          children: ['lun', 'mar', 'mer', 'gio', 'ven', 'sab', 'dom']
              .map((g) => Expanded(
                      child: Text(
                    g,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.white
                            : Colors.black,
                        fontWeight: FontWeight.w600),
                  )))
              .toList(),
        ),
        Container(
          height: MediaQuery.of(context).size.width /
              7 *
              interpolate(1.0, 6.0,
                  heightFactor), // il massimo numero di righe è 6, il massimo numero di colonne è 7: i giorni sono in un aspect ratio di 1:1
          child: PageView.builder(
            itemCount: _pagesCount,
            onPageChanged: (value) {
              _page = value - _pagesCount ~/ 2;
              currentDay = _currentDay;
            },
            controller: _controller,
            itemBuilder: (context, i) => Stack(
              children: _children(context, i - _pagesCount ~/ 2, heightFactor)
                  .toList(),
            ),
          ),
        ),
        Container(
          height: kToolbarHeight,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              AutoSizeText(
                '${main.session.agenda.newEventi > 0 ? main.session.agenda.newEventi : 'nessun'} nuov${main.session.agenda.newEventi > 1 ? 'i' : 'o'} event${main.session.agenda.newEventi > 1 ? 'i' : 'o'} - ${passedTime()}               ',
                textAlign: TextAlign.center,
                minFontSize: 10,
                maxFontSize: 13,
                maxLines: 1,
              ),
            ],
          ),
        ),
      ],
    );
  }

  // TODO: fix chiusura completa dell'header quando ci sono pochi eventi
  Iterable<Widget> _children(BuildContext context, int index,
      [double heightFactor = 0]) sync* {
    // TODO: se il giorno selezionato è in un altro mese, che settimana prendiamo?
    // TODO: in modalità settimana le page devono andare di 7gg in 7gg
    DateTime firstDayOfMonth =
        DateTime.utc(DateTime.now().year, DateTime.now().month + index);
    int month = firstDayOfMonth.month;
    DateTime firstDayRendered;
    DateTime startDay = firstDayRendered =
        firstDayOfMonth.subtract(Duration(days: firstDayOfMonth.weekday - 1));
    final int safeWeek = _currentDay.year == firstDayOfMonth.year &&
            _currentDay.month == firstDayOfMonth.month
        ? _currentDay.difference(firstDayRendered).inDays ~/ 7
        : 0;
    while (startDay.month == month ||
        startDay.isBefore(firstDayOfMonth) ||
        startDay.weekday != 1) {
      final DateTime day = startDay;
      final int week = day.difference(firstDayRendered).inDays ~/ 7;
      final int animationOrder = week > safeWeek ? week - 1 : week;
      final double weekFactor =
          max(0, min(1, (heightFactor - (4 - animationOrder) / 5) * 5));

      if ((4 - animationOrder) / 5 < heightFactor || week == safeWeek)
        yield Positioned(
          width: MediaQuery.of(context).size.width / 7,
          height: MediaQuery.of(context).size.width /
              7 *
              (week == safeWeek ? 1 : weekFactor),
          left: (day.weekday - 1) * MediaQuery.of(context).size.width / 7,
          top: max<double>(
                  (week - animationOrder).toDouble(),
                  interpolate(
                      week.toDouble() - 5, week.toDouble(), heightFactor)) *
              MediaQuery.of(context).size.width /
              7,
          child: Padding(
            padding: const EdgeInsets.all(2.0),
            child: MaterialButton(
              padding: EdgeInsets.all(0),
              clipBehavior: Clip.none,
              onPressed: () {
                currentDay = day;
                if (day.isBefore(firstDayOfMonth))
                  _controller.previousPage(
                      duration: Duration(milliseconds: 250), curve: _curve);
                else if (day.month != month)
                  _controller.nextPage(
                      duration: Duration(milliseconds: 250), curve: _curve);
              },
              child: Stack(children: [
                Center(
                  child: Text(
                    '${startDay.day}',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: () {
                      Color base = day.month != month
                          ? Theme.of(context).brightness == Brightness.dark
                              ? Colors.white24
                              : Colors.black26
                          : day.weekday == 7
                              ? Theme.of(context).primaryColor.withOpacity(0.7)
                              : Theme.of(context).brightness == Brightness.dark
                                  ? Colors.white70
                                  : Colors.black87;
                      if (week == safeWeek) return base;
                      return interpolate(Colors.transparent, base,
                          max(0, weekFactor * 1.25 - 0.25));
                    }()),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(
                      top: MediaQuery.of(context).size.width /
                          7 /
                          1.5 *
                          (week == safeWeek ? 1 : weekFactor)),
                  child: Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: session.agenda
                              .getEvents(day)
                              ?.map((e) => e.getDot(week == safeWeek
                                  ? 1
                                  : max(0, weekFactor * 1.25 - 0.25)))
                              ?.toList() ??
                          []),
                )
              ]),
              shape: CircleBorder(
                  side: BorderSide(
                      color: isSameDay(day, _currentDay)
                          ? Colors.blue
                          : isSameDay(day, DateTime.now())
                              ? interpolate(
                                  Colors.red.withOpacity(0),
                                  Colors.red,
                                  week == safeWeek
                                      ? 1
                                      : max(
                                          0,
                                          weekFactor * 1.25 -
                                              0.25)) // FIXME: interpolazione fra colori
                              : Colors.transparent)),
            ),
          ),
        );
      startDay = startDay.add(Duration(days: 1));
    }
  }

  bool isSameDay(DateTime d1, DateTime d2) =>
      d1.year == d2.year && d1.month == d2.month && d1.day == d2.day;

  @override
  double maxExtent(BuildContext context) =>
      48 + 16 + 15 + MediaQuery.of(context).size.width * 6 / 7 + 10 + 46;

  @override
  double minExtent(BuildContext context) =>
      48 + 16 + 15 + MediaQuery.of(context).size.width / 7 + 10 + 46;
}

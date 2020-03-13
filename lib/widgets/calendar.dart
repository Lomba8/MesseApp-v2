import 'package:Messedaglia/registro/agenda_registro_data.dart';
import 'package:Messedaglia/registro/registro.dart';
import 'package:Messedaglia/widgets/expansion_sliver.dart';
import 'package:flutter/material.dart';
import 'package:flutter_calendar_carousel/classes/event_list.dart';
import 'package:intl/intl.dart';

const int _pagesCount = 2000;

class Calendar extends ResizableWidget {
  final void Function(DateTime day, List<Evento> events) _onDayChanged;

  Calendar([this._onDayChanged]);

  DateTime _currentDay = DateTime.now();
  final PageController _controller =
      PageController(initialPage: _pagesCount ~/ 2);
  int _page = 0;
  static final Curve _curve = Curves.easeIn;

  set currentDay(DateTime currentDay) {
    setState(() => _currentDay = currentDay);
    _onDayChanged(currentDay, RegistroApi.agenda.data.getEvents(currentDay));
  }

  @override
  Widget build(BuildContext context, [double heightFactor]) => Column(
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
              onPageChanged: (value) =>
                  setState(() => _page = value - _pagesCount ~/ 2),
              controller: _controller,
              itemBuilder: (context, i) => Stack(
                children: _children(context, i - _pagesCount ~/ 2, heightFactor)
                    .toList(),
              ),
            ),
          ),
        ],
      );

  Iterable<Widget> _children(BuildContext context, int index,
      [double heightFactor = 0]) sync* {
    // TODO: se il giorno selezionato è in un altro mese, che settimana prendiamo?
    // TODO: in modalità settimana le page devono andare di 7gg in 7gg
    DateTime firstDayOfMonth =
        DateTime(DateTime.now().year, DateTime.now().month + index);
    DateTime firstDayOfWeek = (_currentDay.year == firstDayOfMonth.year &&
            _currentDay.month == firstDayOfMonth.month
        ? _currentDay
        : firstDayOfMonth);
    firstDayOfWeek =
        firstDayOfWeek.subtract(Duration(days: firstDayOfWeek.weekday ));
    DateTime lastDayOfWeek = firstDayOfWeek.add(Duration(days: 7));
    int month = firstDayOfMonth.month;
    DateTime firstDayRendered;
    DateTime startDay = firstDayRendered =
        firstDayOfMonth.subtract(Duration(days: firstDayOfMonth.weekday - 1));
    while (startDay.month == month ||
        startDay.isBefore(firstDayOfMonth) ||
        startDay.weekday != 1) {
      DateTime day = startDay;
      yield Positioned(
        width: MediaQuery.of(context).size.width / 7,
        height: MediaQuery.of(context).size.width / 7,
        left: (day.weekday - 1) * MediaQuery.of(context).size.width / 7,
        top: interpolate(
            0.0,
            MediaQuery.of(context).size.width /
                7 *
                (day.difference(firstDayRendered).inDays ~/ 7),
            heightFactor),
        child: Opacity(
          opacity: day.isAfter(firstDayOfWeek) && day.isBefore(lastDayOfWeek)
              ? 1
              : interpolate(0.0, 1.0, heightFactor),
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
                    style: TextStyle(
                        color: day.month != month
                            ? Theme.of(context).brightness == Brightness.dark
                                ? Colors.white24
                                : Colors.black26
                            : day.weekday == 7
                                ? Theme.of(context)
                                    .primaryColor
                                    .withOpacity(0.7)
                                : Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? Colors.white70
                                    : Colors.black87),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(
                      top: MediaQuery.of(context).size.width / 7 / 1.5),
                  child: Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: ((RegistroApi.agenda.data as EventList<Evento>)
                                  .getEvents(day) ??
                              [])
                          .map((e) => e.getDot())
                          .toList()),
                )
              ]),
              shape: CircleBorder(
                  side: BorderSide(
                      color: isSameDay(day, _currentDay)
                          ? Colors.blue
                          : isSameDay(day, DateTime.now())
                              ? Colors.red
                              : Colors.transparent)),
            ),
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
      48 + 16 + 15 + MediaQuery.of(context).size.width * 6 / 7;

  @override
  double minExtent(BuildContext context) =>
      48 + 16 + 15 + MediaQuery.of(context).size.width / 7;
}

import 'package:Messedaglia/registro/agenda_registro_data.dart';
import 'package:Messedaglia/registro/registro.dart';
import 'package:flutter/material.dart';
import 'package:flutter_calendar_carousel/classes/event_list.dart';
import 'package:intl/intl.dart';

class Calendar extends StatefulWidget {
  final void Function(DateTime day, List<Evento> events) _onDayChanged;

  Calendar([this._onDayChanged]);

  @override
  _CalendarState createState() => _CalendarState();
}

class _CalendarState extends State<Calendar> {
  DateTime _currentDay = DateTime.now();
  final PageController _controller = PageController(initialPage: 12);
  static final Curve _curve = Curves.easeIn;

  set currentDay(DateTime currentDay) {
    setState(() => _currentDay = currentDay);
    widget._onDayChanged(
        currentDay, RegistroApi.agenda.data.getEvents(currentDay));
  }

  @override
  Widget build(BuildContext context) => Column(
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
                          DateTime.now().year +
                              (DateTime.now().month +
                                      (_controller.hasClients
                                          ? _controller.page.round()
                                          : _controller.initialPage) -
                                      1) ~/
                                  12 -
                              1,
                          (DateTime.now().month +
                                      (_controller.hasClients
                                          ? _controller.page.round()
                                          : _controller.initialPage) -
                                      1) %
                                  12 +
                              1))
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
                          color: Colors.white,
                          fontWeight: FontWeight.w600),
                    )))
                .toList(),
          ),
          Container(
            height: MediaQuery.of(context).size.width *
                6 /
                7, // il massimo numero di righe è 6, il massimo numero di colonne è 7: i giorni sono in un aspect ratio di 1:1
            child: PageView.builder(
              itemCount: 24,
              onPageChanged: (value) {
                setState(() {});
                print(value);
              },
              controller: _controller,
              itemBuilder: (context, i) => GridView.count(
                padding: EdgeInsets.all(0),
                physics: NeverScrollableScrollPhysics(),
                crossAxisCount: 7,
                shrinkWrap: true,
                children: _children(i),
              ),
            ),
          ),
        ],
      );

  List<Widget> _children(int index) {
    int month = (DateTime.now().month + index - 1) % 12 + 1;
    DateTime firstDayOfMonth = DateTime(
        DateTime.now().year + (DateTime.now().month + index - 1) ~/ 12 - 1,
        month,
        1);
    DateTime startDay =
        firstDayOfMonth.subtract(Duration(days: firstDayOfMonth.weekday - 1));
    List<Widget> children = [];
    while (startDay.month == month ||
        startDay.isBefore(firstDayOfMonth) ||
        startDay.weekday != 1) {
      DateTime day = startDay;
      children.add(Padding(
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
                        ? Colors.white24
                        : day.weekday == 7
                            ? Theme.of(context).primaryColor.withOpacity(0.7)
                            : Colors.white70),
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
      ));
      startDay = startDay.add(Duration(days: 1));
    }
    return children;
  }

  bool isSameDay(DateTime d1, DateTime d2) =>
      d1.year == d2.year && d1.month == d2.month && d1.day == d2.day;
}

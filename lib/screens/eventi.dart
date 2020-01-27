import 'package:applicazione_prova/registro/registro.dart';
import 'package:flutter/material.dart';

import 'package:flutter_calendar_carousel/classes/event.dart';
import 'package:flutter_calendar_carousel/classes/event_list.dart';

class Eventi {
  static EventList<Event> listaEventi() {
    var _ev = RegistroApi.agenda.data;
    Map<DateTime, List<Event>> _eventi = {};

    EventList<Event> _markedDateMap = new EventList<Event>(events: _eventi);

    _ev.forEach((k, v) {
      DateTime inizio = DateTime.parse(
              v['inizio'].replaceFirst(':', '', v['inizio'].lastIndexOf(':')))
          .toLocal();
      DateTime fine = DateTime.parse(
              v['fine'].replaceFirst(':', '', v['fine'].lastIndexOf(':')))
          .toLocal();
      // DateTime fine = DateTime.parse(v['fine'].replaceFirst(':','',v['fine'].lastIndexOf(':')));
      (_eventi[DateTime(inizio.year, inizio.month, inizio.day)] ??= <Event>[])
          .add(
        Event(
          inizio: inizio, // se è seganto come all day cosa fare?
          fine: fine,
          title: v['info'],
          autore: v['autore'],
          giornaliero: v['giornaliero'],
          nuovo: v['new'],
          // TODO: icon: Icon(Icons.add),
          dot: Container(
            margin: EdgeInsets.symmetric(horizontal: 1.0),
            color: v['new'] ? Colors.red : Colors.lightBlueAccent,
            height: 5.0,
            width: 5.0,
          ),
        ),
      );
    });

    return _markedDateMap;
  }
}

// new DateTime(2019, 2, 10): [
//   new Event(
//     date: new DateTime(2019, 2, 10),
//     title: 'Event 1',
//     icon: _eventIcon,
//     dot: Container(
//       margin: EdgeInsets.symmetric(horizontal: 1.0),
//       color: Colors.red,
//       height: 5.0,
//       width: 5.0,
//     ),
//   ),
//   new Event(
//     date: new DateTime(2019, 2, 10),
//     title: 'Event 2',
//     icon: _eventIcon,
//   ),
//   new Event(
//     date: new DateTime(2019, 2, 10),
//     title: 'Event 3',
//     icon: _eventIcon,
//   ),
// ],

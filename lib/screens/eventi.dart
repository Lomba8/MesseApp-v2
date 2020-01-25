import 'dart:convert';
import 'package:applicazione_prova/server/server.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_file.dart';

import 'package:flutter_calendar_carousel/classes/event.dart';
import 'package:flutter_calendar_carousel/classes/event_list.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Eventi {
  static EventList<Event> listaEventi() {
    var _ev = Server.eventi;
    var _previous_k;
    Map<DateTime, List<Event>> _eventi = {};

    int _anno(DateTime a) => int.parse(DateFormat.y().format(a));
    int _mese(DateTime m) => int.parse(DateFormat.M().format(m));
    int _giorno(DateTime g) => int.parse(DateFormat.d().format(g));

    EventList<Event> _markedDateMap = new EventList<Event>(events: _eventi);

    _ev.forEach((k, v) {
      DateTime orario = DateTime.parse(v['inizio'].toString()).toLocal();
      DateTime _data = DateTime(_anno(orario), _mese(orario), _giorno(orario));
      if (DateFormat.d().format(DateTime.parse(v['inizio']).toLocal()) !=
          _previous_k) {
        _eventi[_data] = <Event>[];
        _eventi[_data].add(
          Event(
            date: _data,
            title: v['info'],
            // TODO: icon: Icon(Icons.add),
            dot: Container(
              margin: EdgeInsets.symmetric(horizontal: 1.0),
              color:
                  Colors.red, //TODO: aggiustare colore container dinamicamente
              height: 5.0,
              width: 5.0,
            ),
          ),
        );
        _previous_k =
            DateFormat.d().format(DateTime.parse(v['inizio']).toLocal());
      } else {
        _eventi[_data].add(
          Event(
            date: _data,
            title: v['info'],
            // TODO: icon: Icon(Icons.add),
            dot: Container(
              margin: EdgeInsets.symmetric(horizontal: 1.0),
              color:
                  Colors.red, //TODO: aggiustare colore container dinamicamente
              height: 5.0,
              width: 5.0,
            ),
          ),
        );
        _previous_k =
            DateFormat.d().format(DateTime.parse(v['inizio']).toLocal());
      }
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

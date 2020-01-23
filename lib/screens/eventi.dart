import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_file.dart';

import 'package:flutter_calendar_carousel/classes/event.dart';
import 'package:flutter_calendar_carousel/classes/event_list.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Eventi {
  static Future<EventList<Event>> listaEventi() async {
    var prefs = await SharedPreferences.getInstance();
    dynamic _eventi = prefs.getString('eventi');
    _eventi = jsonDecode(_eventi);
    Map<DateTime, List<Map<String, dynamic>>> _eventiEncoded = _eventi.map((e) {
      ListTile(
        trailing: e['name?'],
      );
    });
    return EventList<Event>(events: {_eventiEncoded});
  }
}

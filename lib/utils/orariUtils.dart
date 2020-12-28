import 'dart:convert';

import 'package:Messedaglia/main.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:Messedaglia/main.dart' as main;
import 'package:Messedaglia/utils/db_manager.dart';
import 'package:sqflite/sqlite_api.dart';

Map orari = {};
List holidays = List();

// FIXME: senza load il salvataggio su db è inutile, usare etag o fare richiesta solo in particolari periodi dell'anno per risparmiare dati (18 kB * n)
Future downloadOrari() async {
  try {
    http.Response res = await http.get('https://app.messe.dev/orari');
    if (res.statusCode == 200) {
      var jsonResponse = jsonDecode(res.body);
      Batch batch = database.batch();
      jsonResponse.forEach((key, value) {
        batch.insert('orari', Map.fromEntries(() sync* {
          yield MapEntry('cls', key);
          for (int ora = 0; ora < 6; ora++)
            for (int day = 0; day < 6; day++)
              yield MapEntry(
                  '${days[day]}$ora', jsonResponse[key][key][day + ora * 6]);
          yield MapEntry('url', jsonResponse[key]["url"]);
        }()), conflictAlgorithm: ConflictAlgorithm.replace);
        orari[key] = {
          'orari': jsonResponse[key][key],
          'url': jsonResponse[key]["url"]
        };
      });

      batch.commit();
    } else {
      print('Request failed with status: ${res.statusCode}.');
    }
  } catch (e, s) {
    print(e);
    print(s);
  }
}

// FIXME: senza load il salvataggio su sharedprefs è inutile, usare etag o fare richiesta solo in particolari periodi dell'anno per risparmiare dati (18 kB * n)
Future downloadVacanze() async {
  try {
    http.Response res = await http.get('https://app.messe.dev/holidays');
    if (res.statusCode == 200) {
      holidays = jsonDecode(res.body);
      holidays = holidays.map((e) => DateTime.parse(e)).toList();
      prefs.setString('holidays',
          jsonEncode(holidays.map((e) => e.toIso8601String()).toList()));
    } else {
      print('Request failed with status: ${res.statusCode}.');
    }
  } catch (e, s) {
    print(e);
    print(s);
  }
}

String selectedClass = session.cls;

void getSelected() =>
    selectedClass = main.prefs.getString('selectedClass') ?? session.cls;

Iterable<String> getSbjs(int day, [String cls]) sync* {
  cls ??= selectedClass;
  if (cls == null) return;
  for (int i = day; i < orari[cls]['orari'].length; i += 6)
    if (orari[cls]['orari'][i] != '') yield orari[cls]['orari'][i];
}

final Map<String, Color> colors = {
  'ITA': Colors.white,
  'FIS': Color(0xFF95AABF),
  'STO': Color(0xFFDC78DC),
  'ARTE': Color(0xFF78DCAA),
  'SCI': Color(0xFFDC7878),
  'MATE': Color(0xFFDDF7F7),
  'INGL': Color(0xFFDCDC78),
  'LAT': Color(0xFFCEA286),
  'MOT': Color(0xFFDFD5CA),
  'REL': Color(0xFFB4B4B4),
  'FILO': Color(0xFFF7DDEA),
  'STO/GEO': Color(0xFFF7DDDD),
  'INFO': Color(0xFFE9D5C0),
  'INGL POT': Color(0xFFF2F2F2),
};

int dailyHours(DateTime day) {
  int _ore = 0;
  for (int i = day.weekday; i < orari[selectedClass]['orari'].length; i += 6) {
    if (orari[selectedClass]['orari'][i] != "") _ore++;
  }
  return _ore;
}

bool doesSaturday() {
  if (orari[selectedClass]['orari'][5] != "")
    return true;
  else
    return false;
}

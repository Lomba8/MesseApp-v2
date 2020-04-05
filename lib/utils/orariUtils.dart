import 'dart:convert';

import 'package:Messedaglia/main.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:Messedaglia/main.dart' as main;
import 'package:Messedaglia/utils/db_manager.dart';
import 'package:sqflite/sqlite_api.dart';

Map orari = {};

// TODO: senza load il salvataggio su db è inutile, usare etag o fare richiesta solo in particolari periodi dell'anno per risparmiare dati (18 kB * n)
Future downloadOrari() async {
  try {
    http.Response res = await http.get(
        'https://raw.githubusercontent.com/Lomba8/MesseApp-v2/master/orari.json');
    Map json = jsonDecode(res.body);
    Batch batch = database.batch();
    json.keys.where((cls) => !cls.endsWith('url')).forEach((cls) {
      batch.insert('orari', Map.fromEntries(() sync* {
        yield MapEntry('cls', cls);
        for (int ora = 0; ora < 6; ora++)
          for (int day = 0; day < 6; day++)
            yield MapEntry('${days[day]}$ora', json[cls][day + ora * 6]);
        yield MapEntry('url', json[cls + 'url']);
      }()), conflictAlgorithm: ConflictAlgorithm.replace);
      orari[cls] = {
        'orari': json[cls],
        'url': json[cls+'url']
      };
    });
    batch.commit();
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

import 'dart:convert';
import 'dart:io';

import 'package:Messedaglia/main.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:Messedaglia/main.dart' as main;
import 'package:Messedaglia/utils/db_manager.dart';
import 'package:sqflite/sqlite_api.dart';

Map orari = {};
List holidays = [];

Future downloadOrari({bool load = false}) async {
  selectedClass = main.prefs.getString('selectedClass') ?? session.cls;
  var orariData;
  Batch batch = database.batch();
  if (load) {
    batch.rawQuery('SELECT * FROM orari');
    orariData = (await batch.commit()).last.forEach((cls) {
      List<String> orario = List<String>.empty(growable: true);
      for (int giorno = 0; giorno < 6; giorno++) {
        for (int ora = 1; ora < 37; ora += 6) {
          orario.add(cls.row[giorno + ora]);
        }
      }
      orari[cls.row[0]] = {'orari': orario, 'url': cls.row[37]};
    });
  } else
    try {
      http.Response res = await http.get('https://app.messe.dev/orari',
          headers: {'If-None-Match': main.prefs.getString('orariEtag')});
      if (res.statusCode == HttpStatus.ok) {
        await main.prefs.setString('orariEtag', res.headers['etag']);
        var jsonResponse = jsonDecode(res.body);
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

        await batch.commit();
      } else if (res.statusCode == HttpStatus.notModified) {
        batch.rawQuery('SELECT * FROM orari');
        orariData = (await batch.commit())
            .last
            .map((cls) => cls.row)
            .toList(); //FIXME tutti i metodi funzionano con l'ordine del json del server non quello del db cosa fare?
        // print(orariData);
      } else {
        throw ('Request failed with status: ${res.statusCode}.');
      }
    } catch (e, s) {
      print(e);
      print(s);
    }
}

Future downloadVacanze({bool load = false}) async {
  if (load) {
    holidays = jsonDecode(main.prefs.getString('holidays'));
    if (holidays != null)
      holidays = holidays.map((e) => DateTime.parse(e)).toList();
  } else
    try {
      http.Response res = await http.get('https://app.messe.dev/holidays',
          headers: {'If-None-Match': main.prefs.getString('vacanzeEtag')});
      if (res.statusCode == HttpStatus.ok) {
        await main.prefs.setString('vacanzeEtag', res.headers['etag']);

        holidays = jsonDecode(res.body);
        holidays = holidays.map((e) => DateTime.parse(e)).toList();
        prefs.setString('holidays',
            jsonEncode(holidays.map((e) => e.toIso8601String()).toList()));
      } else if (res.statusCode == HttpStatus.notModified) {
        holidays = jsonDecode(main.prefs.getString('holidays'))
            .map((e) => DateTime.parse(e))
            .toList();
      } else {
        throw ('Request failed with status: ${res.statusCode}.');
      }
    } catch (e, s) {
      print(e);
      print(s);
    }
}

String selectedClass = session.cls;

Iterable<String> getSbjs(int day, [String cls]) sync* {
  cls ??= selectedClass;
  if (cls == null) return;
  for (int i = day; i < orari[cls]['orari']?.length ?? 0; i += 6)
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
  for (int i = day.weekday;
      i < orari[selectedClass]['orari']?.length ?? 0;
      i += 6) {
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

int timeLeft({String sbj}) {
  int giorni = 0;
  int ore = 0;
  DateTime day = DateTime.parse(DateTime.now().toString().substring(0, 10));
  DateTime lastDay = holidays.last.add(Duration(days: 1));

  if (session.cls == null) return null;

  if (day.isBefore(holidays.first) && day.isAfter(holidays.last)) return null;

  while (day.isBefore(lastDay)) {
    day = day.add(Duration(days: 1));

    if (day.weekday == DateTime.sunday)
      continue;
    else if (day.weekday == DateTime.saturday && !doesSaturday())
      continue;
    else if (holidays.contains(day))
      continue;
    else {
      if (sbj != null)
        for (String sbj2 in getSbjs(day.weekday)) if (sbj2 == sbj) ore++;
      giorni++;
    }
  }

  return sbj == null ? giorni : ore;
}

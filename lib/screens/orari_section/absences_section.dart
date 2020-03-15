
import 'dart:convert';

import 'package:Messedaglia/registro/registro.dart';
import 'package:Messedaglia/utils/orariUtils.dart';

class Interval {
  DateTime start, end;
  Interval({this.start, this.end});

  Iterable<DateTime> get remainingDays sync* {
    DateTime day = start;
    while (day.isBefore(end)) {
      if (day.weekday != 7 && day.isAfter(DateTime.now())) yield day;
      day = day.add(const Duration(days: 1));
    }
  }
}

// TODO: da dove pigliamo le vacanze senza doverle mettere a mano?
final List<Interval> holidaysData = jsonDecode('''[
        {
                "start": "2019-09-11",
                "end": "2019-11-01"
        },
        {
                "start": "2019-11-03",
                "end": "2019-12-08"
        },
        {
                "start": "2019-12-09",
                "end": "2019-12-23"
        },
        {
                "start": "2020-01-07",
                "end": "2020-02-24"
        },
        {
                "start": "2020-04-03",
                "end": "2020-04-09"
        },
        {
                "start": "2020-04-15",
                "end": "2020-04-25"
        },
        {
                "start": "2020-04-26",
                "end": "2020-05-01"
        },
        {
                "start": "2020-05-03",
                "end": "2020-05-21"
        },
        {
                "start": "2020-05-22",
                "end": "2020-06-02"
        },
        {
                "start": "2020-06-03",
                "end": "2020-06-06"
        }
]''').map<Interval>((data) => Interval(start: DateTime.parse(data['start']), end: DateTime.parse(data['end']))).toList();

// FIXME: mi sa che c'è un errore nel conteggio

// se sbj è null allora conta i giorni invece che le ore
int countRemainingHours ({String sbj, String cls}) {
  cls ??= RegistroApi.cls;
  if (cls == null) return null;
  int count = 0;
  for (Interval interval in holidaysData)
    for (DateTime day in interval.remainingDays) {
      if (sbj != null) {
        for (String sbj2 in getSbjs(day.weekday-1)) if (sbj2 == sbj) count++;
      } else if (getSbjs(day.weekday-1).isNotEmpty) count++;
    }
  return count;
}
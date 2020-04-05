import 'dart:collection';

import 'package:Messedaglia/main.dart';
import 'package:Messedaglia/registro/registro.dart';
import 'package:flutter/material.dart';
import 'package:flutter_calendar_carousel/classes/event.dart';
import 'package:flutter_calendar_carousel/flutter_calendar_carousel.dart';
import 'package:intl/intl.dart';
import 'package:Messedaglia/utils/db_manager.dart';
import 'package:sqflite/sqlite_api.dart';

import 'registro.dart';

class AgendaRegistroData extends RegistroData {
  static String getSchoolYear(DateTime date) {
    int year2 = int.parse(DateFormat.M().format(date)) < 9 ? 1 : 0;
    return '${date.year - year2}0901/${date.year + 1 - year2}0630';
  }

  SplayTreeMap<DateTime, int> dates = SplayTreeMap<DateTime, int>();

  AgendaRegistroData({@required RegistroApi account})
      : super(
            url:
                'https://web.spaggiari.eu/rest/v1/students/%uid/agenda/all/${getSchoolYear(DateTime.now())}',
            account: account,
            name: 'agenda');

  @override
  Future<Result> parseData(json) async {
    try {
      json = json['agenda'];
      List<int> ids = [];

      Batch batch = database.batch();
      json.forEach((m) {
        account.cls = m['classDesc']
            .substring(0, m['classDesc'].indexOf(RegExp(r'[^A-Za-z0-9]')));
        ids.add(m['evtId']);
        String date = m['evtDatetimeBegin'].substring(0, 10) + 'T00:00:00Z';
        batch.insert(
          'agenda',
          {
            'id': m['evtId'],
            'date': date,
            'inizio': m['evtDatetimeBegin'].substring(0, 19) + 'Z',
            'fine': m['evtDatetimeEnd'].substring(0, 19) + 'Z',
            'giornaliero': m['isFullDay'] ? 1 : 0,
            'autore': m['authorName'],
            'info': m['notes'],
            'usrId': account.usrId,
            'new': DateTime.now().isBefore(DateTime.parse(date)) ? 1 : 0
          },
          conflictAlgorithm: ConflictAlgorithm.ignore,
        );
      });
      batch.delete('agenda',
          where: 'usrId = ? AND id NOT IN (${ids.join(', ')})',
          whereArgs: [account.usrId]);
      batch.query('agenda',
          where: 'usrId = ?', whereArgs: [account.usrId], orderBy: 'date');
      dates = SplayTreeMap<DateTime, int>();
      DateTime last;
      int count = 0;
      data = (await batch.commit()).last.map((v) {
        if (DateTime.parse(v['date']) != last) {
          last = DateTime.parse(v['date']);
          dates[last] = count;
        }
        count++;
        return Map.from(v);
      }).toList();

      account.update(); // nel caso fosse stata cambiata la classe
      return Result(true, true);
    } catch (e, stack) {
      print(e);
      print(stack);
    }
    return Result(false, false);
  }

  @override
  Future<void> load() async {
    await super.load();
    data.sort((m1, m2) => m1['date'].compareTo(m2['date']) as int);
    DateTime last;
    int count = 0;
    data = data.map((v) {
      if (DateTime.parse(v['date']) != last) {
        last = DateTime.parse(v['date']);
        dates[last] = count;
      }
      count++;
      return Map.from(v);
    }).toList();
  }

  @override
  Map<String, dynamic> toJson() {
    Map<String, dynamic> tr = super.toJson();
    tr['eventList'] = {};
    (data as EventList<Evento>).events.forEach(
        (key, value) => tr['eventList'][key.toIso8601String()] = value);
    return tr;
  }

  Iterable<Evento> getEvents(DateTime date) sync* {
    int index = dates[date];
    if (index == null) return;
    for (Map evt in data.skip(index)) {
      DateTime evtDate = DateTime.parse(evt['date']);
      if (evtDate != date) return;
      yield Evento.parse(account, evt);
    }
  }

  @override
  Future<void> create() async {
    await database.execute(
        'CREATE TABLE IF NOT EXISTS agenda(id INTEGER PRIMARY KEY, date DATE, inizio DATETIME, fine DATETIME, giornaliero INTEGER, autore TEXT, info TEXT, usrId INTEGER, new INTEGER)');
  }
}

class Evento implements EventInterface {
  final RegistroApi account;
  int _evtId;
  DateTime inizio, fine; // se nulli, allora l'evento è giornaliero
  bool giornaliero, isNew;
  String autore, info;

  Evento.parse(this.account, Map raw) {
    _evtId = raw['id'];
    inizio = DateTime.parse(raw['inizio']);
    fine = DateTime.parse(raw['fine']);
    giornaliero = raw['giornaliero'] == 1;
    autore = raw['autore'];
    info = raw['info'];
    isNew = raw['new'] == 1;
  }

  @override
  DateTime getDate() => DateTime.utc(inizio.year, inizio.month, inizio.day);

  void seen() {
    session.agenda.data
        .where((evt) => evt['id'] == _evtId)
        .forEach((evt) => evt['new'] = false);
    database.update('agenda', {'new': 0},
        where: 'id = ? AND usrId = ?', whereArgs: [_evtId, account.usrId]);
  }

  @override
  Widget getDot([double opacity]) => Container(
        margin: EdgeInsets.symmetric(horizontal: 1.0),
        color: (isNew ?? true ? Colors.red : Colors.lightBlueAccent)
            .withOpacity(opacity),
        height: 5.0,
        width: 5.0,
      );

  @override
  Widget getIcon() => null;

  @override
  String getTitle() => info;

  Map<String, dynamic> toJson() => {
        'evtId': _evtId,
        'inizio': inizio.toIso8601String(),
        'fine': fine.toIso8601String(),
        'giornaliero': giornaliero,
        'autore': autore,
        'info': info
      };
}

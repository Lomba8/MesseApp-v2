import 'dart:convert';
import 'dart:math';

import 'package:Messedaglia/registro/agenda_registro_data.dart';
import 'package:Messedaglia/registro/registro.dart';
import 'package:Messedaglia/utils/db_manager.dart';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:Messedaglia/main.dart' as main;

/** [lessonType]: */
// Lezione
// Attività di laboratorio
// Alternanza scuola-lavoro
// Interrogazione
// Verifica scritta
// Sorveglianza
// Compito in classe
// Supplenza
// Cittadinanza e Costituzione
// Compresenza
// Spiegazione
// PCTO - Attività in aula
// Interrogazione e spiegazione

/** [evtCode] LSF0: lezione */
/** [evtCode] LSC0: compresenza */
/** per le supplenze c'è una "materia" apposta ([subjectDesc] SUPPLENZA) */

class LessonsRegistroData extends RegistroData {
  LessonsRegistroData({@required RegistroApi account})
      : super(
            url:
                'https://web.spaggiari.eu/rest/v1/students/%uid/lessons/${AgendaRegistroData.getSchoolYear(DateTime.now())}',
            account: account,
            name: 'lessons');

  @override
  Future<Result> parseData(json) async {
    Batch batch = database.batch();
    List<int> ids = [];
    Set _materie = Set();

    json = json['lessons'];

    try {
      for (Map lesson in json) {
        account.cls = lesson['classDesc']
            .substring(0, lesson['classDesc'].indexOf(RegExp(r'[^A-Za-z0-9]')));

        _materie.add(lesson['subjectDesc']);

        ids.add(lesson['evtId']);

        batch.insert('lessons', {
          'id': lesson['evtId'],
          'usrId': account.usrId,
          'date': DateTime.parse(lesson['evtDate']).toIso8601String(),
          'hour': lesson['evtHPos'] - 1,
          'duration': lesson['evtDuration'],
          'author': lesson['authorName'],
          'sbj': lesson['subjectDesc'],
          'type': lesson['lessonType'],
          'info': lesson['lessonArg'].isEmpty ? null : lesson['lessonArg']
        });
      }

      batch.delete('lessons',
          where: 'usrId = ? AND id NOT IN (${ids.join(', ')})',
          whereArgs: [account.usrId]);

      batch.query('lessons', where: 'usrId = ?', whereArgs: [account.usrId]);

      data = (await batch.commit())
          .last
          .map<Lezione>((v) => Lezione.parse(v))
          .toList()
            ..sort();

      if (_materie.isNotEmpty) {
        List _materieArray = _materie.map((t) => t).toList();
        main.materie = _materieArray;
        main.prefs.setString('materie', jsonEncode(_materieArray));
      }
      await account.update(); // nel caso fosse stata cambiata la classe
      return Result(true, true);
    } catch (e, s) {
      print(e);
      print(s);
      return Result(false, false);
    }
  }

  @override
  Future<void> create() async {
    await database.execute(
        'CREATE TABLE IF NOT EXISTS lessons(id INTEGER PRIMARY KEY, usrId INTEGER, date DATE, hour INTEGER, duration INTEGER, author TEXT, sbj TEXT, type TEXT, info TEXT)');
  }

  @override
  Future<void> load() async {
    await super.load();
    data = data.map<Lezione>((v) => Lezione.parse(v)).toList()..sort();
  }
}

class Lezione extends Comparable<Lezione> {
  int id;
  DateTime date;
  int hour;
  Duration duration;
  String author;
  String sbj;
  String lessonType;
  String info;

  Lezione(
      {@required this.date,
      @required this.hour,
      @required this.duration,
      @required this.author,
      @required this.sbj,
      @required this.lessonType,
      @required this.info});

  Lezione.parse(Map raw) {
    this.id = raw['id'];
    this.date = DateTime.parse(raw['date']).toLocal();
    this.hour = raw['hour'];
    this.duration = Duration(hours: raw['duration']);
    this.author = raw['author'];
    this.sbj = raw['sbj'];
    this.lessonType = raw['type'];
    this.info = raw['info'];
  }

  bool isCompatible(Lezione l2) =>
      date == l2.date &&
      author == l2.author &&
      sbj == l2.sbj &&
      lessonType == l2.lessonType &&
      info == l2.info &&
      (l2.hour - hour).abs() == duration.inHours;

  void join(Lezione l2) {
    hour = min(hour, l2.hour);
    duration = Duration(hours: duration.inHours + l2.duration.inHours);
  }

  @override
  int compareTo(Lezione other) {
    if (date.isAtSameMomentAs(other.date)) {
      return -hour.compareTo(other.hour);
    }
    return -date.compareTo(other.date);
  }
}

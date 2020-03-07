import 'dart:math';

import 'package:Messedaglia/registro/agenda_registro_data.dart';
import 'package:Messedaglia/registro/registro.dart';
import 'package:flutter/material.dart';

class LessonsRegistroData extends RegistroData {
  LessonsRegistroData()
      : super(
            'https://web.spaggiari.eu/rest/v1/students/%uid/lessons/${AgendaRegistroData.getSchoolYear(DateTime.now())}');

  @override
  Result parseData(json) {
    json = json['lessons'];
    data['sbj'] = <String, List<Lezione>>{};
    data['date'] = <DateTime, List<Lezione>>{};

    /** [evtCode] LSF0: lezione */
    /** [evtCode] LSC0: compresenza */
    /** per le supplenze c'è una "materia" apposta ([subjectDesc] SUPPLENZA) */

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

    for (Map lesson in json) {
      RegistroApi.cls = lesson['classDesc']
          .substring(0, lesson['classDesc'].indexOf(RegExp(r'[^A-Za-z0-9]')));
      Lezione lezione = Lezione(
          date: DateTime.parse(lesson['evtDate']),
          hour: lesson['evtHPos'] - 1,
          duration: Duration(hours: lesson['evtDuration']),
          author: lesson['authorName'],
          sbj: lesson['subjectDesc'],
          lessonType: lesson['lessonType'],
          info: lesson['lessonArg'].isEmpty ? null : lesson['lessonArg']);
      if (data['date'][lezione.date] != null &&
          data['date'][lezione.date].last.isCompatible(lezione))
        data['date'][lezione.date].last.join(lezione);
      else {
        (data['sbj'][lezione.sbj] ??= <Lezione>[]).add(lezione);
        (data['date'][lezione.date] ??= <Lezione>[]).add(lezione);
      }
    }
    return Result(true, true);
  }

  @override
  Map<String, dynamic> toJson() {
    Map<String, dynamic> tr = super.toJson();
    tr['data'] = [];
    data['date'].forEach(
        (date, list) => list.forEach((lesson) => tr['data'].add(lesson)));
    return tr;
  }

  @override
  void fromJson(Map<String, dynamic> json) {
    super.fromJson(json);
    List lezioni = json['data'];
    data['sbj'] = <String, List<Lezione>>{};
    data['date'] = <DateTime, List<Lezione>>{};
    lezioni.forEach((lezione) {
      Lezione l = Lezione.fromJson(lezione);
      (data['sbj'][l.sbj] ??= <Lezione>[]).add(l);
      (data['date'][l.date] ??= <Lezione>[]).add(l);
    });
  }
}

class Lezione {
  final DateTime date;
  int hour;
  Duration duration;
  final String author;
  final String sbj;
  final String lessonType;
  final String info;

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

  Lezione(
      {@required this.date,
      @required this.hour,
      @required this.duration,
      @required this.author,
      @required this.sbj,
      @required this.lessonType,
      @required this.info});

  Map<String, dynamic> toJson() => {
        'date': date.toIso8601String(),
        'hour': hour,
        'duration': duration.inHours,
        'author': author,
        'sbj': sbj,
        'lessonType': lessonType,
        'info': info
      };

  static Lezione fromJson(Map json) => Lezione(
      date: DateTime.parse(json['date']),
      hour: json['hour'],
      duration: Duration(hours: json['duration']),
      author: json['author'],
      sbj: json['sbj'],
      lessonType: json['lessonType'],
      info: json['info']);
}

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
      Lezione lezione = Lezione(
          date: DateTime.parse(lesson['evtDate']),
          hour: lesson['evtHPos']-1,
          duration: Duration(hours: lesson['evtDuration']),
          author: lesson['authorName'],
          sbj: lesson['subjectDesc'],
          lessonType: lesson['lessonType'],
          info: lesson['lessonArg'].isEmpty ? null : lesson['lessonArg']);
      (data['sbj'][lezione.sbj] ??= <Lezione>[]).add(lezione);
      (data['date'][lezione.date] ??= <Lezione>[]).add(lezione);
    }
    return Result(true, true);
  }
}

class Lezione {
  final DateTime date;
  final int hour;
  final Duration duration;
  final String author;
  final String sbj;
  final String lessonType;
  final String info;

  Lezione(
      {@required this.date,
      @required this.hour,
      @required this.duration,
      @required this.author,
      @required this.sbj,
      @required this.lessonType,
      @required this.info});
}

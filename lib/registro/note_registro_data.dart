import 'package:Messedaglia/registro/registro.dart';
import 'package:Messedaglia/utils/db_manager.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sqflite/sqflite.dart';

class NoteRegistroData extends RegistroData {
  NoteRegistroData({@required RegistroApi account})
      : super(
            url: 'https://web.spaggiari.eu/rest/v1/students/%uid/notes/all/',
            account: account,
            name: 'note');

  Batch batch = database.batch();

  /*
    NTTE: ANNOTAZIONI
    NTCL: NOTA DISCIPLINARE
    NTWN: RICHIAMI
    NTST: SANZIONI DISCIPLINARI
  */

  @override
  Future<Result> parseData(json) async {
    json.forEach((tipologia, note) {
      note.forEach((nota) {
        batch.insert(
            'note',
            {
              'id': nota['evtId'],
              'usrId': account.usrId,
              'evt': nota['evtText'],
              'date': tipologia != 'NTST'
                  ? DateTime.parse(nota['evtDate']).toIso8601String()
                  : null,
              'inizio': tipologia == 'NTST'
                  ? DateTime.parse(nota['evtBegin']).toIso8601String()
                  : null,
              'fine': tipologia == 'NTST'
                  ? DateTime.parse(nota['evtEnd']).toIso8601String()
                  : null,
              'new': 1,
              'autore': nota['authorName'],
              'tipologia': tipologia
            },
            conflictAlgorithm: ConflictAlgorithm.ignore);
      });
    });

    batch.query('note', where: 'usrId = ?', whereArgs: [account.usrId]);

    data = (await batch.commit()).last.map((v) => Map.from(v)).toList();

    data = data.map((e) {
      return Nota(
          account: account,
          autore: e['autore'],
          date:
              e['date'] != null ? DateTime.tryParse(e['date']).toLocal() : null,
          inizio: e['inizio'] != null
              ? DateTime.tryParse(e['inizio']).toLocal()
              : null,
          fine:
              e['fine'] != null ? DateTime.tryParse(e['fine']).toLocal() : null,
          id: e['id'],
          isNew: e['new'] == 1 ? true : false,
          motivazione: e['evt'],
          tipologia: e['tipologia']);
    }).toList();

    return Result(true, true);
  }

  @override
  Future<void> create() async {
    await database.execute(
        'CREATE TABLE IF NOT EXISTS note(id INTEGER PRIMARY KEY, usrId INTEGER, evt TEXT, date DATE, inizio DATE, fine DATE, new BIT, autore TEXT, tipologia TEXT)');
  }

  @override
  Future<void> load() async {
    await super.load();
    data = data.map((e) {
      return Nota(
          account: account,
          autore: e['autore'],
          date: DateTime.tryParse(e['date']).toLocal(),
          inizio: DateTime.tryParse(e['inizio']).toLocal(),
          fine: DateTime.tryParse(e['fine']).toLocal(),
          id: e['id'],
          isNew: e['new'] == 1 ? true : false,
          motivazione: e['evt'],
          tipologia: e['tipologia']);
    }).toList();
  }
}

class Nota {
  final RegistroApi account;
  final int id;
  final String motivazione;
  final DateTime date;
  final DateTime inizio, fine;
  final String autore;
  final String tipologia;
  bool isNew;

  Nota(
      {@required this.account,
      @required this.id,
      @required this.motivazione,
      @required this.date,
      @required this.autore,
      @required this.tipologia,
      @required this.isNew,
      this.inizio,
      this.fine});

  String get dateWithSlashes => DateFormat.yMd('it').format(date);

  Future<void> seen() async {
    this.isNew = false;
    int res = await database
        .rawUpdate('UPDATE bacheca SET new = 0 WHERE id = ?', [this.id]);
  }

  String get tipologiaReadable {
    switch (tipologia) {
      case 'NTTE':
        return 'Annotazione';
      case 'NTCL':
        return 'Nota Disciplinare';
      case 'NTWN':
        return 'Richiamo';
      case 'NTST':
        return 'Sanzione Disciplinare';
      default:
        return 'Nota';
    }
  }
}

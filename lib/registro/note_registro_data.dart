import 'package:Messedaglia/registro/registro.dart';
import 'package:Messedaglia/utils/db_manager.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sqflite/sqflite.dart';
import 'package:Messedaglia/main.dart' as main;

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
    try {
      List<int> ids = [];

      json.forEach((tipologia, note) {
        note.forEach((nota) {
          ids.add(nota['evtId']);

          batch.insert(
              'note',
              {
                'id': nota['evtId'],
                'usrId': account.usrId,
                'evt': nota['evtText'].trim(),
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
      batch.delete('note',
          where: 'usrId = ? AND id NOT IN (${ids.join(', ')})',
          whereArgs: [account.usrId]);
      batch.query('note', where: 'usrId = ?', whereArgs: [account.usrId]);

      data =
          (await batch.commit()).last.map<Nota>((v) => Nota.parse(v)).toList();

      return Result(true, true);
    } catch (e, stack) {
      print(stack);
    }
    return Result(false, false);
  }

  @override
  Future<void> create() async {
    await database.execute(
        'CREATE TABLE IF NOT EXISTS note(id INTEGER PRIMARY KEY, usrId INTEGER, evt TEXT, date DATE, inizio DATE, fine DATE, new BIT, autore TEXT, tipologia TEXT)');
  }

  @override
  Future<void> load() async {
    await super.load();
    data = data.map<Nota>((v) => Nota.parse(v)).toList();
  }

  int get newNote =>
      data.length > 0 ? data.where((v) => v.isNew == true).length : 0;
}

class Nota {
  RegistroApi account;
  int id;
  String motivazione;
  DateTime date;
  DateTime inizio, fine;
  String autore;
  String tipologia;
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

  Nota.parse(Map raw) {
    this.account = account;
    this.id = raw['id'];
    this.motivazione = raw['evt'];
    this.date =
        raw['date'] != null ? DateTime.tryParse(raw['date']).toLocal() : null;
    this.autore = raw['autore'];
    this.tipologia = raw['tipologia'];
    this.isNew = raw['new'] == 1 ? true : false;
    this.inizio = raw['inizio'] != null
        ? DateTime.tryParse(raw['inizio']).toLocal()
        : null;
    this.fine =
        raw['fine'] != null ? DateTime.tryParse(raw['fine']).toLocal() : null;
  }

  static String getDateWithSlashes(date) => DateFormat.yMd('it').format(date);
  static String getDateWithSlashesShort(date) =>
      DateFormat.d('it').format(date) +
      '/' +
      DateFormat.M('it').format(date) +
      '/' +
      DateFormat.y('it').format(date).split('').sublist(2).join().toString();

  Future seen() async {
    this.isNew = false;
    int res = await database.rawUpdate(
        'UPDATE note SET new = 0 WHERE id = ? AND usrId = ?',
        [this.id, main.session.usrId]);
  }

  // String get type => getTipo(tipologia);
  static String getTipi(String tipologia) {
    switch (tipologia) {
      case 'NTTE':
        return 'Annotazioni';
      case 'NTCL':
        return 'Note Disciplinari';
      case 'NTWN':
        return 'Richiami';
      case 'NTST':
        return 'Sanzioni Disciplinare';
      default:
        return 'Note';
    }
  }

  static String getTipo(String tipologia) {
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

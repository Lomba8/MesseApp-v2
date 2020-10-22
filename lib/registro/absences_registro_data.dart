import 'dart:convert';

import 'package:Messedaglia/main.dart';
import 'package:Messedaglia/registro/registro.dart';
import 'package:Messedaglia/utils/db_manager.dart';
import 'package:flutter/material.dart';
import 'package:Messedaglia/registro/registro.dart';
import 'package:Messedaglia/utils/db_manager.dart';
import 'package:intl/intl.dart';
import 'package:sqflite/sqflite.dart';

class AbsencesRegistroData extends RegistroData {
  AbsencesRegistroData({@required RegistroApi account})
      : super(
            url:
                'https://web.spaggiari.eu/rest/v1/students/%uid/absences/details',
            account: account,
            name: 'absences');

  /*
                ABA0: Assenza
                ABR0: Ritardo
                ABU0: Uscita
                ABR1: Ritardo Breve
            */
  Batch batch = database.batch();

  @override
  Future<Result> parseData(json) async {
    try {
      List<int> ids = [];

      json = json['events'];

      data = <DateTime, Assenza>{};

      for (Map absence in json) {
        ids.add(absence['evtId']);

        // Assenza assenza = Assenza(
        //   id: absence['evtId'],
        //   hour: absence['evtHPos'],
        //   value: absence['evtValue'],
        //   justified: absence['isJustified'],
        //   justification: absence['justifReasonDesc'],
        //   type: absence['evtCode'] == 'ABA0'
        //       ? 'assenza'
        //       : absence['evtCode'] == 'ABR0' ? 'ritardo' : 'uscita',
        //   isNew: true,
        //   account: account,
        // );
        // data[DateTime.parse(absence['evtDate'])] = assenza;
        batch.insert(
            'absences',
            {
              'id': absence['evtId'],
              'usrId': account.usrId,
              'type': absence['evtCode'],
              'date': DateTime.parse(absence['evtDate'])
                  .toLocal()
                  .toIso8601String(),
              'new': 1,
              'hour': absence['evtHPos'],
              'justification': absence['justifReasonDesc'],
              'justified': absence['isJustified'] ? 1 : 0,
            },
            conflictAlgorithm: ConflictAlgorithm.ignore);
      }
      batch.delete('absences',
          where: 'usrId = ? AND id NOT IN (${ids.join(', ')})',
          whereArgs: [account.usrId]);
      batch.query('absences', where: 'usrId = ?', whereArgs: [account.usrId]);

      data = (await batch.commit()).last.map((v) => Map.from(v)).toList();

      dynamic dataTmp = <DateTime, Assenza>{};

      data.forEach((e) {
        Assenza assenza = Assenza.parse(e);

        dataTmp[DateTime.parse(e['date'])] = assenza;
      });

      data = dataTmp;

      await account.update(); // nel caso fosse stata cambiata la classe

      return Result(true, true);
    } catch (e, stack) {
      print(stack);
      return Result(false, false);
    }
  }

  // @override
  // Map<String, dynamic> toJson() {
  //   Map<String, dynamic> tr = super.toJson();
  //   tr['data'] =
  //       data.map((date, absence) => MapEntry(date.toIso8601String(), absence));
  //   return tr;
  // }

  // @override
  // void fromJson(Map<String, dynamic> json) {
  //   super.fromJson(json);
  //   data = json['data'].map((date, absence) =>
  //       MapEntry(DateTime.parse(date), Assenza.fromJson(absence)));
  // }

  @override
  Future<void> create() async {
    await database.execute(
        'CREATE TABLE IF NOT EXISTS absences(id INTEGER PRIMARY KEY, usrId INTEGER, type TEXT, hour INTEGER, justified BIT, justification TEXT, new BIT, date DATE)');
  }

  @override
  Future<void> load() async {
    await super.load();

    dynamic dataTmp = <DateTime, Assenza>{};

    data.forEach((e) {
      Assenza assenza = Assenza.parse(e);

      dataTmp[DateTime.parse(e['date'])] = assenza;
    });

    data = dataTmp;
  }

  int get newAssenze =>
      data.length > 0 ? data.values.where((v) => v.isNew == true).length : 0;

  double giorniRestanti() {
    double ore = 0;
    List<Assenza> _assenze = data.values.toList();
    _assenze.forEach((assenza) {
      if (assenza.type == 'ABA0') {
        ore += 5; //FIXME lunghezza dei giorni
      } else if (assenza.type == 'ABR0') {
        ore += assenza.hour;
      } else if (assenza.type == 'ABU0') {
        ore += (5 - assenza.hour); //FIXME lunghezza dei giorni
      }
    });
    return ore;
  }
}

class Assenza {
  RegistroApi account;
  int id;
  String type;
  int hour;
  dynamic value; // ?  (non lo ho messo nel database)
  bool justified;
  String justification;
  DateTime date;
  bool isNew;

  Assenza({
    @required this.account,
    @required this.id,
    @required this.hour,
    @required this.date,
    @required this.value,
    @required this.justified,
    @required this.justification,
    @required this.type,
    @required this.isNew,
  });

  Assenza.parse(Map raw) {
    this.account = account;
    this.hour = raw['hour'];
    this.id = raw['id'];
    this.date = DateTime.tryParse(raw['date']);
    this.isNew = raw['new'] == 1 ? true : false;
    this.justification = raw['justification'];
    this.justified = raw['justified'] == 1 ? true : false;
    this.type = raw['type'];
    this.value = raw['value'];
  }

  Future<void> seen() async {
    this.isNew = false;
    int res = await database.rawUpdate(
        'UPDATE note SET new = 0 WHERE id = ? AND usrId = ?',
        [this.id, session.usrId]);
  }

  static String getDateWithSlashes(date) => DateFormat.yMd('it').format(date);
  static String getDateWithSlashesShort(date) =>
      DateFormat.d('it').format(date) +
      '/' +
      DateFormat.M('it').format(date) +
      '/' +
      DateFormat.y('it').format(date).split('').sublist(2).join().toString();

  // String get type => getTipo(tipologia);
  static String getTipo(String tipologia) {
    switch (tipologia) {
      case 'ABA0':
        return 'Assenze';
      case 'ABR0':
        return 'Ritardi';
      case 'ABU0':
        return 'Uscite';
      case 'ABR1':
        return 'Ritardi Brevi';
      default:
        return 'Eventi';
    }
  }
  // Map<String, dynamic> toJson() => {
  //       'hour': hour,
  //       'value': value,
  //       'justified': justified,
  //       'justification': justification
  //     };
  // static Assenza fromJson(Map json) => Assenza(
  //     hour: json['hour'],
  //     value: json['value'],
  //     justified: json['justified'],
  //     justification: json['justification'],
  //     type: null);
}

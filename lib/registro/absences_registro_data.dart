import 'dart:convert';

import 'package:Messedaglia/registro/registro.dart';
import 'package:Messedaglia/utils/db_manager.dart';
import 'package:flutter/material.dart';
import 'package:Messedaglia/registro/registro.dart';
import 'package:Messedaglia/utils/db_manager.dart';
import 'package:sqflite/sqflite.dart';

class AbsencesRegistroData extends RegistroData {
  AbsencesRegistroData({@required RegistroApi account})
      : super(
            url:
                'https://web.spaggiari.eu/rest/v1/students/%uid/absences/details',
            account: account,
            name: 'absences');

  @override
  Future<Result> parseData(json) async {
    json = json['events'];
    data = <DateTime, Assenza>{};
    Batch batch = database.batch();

    for (Map absence in json) {
      Assenza assenza = Assenza(
        id: absence['evtId'],
        hour: absence['evtHPos'],
        value: absence['evtValue'],
        justified: absence['isJustified'],
        justification: absence['justifReasonDesc'],
        type: absence['evtCode'] == 'ABA0'
            ? 'assenza'
            : absence['evtCode'] == 'ABR0' ? 'ritardo' : 'uscita',
        isNew: true,
        account: account,
      );
      data[DateTime.parse(absence['evtDate'])] = assenza;
      batch.insert(
          'absences',
          {
            'id': absence['evtId'],
            'usrId': account.usrId,
            'type': absence['evtCode'] == 'ABA0'
                ? 'assenza'
                : absence['evtCode'] == 'ABR0' ? 'ritardo' : 'uscita',
            'date':
                DateTime.parse(absence['evtDate']).toLocal().toIso8601String(),
            'new': 1,
            'hour': absence['evtHPos'],
            'justification': absence['justifReasonDesc'], // NON LO SALVA
            'justified': absence['isJustified'] ? 1 : 0,
          },
          conflictAlgorithm: ConflictAlgorithm.ignore);
    }

    batch.query('absences', where: 'usrId = ?', whereArgs: [account.usrId]);

    //TODO add  batch.absences('voti', where: 'usrId = ? AND id NOT IN (${ids.join(', ')})', whereArgs: [account.usrId]);

    data = (await batch.commit()).last.map((v) => Map.from(v)).toList();

    dynamic dataTmp = <DateTime, Assenza>{};

    data.forEach((e) {
      Assenza assenza = Assenza(
          account: account,
          hour: e['hour'],
          id: e['id'],
          isNew: e['new'] == 1 ? true : false,
          justification: e['justification'],
          justified: e['justified'] == 1 ? true : false,
          type: e['type'],
          value: e['value']);

      dataTmp[DateTime.parse(e['date'])] = assenza;
    });

    data = dataTmp;
    return Result(true, true);
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
      Assenza assenza = Assenza(
          account: account,
          hour: e['hour'],
          id: e['id'],
          isNew: e['new'] == 1 ? true : false,
          justification: e['justification'],
          justified: e['justified'] == 1 ? true : false,
          type: e['type'],
          value: e['value']);

      dataTmp[DateTime.parse(e['date'])] = assenza;
    });

    data = dataTmp;
  }

  int get newAssenze => data.values.where((v) => v.isNew == true).length;
}

class Assenza {
  final RegistroApi account;
  final int id;
  final String type;
  final int hour;
  final dynamic value; // ?  (non lo ho messo nel database)
  final bool justified;
  final String justification;
  bool isNew;

  Assenza({
    @required this.account,
    @required this.id,
    @required this.hour,
    @required this.value,
    @required this.justified,
    @required this.justification,
    @required this.type,
    @required this.isNew,
  });

  Future<void> seen() async {
    this.isNew = false;
    int res = await database
        .rawUpdate('UPDATE note SET new = 0 WHERE id = ?', [this.id]);
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

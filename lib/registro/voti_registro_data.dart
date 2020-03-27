import 'package:Messedaglia/main.dart';
import 'package:Messedaglia/registro/registro.dart';
import 'package:Messedaglia/utils/db_manager.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sqflite/sqlite_api.dart';

import 'registro.dart';

class VotiRegistroData extends RegistroData {
  List<String> periods = ['TOTALE', 'TRIMESTRE', 'PENTAMESTRE'];

  VotiRegistroData({@required RegistroApi account})
      : super(
            url: 'https://web.spaggiari.eu/rest/v1/students/%uid/grades2',
            account: account,
            name: 'voti') {
    period = DateTime.now().month < 8 ? 2 : 1;
  }

  @override
  Future<Result> parseData(json) async {
    try {
      json = json.values.first;
      List<int> ids = [];
      Batch batch = database.batch();
      for (Map m in json) {
        if (m['canceled']) continue;
        ids.add(m['evtId']);
        batch.insert(
          'voti',
          {
            'id': m['evtId'],
            'sbj': m['subjectDesc'],
            'period': m['periodDesc'].toUpperCase(),
            'date': m['evtDate']?.replaceAll(':', ''),
            'voto': m['decimalValue'],
            'votoStr': m['displayValue'],
            'info': m['notesForFamily'],
            'usrId': account.usrId,
            'new': 1
          },
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
      batch.delete('voti',
          where: 'usrId = ? AND id NOT IN (${ids.join(', ')})',
          whereArgs: [account.usrId]);
      batch.query('voti', where: 'usrId = ?', whereArgs: [account.usrId]);
      data = (await batch.commit()).last.map((v) => Map.from(v)).toList();
      return Result(true, true);
    } catch (e, stack) {
      print(e);
      print(stack);
    }
    return Result(false, false);
  }

  Iterable<String> sbjsWithMarks ([int period = 0]) {
    return Set.from(
        data.where((v) => periods[period] == 'TOTALE' || v['period'] == periods[period]).map((v) => v['sbj']));
  }

  set period(int i) {
    String temp = periods[0];
    periods[0] = periods[i];
    periods[i] = temp;
  }

  // FIXME: non salva sul db
  void allSeen({String sbj}) {
    data.where((v) => (v['period'] == periods[0] || periods[0] == 'TOTALE') && (sbj == null || v['sbj'] == sbj)).forEach((v) => v['new'] = 0);
    database.update('voti', {'new': 0},
        where: 'period = ? AND usrId = ?'+(sbj == null ? '' : ' AND sbj = ?'),
        whereArgs: [periods[0], account.usrId, if (sbj != null) sbj]).then((value) => print(value));
  }

  Iterable<Voto> sbjVoti(String sbj, [int period = 0]) {
    return data
        .where((v) => (periods[period] == 'TOTALE' || v['period'] == periods[period]) && v['sbj'] == sbj)
        .map<Voto>((v) => Voto.parse(v));
  }

  double average(String sbj, [int period = 0]) {
    int n = 0;
    return sbjVoti(sbj, period).fold(0.0, (sum, v) {
          if (v.voto == null || v.voto.isNaN || v.voto < 0.0) return sum;
          n++;
          return sum += v.voto;
        }) /
        n;
  }

  double averagePeriodo(int period) {
    int n = 0;
    return sbjsWithMarks(period).fold(0, (sum, sbj) {
          double avg = average(sbj, period);
          if (avg.isNaN) return sum;
          n++;
          return sum + avg.round();
        }) /
        n;
  }

  int _countNewMarks(String sbj) => sbjVoti(sbj).where((v) => v.isNew).length;

  bool hasNewMarks(String sbj) => sbjVoti(sbj).any((v) => v.isNew);

  int get newVotiTot => data.where((v) => v['new'] == 1).length;
  int get newVotiPeriodCount =>
      data.where((v) => v['new'] == 1 && (v['period'] == periods[0] || periods[0] == 'TOTALE')).length;

  @override
  Future<void> create() async {
    await database.execute(
        'CREATE TABLE IF NOT EXISTS voti(id INTEGER PRIMARY KEY, sbj TEXT, period TEXT, date DATETIME, voto REAL, votoStr TEXT, info TEXT, usrId INTEGER, new INTEGER)');
  }
}

class Voto extends Comparable<Voto> {
  int _id;
  DateTime _data;
  double voto;
  bool isNew;
  String votoStr, info;

  Voto({var id, num voto, @required this.votoStr, this.info, String data, this.isNew = true}) {
    _id = id;
    this.voto = voto?.toDouble();
    _data = DateTime.parse(data);
  }
  Voto.parse(Map raw) {
    _id = raw['id'];
    _data = DateTime.parse(raw['date']);
    voto = raw['voto'];
    votoStr = raw['votoStr'];
    info = raw['info'];
    isNew = raw['new'] == 1;
  }

  Color get color => getColor(voto);
  static Color getColor(double value) {
    if (value == null || value < 0 || value.isNaN) return Colors.blue[800];
    if (value < 6) return Colors.deepOrange[900];
    return Colors.green[700];
  }

  String get data => DateFormat.yMMMMd('it').format(_data);

  Map<String, dynamic> toJson() => {
        'evtId': _id,
        'data': _data.toIso8601String(),
        'voto': voto,
        'votoStr': votoStr,
        'info': info
      };

  static Voto fromJson(Map<String, dynamic> json) => Voto(
      id: json['evtId'],
      voto: json['voto'],
      votoStr: json['votoStr'],
      info: json['info'],
      data: json['data']);

  @override
  int compareTo(Voto other) => _data.compareTo(other._data);
}

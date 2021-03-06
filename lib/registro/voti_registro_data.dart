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
        DateTime date = DateTime.tryParse(m['evtDate']?.replaceAll(':', ''));
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
            'new': DateTime(DateTime.now().year, DateTime.now().month,
                        DateTime.now().day)
                    .isAfter(date)
                ? 0
                : 1,
          },
          conflictAlgorithm: ConflictAlgorithm.ignore,
        );
      }
      batch.delete('voti',
          where: 'usrId = ? AND id NOT IN (${ids.join(', ')})',
          whereArgs: [account.usrId]);
      batch.query('voti', where: 'usrId = ?', whereArgs: [account.usrId]);
      data =
          (await batch.commit()).last.map<Voto>((v) => Voto.parse(v)).toList();
      await account.update(); // nel caso fosse stata cambiata la classe

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
    data = data.map<Voto>((v) => Voto.parse(v)).toList();
  }

  Iterable<String> sbjsWithMarks([int period = 0]) {
    return data.length == 0
        ? Iterable.empty()
        : Set.from(data
            .where((Voto v) =>
                periods[period] == 'TOTALE' || v.period == periods[period])
            .map((Voto v) => v.sbj));
  }

  set period(int i) {
    String temp = periods[0];
    periods[0] = periods[i];
    periods[i] = temp;
  }

  void allSeen({String sbj}) {
    data
        .where((Voto v) =>
            (v.period == periods[0] || periods[0] == 'TOTALE') &&
            (sbj == null || v.sbj == sbj))
        .forEach((Voto v) => v.isNew = false);
    database
        .update('voti', {'new': 0},
            where: 'usrId = ?' +
                (sbj == null ? '' : ' AND sbj = ?') +
                (periods[0] == 'TOTALE' ? '' : ' AND period = ?'),
            whereArgs: [
              account.usrId,
              if (sbj != null) sbj,
              if (periods[0] != 'TOTALE') periods[0]
            ])
        .then((value) => print(value));
  }

  Iterable<Voto> sbjVoti(String sbj, [int period = 0]) {
    return data.where((Voto v) =>
        (periods[period] == 'TOTALE' || v.period == periods[period]) &&
        v.sbj == sbj);
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

  Map<int, double> averageByMonth({bool currentPeriod = false}) {
    List<double> sums = List.filled(10, 0.0);
    List<int> counts = List.filled(10, 0);
    if (data.length > 0)
      data.where((Voto v) => !v.isBlue).forEach((Voto v) {
        counts[(v.date.month + 3) % 12]++;
        sums[(v.date.month + 3) % 12] += v.voto;
      });
    return Map.fromIterables(Iterable.generate(10, (i) => i),
        Iterable.generate(10, (i) => sums[i] / counts[i]));
  }

  int _countNewMarks(String sbj) => sbjVoti(sbj).where((v) => v.isNew).length;

  bool hasNewMarks(String sbj) => sbjVoti(sbj).any((v) => v.isNew);

  int get newVotiTot =>
      data.length == 0 ? 0 : data.where((Voto v) => v.isNew).length;
  int get newVotiPeriodCount => data.length == 0
      ? 0
      : data
          .where((Voto v) =>
              v.isNew && (v.period == periods[0] || periods[0] == 'TOTALE'))
          .length;

  @override
  Future<void> create() async {
    await database.execute(
        'CREATE TABLE IF NOT EXISTS voti(id INTEGER PRIMARY KEY, sbj TEXT, period TEXT, date DATETIME, voto REAL, votoStr TEXT, info TEXT, usrId INTEGER, new INTEGER)');
  }
}

class Voto extends Comparable<Voto> {
  int _id;
  DateTime date;
  double voto;
  bool isNew;
  String votoStr, info, period, sbj;

  Voto(
      {var id,
      num voto,
      @required this.votoStr,
      this.info,
      String data,
      this.isNew = true}) {
    _id = id;
    this.voto = voto?.toDouble();
    date = DateTime.parse(data);
  }
  Voto.parse(Map raw) {
    _id = raw['id'];
    date = DateTime.parse(raw['date']);
    voto = raw['voto'];
    votoStr = raw['votoStr'];
    info = raw['info'];
    isNew = raw['new'] == 1;
    period = raw['period'];
    sbj = raw['sbj'];
  }

  Color get color => getColor(voto);
  static Color getColor(double value) {
    if (value == null || value < 0 || value.isNaN) return Colors.blue[800];
    if (value < 6) return Colors.deepOrange[900];
    return Colors.green[700];
  }

  bool get isBlue => voto == null || voto < 0 || voto.isNaN;

  String get data => DateFormat.yMMMMd('it').format(date);

  String get dateWithSlashes => DateFormat.yMd('it').format(date);
  String get dateWithSlashesShort =>
      DateFormat.d('it').format(date) +
      '/' +
      DateFormat.M('it').format(date) +
      '/' +
      DateFormat.y('it').format(date).split('').sublist(2).join().toString();

  Map<String, dynamic> toJson() => {
        'evtId': _id,
        'data': date.toIso8601String(),
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
  int compareTo(Voto other) => date.compareTo(other.date);
}

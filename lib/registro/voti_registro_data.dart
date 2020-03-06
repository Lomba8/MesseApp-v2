import 'dart:convert';

import 'package:Messedaglia/main.dart';
import 'package:Messedaglia/registro/registro.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'registro.dart';

class VotiRegistroData extends RegistroData {
  List<String> periods = ['TOTALE', 'TRIMESTRE', 'PENTAMESTRE'];

  Map<String, bool> votiNewFlags = <String, bool>{};

  VotiRegistroData()
      : super('https://web.spaggiari.eu/rest/v1/students/%uid/grades2');

  @override
  Result parseData(json) {
    try {
      json = json['grades'];
      Map<String, Map> data2 = {};
      Map<String, bool> votiNewFlags2 = {};

      json.forEach((m) {
        if (m['canceled']) return;
        List<String> periods = [m['periodDesc'].toUpperCase(), 'TOTALE'];
        Map<String, Map<String, dynamic>> period;
        Map subject;
        Voto voto = Voto(
            id: m['evtId'],
            data: m['evtDate'],
            voto: m['decimalValue'],
            votoStr: m['displayValue'],
            info: m['notesForFamily']);
        for (String p in periods) {
          period = data2[p] ??= <String, Map<String, dynamic>>{};
          subject = period[m['subjectId'].toString()] ??= <String, dynamic>{
            'subjectCode': m['subjectCode'], // nome abbreviato
            'subjectDesc': m['subjectDesc'], // nome completo
            'voti': <Voto>[]
          };
          List<Voto> voti = subject['voti'];
          voti.add(voto);
        }
        votiNewFlags2[voto._id] = votiNewFlags[voto._id] ?? true;
      });

      data = data2;
      votiNewFlags = votiNewFlags2;
      saveData(this, 'voti');
      return Result(true, true);
    } catch (e, stack) {
      print(e);
      print(stack);
    }
    return Result(false, false);
  }

  Iterable get sbjsWithMarks {
    return data[periods[0]].values;
  }

  set period(int i) {
    String temp = periods[0];
    periods[0] = periods[i];
    periods[i] = temp;
  }

  void allSeen() {
    data[periods[0]]
        .values
        .forEach((sbj) => sbj['voti'].forEach((v) => v.seen()));
  }

  Iterable sbjIdVoti(String sbjId, [int period = 0]) {
    return (data[periods[period]][sbjId] ?? {})['voti'];
  }

  Iterable sbjVoti(Map sbj) {
    return sbj['voti'];
  }

  double average(Map sbj) {
    return _average(sbj['voti']);
  }

  double _average(Iterable<Voto> voti) {
    if (voti == null) return double.nan;
    int n = 0;
    return voti.fold<double>(0, (sum, voto) {
          if (voto.voto == null) return sum;
          n++;
          return sum += voto.voto;
        }) /
        n;
  }

  double averagePeriodo(int period) {
    int n = 0;
    return data[periods[period]].values.fold(0, (sum, sbj) {
          double avg = _average(sbj['voti']);
          if (avg.isNaN) return sum;
          n++;
          return sum + avg.round();
        }) /
        n;
  }

  int _countNewMarks(Map sbj) {
    Iterable<Voto> voti = sbj['voti'];
    if (voti == null) return 0;
    return voti.fold(0, (sum, mark) {
      if (mark.isNew) return sum + 1;
      return sum;
    });
  }

  bool hasNewMarks(Map sbj) {
    Iterable<Voto> voti = sbj['voti'];
    if (voti == null) return false;
    return voti.any((mark) => mark.isNew);
  }

  int get newVotiTot => data['TOTALE'].values.fold(0, (sum, sbj) {
        return sum + _countNewMarks(sbj);
      });
  int get newVotiPeriodCount => data[periods[0]].values.fold(0, (sum, sbj) {
        return sum + _countNewMarks(sbj);
      });

  @override
  Map<String, dynamic> toJson() {
    Map<String, dynamic> tr = super.toJson();
    tr['periodi'] = {
      'TRIMESTRE': data['TRIMESTRE'],
      'PENTAMESTRE': data['PENTAMESTRE']
    };
    tr['newFlags'] = votiNewFlags;
    return tr;
  }

  @override
  void fromJson(Map<String, dynamic> json) {
    super.fromJson(json);
    data = json['periodi'];
    Map<String, Map> totale = data['TOTALE'] = <String, Map>{};
    List<String> periods = ['TRIMESTRE', 'PENTAMESTRE'];
    for (String period in periods) {
      data[period].forEach((sbjId, sbj) {
        totale[sbjId] ??= {
          'subjectCode': sbj['subjectCode'], // nome abbreviato
          'subjectDesc': sbj['subjectDesc'], // nome completo
          'voti': <Voto>[]
        };
        sbj['voti'] = sbj['voti'].map<Voto>((raw) {
          Voto voto = Voto.fromJson(raw);
          totale[sbjId]['voti'].add(voto);
          return voto;
        }).toList();
      });
    }
    votiNewFlags = json['newFlags']
        .map<String, bool>((k, v) => MapEntry<String, bool>(k, v));
  }
}

class Voto extends Comparable<Voto> {
  String _id;
  DateTime _data;
  double voto;
  String votoStr, info;

  Voto({var id, num voto, @required this.votoStr, this.info, String data}) {
    _id = id.toString();
    this.voto = voto?.toDouble();
    _data = DateTime.parse(data);
  }

  Color get color => getColor(voto);
  static Color getColor(double value) {
    if (value == null || value < 0 || value.isNaN) return Colors.blue[800];
    if (value < 6) return Colors.deepOrange[900];
    return Colors.green[700];
  }

  String get data => DateFormat.yMMMMd('it').format(_data);
  bool get isNew => RegistroApi.voti.votiNewFlags[_id] ?? true;
  void seen() => RegistroApi.voti.votiNewFlags[_id] = false;

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

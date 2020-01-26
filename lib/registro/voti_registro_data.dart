import 'package:applicazione_prova/registro/registro.dart';

class VotiRegistroData extends RegistroData {
  List<String> periods = ['TOTALE', 'TRIMESTRE', 'PENTAMESTRE'];

  VotiRegistroData()
      : super('https://web.spaggiari.eu/rest/v1/students/%uid/grades2');

  @override
  Result parseData(json) {
    try {
      json = json['grades'];
      Map<String, Map> data2 = {};

      json.forEach((m) {
        if (m['canceled']) return;
        Map subject = data2[m['subjectId'].toString()] ??= <String, dynamic>{
          'subjectCode': m['subjectCode'], // nome abbreviato
          'subjectDesc': m['subjectDesc'], // nome completo
          'periodi': []
        };
        Map votiPeriodo = subject[m['periodDesc'].toUpperCase()];
        if (votiPeriodo == null) {
          votiPeriodo =
              subject[m['periodDesc'].toUpperCase()] = <String, Map>{};
          subject['periodi'].add(m['periodDesc'].toUpperCase());
        }
        Map prevVoto = data[m['subjectId'].toString()];
        if (prevVoto != null)
          prevVoto = prevVoto[m['periodDesc'].toUpperCase()];
        if (prevVoto != null) prevVoto = prevVoto[m['evtId'].toString()];
        votiPeriodo[m['evtId'].toString()] = <String, dynamic>{
          'data': m['evtDate'],
          'voto': m['decimalValue'],
          'votoStr': m['displayValue'],
          'info': m['notesForFamily'],
          'new': prevVoto == null || prevVoto['new']
        };
      });
      data2.values.forEach((value) {
        value['TOTALE'] ??= {};
        value['periodi'].forEach((p) {
          value['TOTALE'].addAll(value[p]);
        });
      });
      data = data2;

      return Result(true, true);
    } catch (e, stack) {
      print(e);
      print(stack);
    }
    return Result(false, false);
  }

  Iterable get sbjsWithMarks {
    return data.values
        .where((sbj) => sbj[periods[0]] != null && sbj[periods[0]].isNotEmpty);
  }

  set period(int i) {
    String temp = periods[0];
    periods[0] = periods[i];
    periods[i] = temp;
  }

  Iterable sbjIdVoti(String sbjId) {
    return data[sbjId][periods[0]]?.values;
  }
  Iterable sbjVoti(Map sbj, [int period = 0]) {
    return sbj[periods[period]]?.values;
  }

  double average(Map sbj, [int period = 0]) {
    Iterable voti = sbjVoti(sbj, period);
    return _average(voti);
  }
  double _average(Iterable voti) {
    if (voti == null) return double.nan;
    int n = 0;
    return voti.fold<double>(0, (sum, m) {
          if (m['voto'] == null) return sum;
          n++;
          return sum += m['voto'];
        }) /
        n;
  }

  double averagePeriodo(int period) {
    int n = 0;
    return data.values.where((sbj) => sbj[periods[period]] != null).fold(0,
            (sum, sbj) {
          double avg = _average(sbjVoti(sbj, period));
          if (avg.isNaN) return sum;
          n++;
          return sum + avg.round();
        }) /
        n;
  }

  int _countNewMarks(String sbjId) {
    Iterable voti = sbjIdVoti(sbjId);
    if (voti == null) return 0;
    return voti.fold(0, (sum, mark) {
      if (mark['new']) return sum + 1;
      return sum;
    });
  }

  bool hasNewMarks(Map sbj) {
    Iterable voti = sbjVoti(sbj);
    if (voti == null) return false;
    return voti.any((mark) => mark['new'] as bool);
  }

  int get newVotiPeriodCount => data.keys.fold(0, (sum, sbjId) {
        if (data[sbjId][periods[0]] == null) return sum;
        return sum + _countNewMarks(sbjId);
      });
}

import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:applicazione_prova/registro/registro.dart';
import 'package:intl/intl.dart';

class AgendaRegistroData extends RegistroData {
  static String _getSchoolYear(DateTime date) {
    int year2 = int.parse(DateFormat.M().format(date)) >= 9 ? 1 : 0;
    return '${DateFormat.y().format(date)}${DateFormat.M().format(date).padLeft(2, '0')}${DateFormat.d().format(date).padLeft(2, '0')}/${int.parse(DateFormat.y().format(date)) + year2}1231';
  }

  AgendaRegistroData()
      : super(
            'https://web.spaggiari.eu/rest/v1/students/%uid/agenda/all/${_getSchoolYear(DateTime.now())}');

  @override
  Future<Result> getData() async {
    // TODO: gestire Z-If-None-Match
    try {
      var r = await http.get(url, headers: RegistroData.headers);
      if (r.statusCode != 200) return Result(false, false);
      var data = json.decode(r.body)['agenda'];
      Map<String, Map> data2 = {};

      data.forEach((m) {
        var prevEvento = this.data[m['evtId']];

        Map event = data2[m['evtId'].toString()] ??= <String, dynamic>{
          'inizio': m['evtDatetimeBegin'],
          'fine': m['evtDatetimeEnd'],
          'giornaliero': m['isFullDay'],
          'info': m['notes'],
          'autore': m['authorName'],
          'classe': m['classDesc'],
          'new': prevEvento == null || prevEvento['new']
        };
      });

      this.data = data2;
      lastUpdate = DateTime.now().millisecondsSinceEpoch;

      return Result(true, true);
    } catch (e, stack) {
      print(e);
      print(stack);
    }
    return Result(false, false);
  }
}

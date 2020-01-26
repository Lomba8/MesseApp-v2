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
  Result parseData(json) {
    try {
      json = json['agenda'];
      Map<String, Map> data2 = {};

      json.forEach((m) {
        var prevEvento = data[m['evtId']];

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

      data = data2;

      return Result(true, true);
    } catch (e, stack) {
      print(e);
      print(stack);
    }
    return Result(false, false);
  }
}

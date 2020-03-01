import 'package:Messedaglia/registro/registro.dart';

class NoteRegistroData extends RegistroData {
  NoteRegistroData()
      : super('https://web.spaggiari.eu/rest/v1/students/%uid/notes/all/');

  Map<int, bool> noteNewFlags = {};
  String json;

  @override
  Result parseData(json) {
    this.json = json.toString();
    /*
    json = json['items'];
    List<Comunicazione> data2 = [];
    Map<int, bool> noteNewFlags2 = {};

    json.forEach((c) {
      data2.add(Comunicazione(
        c['pubId'],
          DateTime.parse(
                  c['pubDT'].replaceFirst(':', '', c['pubDT'].lastIndexOf(':')))
              .toLocal(),
          c['cntValidInRange'],
          c['cntTitle'],
          c['attachments']));
      bachecaNewFlags2[c['pubId']] = bachecaNewFlags[c['pubId']] ?? c['readStatus'];
    });

    data = data2..sort();
    bachecaNewFlags = bachecaNewFlags2;
    return Result(true, true);*/
  }
}

class Comunicazione extends Comparable<Comunicazione> {
  final int id;
  final DateTime _date;
  final bool valid;
  final String title;
  final List attachments;
  Comunicazione(this.id, this._date, this.valid, this.title, this.attachments);

  @override
  int compareTo(Comunicazione other) => -_date.compareTo(other._date);
}

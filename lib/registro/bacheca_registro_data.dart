import 'dart:convert';

import 'package:Messedaglia/registro/registro.dart';
import 'package:http/http.dart' as http;

class BachecaRegistroData extends RegistroData {
  BachecaRegistroData()
      : super('https://web.spaggiari.eu/rest/v1/students/%uid/noticeboard');

  Map<int, bool> bachecaNewFlags = {};

  @override
  Result parseData(json) {
    json = json['items'];
    List<Comunicazione> data2 = [];
    Map<int, bool> bachecaNewFlags2 = {};

    json.forEach((c) {
      data2.add(Comunicazione(
          c['evtCode'],
          c['pubId'],
          DateTime.parse(
                  c['pubDT'].replaceFirst(':', '', c['pubDT'].lastIndexOf(':')))
              .toLocal(),
          c['cntValidInRange'],
          c['cntTitle'],
          c['attachments']));
      bachecaNewFlags2[c['pubId']] =
          bachecaNewFlags[c['pubId']] ?? c['readStatus'];
    });

    data = data2..sort();
    bachecaNewFlags = bachecaNewFlags2;
    return Result(true, true);
  }
}

class Comunicazione extends Comparable<Comunicazione> {
  final String evt;
  final int id;
  final DateTime _date;
  final bool valid;
  final String title;
  String content;
  void loadContent(void Function() callback) async {
    http.Response r = await http.post(
        'https://web.spaggiari.eu/rest/v1/students/${RegistroApi.usrId}/noticeboard/read/$evt/$id/101',
        headers: {
          'Z-Dev-Apikey': 'Tg1NWEwNGIgIC0K',
          'Content-Type': 'application/json',
          'User-Agent': 'CVVS/std/1.7.9 Android/6.0',
          'Z-Auth-Token': RegistroApi.token,
        });
    Map json = jsonDecode(r.body);
    content = json['item']['text'];
    callback ();
  }

  final List attachments;
  Comunicazione(
      this.evt, this.id, this._date, this.valid, this.title, this.attachments);

  @override
  int compareTo(Comunicazione other) => -_date.compareTo(other._date);
}

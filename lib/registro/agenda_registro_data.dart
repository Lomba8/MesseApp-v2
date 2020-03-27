import 'package:Messedaglia/main.dart';
import 'package:Messedaglia/registro/registro.dart';
import 'package:flutter/material.dart';
import 'package:flutter_calendar_carousel/classes/event.dart';
import 'package:flutter_calendar_carousel/flutter_calendar_carousel.dart';
import 'package:intl/intl.dart';

import 'registro.dart';

class AgendaRegistroData extends RegistroData {
  Map<String, bool> eventiNewFlags = {};

  static String getSchoolYear(DateTime date) {
    int year2 = int.parse(DateFormat.M().format(date)) < 9 ? 1 : 0;
    return '${date.year - year2}0901/${date.year + 1 - year2}0630';
  }

  AgendaRegistroData({@required RegistroApi account})
      : super(
            url:
                'https://web.spaggiari.eu/rest/v1/students/%uid/agenda/all/${getSchoolYear(DateTime.now())}',
            account: account, name: 'agenda');

  @override
  Future<Result> parseData(json) async {
    try {
      json = json['agenda'];
      EventList<Evento> data2 = EventList<Evento>();
      Map<String, bool> eventiNewFlags2 = {};

      json.forEach((m) {
        account.cls = m['classDesc']
            .substring(0, m['classDesc'].indexOf(RegExp(r'[^A-Za-z0-9]')));
        Evento evt = Evento(m['evtId'].toString(),
            inizio: DateTime.parse(m['evtDatetimeBegin'].replaceFirst(
                    ':', '', m['evtDatetimeBegin'].lastIndexOf(':')))
                .toLocal(),
            fine: DateTime.parse(m['evtDatetimeEnd'].replaceFirst(
                    ':', '', m['evtDatetimeEnd'].lastIndexOf(':')))
                .toLocal(),
            giornaliero: m['isFullDay'],
            info: m['notes'],
            autore: m['authorName']);

        data2.add(evt.getDate(), evt);
        eventiNewFlags2[m['evtId'].toString()] =
            DateTime.now().isBefore(evt.getDate()) &&
                (eventiNewFlags[m['evtId'].toString()] ?? true);
      });

      data = data2;
      eventiNewFlags = eventiNewFlags2;

      account.update();
      return Result(true, true);
    } catch (e, stack) {
      print(e);
      print(stack);
    }
    return Result(false, false);
  }

  @override
  Map<String, dynamic> toJson() {
    Map<String, dynamic> tr = super.toJson();
    tr['eventList'] = {};
    (data as EventList<Evento>).events.forEach(
        (key, value) => tr['eventList'][key.toIso8601String()] = value);
    tr['newFlags'] = eventiNewFlags;
    return tr;
  }

  @override
  void fromJson(Map<String, dynamic> json) {
    super.fromJson(json);
    data = json['eventList'];
    EventList<Evento> evtList = EventList<Evento>();

    data = data.forEach((k, v) {
      for (int i = 0; i < v.length; i++) {
        v[i] = Evento.fromJson(v[i]);
        evtList.add(v[i].getDate(), v[i]);
      }
    });
    data = evtList;
    eventiNewFlags = json['newFlags']
        .map<String, bool>((k, v) => MapEntry<String, bool>(k, v));
  }

  @override
  Future<void> create() {
    // TODO: implement create
  }
}

class Evento implements EventInterface {
  String _evtId;
  DateTime inizio, fine; // se nulli, allora l'evento è giornaliero
  bool giornaliero;
  String autore, info;

  Evento(this._evtId,
      {this.inizio, this.fine, this.autore, this.info, this.giornaliero})
      : assert(autore != null && info != null);

  @override
  DateTime getDate() => DateTime(inizio.year, inizio.month, inizio.day);

  bool get nuovo => session.agenda.eventiNewFlags[_evtId];
  void seen() {
    session.agenda.eventiNewFlags[_evtId] = false;
  }

  @override
  Widget getDot([double opacity]) => Container(
        margin: EdgeInsets.symmetric(horizontal: 1.0),
        color: (nuovo ?? true ? Colors.red : Colors.lightBlueAccent)
            .withOpacity(opacity),
        height: 5.0,
        width: 5.0,
      );

  @override
  Widget getIcon() => null;

  @override
  String getTitle() => info;

  Map<String, dynamic> toJson() => {
        'evtId': _evtId,
        'inizio': inizio.toIso8601String(),
        'fine': fine.toIso8601String(),
        'giornaliero': giornaliero,
        'autore': autore,
        'info': info
      };
  static Evento fromJson(json) => Evento(json['evtId'],
      inizio: DateTime.parse(json['inizio']),
      fine: DateTime.parse(json['fine']),
      giornaliero: json['giornaliero'],
      autore: json['autore'],
      info: json['info']);
}

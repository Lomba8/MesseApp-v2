import 'package:applicazione_prova/registro/registro.dart';
import 'package:flutter/material.dart';
import 'package:flutter_calendar_carousel/classes/event.dart';
import 'package:flutter_calendar_carousel/flutter_calendar_carousel.dart';
import 'package:intl/intl.dart';

import 'registro.dart';

class AgendaRegistroData extends RegistroData {
  Map<String, bool> eventiNewFlags = {};

  static String classe;
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
      EventList<Evento> data2 = EventList<Evento>();
      Map<String, bool> eventiNewFlags2 = {};

      json.forEach((m) {
        classe = m['classDesc'];
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
            eventiNewFlags[m['evtId'].toString()] ?? true;
      });

      data = data2;
      eventiNewFlags = eventiNewFlags2;

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

  bool get nuovo => RegistroApi.agenda.eventiNewFlags[_evtId];
  void seen() {
    RegistroApi.agenda.eventiNewFlags[_evtId] = false;
  }

  @override
  Widget getDot() => Container(
        margin: EdgeInsets.symmetric(horizontal: 1.0),
        color: nuovo ? Colors.red : Colors.lightBlueAccent,
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

  String getAutore() {
    // TODO: implement getAutore
    throw UnimplementedError();
  }

  DateTime getFine() {
    // TODO: implement getFine
    throw UnimplementedError();
  }

  bool getGiornaliero() {
    // TODO: implement getGiornaliero
    throw UnimplementedError();
  }

  DateTime getInizio() {
    // TODO: implement getInizio
    throw UnimplementedError();
  }

  bool getNuovo() {
    // TODO: implement getNuovo
    throw UnimplementedError();
  }
}

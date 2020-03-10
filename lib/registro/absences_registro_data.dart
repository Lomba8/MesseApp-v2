import 'package:Messedaglia/registro/registro.dart';
import 'package:flutter/material.dart';

class AbsencesRegistroData extends RegistroData {
  AbsencesRegistroData()
      : super(
            'https://web.spaggiari.eu/rest/v1/students/%uid/absences/details');

  @override
  Result parseData(json) {
    json = json['events'];
    data = <DateTime, Assenza>{};

    for (Map absence in json) {
      Assenza assenza = Assenza(
          hour: absence['evtHPos'],
          value: absence['evtValue'],
          justified: absence['isJustified'],
          justification: absence['justifyReasonDesc'],
          type: absence['evtCode'] == 'ABA0'
              ? 'assenza'
              : absence['evtCode'] == 'ABR0' ? 'ritardo' : 'uscita');
      data[DateTime.parse(absence['evtDate'])] = assenza;
    }
    return Result(true, true);
  }

  @override
  Map<String, dynamic> toJson() {
    Map<String, dynamic> tr = super.toJson();
    tr['data'] =
        data.map((date, absence) => MapEntry(date.toIso8601String(), absence));
    return tr;
  }

  @override
  void fromJson(Map<String, dynamic> json) {
    super.fromJson(json);
    data = json['data'].map((date, absence) =>
        MapEntry(DateTime.parse(date), Assenza.fromJson(absence)));
  }
}

class Assenza {
  final String type;
  final int hour;
  final dynamic value; // ?
  final bool justified;
  final String justification;

  Assenza(
      {@required this.hour,
      @required this.value,
      @required this.justified,
      @required this.justification,
      @required this.type});

  Map<String, dynamic> toJson() => {
        'hour': hour,
        'value': value,
        'justified': justified,
        'justification': justification
      };
  static Assenza fromJson(Map json) => Assenza(
      hour: json['hour'],
      value: json['value'],
      justified: json['justified'],
      justification: json['justification']);
}

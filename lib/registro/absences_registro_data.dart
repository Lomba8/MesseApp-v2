import 'package:Messedaglia/registro/registro.dart';
import 'package:flutter/material.dart';

class AbsencesRegistroData extends RegistroData {
  AbsencesRegistroData()
      : super(
            'https://web.spaggiari.eu/rest/v1/students/%uid/absences/details');

  Map<int, bool> noteNewFlags = {};

  @override
  Result parseData(json) {
    json = json['events'];

    for (Map absence in json) {
      Assenza lezione = Assenza(
          hour: absence['evtHPos'],
          value: absence['evtValue'],
          justified: absence['isJustified'],
          justification: absence['justifyReasonDesc']);
      data[DateTime.parse(absence['evtDate'])] = lezione;
    }
    return Result(true, true);
  }
}

class Assenza {
  final int hour;
  final dynamic value; // ?
  final bool justified;
  final String justification;

  Assenza({
    @required this.hour,
    @required this.value,
    @required this.justified,
    @required this.justification,
  });
}

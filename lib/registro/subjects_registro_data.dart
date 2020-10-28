import 'package:Messedaglia/preferences/globals.dart';
import 'package:Messedaglia/registro/registro.dart';
import 'package:flutter/material.dart';

class SubjectsRegistroData extends RegistroData {
  SubjectsRegistroData({@required RegistroApi account})
      : super(
            url: 'https://web.spaggiari.eu/rest/v1/students/%uid/subjects',
            account: account,
            name: 'subjects');

  @override
  Future<Result> parseData(json) async {
    try {
      data.clear();
      for (Map<String, dynamic> sbj in json['subjects']) {
        for (Map<String, dynamic> teacher in sbj['teachers']) {
          if (data[teacher['teacherName']] == null)
            data[teacher['teacherName']] = sbj['description'];
          else if (data[teacher['teacherName']] is String)
            data[teacher['teacherName']] = [
              data[teacher['teacherName']],
              sbj['description']
            ];
          else
            data[teacher['teacherName']].add(sbj['description']);
        }
      }

      // for (dynamic profe in data) {
      //   if (profe["teachers"].length > 1) {
      //     if (profe["teachers"].contains("EDUCAZIONE CIVICA"))
      //       profe["teachers"].toList().removeWhere(
      //           (element) => element.toString() == "EDUCAZIONE CIVICA");
      //   }
      // }

      Map.from(data).forEach((key, value) {
        if (value is List) {
          value.removeWhere(
              (e) => e.compareTo("EDUCAZIONE CIVICA") == 0 ? true : false);
        }
      });
    } catch (e, stack) {
      print(e);
      print(stack);
    }
    return Result(false, false);
  }

  @override
  Map<String, dynamic> toJson() {
    Map<String, dynamic> tr = super.toJson();
    tr['data'] = data;
    return tr;
  }

  @override
  void fromJson(Map<String, dynamic> json) {
    super.fromJson(json);
    data = json['data'];
  }

  String getFirstSubject(String teacher) =>
      data[teacher] is String ? data[teacher] : data[teacher]?.first;

  Map subjectTheme(String teacher) =>
      Globals.subjects[getFirstSubject(teacher)];

  @override
  Future<void> create() {
    // TODO: implement create
  }
}

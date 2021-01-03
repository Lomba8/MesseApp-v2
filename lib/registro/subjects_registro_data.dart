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

      Map.from(data).forEach((key, value) {
        if (value is List) {
          value.removeWhere(
              (e) => e.compareTo("EDUCAZIONE CIVICA") == 0 ? true : false);
        } else if (value is String) {
          data[key] = List.generate(1, (index) => value);
        }
      });
      await account.update(); // nel caso fosse stata cambiata la classe

      return Result(true, true);
    } catch (e, stack) {
      print(e);
      print(stack);
      return Result(false, false);
    }
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
    // non usiamo il db ma salviamo su .json
  }
}

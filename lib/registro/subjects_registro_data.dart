import 'package:Messedaglia/preferences/globals.dart';
import 'package:Messedaglia/registro/registro.dart';

class SubjectsRegistroData extends RegistroData {
  SubjectsRegistroData()
      : super('https://web.spaggiari.eu/rest/v1/students/%uid/subjects');

  @override
  Result parseData(json) {
    try {
      data.clear();
      for (Map<String, dynamic> sbj in json['subjects']) {
        for (Map<String, dynamic> teacher in sbj['teachers']) {
          if (data[teacher['teacherName']] == null)
            data[teacher['teacherName']] = sbj['description'];
          else if (data[teacher['teacherName']] is String)
            data[teacher['teacherName']] = [data[teacher['teacherName']], sbj['description']];
          else data[teacher['teacherName']].add(sbj['description']);
        }
      }
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

  String getFirstSubject (String teacher) => data[teacher] is String ? data[teacher] : data[teacher]?.first;

  Map subjectTheme (String teacher) => Globals.subjects[getFirstSubject(teacher)];

}

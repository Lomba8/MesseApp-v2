import 'package:applicazione_prova/preferences/globals.dart';
import 'package:applicazione_prova/registro/registro.dart';

class SubjectsRegistroData extends RegistroData {
  SubjectsRegistroData()
      : super('https://web.spaggiari.eu/rest/v1/students/%uid/subjects');

  static Map<String, Map<String, dynamic>> newSubjects = {};

  @override
  Result parseData(json) {
    try {
      json = json['subjects'];

      for (int i = 0; i < json.length; i++) {
        Globals.subjects.forEach((k, v) {
          if (v['materia'] == json[i]['description']) {
            if (json[i]['teachers'].length > 1) {
              for (int j = 0; j < json[i]['teachers'].length; j++) {
                newSubjects.putIfAbsent(
                    '${json[i]['teachers'][j]['teacherName']}', () => v);
              }
            }
            newSubjects.putIfAbsent(
                '${json[i]['teachers'][0]['teacherName']}', () => v);
          }
        });
      }

      Globals.subjects = newSubjects;
    } catch (e, stack) {
      print(e);
      print(stack);
    }
    return Result(false, false);
  }
}

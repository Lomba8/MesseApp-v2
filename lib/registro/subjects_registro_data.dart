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
          data[teacher['teacherName']] = sbj['description'];
        }
      }
    } catch (e, stack) {
      print(e);
      print(stack);
    }
    return Result(false, false);
  }
}

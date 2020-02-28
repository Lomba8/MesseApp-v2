import 'package:flutter/material.dart';
import 'package:path_parsing/path_parsing.dart';

final Map<String, List<String>> testActivitiesMask = {
  'JUST DANCE': ['AULA MAGNA'],
  'SIMPOSIO': ['AULA 11', 'AULA 13', 'AULA 18', 'AULA 20'],
  'QUIZ': ['AULA 22', 'AULA 24'],
  'VIDEOGAMES': ['AULA 29'],
  'BUBBLE FOOTBALL': ['PALESTRA 1', 'PALESTRA 2'],
  // 'CINEFORUM': ['AULA 32', 'AULA 33', 'AULA 34', 'AULA 35'] TODO: aule
};

int getFloor(String className) {
  for (int i = 0; i < floors.length; i++)
    if (floors[i].classes.containsKey(className) &&
        floors[i].classes[className]['selectable']) return i - 2;
  return null;
}

/// school:[0|1]      la maschera del profilo della scuola
/// |                       separatore per le classi
/// [nome classe]:[maschera della classe]&[pos x],[pos y]{[selectable (true|false)]&[default fill color (HEX)]}
final List<Floor> floors = [
  'school:0|PALESTRA 1:gym&163,0|PALESTRA 2:gym&593,0', // TODO: floor -2

  '''school:0|PALESTRINA:class3&0,169|PALESTRA 1:gym2&163,0&false&50000000|
    LABORATORIO BIOLOGIA:class4&103,0|LABORATORIO ROBOTICA:class4&319,0|LABORATORIO CHIMICA 3:class4&809,0|
    AULA MAGNA:aulamgn&379,169|PALESTRA 2:gym&593,0&false&50000000|LABORATORIO FISICA:class3&869,169''', // floor -1 (TO COMPLETE)

  '''school:0|BIBLIOTECA:class3&0,169|AULA 1:class1&156,0|AULA 2:class1&241,0|AULA 3:class2&103,121|
    AULA 4:class0&204,121|AULA 5:class2&278,121|AULA 6:class1&646,0|AULA 7:class1&731,0|
    AULA 8:class2&593,121|AULA 9:class0&694,121|AULA 10:class2&768,121|AULA INSEGNANTI:class3&869,169|
    BAGNO1:bagno&0,0&false&A00000AA|BAGNO2:bagno&869,0&false&A0E427B3''', // floor 0 , TODO: fix biblioteca

  '''school:1|AULA AUDIOVISIVI:class3&0,169|AULA 11:class1&156,0|AULA 12:class1&241,0|AULA 13:class2&103,121|
    AULA 14:class0&204,121|AULA 15:class2&278,121|SEGRETERIA AMMINISTRATIVA:lab&379,169|
    AULA 16:class1&646,0|AULA 17:class1&731,0|AULA 18:class2&593,121|
    AULA 19:class0&694,121|AULA 20:class2&768,121|AULA 20 BIS:class3&869,169|
    BAGNO1:bagno&0,0&false&A0E427B3|BAGNO2:bagno&869,0&false&A00000AA''', // floor 1 TODO: fix aula audiovisivi

  '''school:1|LABORATORIO CHIMICA:class3&0,169|AULA 21:class1&156,0|AULA 22:class1&241,0|AULA 23:class2&103,121|
    AULA 24:class0&204,121|AULA 25:class2&278,121|LABORATORIO LINGUE:lab&379,169|LABORATORIO INFO:lab&501,169|
    AULA 26:class1&646,0|AULA 27:class1&731,0|AULA 28:class2&593,121|
    AULA 29:class0&694,121|AULA 30:class2&768,121|AULA 30 BIS:class3&869,169|
    BAGNO1:bagno&0,0&false&A00000AA|BAGNO2:bagno&869,0&false&A0E427B3''', // floor 2

  '''school:0|BIBLIOTECA:biblio&379,169|
    BAGNO1:bagno&0,0&false&A0E427B3|BAGNO2:bagno&869,0&false&A00000AA''' // floor 3
].map((data) => Floor(data)).toList();

class Floor {
  PathBuilder school;
  Map<String, Map<String, dynamic>> classes = {};

  Floor(String data) {
    data +=
        '|stairs0:stairsLTR&-7,46&false&0|stairs1:stairsRTL&897,46&false&0|stairs2:stairsLTR&379,0&false&0|stairs3:stairsRTL&511,0&false&0';
    List<String> rawClasses = data.split('|');
    assert(rawClasses[0].split(':')[0] == 'school');
    school = scuole[int.parse(rawClasses[0].split(':')[1])];

    for (int i = 1; i < rawClasses.length; i++) {
      List<String> split1 = rawClasses[i].split(':');
      List<String> split2 = split1[1].split('&');
      List<String> split3 = split2[1].split(',');
      classes[split1[0].trim()] = {
        'pathBuilder': pathBuilders[split2[0]],
        'translation': Offset(double.parse(split3[0]), double.parse(split3[1])),
        'selectable': split2.length >= 3 ? split2[2] == 'true' : true,
        'defaultColor': split2.length >= 4
            ? Color(int.parse(split2[3], radix: 16))
            : Colors.lime[800]
      };
    }

    // TODO: dove li metto sti alberi?
    int c = 0;
    [Offset(200, -200), Offset(400, -100),
    Offset(600,-300), Offset(800, -250),
    Offset(700, -125), Offset(300, -275)]
    .forEach((offset) {
      classes['tree${c++}'] = {
        'pathBuilder': pathBuilders['tree'],
        'translation': offset,
        'selectable': false,
        'defaultColor': Color(0xFF004400)
      };
    });
  }

  List<String> get classesList {
    List<String> list = [];
    for (String key in classes.keys)
      if (classes[key]['selectable']) list.add(key);
    return list;
  }
}

final List<PathBuilder> scuole = [
  PathBuilder(
      'v46h-7v50h7v73h103v-48h276v48h214v-48h276v48h103v-73h7v-50h-7v-46'),
  PathBuilder(
      'v46h-7v50h7v73h103v-48h276v48h92v-30h30v30h92v-48h276v48h103v-73h7v-50h-7v-46')
];
final Map<String, PathBuilder> pathBuilders = {
  'tree': PathBuilder('q-10,-14,8,-16q0,-20,16,-16q10,-10,16,4q16,-2,14,12q14,10,0,20q8,16,-8,20q-12,28,-24,4q-20,8,-16,-12q-14,-4,-6,-16'),
  'lab': PathBuilder('h92v-73h-92'),
  'class0': PathBuilder('h74v-50h-74'),
  'class1': PathBuilder('h85v50h-85'),
  'class2': PathBuilder('h101v-50h-101'),
  'class3': PathBuilder('h103v-73h-103'),
  'class4': PathBuilder('h60v121h-60'),
  'gym': PathBuilder('h216v121h-216'),
  'gym2': PathBuilder('h156v121h-156'),
  'stairsLTR': PathBuilder(
      'M21,0v50m10,0v-50m10,0v50m10,0v-50m10,0v50m21,0h-82v-50h82M21,25h40',
      close: false,
      startFromOrigin: false), // 82* 50
  'stairsRTL': PathBuilder(
      'h82v50h-82m21,-50v50m10,0v-50m10,0v50m10,0v-50m10,0v50m-61,0M21,25h40',
      close: false),
  'biblio': PathBuilder('h214v-98h-214'),
  'bagno': PathBuilder('h103v46h-103'),
  'aulamgn': PathBuilder('''h214v-68h-40l-15,-30h-104l-15,30h-40z
  M51.25,-90.5L76.77,-81.06H137.23L162.75,-90.5
  M47.5,-83L74.73,-72.93H139.27L166.5,-83
  M43.75,-75.5L72.7,-64.79H141.3L170.25,-75.5
  M40,-68L70.66,-56.66H143.34L174,-68

  M32.5,-53L66.59,-40.39H147.41L181.5,-53
  M28.75,-45.5L64.56,-32.36H149.45L185.25,-45.5
  M25,-38L62.52,-24.12H151.48L189,-38
  M21.25,-30.5L60.49,-15.99H153.52L192.75,-30.5''', close: false)
};

class PathBuilder extends PathProxy {
  String _svg;
  double _width, _height; // crop factor
  Offset _offset;
  Path _path = Path();

  PathBuilder(String svg, {bool close = true, bool startFromOrigin = true}) {
    _svg = '${startFromOrigin ? 'M0,0' : ''}$svg${close ? 'z' : ''}';
  }

  Path create(
      {Offset translation = const Offset(0, 0),
      double cropWidth = 1.0,
      double cropHeight = 1.0}) {
    _path.reset();
    _width = cropWidth;
    _height = cropHeight;
    _offset = translation;
    writeSvgPathDataToPath(_svg, this);
    return _path;
  }

  @override
  void close() {
    _path.close();
  }

  @override
  void cubicTo(
      double x1, double y1, double x2, double y2, double x3, double y3) {
    _path.cubicTo(
        (x1 + _offset.dx) * _width,
        (y1 + _offset.dy) * _height,
        (x2 + _offset.dx) * _width,
        (y2 + _offset.dy) * _height,
        (x3 + _offset.dx) * _width,
        (y3 + _offset.dy) * _height);
  }

  @override
  void lineTo(double x, double y) {
    _path.lineTo((x + _offset.dx) * _width, (y + _offset.dy) * _height);
  }

  @override
  void moveTo(double x, double y) {
    _path.moveTo((x + _offset.dx) * _width, (y + _offset.dy) * _height);
  }
}

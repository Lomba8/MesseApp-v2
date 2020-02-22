import 'package:flutter/material.dart';

import 'package:path_parsing/path_parsing.dart';

class MapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  bool _scroll = false;
  String selectedClass;
  double _floor = 0;

  static final List<Floor> floors = [
    'school:0', // TODO: floor -2

    'school:0|PALESTRINA:big&0,169|LABORATORIO FISICA:big&869,169', // floor -1 (TO COMPLETE)

    '''school:0|BIBLIOTECA:big&0,169|AULA 3:med&103,121|AULA 4:small&204,121|AULA 5:med&278,121|
    AULA 8:med&593,121|AULA 9:small&693,121|AULA 10:med&768,121|AULA INSEGNANTI:big&869,169''', // floor 0 , TODO: sbaglio o non c'è più la biblioteca?

    '''school:1|AULA AUDIOVISIVI:big&0,169|AULA 13:med&103,121|AULA 14:small&204,121|
    AULA 15:med&278,121|SEGRETERIA AMMINISTRATIVA:lab&379,169|AULA 18:med&593,121|
    AULA 19:small&693,121|AULA 20:med&768,121|AULA 20 BIS:big&869,169''', // floor 1 TODO: fix aula audiovisivi

    '''school:1|LABORATORIO CHIMICA:big&0,169|AULA 23:med&103,121|AULA 24:small&204,121|
    AULA 25:med&278,121|LABORATORIO LINGUE:lab&379,169|LABORATORIO INFO:lab&501,169|AULA 28:med&593,121|
    AULA 29:small&693,121|AULA 30:med&768,121|AULA 30 BIS:big&869,169''', // floor 2

    'school:0' // floor 3
  ].map((data) => Floor(data)).toList();

  @override
  Widget build(BuildContext context) => Scaffold(
        body: Padding(
          padding: MediaQuery.of(context).padding,
          child: Column(children: <Widget>[
            Stack(children: [
              SingleChildScrollView(
                // TODO:  con o senza scroll?
                scrollDirection: Axis.horizontal,
                child: CustomPaint(
                  size: _scroll
                      ? Size(1000, 200)
                      : Size(MediaQuery.of(context).size.width,
                          MediaQuery.of(context).size.width * 3 / 5),
                  painter: MapPainter(selectedClass, floor: _floor),
                ),
              ),
              Positioned(
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                        color: Colors.black
                            .withOpacity(_floor.floor() + 1 - _floor),
                        borderRadius: BorderRadius.circular(10)),
                    child: Center(
                        child: Text(
                      _floor.floor().toString(),
                      style: TextStyle(
                          color: Colors.white
                              .withOpacity(_floor.floor() + 1 - _floor)),
                    )),
                  ),
                  top: 20,
                  left: 20),
              Positioned(
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                        color:
                            Colors.black.withOpacity(_floor - _floor.floor()),
                        borderRadius: BorderRadius.circular(10)),
                    child: Center(
                        child: Text(
                      _floor.ceil().toString(),
                      style: TextStyle(
                          color: Colors.white
                              .withOpacity(_floor - _floor.floor())),
                    )),
                  ),
                  top: 20,
                  left: 20)
            ]),
            Slider(
              value: _floor,
              onChanged: (v) => setState(() => _floor = v),
              onChangeEnd: (v) => setState(() => _floor = v.roundToDouble()),
              min: -2,
              max: 3,
              //label: _floor.round().toString(),
              activeColor: Theme.of(context).primaryColor,
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: <Widget>[
                  Icon(
                    Icons.warning,
                    color: Colors.yellow,
                  ),
                  Expanded(
                      child: Text(
                    "WORK IN PROGRESS!",
                    textAlign: TextAlign.center,
                  )),
                  Icon(
                    Icons.warning,
                    color: Colors.yellow,
                  ),
                ],
              ),
            ),
            Row(
              children: <Widget>[
                Expanded(
                    child: Text(
                  "Qual è meglio?",
                  style: TextStyle(fontWeight: FontWeight.normal),
                )),
                IconButton(
                  icon:
                      Icon(_scroll ? Icons.fullscreen : Icons.fullscreen_exit),
                  onPressed: () => setState(() => _scroll = !_scroll),
                ),
              ],
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                    children: floors[_floor.round()+2].classes.keys
                        .map((aula) => GestureDetector(
                              child: Padding(
                                  padding: EdgeInsets.all(8),
                                  child: Text(aula)),
                              onTap: () => setState(() => selectedClass = aula),
                            ))
                        .toList()),
              ),
            )
          ]),
        ),
      );
}

class MapPainter extends CustomPainter {
  Paint _paint = Paint()
    ..color = Colors.white
    ..style = PaintingStyle.stroke
    ..strokeWidth = 2;

  String _selectedClass;
  double floor;
  MapPainter(this._selectedClass, {this.floor = 0});

  static final List<PathBuilder> scuole = [
    PathBuilder(
        'v46h-7v50h7v73h103v-48h276v48h214v-48h276v48h103v-73h7v-50h-7v-46'),
    PathBuilder(
        'v46h-7v50h7v73h103v-48h276v48h92v-30h30v30h92v-48h276v48h103v-73h7v-50h-7v-46')
  ];
  static final Map<String, PathBuilder> pathBuilders = {
    'lab': PathBuilder('h92v-73h-92'),
    'med': PathBuilder('h101v-50h-101'),
    'small': PathBuilder('h74v-50h-74'),
    'big': PathBuilder('h103v-73h-103')
  };

  @override
  void paint(Canvas canvas, Size size) {
    // TODO: le porte?
    double cropWidth = size.width / 1000, cropHeight = size.height / 600;
    if (size.width / size.height == 5) cropHeight *= 3;
    _paint.color = Colors.green[900];
    canvas.drawPaint(_paint);
    _paint.color = Colors.white;

    _paintFloor(canvas, _MapScreenState.floors[floor.floor()+2], floor.floor()-floor+1, cropWidth,
        cropHeight, size.width / size.height);
    _paintFloor(canvas, _MapScreenState.floors[floor.ceil()+2], floor-floor.floor(), cropWidth,
        cropHeight, size.width/size.height);
  }

  void _paintFloor(Canvas canvas, Floor floor, double opacity, double cropWidth,
      double cropHeight, double ratio) {

    
    Offset start = Offset(14, ratio == 5 ? 16 : 400);

    Path path = floor.school.create(
        cropWidth: cropWidth, cropHeight: cropHeight, translation: start);

    _paint.color = Colors.lime[900].withOpacity(opacity); //.withAlpha(128);
    _paint.style = PaintingStyle.fill;
    canvas.drawPath(path, _paint);
    _paint.color = Colors.white.withOpacity(opacity);
    _paint.style = PaintingStyle.stroke;
    canvas.drawPath(path, _paint);

    floor.classes.forEach((aula, data) {
      path = data['pathBuilder'].create(
          cropWidth: cropWidth,
          cropHeight: cropHeight,
          translation: (data['translation'] ?? Offset(0, 0))
              .translate(start.dx, start.dy));
      if (aula == _selectedClass) {
        _paint
          ..color = Colors.yellow[700].withOpacity(opacity)
          ..style = PaintingStyle.fill;
        canvas.drawPath(path, _paint);
        _paint
          ..color = Colors.white.withOpacity(opacity)
          ..style = PaintingStyle.stroke;
      }
      canvas.drawPath(path, _paint);
    });
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}

enum Mode { ABSOLUTE, RELATIVE }

class PathBuilder extends PathProxy {
  String _svg;
  double _width, _height; // crop factor
  Offset _offset;
  Path _path = Path();

  PathBuilder(String svg) {
    _svg = 'M0,0${svg}z';
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
    // TODO: implement cubicTo
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

class Point {
  final double x, y;
  Point(this.x, this.y);
}

class Floor {
  PathBuilder school;
  Map<String, Map<String, dynamic>> classes = {};

  Floor(String data) {
    List<String> rawClasses = data.split('|');
    assert(rawClasses[0].split(':')[0] == 'school');
    school = MapPainter.scuole[int.parse(rawClasses[0].split(':')[1])];

    for (int i = 1; i < rawClasses.length; i++) {
      List<String> split1 = rawClasses[i].split(':');
      List<String> split2 = split1[1].split('&');
      List<String> split3 = split2[1].split(',');
      classes[split1[0].trim()] = {
        'pathBuilder': MapPainter.pathBuilders[split2[0]],
        'translation': Offset(double.parse(split3[0]), double.parse(split3[1]))
      };
    }
  }
}

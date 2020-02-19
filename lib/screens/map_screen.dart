import 'package:flutter/material.dart';

class MapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  bool _scroll = true;
  String selectedClass;

  static final Map<String, Map<String, dynamic>> classes = {
    'LAB CHIMICA': {
      'pathBuilder': MapPainter.bigClass,
      'translation': null
    },
    'AULA 23': {
      'pathBuilder': MapPainter.mediumClass,
      'translation': null
    },
    'AULA 24': {
      'pathBuilder': MapPainter.smallClass,
      'translation': null
    },
    'AULA 25': {
      'pathBuilder': MapPainter.mediumClass,
      'translation': Offset(175, 0)
    },
    'LABORATORIO LINGUE': {
      'pathBuilder': MapPainter.labs,
      'translation': null
    },
    'LABORATORIO INFO': {
      'pathBuilder': MapPainter.labs,
      'translation': Offset(122, 0)
    },
    'AULA 28': {
      'pathBuilder': MapPainter.mediumClass,
      'translation': Offset(490, 0)
    },
    'AULA 29': {
      'pathBuilder': MapPainter.smallClass,
      'translation': Offset(490, 0)
    },
    'AULA 30': {
      'pathBuilder': MapPainter.mediumClass,
      'translation': Offset(665, 0)
    },
    'AULA 30 BIS': {
      'pathBuilder': MapPainter.bigClass,
      'translation': Offset(869, 0)
    }
  };

  @override
  Widget build(BuildContext context) => Scaffold(
        body: Padding(
          padding: MediaQuery.of(context).padding,
          child: Column(
            children: <Widget>[
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
              SingleChildScrollView(  // TODO:  con o senza scroll?
                scrollDirection: Axis.horizontal,
                child: CustomPaint(
                  size: _scroll ? Size(1000, 200) :
                  Size(MediaQuery.of(context).size.width, MediaQuery.of(context).size.width/5),
                  painter: MapPainter(selectedClass),
                ),
              ),
              Row(
                children: <Widget>[
                  Expanded(child: Text("Qual è meglio?", style: TextStyle(fontWeight: FontWeight.normal),)),
                  IconButton(
                    icon: Icon(_scroll ? Icons.fullscreen : Icons.fullscreen_exit),
                    onPressed: () => setState(() => _scroll = !_scroll),
                  ),
                ],
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: classes.keys.map((aula) => GestureDetector(
                      child: Padding(
                        padding: EdgeInsets.all(8),
                        child: Text(aula)
                      ),
                      onTap: () => setState(() => selectedClass = aula),
                    )).toList()
                  ),
                ),
              )
            ]
          ),
        ),
      );
}

class MapPainter extends CustomPainter {
  Paint _paint = Paint()
    ..color = Colors.white
    ..style = PaintingStyle.stroke
    ..strokeWidth = 2;

  String _selectedClass;
  MapPainter (this._selectedClass);

  static final PathBuilder scuola = PathBuilder(
    1000, 200,
    [14,0,-7,0,7,0,103,0,276,0,214,0,276,0,103,0,7,0,-7,0],
    [16,46,0,50,0,73,0,-48,0,48,0,-48,0,48,0,-73,0,-50,0,-46]
  );
  static final PathBuilder labs = PathBuilder(
    1000, 200,
    [393,92,0,-92],
    [185,0,-73,0],
  );
  static final PathBuilder mediumClass = PathBuilder(
    1000, 200,
    [117, 101, 0, -101],
    [137, 0, -50, 0]
  );
  static final PathBuilder smallClass = PathBuilder(
    1000, 200,
    [218, 74, 0, -74],
    [137, 0, -50, 0]
  );
  static final PathBuilder bigClass = PathBuilder(
    1000, 200,
    [14,103,0,-103],
    [185,0,-73,0]
  );

  @override
  void paint(Canvas canvas, Size size) {  // TODO: le porte?

    _MapScreenState.classes.forEach((aula, data) {
      if (aula == _selectedClass){
        _paint..color = Colors.green
          ..style = PaintingStyle.fill;
        canvas.drawPath(data['pathBuilder'].create(size.width, size.height, translation: data['translation'] ?? Offset(0, 0)), _paint);
        _paint..color = Colors.white
          ..style = PaintingStyle.stroke;
      }
      canvas.drawPath(data['pathBuilder'].create(size.width, size.height, translation: data['translation'] ?? Offset(0, 0)), _paint);
    });

    canvas.drawPath(scuola.create(size.width, size.height), _paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}

enum Mode {
  ABSOLUTE, RELATIVE
}
class PathBuilder {
  int _width, _height; // larghezza e altezza alle quali si riferiscono i punti
  final List<Point> _pts = [];
  final Mode mode;

  PathBuilder(this._width, this._height, List<double> xs, List<double> ys, {this.mode = Mode.RELATIVE}) {
    print ('${xs.length} x ${ys.length}');
    assert(xs.length == ys.length);
    for (int i = 0; i < xs.length; i++) _pts.add(Point(xs[i], ys[i]));
  }

  Path create(double width, double height, {Offset translation = const Offset(0, 0)}) {
    // larghezza e altezza reali
    double cx = width / _width, cy = height / _height;
    translation = Offset(translation.dx*cx, translation.dy*cy);
    Path path = Path();
    path.moveTo(_pts[0].x * cx + translation.dx, _pts[0].y * cy + translation.dy);
    for (int i = 1; i < _pts.length; i++)
      if (mode == Mode.ABSOLUTE) path.lineTo(_pts[i].x * cx + translation.dx, _pts[i].y * cy + translation.dy);
      else path.relativeLineTo(_pts[i].x * cx, _pts[i].y * cy);
    path.close();
    return path;
  }
}

class Point {
  final double x, y;
  Point(this.x, this.y);
}

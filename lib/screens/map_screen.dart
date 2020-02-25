import 'package:Messedaglia/utils/mapUtils.dart';
import 'package:flutter/material.dart';

class MapScreen extends StatefulWidget {
  //final Map<String, List<String>> activities;   TODO: attualmente gestito internamente, deve essere lanciata la route con il parametro

  MapScreen(/*{this.activities}*/);

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  bool _scroll = false;
  List<String> selectedClass = [];
  double _floor = 0;

  Map<String, List<String>> activities;

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
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(10)),
                    child: Center(
                        child: Text(
                      _floor.floor().toString(),
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
            Row(
              children: <Widget>[
                Expanded(
                    child: Text(
                  'Visualizza le attività:',
                  style: TextStyle(fontWeight: FontWeight.normal),
                )),
                Switch(
                  value: activities != null,
                  onChanged: (v) => setState(
                      () => activities = v ? testActivitiesMask : null),
                ),
              ],
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                    children: activities == null
                        ? floors[_floor.round() + 2]
                            .classesList
                            .map((aula) => GestureDetector(
                                  child: Padding(
                                      padding: EdgeInsets.all(8),
                                      child: Text(aula)),
                                  onTap: () =>
                                      setState(() => selectedClass = [aula]),
                                ))
                            .toList()
                        : activities.keys
                            .map((activity) => GestureDetector(
                                  child: Padding(
                                      padding: EdgeInsets.all(8),
                                      child: Text(activity)),
                                  onTap: () =>
                                      setState(() {
                                        _floor = getFloor (activities[activity][0]).toDouble();
                                        selectedClass = activities[activity];
                                      }),
                                ))
                            .toList()),
              ),
            )
          ]),
        ),
      );
}

class MapPainter extends CustomPainter {
  static final Color border = Colors.black; // TODO: meglio bianco o nero?

  Paint _paint = Paint()
    ..color = border
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1;

  List<String> _selectedClass;
  double floor;
  MapPainter(this._selectedClass, {this.floor = 0});

  @override
  void paint(Canvas canvas, Size size) {
    // TODO: le porte?
    double cropWidth = size.width / 1000, cropHeight = size.height / 600;
    if (size.width / size.height == 5) cropHeight *= 3;
    _paint.color = Colors.green[900];
    canvas.drawPaint(_paint);
    _paint.color = border;

    _paintFloor(canvas, floors[floor.floor() + 2], 1, cropWidth, cropHeight,
        size.width / size.height);
    _paintFloor(canvas, floors[floor.ceil() + 2], floor - floor.floor(),
        cropWidth, cropHeight, size.width / size.height);
  }

  void _paintFloor(Canvas canvas, Floor floor, double opacity, double cropWidth,
      double cropHeight, double ratio) {
    Offset start = Offset(14, ratio == 5 ? 16 : 400);

    Path path = floor.school.create(
        cropWidth: cropWidth, cropHeight: cropHeight, translation: start);

    _paint.color = Colors.lime[900].withOpacity(opacity); //.withAlpha(128);
    _paint.style = PaintingStyle.fill;
    canvas.drawPath(path, _paint);
    _paint.color = border.withOpacity(opacity);
    _paint.style = PaintingStyle.stroke;
    canvas.drawPath(path, _paint);

    floor.classes.forEach((aula, data) {
      path = data['pathBuilder'].create(
          cropWidth: cropWidth,
          cropHeight: cropHeight,
          translation: (data['translation'] ?? Offset(0, 0))
              .translate(start.dx, start.dy));
      _paint
        ..color = _selectedClass.contains(aula) && data['selectable']
            ? Colors.yellow[700].withOpacity(opacity)
            : data['defaultColor']
                .withOpacity(data['defaultColor'].opacity * opacity)
        ..style = PaintingStyle.fill;
      canvas.drawPath(path, _paint);
      _paint
        ..color = border.withOpacity(opacity)
        ..style = PaintingStyle.stroke;

      canvas.drawPath(path, _paint);
    });
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}

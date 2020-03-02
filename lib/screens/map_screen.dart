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
                child: GestureDetector(
                  onTapUp: (details) {
                    final Offset start = Offset(14, _scroll ? 16 : 800);
                    selectedClass = [];
                    floors[_floor.toInt() + 2].classes.forEach((cls, data) {
                      if (data.selectable &&
                          data
                              .getFill(
                                  _scroll
                                      ? 1
                                      : MediaQuery.of(context).size.width /
                                          1000,
                                  Paint(),
                                  translateX: start.dx,
                                  translateY: start.dy)
                              .contains(details.localPosition))
                        selectedClass.add(cls);
                    });
                    setState(() {});
                  },
                  child: CustomPaint(
                    size: _scroll
                        ? Size(1000, 200)
                        : Size(MediaQuery.of(context).size.width,
                            MediaQuery.of(context).size.width),
                    painter: MapPainter(selectedClass, floor: _floor.toInt()),
                  ),
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
                      _floor.toStringAsFixed(0),
                      style: TextStyle(color: Colors.white),
                    )),
                  ),
                  top: 20,
                  left: 20),
            ]),
            Slider(
              label: 'piano ${_floor.toStringAsFixed(0)}',
              divisions: 5,
              value: _floor,
              onChanged: (v) => setState(() => _floor = v),
              onChangeEnd: (v) => setState(() => _floor = v.roundToDouble()),
              min: -2,
              max: 3,
              //label: _floor.round().toString(),
              activeColor: Theme.of(context).primaryColor,
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
                                  onTap: () => setState(() {
                                    _floor = getFloor(activities[activity][0])
                                        .toDouble();
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
  int floor;
  MapPainter(this._selectedClass, {this.floor = 0});

  @override
  void paint(Canvas canvas, Size size) {
    // TODO: le porte?
    double cropWidth = size.width / 1000;
    _paint.color = Colors.grey[700];
    canvas.drawPaint(_paint);
    _paint.color = border;

    _paintFloor(canvas, floors[floor + 2], cropWidth, size.width / size.height);
  }

  void _paintFloor(Canvas canvas, Floor floor, double crop, double ratio) {
    final Offset start = Offset(14, ratio == 5 ? 16 : 800);

    decorations.forEach((decoration) {
      canvas.drawPath(
          decoration.getFill(crop, _paint, translateY: start.dy), _paint);
      canvas.drawPath(
          decoration.getStroke(crop, _paint,
              translateY: start.dy, defaultColor: border),
          _paint);
    });

    floor.classes.forEach((aula, data) {
      canvas.drawPath(
          data.getFill(crop, _paint,
              translateX: start.dx,
              translateY: start.dy,
              color: _selectedClass.contains(aula) ? Colors.yellow[700] : null),
          _paint);
      canvas.drawPath(
          data.getStroke(crop, _paint,
              translateX: start.dx, translateY: start.dy, defaultColor: border),
          _paint);
    });
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}

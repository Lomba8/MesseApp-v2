import 'package:Messedaglia/screens/menu_screen.dart';
import 'package:Messedaglia/utils/mapUtils.dart';
import 'package:flutter/material.dart';

class MapScreen extends StatefulWidget {
  //final Map<String, List<String>> activities;   TODO: attualmente gestito internamente, deve essere lanciata la route con il parametro

  MapScreen(/*{this.activities}*/);

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  List<String> selectedClass = [];
  double _floor = 0;

  Map<String, List<String>> activities;

  @override
  Widget build(BuildContext context) => Material(
        child: CustomScrollView(slivers: [
          SliverAppBar(
            elevation: 0,
            pinned: true,
            title: Text(
              'CARTINA',
              style: Theme.of(context).textTheme.bodyText2,
            ),
            bottom: PreferredSize(
              child: Container(),
              preferredSize:
                  Size.fromHeight(MediaQuery.of(context).size.width / 8),
            ),
            centerTitle: true,
            backgroundColor: Colors.transparent,
            flexibleSpace: CustomPaint(
              painter: BackgroundPainter(Theme.of(context)),
              size: Size.infinite,
            ),
          ),
          SliverFillRemaining(
            child: Stack(children: [
              GestureDetector(
                onTapUp: (details) {
                  final Offset start = Offset(14, 800);
                  selectedClass = [];
                  floors[_floor.toInt() + 2].classes.forEach((cls, data) {
                    if (data.selectable &&
                        data
                            .getFill(MediaQuery.of(context).size.width / 1000,
                                Paint(),
                                translateX: start.dx, translateY: start.dy)
                            .contains(details.localPosition))
                      selectedClass.add(cls);
                  });
                  setState(() {});
                },
                child: CustomPaint(
                  size: Size.infinite,
                  painter: MapPainter(selectedClass, floor: _floor.toInt()),
                ),
              ),
              Container(
                height: 80,
                child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(20),
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
                      ),
                      Expanded(
                        child: Slider(
                          label: 'piano ${_floor.toStringAsFixed(0)}',
                          divisions: 5,
                          value: _floor,
                          onChanged: (v) => setState(() => _floor = v),
                          onChangeEnd: (v) =>
                              setState(() => _floor = v.roundToDouble()),
                          min: -2,
                          max: 3,
                          //label: _floor.round().toString(),
                          activeColor: Theme.of(context).primaryColor,
                        ),
                      ),
                    ]),
              ),
            ]),
          )
        ]),
      );
}

class MapPainter extends CustomPainter {
  static final Color border = Colors.black;

  Paint _paint = Paint()
    ..color = border
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1;

  List<String> _selectedClass;
  int floor;
  MapPainter(this._selectedClass, {this.floor = 0});

  @override
  void paint(Canvas canvas, Size size) {
    double cropWidth = size.width / 1000;
    _paint.color = Colors.grey[700];
    canvas.drawPaint(_paint);
    _paint.color = border;
    _paintFloor(canvas, floors[floor + 2], cropWidth,
        Offset(14, size.height / cropWidth - 200));
  }

  void _paintFloor(
      Canvas canvas, Floor floor, double crop, final Offset start) {
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

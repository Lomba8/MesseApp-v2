import 'package:Messedaglia/screens/menu_screen.dart';
import 'package:Messedaglia/utils/mapUtils.dart';
import 'package:Messedaglia/widgets/CustomConnectionStatusBar.dart';
import 'package:autocomplete_textfield/autocomplete_textfield.dart';
import 'package:flutter/material.dart';

class MapScreen extends StatefulWidget {
  MapScreen();

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GlobalKey<AutoCompleteTextFieldState<String>> _autocompleteKey = GlobalKey();
  TextEditingController _autocompleteController = TextEditingController();
  double floor = 0;

  String mask = 'aule';
  String selectedKey;
  bool showSearch = false;

  String reversePicker(String aula) => mapData[mask]['mask'].keys.singleWhere(
      (key) => mapData[mask]['mask'][key].contains(aula) as bool,
      orElse: () => null);

  @override
  Widget build(BuildContext context) => Material(
          child: SingleChildScrollView(
              child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(
          color: Colors.grey[700],
          child: CustomPaint(
              painter: BackgroundPainter(Theme.of(context)),
              child: Column(children: [
                Padding(
                  padding: EdgeInsets.only(
                      top: MediaQuery.of(context).padding.top + 8),
                  child: Row(
                    children: <Widget>[
                      IconButton(
                        icon: Icon(Icons.arrow_back_ios),
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.white60
                            : Colors.black54,
                        onPressed: () => Navigator.pop(context),
                      ),
                      Expanded(
                        child: Column(
                          children: <Widget>[
                            Text(
                              'CARTINA',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: Theme.of(context).brightness ==
                                          Brightness.light
                                      ? Colors.black
                                      : Colors.white,
                                  fontSize: 30,
                                  fontWeight: FontWeight.bold),
                            ),
                            CustomConnectionStatusBar(
                              width: MediaQuery.of(context).size.width / 3,
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.search),
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.white60
                            : Colors.black54,
                        onPressed: () =>
                            setState(() => showSearch = !showSearch),
                      )
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(
                      bottom: 20 + MediaQuery.of(context).size.width / 8),
                  child: Column(
                    children: <Widget>[
                      Container(
                        alignment: Alignment.center,
                        padding: EdgeInsets.only(
                            right: 20.0, left: showSearch ? 20 : 0),
                        child: showSearch
                            ? AutoCompleteTextField<String>(
                                itemSubmitted: (item) {
                                  setState(() => floor = getFloor(
                                          mapData[mask]['mask'][item]?.first,
                                          mask)
                                      .toDouble());
                                  selectedKey = item;
                                },
                                key: _autocompleteKey,
                                suggestions:
                                    mapData[mask]['mask'].keys.toList(),
                                itemBuilder: (context, suggestion) => Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(suggestion),
                                ),
                                itemSorter: (a, b) => a.compareTo(b),
                                itemFilter: (suggestion, query) {
                                  query = query.toUpperCase();
                                  List<String> split = query.split(' ');
                                  return split.every((s) =>
                                      suggestion.toUpperCase().contains(s));
                                },
                                clearOnSubmit: false,
                                controller: _autocompleteController,
                                suggestionsAmount: 10,
                                decoration: InputDecoration(
                                    icon: Icon(Icons.search),
                                    filled: true,
                                    hintText: 'cerca ${mapData[mask]['item']}'),
                              )
                            : Row(children: [
                                Expanded(
                                  child: Slider(
                                    label: 'piano ${floor.toStringAsFixed(0)}',
                                    divisions: 5,
                                    value: floor,
                                    onChanged: (v) => setState(() => floor = v),
                                    onChangeEnd: (v) => setState(
                                        () => floor = v.roundToDouble()),
                                    min: -2,
                                    max: 3,
                                    //label: _floor.round().toString(),
                                    activeColor: Theme.of(context).primaryColor,
                                  ),
                                ),
                                DropdownButton<String>(
                                  value: mask,
                                  items: mapData.keys
                                      .map((key) => DropdownMenuItem<String>(
                                          value: key, child: Text(key)))
                                      .toList(),
                                  onChanged: (value) => setState(() {
                                    mask = value;
                                    _autocompleteKey = GlobalKey();
                                    _autocompleteController.clear();
                                    selectedKey = null;
                                  }),
                                ),
                              ]),
                      ),
                    ],
                  ),
                ),
              ])),
        ),
        Stack(overflow: Overflow.clip, children: [
          GestureDetector(
            onTapUp: (details) {
              final Offset start = Offset(14, 703);
              Function(String, dynamic) picker = (cls, data) {
                if (data.selectable &&
                    data
                        .getFill(
                            MediaQuery.of(context).size.width / 1000, Paint(),
                            translateX: start.dx, translateY: start.dy)
                        .contains(details.localPosition))
                  _autocompleteController.text =
                      selectedKey = reversePicker(cls) ?? selectedKey;
              };
              floors[floor.toInt() + 2].classes.forEach(picker);
              if (mapData[mask]['classes'].length > floor + 2)
                mapData[mask]['classes'][floor.toInt() + 2].forEach(picker);
              setState(() {});
            },
            child: CustomPaint(
              size: Size.fromHeight(
                  MediaQuery.of(context).size.width * 903 / 1000),
              painter: MapPainter(mapData[mask]['mask'][selectedKey], mask,
                  floor: floor.toInt()),
            ),
          ),
          Container(
            margin: const EdgeInsets.all(20),
            width: 40,
            height: 40,
            decoration: BoxDecoration(
                color: Colors.black, borderRadius: BorderRadius.circular(10)),
            child: Center(
                child: Text(
              floor.toStringAsFixed(0),
              style: TextStyle(color: Colors.white),
            )),
          ),
        ]),
      ])));
}

class MapPainter extends CustomPainter {
  static final Color border = Colors.black;

  Paint _paint = Paint()
    ..color = border
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1;

  List _selectedClass;
  String _mask;
  int floor;
  MapPainter(this._selectedClass, this._mask, {this.floor = 0});

  @override
  void paint(Canvas canvas, Size size) {
    canvas.clipRect(Rect.fromLTWH(0, 0, size.width, size.height));
    double cropWidth = size.width / 1000;
    _paint.color = Colors.grey[700];
    canvas.drawPaint(_paint);
    _paint.color = border;
    _paintFloor(canvas, floors[floor + 2], cropWidth,
        Offset(14, size.height / cropWidth - 200));
  }

  void _paintFloor(
      Canvas canvas, Floor floor, double crop, final Offset start) {
    decorations.followedBy(mapData[_mask]['decorations']).forEach((decoration) {
      canvas.drawPath(
          decoration.getFill(crop, _paint, translateY: start.dy), _paint);
      canvas.drawPath(
          decoration.getStroke(crop, _paint,
              translateY: start.dy, defaultColor: border),
          _paint);
    });

    Function(String, dynamic) drawer = (aula, data) {
      canvas.drawPath(
          data.getFill(crop, _paint,
              translateX: start.dx,
              translateY: start.dy,
              color: (_selectedClass ?? []).contains(aula)
                  ? Colors.yellow[700]
                  : null),
          _paint);
      canvas.drawPath(
          data.getStroke(crop, _paint,
              translateX: start.dx, translateY: start.dy, defaultColor: border),
          _paint);
    };

    floor.classes.forEach(drawer); // join delle due mappe
    if (mapData[_mask]['classes'].length > this.floor + 2)
      mapData[_mask]['classes'][this.floor + 2].forEach(drawer);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}

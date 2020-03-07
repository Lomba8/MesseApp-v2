import 'package:Messedaglia/screens/menu_screen.dart';
import 'package:Messedaglia/utils/mapUtils.dart';
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

  String reversePicker(String aula) => masks[mask]
      .keys
      .firstWhere((key) => masks[mask][key].contains(aula), orElse: () => null);

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
                        child: Text(
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
                      ),
                      IconButton(
                        // per centrare il titolo
                        icon: Icon(Icons.arrow_forward_ios),
                        onPressed: null,
                        disabledColor: Colors.transparent,
                      )
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(
                      top: 20,
                      left: 20,
                      right: 20,
                      bottom: 20 + MediaQuery.of(context).size.width / 8),
                  child: Column(
                    children: <Widget>[
                      Slider(
                        label: 'piano ${floor.toStringAsFixed(0)}',
                        divisions: 5,
                        value: floor,
                        onChanged: (v) => setState(() => floor = v),
                        onChangeEnd: (v) =>
                            setState(() => floor = v.roundToDouble()),
                        min: -2,
                        max: 3,
                        //label: _floor.round().toString(),
                        activeColor: Theme.of(context).primaryColor,
                      ),
                      AutoCompleteTextField<String>(
                        itemSubmitted: (item) {
                          setState(() => floor =
                              getFloor(masks[mask][item]?.first).toDouble());
                          selectedKey = item;
                        },
                        key: _autocompleteKey,
                        suggestions: masks[mask].keys.toList(),
                        itemBuilder: (context, suggestion) => Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(suggestion),
                        ),
                        itemSorter: (a, b) => a.compareTo(b),
                        itemFilter: (suggestion, query) {
                          query = query.toUpperCase();
                          List<String> split = query.split(' ');
                          return split.every(
                              (s) => suggestion.toUpperCase().contains(s));
                        },
                        clearOnSubmit: false,
                        controller: _autocompleteController,
                        suggestionsAmount: 10,
                      ),
                      DropdownButton<String>(
                        isExpanded: true,
                        value: mask,
                        items: masks.keys
                            .map((key) => DropdownMenuItem<String>(
                                value: key, child: Text(key)))
                            .toList(),
                        onChanged: (value) => setState(() {
                          mask = value;
                          _autocompleteKey = GlobalKey();
                          _autocompleteController.clear();
                          selectedKey = null;
                        }),
                      )
                    ],
                  ),
                ),
              ])),
        ),
        Stack(overflow: Overflow.clip, children: [
          GestureDetector(
            onTapUp: (details) {
              final Offset start = Offset(14, 703);
              floors[floor.toInt() + 2].classes.forEach((cls, data) {
                if (data.selectable &&
                    data
                        .getFill(
                            MediaQuery.of(context).size.width / 1000, Paint(),
                            translateX: start.dx, translateY: start.dy)
                        .contains(details.localPosition))
                  _autocompleteController.text =
                      selectedKey = reversePicker(cls) ?? selectedKey;
              });
              setState(() {});
            },
            child: CustomPaint(
              size: Size.fromHeight(
                  MediaQuery.of(context).size.width * 903 / 1000),
              painter:
                  MapPainter(masks[mask][selectedKey], floor: floor.toInt()),
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

  List<String> _selectedClass;
  int floor;
  MapPainter(this._selectedClass, {this.floor = 0});

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
              color: (_selectedClass ?? []).contains(aula)
                  ? Colors.yellow[700]
                  : null),
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

import 'package:applicazione_prova/utils/orariUtils.dart' as orariUtils;
import 'package:flutter/material.dart';

class Orari extends StatefulWidget {
  static final String id = 'orari_screen';
  @override
  _OrariState createState() => _OrariState();
}

class _OrariState extends State<Orari> {
  String _selectedClass;

  @override
  void initState() {
    super.initState();
  }

  List<double> invertMatrix = [
    -209.15/255,-0.1,0.03,0,255,
    0.05,-209.15/255,-0.12,0,255,
    0.07,-0.04,-223.65/255,0,255,
    0,0,0,1,255
  ];

  @override
  Widget build(BuildContext context) => Padding(
        padding: MediaQuery.of(context).padding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: DropdownButton(
                  isExpanded: true,
                  hint: Text('seleziona una classe...'),
                  value: _selectedClass,
                  items: orariUtils.orari.keys
                      .map((cls) => DropdownMenuItem<String>(
                            child: Text('    $cls'),
                            value: cls,
                          ))
                      .toList()..sort((d1, d2) => d1.value.compareTo(d2.value)),  // TODO: sort solo una volta
                  onChanged: (cls) => setState(() => _selectedClass = cls)),
            ),
            if (_selectedClass != null)
              GridView.count(
                crossAxisCount: 6,
                shrinkWrap: true,
                children: (orariUtils.orari[_selectedClass] ?? []).map<Widget>((sbj) => 
                  Center(
                    child: Text(sbj),
                  )                
                ).toList(),
              )
          ],
        ),
      );
}

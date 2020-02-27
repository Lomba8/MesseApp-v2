import 'package:Messedaglia/utils/orariUtils.dart' as orariUtils;
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';

//TODO: optional menu scelta materia con highligth(aggiungendo alpha a materie non rilevanti)

class Orari extends StatefulWidget {
  static final String id = 'orari_screen';
  @override
  _OrariState createState() => _OrariState();
}

class _OrariState extends State<Orari> {
  static String _selectedClass;

  @override
  void initState() {
    super.initState();
  }

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
                      .toList()
                        ..sort((d1, d2) => d1.value
                            .compareTo(d2.value)), // TODO: sort solo una volta
                  onChanged: (cls) => setState(() => _selectedClass = cls)),
            ),
            if (_selectedClass != null)
              GridView.count(
                crossAxisCount: 6,
                childAspectRatio: 1.5,
                shrinkWrap: true,
                children: (orariUtils.orari[_selectedClass] ?? [])
                    .map<Widget>((sbj) => Container(
                          color: orariUtils.colors[sbj]?.withOpacity(1) ??
                              Colors.transparent,
                          child: Center(
                            child: AutoSizeText(
                              sbj,
                              style: TextStyle(color: Colors.black54),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ))
                    .toList(),
              )
          ],
        ),
      );
}

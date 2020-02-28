import 'package:Messedaglia/screens/menu_screen.dart';
import 'package:Messedaglia/utils/orariUtils.dart' as orariUtils;
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';

class Orari extends StatefulWidget {
  static final String id = 'orari_screen';
  @override
  _OrariState createState() => _OrariState();
}

class _OrariState extends State<Orari> {
  static String _selectedClass;
  String _selectedSbj;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) =>
      CustomScrollView(physics: ClampingScrollPhysics(), slivers: [
        SliverAppBar(
          centerTitle: true,
          title: Text(
            'ORARI',
            textAlign: TextAlign.center,
            style: TextStyle(
                color: Theme.of(context).brightness == Brightness.light
                    ? Colors.black
                    : Colors.white,
                fontSize: 30,
                fontWeight: FontWeight.bold),
          ),
          pinned: true,
          backgroundColor: Colors.transparent,
          flexibleSpace: CustomPaint(
            painter: BackgroundPainter(Theme.of(context)),
            size: Size.infinite,
          ),
          bottom: PreferredSize(
              child: Container(
                height: MediaQuery.of(context).size.height / 6,
                padding: EdgeInsets.symmetric(horizontal: 20.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Expanded(
                      child: DropdownButton(
                          isExpanded: true,
                          hint: Text('seleziona una classe...'),
                          value: _selectedClass,
                          items: orariUtils.orari.keys
                              .where((cls) => !cls.endsWith('url'))
                              .map((cls) => DropdownMenuItem<String>(
                                    child: Text('    $cls'),
                                    value: cls,
                                  ))
                              .toList()
                                ..sort((d1, d2) => d1.value.compareTo(
                                    d2.value)), // TODO: sort solo una volta
                          onChanged: (cls) =>
                              setState(() => _selectedClass = cls)),
                    ),
                    IconButton(
                        icon: Icon(Icons.file_download),
                        onPressed: _selectedClass == null
                            ? null
                            : () => orariUtils
                                .downloadOrario(_selectedClass)
                                .then((path) =>
                                    Scaffold.of(context).showSnackBar(SnackBar(
                                      content: Text(
                                          'Immagine scaricata con successo nella posizione $path'),
                                      behavior: SnackBarBehavior.floating,
                                      duration: Duration(minutes: 1),
                                    ))))
                  ],
                ),
              ),
              preferredSize:
                  Size.fromHeight(MediaQuery.of(context).size.height / 6)),
        ),
        SliverList(
            delegate: SliverChildListDelegate(
          [
            if (_selectedClass != null)
              GridView.count(
                physics: NeverScrollableScrollPhysics(),
                crossAxisCount: 6,
                childAspectRatio: 1.5,
                shrinkWrap: true,
                children: (orariUtils.orari[_selectedClass] ?? [])
                    .map<Widget>((sbj) => GestureDetector(
                          onTap: () => setState(() =>
                              _selectedSbj = sbj == _selectedSbj ? null : sbj),
                          child: Container(
                            color: orariUtils.colors[sbj]?.withOpacity(
                                    _selectedSbj == null || _selectedSbj == sbj
                                        ? 1
                                        : 0.5) ??
                                Colors.transparent,
                            child: Center(
                              child: AutoSizeText(
                                sbj,
                                style: TextStyle(
                                    color: _selectedSbj == null ||
                                            _selectedSbj == sbj
                                        ? Colors.black54
                                        : Colors.white54),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ))
                    .toList(),
              )
          ],
        ))
      ]);
}

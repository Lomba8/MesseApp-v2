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

  bool get _hasSaturday {
    List orario = orariUtils.orari[_selectedClass];
    if (orario == null) return true;
    for (int i = 5; i < orario.length; i += 6) if (orario[i] != '') return true;
    return false;
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
          actions: <Widget>[
            IconButton(
                icon: Icon(
                  Icons.file_download,
                  color: Colors.white,
                ),
                onPressed: _selectedClass == null
                    ? null
                    : () => orariUtils.downloadOrario(_selectedClass).then(
                        (path) => Scaffold.of(context).showSnackBar(SnackBar(
                              content: Text(path == null
                                  ? 'Errore durante il download'
                                  : 'Immagine scaricata con successo nella posizione $path'),
                              behavior: SnackBarBehavior.floating,
                              duration: Duration(minutes: 1),
                            ))))
          ],
          pinned: true,
          backgroundColor: Colors.transparent,
          flexibleSpace: CustomPaint(
            painter: BackgroundPainter(Theme.of(context)),
            size: Size.infinite,
          ),
          bottom: PreferredSize(
              child: Container(),
              preferredSize:
                  Size.fromHeight(MediaQuery.of(context).size.height / 8)),
        ),
        SliverList(
            delegate: SliverChildListDelegate([
          GridView.count(
              crossAxisCount: _hasSaturday ? 7 : 6,
              childAspectRatio: 1.5,
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              children: _children(context)),
          _selectionChildren(context)
        ])),
      ]);

  List<Widget> _children(BuildContext context) {
    List orario = orariUtils.orari[_selectedClass];
    if (orario == null) return [];
    bool saturday = _hasSaturday;
    List<Widget> children = [Container()];
    ['LUN', 'MAR', 'MER', 'GIO', 'VEN', if (saturday) 'SAB']
        .forEach((d) => children.add(Center(
              child: Text(
                d,
                style: Theme.of(context).textTheme.bodyText1,
              ),
            )));
    for (int i = 0; i < orario.length; i++) {
      if ((i + 1) % 6 == 0 && !saturday)
        continue;
      else if (i % 6 == 0)
        children.add(Text(
          '${(i ~/ 6 + 8).toString().padLeft(2, '0')}:00',
          style: Theme.of(context).textTheme.bodyText1,
          textAlign: TextAlign.center,
        ));
      children.add(GestureDetector(
        onTap: () => setState(
            () => _selectedSbj = orario[i] == _selectedSbj ? null : orario[i]),
        child: Container(
          color: orariUtils.colors[orario[i]]?.withOpacity(
                  _selectedSbj == null || _selectedSbj == orario[i]
                      ? 1
                      : 0.1) ??
              Colors.transparent,
          child: Center(
            child: AutoSizeText(
              orario[i],
              style: TextStyle(
                  color: _selectedSbj == null || _selectedSbj == orario[i]
                      ? Colors.black54
                      : Colors.white10),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ));
    }

    return children;
  }

  GridView _selectionChildren(BuildContext context) {
    TextStyle titleStyle = TextStyle(color: Colors.white54, fontSize: 16);
    List<Widget> children = [
      Text(
        'I',
        style: titleStyle,
        textAlign: TextAlign.center,
      ),
      Text(
        'II',
        style: titleStyle,
        textAlign: TextAlign.center,
      ),
      Text(
        'III',
        style: titleStyle,
        textAlign: TextAlign.center,
      ),
      Text(
        'IV',
        style: titleStyle,
        textAlign: TextAlign.center,
      ),
      Text(
        'V',
        style: titleStyle,
        textAlign: TextAlign.center,
      )
    ];
    String sezioni = 'ABCDEFGHILMNOPQRSTUVZ';
    for (int sezione = 0; sezione < sezioni.length; sezione++) {
      bool hasMore = false;
      for (int anno = 1; anno <= 5; anno++) {
        if (orariUtils.orari.containsKey('$anno${sezioni[sezione]}')) {
          children.add(GestureDetector(
            onTap: () =>
                setState(() => _selectedClass = '$anno${sezioni[sezione]}'),
            child: AnimatedContainer(
              duration: Duration(seconds: 1),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(20)),
                color: '$anno${sezioni[sezione]}' == _selectedClass
                  ? Colors.white
                  : Colors.transparent,
              ),
              child: Center(
                child: Text(
                  sezioni[sezione],
                  style: TextStyle(
                      color: '$anno${sezioni[sezione]}' == _selectedClass
                          ? Colors.black
                          : Colors.white,
                      fontSize: 16),
                ),
              ),
            ),
          ));
          hasMore = true;
        } else children.add(Container());
      }
      if (!hasMore) break;
    }

    return GridView.count(
      physics: NeverScrollableScrollPhysics(),
      crossAxisCount: 5,
      childAspectRatio: 2,
      children: children,
      shrinkWrap: true,
    );
  }
}

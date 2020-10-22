import 'package:Messedaglia/main.dart' as main;
import 'package:Messedaglia/preferences/globals.dart';
import 'package:Messedaglia/registro/absences_registro_data.dart';
import 'package:Messedaglia/registro/note_registro_data.dart';
import 'package:Messedaglia/registro/voti_registro_data.dart';
import 'package:Messedaglia/screens/absences_screen.dart';
import 'package:Messedaglia/screens/bacheca_screen.dart';
import 'package:Messedaglia/screens/didattica_screen.dart';
import 'package:Messedaglia/screens/note_screen.dart';
import 'package:Messedaglia/screens/voti_screen.dart';
import 'package:Messedaglia/widgets/nav_bar_sotto.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:sliding_sheet/sliding_sheet.dart';

import 'agenda_screen.dart';
import 'area_studenti_screen.dart';
import 'home_screen1.dart';
import 'orari_screen.dart';

class Menu extends StatefulWidget {
  static String id = "menu_screen";
  @override
  MenuState createState() => MenuState();
}

SheetController sheetController;
SheetState _state;

class MenuState extends State<Menu> with WidgetsBindingObserver {
  List<Widget> screens = [Orari(), Agenda(), Home(), Voti(), AreaStudenti()];

  bool sheetExtended = false;

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    sheetController = SheetController();

    super.initState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    main.session.save();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SlidingSheet(
        controller: sheetController,

        body: Builder(
            builder: (context) => Container(
                  child: screens[active],
                  margin: EdgeInsets.only(bottom: 100.0),
                )),
        elevation: 10,
        cornerRadius: 20,
        duration: Duration(milliseconds: 900),

        //color: Colors.black,
        snapSpec: SnapSpec(
          positioning: SnapPositioning.relativeToAvailableSpace,
          snappings: [SnapSpec.footerSnap, 1], //[SnapSpec.footerSnap, 0.5],
          snap: true,
          initialSnap: SnapSpec.expanded,
        ),
        listener: (state) {
          if (sheetExtended != state.isExpanded)
            setState(() {
              sheetExtended = state.isExpanded;
            });
        },
        cornerRadiusOnFullscreen: 0,
        footerBuilder: (context, state) {
          return Padding(
            padding: const EdgeInsets.only(
                bottom:
                    15.0), //FIXME non mi piace che is veda l'animated container perche occupa troppo spazio nello schermo però senza non si capisce in quale schermata si è
            child: NavBarSotto(
              (pos) async {
                if (pos == 2) {
                  sheetController.snapToExtent(state.maxExtent,
                      duration: Duration(milliseconds: 200));
                } else
                  await sheetController.snapToExtent(state.minExtent,
                      duration: Duration(milliseconds: 200));
                setState(() => active = pos);
              },
            ),
          );
        },
        isBackdropInteractable: true,
        addTopViewPaddingOnFullscreen: true,
        headerBuilder: (context, state) => Container(
          width: 30,
          height: 5,
          margin: EdgeInsets.all(5),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(2.5), color: Colors.grey),
        ),
        builder: (context, state) {
          _state = state;
          //FIXME: choose svg images
          return SizedBox(
            height: MediaQuery.of(context).size.height * 0.3,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20.0, vertical: 5.0),
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: <Widget>[
                        Stack(
                          alignment: Alignment.topRight,
                          children: <Widget>[
                            GestureDetector(
                              onTap: () {
                                _push(3);
                                setState(() {});
                              },
                              child: Transform.scale(
                                scale: 1.2,
                                child: SvgPicture.asset(
                                    'icons/grade4.svg'), // 1 & 3 NO dire 4 ma ce anche il 2
                              ),
                            ),
                            main.session.voti.newVotiTot > 0
                                ? Icon(
                                    Icons.brightness_1,
                                    color: Colors.yellow,
                                    size: 12,
                                  )
                                : Offstage(),
                          ],
                        ),
                        Stack(
                          alignment: Alignment.topRight,
                          children: <Widget>[
                            GestureDetector(
                              onTap: () => _push(1),
                              child: Transform.scale(
                                  scale: 1.2,
                                  child:
                                      SvgPicture.asset('icons/calendar.svg')),
                            ),
                            main.session.agenda.data
                                        .where((e) =>
                                            e.isNew == true &&
                                            e.inizio.isAfter(DateTime.now()) ==
                                                true)
                                        .length >
                                    0
                                ? Icon(
                                    Icons.brightness_1,
                                    color: Colors.yellow,
                                    size: 12,
                                  )
                                : Offstage(),
                          ],
                        ),
                        Stack(
                          //TODO implement newFiles
                          alignment: Alignment.topRight,
                          children: <Widget>[
                            GestureDetector(
                              onTap: () => Navigator.pushNamed(
                                  context, DidatticaScreen.id),
                              child: SvgPicture.asset('icons/file.svg'),
                            ),
                            Icon(
                              Icons.brightness_1,
                              color: Colors.yellow,
                              size: 12,
                            ),
                          ],
                        ),
                        Stack(
                          alignment: Alignment.topRight,
                          children: <Widget>[
                            GestureDetector(
                              onTap: () => Navigator.pushNamed(
                                  context, BachecaScreen.id),
                              child: SvgPicture.asset('icons/inbox.svg'),
                            ),
                            main.session.bacheca.newComunicazioni > 0
                                ? Icon(
                                    Icons.brightness_1,
                                    color: Colors.yellow,
                                    size: 12,
                                  )
                                : Offstage(),
                          ],
                        ),
                        Stack(
                          alignment: Alignment.topRight,
                          children: <Widget>[
                            GestureDetector(
                              onTap: () =>
                                  Navigator.pushNamed(context, NoteScreen.id),
                              child: SvgPicture.asset('icons/sad1.svg'),
                            ),
                            main.session.note.newNote > 0
                                ? Icon(
                                    Icons.brightness_1,
                                    color: Colors.yellow,
                                    size: 12,
                                  )
                                : Offstage(),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Divider(
                    color: Colors.black,
                    height: 3,
                    thickness: 2,
                    indent: 25,
                    endIndent: 25,
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width,
                    child: HomeScreenWidgets(),
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

void _push(int position) {
  sheetController.snapToExtent(_state.minExtent,
      duration: Duration(milliseconds: 200));
  active = position;
}

class HomeScreenWidgets extends StatefulWidget {
  @override
  _HomeScreenWidgetsState createState() => _HomeScreenWidgetsState();
}

class _HomeScreenWidgetsState extends State<HomeScreenWidgets> {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Flexible(
          flex: 1,
          child: Container(
            alignment: Alignment.topCenter,
            width: MediaQuery.of(context).size.width / 2,
            // color: Colors.red,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: (_noteWidget(context))
                  .followedBy(_assenzeWidget(setState(() {}), context))
                  .toList(),
            ),
          ),
        ),
        Flexible(
          flex: 1,
          child: Container(
            width: MediaQuery.of(context).size.width / 2,
            child: Column(
              children: _votiWidget(setState(() {}), context),
            ),
          ),
        ),
      ],
    );
  }
}

_noteWidget(BuildContext context) {
  List<Widget> note = List();

  main.session.note.data.where((n) => n.isNew == true).forEach((nota) {
    note.add(
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40.0),
        child: SizedBox(
          height: 80 + 20.0,
          child: Column(
            children: <Widget>[
              SizedBox(
                height: 10.0,
              ),
              Expanded(
                child: Material(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Color(0xFF33333D)
                      : Color(0xFFD2D1D7),
                  borderRadius: BorderRadius.circular(10.0),
                  elevation: 10.0, //TODO: elelvation or not?
                  child: ListTile(
                    onTap: () {
                      Navigator.of(context).pushNamed(NoteScreen.id);
                    },
                    title: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        Icon(
                          Globals.iconeNote[nota.tipologia],
                          color: Globals.coloriNote[nota.tipologia],
                          size: 30,
                        ),
                        AutoSizeText(
                          nota?.date != null
                              ? Nota.getDateWithSlashes(nota?.date)
                              : Nota.getDateWithSlashesShort(nota?.inizio) +
                                  ' - ' +
                                  Nota.getDateWithSlashesShort(nota?.fine),
                          maxLines: 1,
                          minFontSize: 11,
                          maxFontSize: 15,
                          style: TextStyle(
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  });
  return note.reversed.toList();
}

_assenzeWidget(void _fn, BuildContext context) {
  List<Widget> assenze = List();

  main.session.absences.data.values
      .where((a) => a.justified == false)
      .forEach((assenza) {
    assenze.add(
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10.0),
        child: SizedBox(
          height: 80.0,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              SizedBox(
                height: 10.0,
              ),
              Expanded(
                child: Material(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Color(0xFF33333D)
                      : Color(0xFFD2D1D7),
                  borderRadius: BorderRadius.circular(10.0),
                  elevation: 10.0, //TODO: elelvation or not?
                  child: ListTile(
                    onTap: () {
                      Navigator.of(context).pushNamed(AbsencesScreen.id);
                    },
                    dense: true,
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        Container(
                          margin: EdgeInsets.only(
                            right: 10,
                            bottom: 10,
                          ),
                          width: 35.0,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: Globals.coloriAssenze[assenza.type],
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Globals.iconeAssenze[assenza.justification],
                            color: Colors.black,
                            size: 20,
                          ),
                        ),
                        AutoSizeText(
                          Assenza.getDateWithSlashes(assenza.date),
                          maxLines: 1,
                          maxFontSize: 13,
                          minFontSize: 8,
                          style: TextStyle(
                            fontSize: 15.0,
                            color: Colors.white70,
                            fontFamily: 'CoreSans',
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  });
  return assenze.reversed.toList();
}

_votiWidget(void _fn, BuildContext context) {
  List<Widget> voti = List();

  main.session.voti.data.where((voto) => voto.isNew == true).forEach((voto) {
    voti.add(
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: SizedBox(
          height: 50 + 10.0,
          child: Column(
            children: <Widget>[
              SizedBox(
                height: 10.0,
              ),
              Material(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Color(0xFF33333D)
                    : Color(0xFFD2D1D7),
                borderRadius: BorderRadius.circular(10.0),
                elevation: 10.0, //TODO: elelvation or not?
                child: ListTile(
                  onTap: () {
                    _push(3);
                    _fn;
                  },
                  dense: true,
                  leading: Container(
                    margin: EdgeInsets.only(left: 10),
                    width: 30.0,
                    alignment: Alignment.center,
                    decoration: new BoxDecoration(
                      color: Voto.getColor(
                          voto.voto), //TODO: colore dinamico a seconda del voto
                      shape: BoxShape.circle,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                      child: AutoSizeText(
                        voto.votoStr,
                        maxLines: 1,
                        maxFontSize: 15,
                        style: TextStyle(
                          fontFamily: 'CoresansRounded',
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 20,
                        ),
                      ),
                    ),
                  ),
                  title: AutoSizeText.rich(
                    TextSpan(
                      text: voto.sbj + '\n',
                      style: TextStyle(fontSize: 13, color: Colors.white70),
                      children: <TextSpan>[
                        TextSpan(
                          text: voto.dateWithSlashes,
                          style: TextStyle(fontSize: 10),
                        ),
                      ],
                    ),
                    maxLines: 3,
                    maxFontSize: 15,
                    minFontSize: 8,
                    style: TextStyle(
                      fontFamily: 'CoresansRounded',
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 10,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  });
  return voti.reversed.toList();
}

class BackgroundPainter extends CustomPainter {
  final ThemeData _theme;
  final Paint p = Paint();
  final Path path = Path();

  BackgroundPainter(this._theme);

  @override
  void paint(Canvas canvas, Size size) {
    double k = size.width / 100;

    path.reset();
    path.lineTo(0, size.height - 16);
    path.quadraticBezierTo(
        k * 10, size.height - k * 5, k * 21, size.height - k * 3);
    path.quadraticBezierTo(
        k * 36, size.height + k * 0.6, k * 47, size.height - k * 3);
    path.quadraticBezierTo(
        k * 56, size.height - k * 6, k * 63, size.height - k * 12);
    path.quadraticBezierTo(
        k * 81, size.height - k * 27, k * 100, size.height - k * 0.7);
    path.lineTo(size.width, 0);
    path.close();
    p.color = _theme.primaryColor;
    canvas.drawPath(path, p);

    path.reset();
    path.lineTo(0, size.height - 1.5);
    path.quadraticBezierTo(
        k * 19, size.height - k * 23, k * 31, size.height - k * 8);
    path.quadraticBezierTo(
        k * 39, size.height + k * 1, k * 52, size.height - k * 11);
    path.quadraticBezierTo(
        k * 84, size.height - k * 45, k * 100, size.height - k * 8);
    path.lineTo(size.width, 0);
    path.close();
    p.color = _theme.accentColor;
    canvas.drawPath(path, p);

    path.reset();
    path.lineTo(0, size.height - 12);
    path.quadraticBezierTo(
        k * 13, size.height - k * 23, k * 21, size.height - k * 10);
    path.quadraticBezierTo(
        k * 25, size.height - k * 4, k * 34, size.height - k * 10);
    path.quadraticBezierTo(
        k * 41, size.height - k * 14, k * 63, size.height - k * 9);
    path.quadraticBezierTo(
        k * 82, size.height - k * 5, k * 100, size.height - k * 5);
    path.lineTo(size.width, 0);
    path.close();
    p.color = _theme.brightness == Brightness.light
        ? Color(0xFFBDBDBD)
        : Colors.grey[800];
    canvas.drawPath(path, p);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return oldDelegate != this;
  }
}

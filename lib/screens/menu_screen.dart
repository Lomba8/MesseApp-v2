import 'dart:async';

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
import 'package:intl/intl.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:path/path.dart';
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
  bool _first = false;

  @override
  void initState() {
    super.initState();
    Timer.periodic(Duration(seconds: 3), (Timer t) {
      _first = !_first;
      setState(() {});
    });
  }

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
              children: _votiWidget(setState(() {}), context)
                  .followedBy(_eventiWidget(setState(() {}), context, _first))
                  .toList(),
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
          height: 100 + 20.0,
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
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          Nota.getTipo(nota.tipologia),
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                          ),
                        ), // Icon(

                        Container(
                          padding: EdgeInsets.all(7),
                          width: 40.0,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: Globals.coloriNote[nota.tipologia],
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Globals.subjects[main.session.subjects
                                    .data[nota.autore][0]]['icona'] ??
                                MdiIcons.sleep,
                            color: Colors.black,
                            size: 17,
                          ),
                        ),

                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 5.0),
                          child: AutoSizeText(
                            nota?.date != null
                                ? Nota.getDateWithSlashes(nota?.date)
                                : Nota.getDateWithSlashesShort(nota?.inizio) +
                                    ' - ' +
                                    Nota.getDateWithSlashesShort(nota?.fine),
                            maxLines: 1,
                            minFontSize: 11,
                            maxFontSize: 13,
                            style: TextStyle(
                              color: Colors.white70,
                            ),
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
      GestureDetector(
        onTap: () {
          Navigator.pushNamed(context, AbsencesScreen.id);
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15.0),
          child: SizedBox(
            height: 65.0,
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
                        mainAxisAlignment:
                            Assenza.getTipo(assenza.type).split(' ').length == 1
                                ? MainAxisAlignment.spaceEvenly
                                : MainAxisAlignment.spaceAround,
                        children: <Widget>[
                          Container(
                            margin: EdgeInsets.only(
                              right: 10,
                              bottom: 7,
                            ),
                            padding: EdgeInsets.only(
                              left: 1,
                              top: 4,
                            ),
                            width: 30.0,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: Globals.coloriAssenze[assenza.type],
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              Assenza.getTipo(assenza.type)
                                  .split(' ')
                                  .map((e) => e[0].toString())
                                  .join('')
                                  .trim(),
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: Assenza.getTipo(assenza.type)
                                            .split(' ')
                                            .length ==
                                        1
                                    ? 17.0
                                    : 15.0,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'CoreSansRounded',
                              ),
                            ),
                          ),
                          AutoSizeText(
                            assenza.hour == null
                                ? ''
                                : assenza.hour.toString() + 'ᵃ',
                            maxLines: 1,
                            maxFontSize: 13,
                            minFontSize: 8,
                            style: TextStyle(
                              fontSize: 15.0,
                              color: Colors.white,
                              fontFamily: 'CoreSans',
                              fontWeight: FontWeight.w600,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          AutoSizeText(
                            Assenza.getTipo(assenza.type).split(' ').length >
                                        1 ||
                                    assenza.type == 'ABA0'
                                ? Assenza.getDateWithSlashes(assenza.date)
                                : Assenza.getDateWithSlashesShort(assenza.date),
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
      ),
    );
  });
  return assenze.reversed.toList();
}

_eventiWidget(void _fn, BuildContext context, bool _first) {
  List<Widget> eventi = List();

  main.session.agenda.data
      .where((a) => a.isNew == true && a.autore != "Didattica a distanza")
      .forEach((evento) {
    eventi.add(
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
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
                      _push(1);
                      _fn;
                    },
                    dense: true,
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Container(
                          margin: EdgeInsets.only(
                            right: 10,
                            bottom: 10,
                          ),
                          width: 35.0,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: main.session.subjects.data[evento.autore] == null ||
                                    main.session.subjects.data[evento.autore]
                                        is String ||
                                    main.session.subjects.data[evento.autore]?.length ==
                                        1
                                ? ((evento.autore == "Didattica a distanza" ||
                                        evento.account == null)
                                    ? (Theme.of(context).brightness == Brightness.dark
                                        ? Colors.white10
                                        : Colors.black12)
                                    : Globals.subjects[main.session.subjects.data[evento.autore]] != null
                                        ? Globals.subjects[main.session.subjects.data[evento.autore]]['colore']
                                            .withOpacity(0.7)
                                        : Globals.subjects[main.session.subjects.data[evento.autore][0]]['colore']
                                            .withOpacity(0.7))
                                : main.session.subjects.data[evento.autore] is List
                                    ? Globals.subjects[main.session.subjects.data[evento.autore][0]]['colore'].withOpacity(0.7)
                                    : (Theme.of(context).brightness == Brightness.dark ? Colors.white10 : Colors.black12),
                            shape: BoxShape.circle,
                          ),
                          child: main.session.subjects.data[evento.autore]
                                      is String ||
                                  main.session.subjects.data[evento.autore]
                                          .length ==
                                      1 ||
                                  main.session.subjects.data[evento.autore] ==
                                      null
                              ? Icon(
                                  main.session.subjects.data[evento.autore] == null ||
                                          main.session.subjects
                                              .data[evento.autore] is String ||
                                          main.session.subjects.data[evento.autore]?.length ==
                                              1
                                      ? Globals.subjects[main.session.subjects.data[evento.autore]] != null
                                          ? Globals.subjects[main
                                              .session
                                              .subjects
                                              .data[evento.autore]]['icona']
                                          : Globals.subjects[main
                                              .session
                                              .subjects
                                              .data[evento.autore][0]]['icona']
                                      : MdiIcons.help,
                                  color: Colors.black,
                                  size: 20,
                                )
                              : AnimatedCrossFade(
                                  firstChild: Icon(
                                    (Globals.subjects[main.session.subjects
                                                .data[evento.autore][0]]
                                            ['icona']) ??
                                        MdiIcons.help,
                                    color: Colors.black,
                                    size: 20,
                                  ),
                                  secondChild: Icon(
                                    (Globals.subjects[main.session.subjects
                                                .data[evento.autore][1]]
                                            ['icona']) ??
                                        MdiIcons.help,
                                    color: Colors.black,
                                    size: 20,
                                  ),
                                  crossFadeState: _first
                                      ? CrossFadeState.showFirst
                                      : CrossFadeState.showSecond,
                                  duration: Duration(milliseconds: 500),
                                ),
                        ),

                        Container(
                          margin: EdgeInsets.only(bottom: 7),
                          child: Stack(
                              alignment: Alignment(-0.9, 0.0),
                              overflow: Overflow.visible,
                              children: [
                                Icon(
                                  Icons.calendar_today,
                                  size: 40,
                                  color: Colors.green[200],
                                ),
                                // Container(
                                //   margin: EdgeInsets.only(left: 8.0),
                                //   width: 34.0,
                                //   height: 38.0,
                                //   decoration:
                                //       BoxDecoration(color: Colors.white10),
                                //   child: SizedBox(),
                                // ),
                                Padding(
                                  padding: EdgeInsets.only(
                                    left: (evento.date.day < 10) ? 15.5 : 11.5,
                                    top: 12.0,
                                  ),
                                  child: Text(
                                    evento.date.day.toString(),
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              ]),
                        ),

                        // AutoSizeText(
                        //   DateFormat.yMd('it').format(evento.inizio),
                        //   maxLines: 1,
                        //   maxFontSize: 13,
                        //   minFontSize: 8,
                        //   style: TextStyle(
                        //     fontSize: 15.0,
                        //     color: Colors.white70,
                        //     fontFamily: 'CoreSans',
                        //     fontWeight: FontWeight.w600,
                        //   ),
                        //   textAlign: TextAlign.center,
                        // ),
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
  return eventi.reversed.toList();
}

_votiWidget(void _fn, BuildContext context) {
  List<Widget> voti = List();

  main.session.voti.data.where((voto) => voto.isNew == true).forEach((voto) {
    voti.add(
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15.0),
        child: SizedBox(
          height: 70 + 10.0,
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
                  child: Center(
                    child: ListTile(
                      onTap: () {
                        _push(3);
                        _fn;
                      },
                      dense: true,
                      leading: Container(
                        margin: EdgeInsets.only(left: 10),
                        width: 35.0,
                        alignment: Alignment.center,
                        decoration: new BoxDecoration(
                          color: Voto.getColor(voto
                              .voto), //TODO: colore dinamico a seconda del voto
                          shape: BoxShape.circle,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.only(
                            left: 4.0,
                            right: 4.0,
                            top: 2,
                          ),
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
                          text: Globals.getMaterieSHort(voto.sbj) + '\n',
                          style: TextStyle(fontSize: 15, color: Colors.white),
                          children: <TextSpan>[
                            TextSpan(
                              text: '\n' + voto.dateWithSlashesShort,
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                        maxLines: 3,
                        maxFontSize: 15,
                        minFontSize: 8,
                        style: TextStyle(
                          fontFamily: 'CoresansRounded',
                          color: Colors.white70,
                          fontWeight: FontWeight.w600,
                          fontSize: 10,
                        ),
                        textAlign: TextAlign.center,
                      ),
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

import 'package:Messedaglia/main.dart' as main;
import 'package:Messedaglia/registro/voti_registro_data.dart';
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

class MenuState extends State<Menu> with WidgetsBindingObserver {
  List<Widget> screens = [Orari(), Agenda(), Home(), Voti(), AreaStudenti()];

  bool sheetExtended = false;
  SheetController sheetController;

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
          void _push(int position) {
            sheetController.snapToExtent(state.minExtent,
                duration: Duration(milliseconds: 200));
            active = position;
            setState(() {});
          }

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
                              onTap: () => _push(3),
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
                            main.session.agenda
                                        .getEvents(getDayFromDT(DateTime.now())
                                            .add(Duration(days: 1)))
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
                          //TODO implement new note
                          alignment: Alignment.topRight,
                          children: <Widget>[
                            GestureDetector(
                              onTap: () =>
                                  Navigator.pushNamed(context, NoteScreen.id),
                              child: SvgPicture.asset('icons/sad1.svg'),
                            ),
                            Icon(
                              Icons.brightness_1,
                              color: Colors.yellow,
                              size: 12,
                            ),
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

class HomeScreenWidgets extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: <Widget>[
        Flexible(
          flex: 1,
          child: Column(
            children: <Widget>[
              Container(
                width: MediaQuery.of(context).size.width / 2,
                height: 100,
                color: Colors.red,
              )
            ],
          ),
        ),
        Flexible(
          flex: 1,
          child: Column(
            children: _votiWidget().toList(),
          ),
        ),
      ],
    );
  }
}

_votiWidget() {
  List<Widget> voti = new List();

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
                color: Voto.getColor(voto.voto).withOpacity(0.5),
                borderRadius: BorderRadius.circular(10.0),
                // elevation: 10.0,  //TODO: elelvation or not?
                child: ListTile(
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
                      style: TextStyle(fontSize: 13, color: Colors.black87),
                      children: <TextSpan>[
                        TextSpan(
                          text: voto.dataWithSlashes,
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

                  // AutoSizeText(
                  //   voto.sbj + '\n' + voto.dataWithSlashes,
                  //   maxLines: 2,
                  //   maxFontSize: 15,
                  //   minFontSize: 8,
                  //   textAlign: TextAlign.center,
                  //   style: TextStyle(
                  //     fontFamily: 'CoresansRounded',
                  //     color: Colors.black,
                  //     fontWeight: FontWeight.w600,
                  //   ),
                  // ),
                  // trailing: SizedBox(
                  //   width: 35,
                  //   child: AutoSizeText(
                  //     voto.dataWithSlashes, //FIXME manca parte della data
                  //     maxLines: 1,
                  //     minFontSize: 8,
                  //     maxFontSize: 15,
                  //     textAlign: TextAlign.center,
                  //     style: TextStyle(
                  //       fontFamily: 'CoresansRounded',
                  //       color: Colors.black,
                  //       fontWeight: FontWeight.w600,
                  //       fontSize: 15,
                  //     ),
                  //   ),
                  // ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  });
  return voti;
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

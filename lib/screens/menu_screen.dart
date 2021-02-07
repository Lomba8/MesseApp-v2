import 'package:Messedaglia/main.dart' as main;
import 'package:Messedaglia/screens/screens.dart';
import 'package:Messedaglia/widgets/note_widget.dart';
import 'package:Messedaglia/widgets/nav_bar_sotto.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:sliding_sheet/sliding_sheet.dart';
import 'package:Messedaglia/widgets/menu_screen_widgets.dart';

import 'agenda_screen.dart';
import 'area_studenti_screen.dart';
import 'home_screen1.dart';

class Menu extends StatefulWidget {
  static String id = "menu_screen";
  @override
  MenuState createState() => MenuState();
}

final SheetController sheetController = SheetController();
SheetState _state;

class MenuState extends State<Menu> with WidgetsBindingObserver {
  List<Widget> screens = [Orari(), Agenda(), Home(), Voti(), AreaStudenti()];

  bool sheetExtended = false;

  void _setStateIfAlive() {
    if (mounted) setState(() {});
  }

  String _passedTime() {
    List sections = [
      main.session.voti,
      main.session.agenda,
      main.session.subjects,
      main.session.bacheca,
      main.session.note,
      main.session.lessons,
      main.session.absences,
      main.session.didactics
    ];

    List lastUpdates = sections.map((element) => element.lastUpdate).toList();
    if (lastUpdates.every((element) => element == null))
      return 'mai aggiornato';
    lastUpdates.sort();
    Duration difference = DateTime.now().difference(lastUpdates.first);
    if (difference.inMinutes < 1) {
      Future.delayed(Duration(seconds: 15), _setStateIfAlive);
      return 'adesso';
    }
    if (difference.inHours < 1) {
      Future.delayed(Duration(minutes: 1), _setStateIfAlive);
      int mins = difference.inMinutes;
      return '$mins minut${mins == 1 ? 'o' : 'i'} fa';
    }
    if (difference.inDays < 1) {
      Future.delayed(Duration(hours: 1), _setStateIfAlive);
      int hours = difference.inHours;
      return '$hours or${hours == 1 ? 'a' : 'e'} fa';
    }
    return 'più di un giorno fa';
  }

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
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
          ),
        ),
        elevation: 10,
        cornerRadius: 20,
        duration: Duration(milliseconds: 900),

        //color: Colors.black,
        snapSpec: SnapSpec(
          positioning: SnapPositioning.relativeToAvailableSpace,
          snappings: [
            SnapSpec.footerSnap,
            SnapSpec.expanded
          ], //[SnapSpec.footerSnap, 0.5],
          snap: true,
          initialSnap: main.session.voti.newVotiTot > 0 ||
                  main.session.note.newNote > 0 ||
                  main.session.agenda.newEventi > 0 ||
                  main.session.absences.newAssenze > 0
              ? SnapSpec.expanded
              : SnapSpec.footerSnap,
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
            padding: const EdgeInsets.only(bottom: 15.0),
            child: NavBarSotto(
              (pos) async {
                if (pos == 2) {
                  sheetController.snapToExtent(
                      state.extent == state.maxExtent
                          ? state.minExtent
                          : state.maxExtent,
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
          //CHOOSE: choose svg images
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
                                push(3);
                                setState(() {});
                              },
                              child: Transform.scale(
                                scale: 1.2,
                                child: SvgPicture.asset(
                                  'icons/grade4.svg',
                                  color: Colors.white,
                                ), // 1 & 3 NO dire 4 ma ce anche il 2
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
                              onTap: () => push(1),
                              child: Transform.scale(
                                scale: 1.2,
                                child: SvgPicture.asset(
                                  'icons/calendar.svg',
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            main.session.agenda.newEventi > 0
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
                              onTap: () => Navigator.pushNamed(
                                  context, DidatticaScreen.id),
                              child: SvgPicture.asset(
                                'icons/file.svg',
                                color: Colors.white,
                              ),
                            ),
                            main.session.didactics.data is Map &&
                                    main.session.didactics.data.length == 0
                                ? Offstage()
                                : main.session.didactics.data.children.values
                                        .any((customDir) =>
                                            customDir.changed == true)
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
                              onTap: () => Navigator.pushNamed(
                                  context, BachecaScreen.id),
                              child: SvgPicture.asset(
                                'icons/inbox.svg',
                                color: Colors.white,
                              ),
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
                              child: SvgPicture.asset(
                                'icons/sad1.svg',
                                color: Colors.white,
                              ),
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
                    color: Colors.white,
                    height: 3,
                    thickness: 2,
                    indent: 25,
                    endIndent: 25,
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  AutoSizeText(
                    'Ultimo aggiornamento: ' + _passedTime(),
                    textAlign: TextAlign.center,
                    minFontSize: 8,
                    maxFontSize: 14,
                    maxLines: 1,
                    style: TextStyle(
                      color: Colors.white70,
                      fontFamily: 'CoreSans',
                    ),
                  ),
                  HomeScreenWidgets(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class HomeScreenWidgets extends StatefulWidget {
  @override
  _HomeScreenWidgetsState createState() => _HomeScreenWidgetsState();
}

class _HomeScreenWidgetsState extends State<HomeScreenWidgets> {
  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Flexible(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              NoteWidget(),
              AssenzeWidget(),
            ],
          ),
        ),
        Flexible(
          child: Column(
            children: [
              VotiWIdget(),
              EventiWidget(),
            ],
          ),
        ),
      ],
    );
  }
}

Function push = (int position) {
  sheetController.snapToExtent(_state.minExtent,
      duration: Duration(milliseconds: 200));
  active = position;
};

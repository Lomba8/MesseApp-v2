import 'package:Messedaglia/main.dart' as main;
import 'package:Messedaglia/preferences/globals.dart';
import 'package:Messedaglia/screens/menu_screen.dart' as menu;
import 'package:Messedaglia/widgets/calendar_month_icons.dart';
import 'package:flutter/material.dart';
import 'package:Messedaglia/screens/screens.dart';
import 'package:intl/intl.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

Function eventiWidget = (BuildContext context, bool _first) {
  List<Widget> eventi = List();

  main.session.agenda.data
      .where((a) => a.isNew == true && a.autore != "Didattica a distanza")
      .forEach((evento) {
    eventi.add(
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30.0),
        child: SizedBox(
          height: 100.0,
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
                  elevation: 10.0,
                  child: ListTile(
                    onTap: () {
                      giornoSelezionato = evento.date;
                      main.session.agenda.data.forEach((e) async =>
                          e.date.isAtSameMomentAs(evento.date)
                              ? await e.seen()
                              : null);
                      menu.push(1);
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
                            top: 3,
                          ),
                          width: 40.0,
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
                                  size: 25,
                                )
                              : AnimatedCrossFade(
                                  firstChild: Icon(
                                    (Globals.subjects[main.session.subjects
                                                .data[evento.autore][0]]
                                            ['icona']) ??
                                        MdiIcons.help,
                                    color: Colors.black,
                                    size: 25,
                                  ),
                                  secondChild: Icon(
                                    (Globals.subjects[main.session.subjects
                                                .data[evento.autore][1]]
                                            ['icona']) ??
                                        MdiIcons.help,
                                    color: Colors.black,
                                    size: 25,
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
                                  CalendarMonth.calendar_blank,
                                  size: 55,
                                  color: Colors.green[200],
                                ),
                                Container(
                                  margin: EdgeInsets.only(left: 10.0, top: 3),
                                  width: 34.0,
                                  height: 38.0,
                                  decoration:
                                      BoxDecoration(color: Colors.white10),
                                  child: Offstage(),
                                ),
                                Positioned(
                                  left: 16,
                                  top: 12,
                                  child: Text(
                                    DateFormat.MMMM('it')
                                        .format(evento.date)
                                        .split('')
                                        .toList()
                                        .sublist(0, 3)
                                        .join('')
                                        .toString()
                                        .toUpperCase(),
                                    style: TextStyle(
                                      fontSize: 11.5,
                                      color: Colors.black,
                                      fontFamily: 'CoreSansRounded',
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.only(
                                    left: (evento.date.day < 10) ? 23 : 18,
                                    top: 18.0,
                                  ),
                                  child: Text(
                                    evento.date.day.toString(),
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ]),
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
  return eventi;
};

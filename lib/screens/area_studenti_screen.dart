import 'package:applicazione_prova/registro/agenda_registro_data.dart';
import 'package:applicazione_prova/registro/registro.dart';
import 'package:applicazione_prova/screens/map_screen.dart';
import 'package:applicazione_prova/screens/menu_screen.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_calendar_carousel/classes/event_list.dart';
import 'package:flutter_calendar_carousel/flutter_calendar_carousel.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';

import 'package:flutter/cupertino.dart';

import '../registro/agenda_registro_data.dart';
import '../registro/registro.dart';

class AreaStudenti extends StatefulWidget {
  static final String id = 'area_studenti_screen';
  @override
  _AreaStudentiState createState() => _AreaStudentiState();
}

class _AreaStudentiState extends State<AreaStudenti> {
  String _passedTime() {
    if (RegistroApi.agenda.lastUpdate == null) return 'mai aggiornato';
    Duration difference =
        DateTime.now().difference(RegistroApi.agenda.lastUpdate);
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

  void _setStateIfAlive() {
    if (mounted) setState(() {});
  }

  Future<void> _refresh() async {
    RegistroApi.agenda.getData().then((r) {
      if (r.ok) _setStateIfAlive();
    });
    return null;
  }

  DateTime _currentDate, _currentMonth = DateTime.now();

  EventList<Evento> get e => RegistroApi.agenda.data;

  List<Evento> dayEvents = List<Evento>();

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return LiquidPullToRefresh(
      onRefresh: _refresh,
      showChildOpacityTransition: false, // refresh callback

      child: CustomScrollView(
        scrollDirection: Axis.vertical,
        slivers: <Widget>[
          SliverList(
            delegate: SliverChildListDelegate(
              [
                CustomPaint(
                  painter: BackgroundPainter(Theme.of(context)),
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 50),
                    child: Padding(
                      padding: EdgeInsets.only(
                          bottom: size.height / 100, top: size.height / 18),
                      child: Column(
                        children: <Widget>[
                          Text(
                            "Agenda",
                            textAlign: TextAlign
                                .center, //FIXME: _calendarController si inizializza solo dopo un secondo come fare ad aspettare la sua inizalizzazione?
                            style: TextStyle(
                                color: Theme.of(context).brightness ==
                                        Brightness.light
                                    ? Colors.black
                                    : Colors.white,
                                fontSize: 30,
                                fontWeight: FontWeight.bold),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 15.0),
                            child: SizedBox(
                              width: size.width,
                              child: Text(
                                '\n${_passedTime()}',
                                textAlign: TextAlign
                                    .right, //FIXME: _calendarController si inizializza solo dopo un secondo come fare ad aspettare la sua inizalizzazione?
                                style: TextStyle(
                                    color: Theme.of(context).brightness ==
                                            Brightness.light
                                        ? Colors.black
                                        : Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold),
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
          SliverGrid.count(
            crossAxisCount: 4,
            children: <Widget>[
              GestureDetector(
                onTap: () => Navigator.push(
                    context, MaterialPageRoute(builder: (c) => MapScreen())),
                child: Card(
                  color: Colors.transparent,
                  child: Container(
                    height: 500,
                    width: 400,
                    decoration: BoxDecoration(
                      color: Color.fromRGBO(62, 123, 150, 0.5),
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    child: Column(
                      children: <Widget>[
                        SizedBox(height: 10),
                        SizedBox(
                            child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Color.fromRGBO(109, 158, 218, 1.0),
                          ),
                          child: Icon(Icons.map),
                        )),
                        SizedBox(height: 10),
                        SizedBox(
                          height: 10,
                          child: AutoSizeText(
                            'Autogestione',
                            maxLines: 1,
                            maxFontSize: 12.0,
                            minFontSize: 7.0,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Color.fromRGBO(109, 158, 218, 1.0),
                            ),
                          ),
                        ),
                        SizedBox(height: 10),
                      ],
                    ),
                  ),
                ),
              ),
              GestureDetector(
                onTap: () => Navigator.push(
                    context, MaterialPageRoute(builder: (c) => MapScreen())),
                child: Card(
                  color: Colors.transparent,
                  child: Container(
                    height: 500,
                    width: 400,
                    decoration: BoxDecoration(
                      color: Color.fromRGBO(105, 181, 201, 0.5),
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    child: Column(
                      children: <Widget>[
                        SizedBox(height: 10),
                        SizedBox(
                            child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Color.fromRGBO(109, 158, 218, 1.0),
                          ),
                          child: Icon(Icons.map),
                        )),
                        SizedBox(height: 10),
                        SizedBox(
                          height: 10,
                          child: AutoSizeText(
                            'Autogestione',
                            maxLines: 1,
                            maxFontSize: 12.0,
                            minFontSize: 7.0,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Color.fromRGBO(109, 158, 218, 1.0),
                            ),
                          ),
                        ),
                        SizedBox(height: 10),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}

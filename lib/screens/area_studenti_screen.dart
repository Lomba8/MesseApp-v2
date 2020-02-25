import 'package:Messedaglia/preferences/globals.dart';
import 'package:Messedaglia/registro/agenda_registro_data.dart';
import 'package:Messedaglia/registro/registro.dart';
import 'package:Messedaglia/screens/map_screen.dart';
import 'package:Messedaglia/screens/menu_screen.dart';
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
    return LiquidPullToRefresh(
      onRefresh: _refresh,
      showChildOpacityTransition: false, // refresh callback
      child: CustomScrollView(
        scrollDirection: Axis.vertical,
        slivers: <Widget>[
          SliverAppBar(
            elevation: 0,
            backgroundColor: Colors.transparent,
            title: Text(
              "Area Studenti",
              textAlign: TextAlign
                  .center, //FIXME: _calendarController si inizializza solo dopo un secondo come fare ad aspettare la sua inizalizzazione?
              style: TextStyle(
                  color: Theme.of(context).brightness == Brightness.light
                      ? Colors.black
                      : Colors.white,
                  fontSize: 30,
                  fontWeight: FontWeight.bold),
            ),
            bottom: PreferredSize(child: Container(), preferredSize: Size.fromHeight(MediaQuery.of(context).size.width/8)),
            pinned: true,
            centerTitle: true,
            flexibleSpace: CustomPaint(
              painter: BackgroundPainter(Theme.of(context)),
              size: Size.infinite,
            ),
          ),
          SliverGrid.count(
            crossAxisCount: 2,
            children: <Widget>[
              Section(
                sezione: 'Autogestione', // mappa Globals.icone[sezione]
                colore: 'verde', // mappa Globals.sezioni[colore]
                page: MapScreen(),
              ),
              Section(
                sezione: 'Alternanza',
                colore: 'blu',
                page: MapScreen(),
              ),
              Section(
                sezione: 'Bacheca',
                colore: 'arancione',
                page: MapScreen(),
              ),
              Section(
                sezione: 'Note',
                colore: 'rosa',
                page: MapScreen(),
              ),
              Section(
                sezione: 'App Panini',
                colore: 'viola',
                page: MapScreen(),
              ),
              Section(
                sezione: 'Tutoraggi',
                colore: 'rosso',
                page: MapScreen(),
              ),
            ],
          )
        ],
      ),
    );
  }
}

class Section extends StatelessWidget {
  final String colore, sezione;
  final dynamic page;

  const Section({
    Key key,
    @required this.colore,
    @required this.sezione,
    @required this.page,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(10.0),
      child: GestureDetector(
        onTap: () =>
            Navigator.push(context, MaterialPageRoute(builder: (c) => page)),
        child: Card(
          color: Colors.white10,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Container(
                width: 65,
                height: 65,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Globals.sezioni[colore]['color'],
                  gradient: RadialGradient(
                    colors: Globals.sezioni[colore]['gradientColors'],
                    center: Alignment(1.0, 1.0),
                    radius: 1,
                    focal: Alignment(1.0, 1.0),
                  ),
                ),
                child: Globals.icone[sezione], //icona
              ),
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: AutoSizeText(
                  sezione,
                  maxLines: 1,
                  maxFontSize: 14.0,
                  minFontSize: 9.0,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    letterSpacing: 1.5,
                    color: Globals.sezioni[colore]['textColor'],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

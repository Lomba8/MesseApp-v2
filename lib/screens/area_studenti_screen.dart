import 'package:Messedaglia/preferences/globals.dart';
import 'package:Messedaglia/registro/agenda_registro_data.dart';
import 'package:Messedaglia/registro/registro.dart';
import 'package:Messedaglia/screens/bacheca_screen.dart';
import 'package:Messedaglia/screens/map_screen.dart';
import 'package:Messedaglia/screens/menu_screen.dart';
import 'package:Messedaglia/screens/tutoraggi_screen.dart';
import 'package:Messedaglia/screens/tutoraggi_screen_scrape.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_calendar_carousel/classes/event_list.dart';
import 'package:flutter_calendar_carousel/flutter_calendar_carousel.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';

import 'package:flutter/cupertino.dart';
import 'package:url_launcher/url_launcher.dart';

import '../registro/agenda_registro_data.dart';
import '../registro/registro.dart';

class AreaStudenti extends StatefulWidget {
  static final String id = 'area_studenti_screen';

  @override
  _AreaStudentiState createState() => _AreaStudentiState();
}

class _AreaStudentiState extends State<AreaStudenti> {
  /*String _passedTime() {
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
  }*/

  void _setStateIfAlive() {
    if (mounted) setState(() {});
  }

  Future<void> _refresh() async {
    RegistroApi.agenda.getData().then((r) {
      if (r.ok) _setStateIfAlive();
    });
    return null;
  }

  _listaPanini() async {
    const url = 'https://pagni.altervista.org/istituto/lista.php';
    if (await canLaunch(url)) {
      await launch(url,
          forceSafariVC: true,
          enableJavaScript: true,
          forceWebView: true,
          headers: {'User-Agent': 'MesseApp <3'});
    } else {
      Flushbar(
        padding: EdgeInsets.all(10),
        borderRadius: 20,
        backgroundGradient: LinearGradient(
          colors: Globals.sezioni['viola']['gradientColors'],
          stops: [0.3, 0.6, 1],
        ),
        boxShadows: [
          BoxShadow(
            color: Colors.black45,
            offset: Offset(3, 3),
            blurRadius: 6,
          ),
        ],
        duration: Duration(seconds: 5),
        isDismissible: true,
        icon: Icon(
          Icons.error_outline,
          size: 35,
          color: Theme.of(context).backgroundColor,
        ),
        shouldIconPulse: true,
        animationDuration: Duration(seconds: 1),
        dismissDirection: FlushbarDismissDirection.HORIZONTAL,
        // The default curve is Curves.easeOut
        forwardAnimationCurve: Curves.fastOutSlowIn,
        title: 'Errore nell\'aprire l\'url:',
        message: '$url',
      ).show(context);
    }
  }

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
            brightness: Theme.of(context).brightness,
            elevation: 0,
            backgroundColor: Colors.transparent,
            title: Text(
              "AREA STUDENTI",
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: Theme.of(context).brightness == Brightness.light
                      ? Colors.black
                      : Colors.white,
                  fontSize: 30,
                  fontWeight: FontWeight.bold),
            ),
            bottom: PreferredSize(
                child: Container(),
                preferredSize:
                    Size.fromHeight(MediaQuery.of(context).size.width / 8)),
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
                page: null,
              ),
              Section(
                sezione: 'Bacheca',
                colore: 'arancione',
                page: BachecaScreen(),
              ),
              Section(
                sezione: 'Note',
                colore: 'rosa',
                page: null,//NoteScreen(),
              ),
              Section(
                sezione: 'App Panini',
                colore: 'viola',
                action: _listaPanini,
              ),
              Section(
                sezione: 'Tutoraggi',
                colore: 'rosso',
                page: TutoraggiScreen(),
              ),
              Section(
                // FIXME: pietro quando hai finito tutto quello che devi fare sui tutoraggi io farei le cards ed integrerei il web scraping
                sezione: 'Tutoraggi-scrape',
                colore: 'rosso',
                page: TutoraggiScreenScrape(),
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
  final dynamic action;

  const Section({
    Key key,
    @required this.colore,
    @required this.sezione,
    this.page,
    this.action,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(10.0),
      child: GestureDetector(
        onTap: action == null
            ? page == null
                ? null
                : () => Navigator.push(
                    context, MaterialPageRoute(builder: (c) => page))
            : action,
        child: Card(
          elevation: 0,
          color: Theme.of(context).brightness == Brightness.dark
              ? page == null && action == null ? Colors.white24 : Colors.white10
              : page == null && action == null
                  ? Colors.black26
                  : Colors.black12,
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
                  color: action == null && page == null
                      ? Colors.white54
                      : Globals.sezioni[colore]['color'],
                  gradient: RadialGradient(
                    colors: action == null && page == null
                        ? [Colors.white54, Colors.white30]
                        : Globals.sezioni[colore]['gradientColors'],
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
                    color: action == null && page == null
                        ? Colors.white54
                        : Globals.sezioni[colore]['textColor'],
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

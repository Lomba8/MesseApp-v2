import 'package:Messedaglia/preferences/globals.dart';
import 'package:Messedaglia/widgets/background_painter.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:Messedaglia/screens/screens.dart';
import 'package:Messedaglia/main.dart' as main;

import 'package:flutter/cupertino.dart';

class AreaStudenti extends StatefulWidget {
  static final String id = 'area_studenti_screen';

  @override
  _AreaStudentiState createState() => _AreaStudentiState();
}

class _AreaStudentiState extends State<AreaStudenti> {
  /*String _passedTime() {
    if (session.agenda.lastUpdate == null) return 'mai aggiornato';
    Duration difference =
        DateTime.now().difference(session.agenda.lastUpdate);
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
    main.session.agenda.getData().then((r) {
      if (r.ok) _setStateIfAlive();
    });
    HapticFeedback.mediumImpact();

    return null;
  }

  @override
  void initState() {
    super.initState();
  }

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
            title: Column(
              children: <Widget>[
                Text(
                  "AREA STUDENTI",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: Theme.of(context).brightness == Brightness.light
                          ? Colors.black
                          : Colors.white,
                      fontSize: 30,
                      fontWeight: FontWeight.bold),
                ),
              ],
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
              // Section(
              //   sezione: 'Autogestione', // mappa Globals.icone[sezione]
              //   colore: 'verde', // mappa Globals.sezioni[colore]
              //   page: MapScreen(),
              // ),
              // Section(
              //   sezione: 'Alternanza',
              //   colore: 'blu',
              //   page: null,
              // ),
              Section(
                sezione: 'Bacheca',
                colore: 'blu',
                page: BachecaScreen(),
              ),
              Section(
                sezione: 'Didattica',
                colore: 'rosa',
                page: DidatticaScreen(),
              ),
              Section(
                sezione: 'Note',
                colore: 'arancione',
                page: NoteScreen(),
              ),
              Section(
                sezione: 'Giustificazioni',
                colore: 'rosso',
                page: AbsencesScreen(),
              ),
              Section(
                sezione: 'Lezioni',
                colore: 'verde',
                page: LessonsScreen(),
              ),
              Section(
                sezione: 'Tutoraggi',
                colore: 'viola',
                page: TutoraggiScreen(),
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
                child: Globals.iconeAreaStudenti[sezione], //icona
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

import 'package:Messedaglia/main.dart';
import 'package:Messedaglia/preferences/globals.dart';
import 'package:Messedaglia/registro/lessons_registro_data.dart';
import 'package:Messedaglia/screens/menu_screen.dart';
import 'package:Messedaglia/widgets/expansion_tile.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:marquee/marquee.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class LessonsScreen extends StatefulWidget {
  //TODO implementare il liquidpulltorefresh con HapticFeedback.mediumImpact(); alla fine
  @override
  _LessonsScreenState createState() => _LessonsScreenState();
}

class _LessonsScreenState extends State<LessonsScreen> {
  void _setStateIfAlive() {
    if (mounted) setState(() {});
  }

  Future<void> _refresh() async {
    session.agenda.getData().then((r) {
      if (r.ok) _setStateIfAlive();
    });
    HapticFeedback.mediumImpact();

    return null;
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        body: LiquidPullToRefresh(
          onRefresh: _refresh,
          showChildOpacityTransition: false,
          child: CustomScrollView(
            slivers: <Widget>[
              SliverAppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                brightness: Theme.of(context).brightness,
                title: Text(
                  'LEZIONI',
                  style: TextStyle(
                      color: Theme.of(context).brightness == Brightness.light
                          ? Colors.black
                          : Colors.white,
                      fontSize: 30,
                      fontWeight: FontWeight.bold),
                ),
                centerTitle: true,
                pinned: true,
                flexibleSpace: CustomPaint(
                  painter: BackgroundPainter(Theme.of(context)),
                  size: Size.infinite,
                ),
                bottom: PreferredSize(
                  child: Container(),
                  preferredSize:
                      Size.fromHeight(MediaQuery.of(context).size.width / 8),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(left: 10.0),
                  child: Column(
                    children: session.lessons.data['sbj'].keys
                        .map<Widget>(
                          (sbj) => SizedBox(
                            width: MediaQuery.of(context).size.width,
                            height: 55,
                            child: ListTile(
                              title: AutoSizeText(
                                sbj,
                                overflowReplacement: Marquee(
                                  text: sbj,
                                  blankSpace: 40.0,
                                  style: Theme.of(context).textTheme.bodyText2,
                                  pauseAfterRound: Duration(milliseconds: 800),
                                ),
                                style: Theme.of(context).textTheme.bodyText2,
                                textAlign: TextAlign.center,
                                maxLines: 1,
                                minFontSize: 20.0,
                                maxFontSize: 20.0,
                              ),
                              leading: Container(
                                child: CircleAvatar(
                                  child: Icon(
                                    (Globals.subjects[sbj] ?? {})['icona'] ??
                                        MdiIcons.sleep,
                                    color: Colors.black,
                                  ),
                                  backgroundColor:
                                      (Globals.subjects[sbj] ?? {})['colore']
                                          ?.withOpacity(0.7),
                                ),
                              ),
                              onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          LessonsDetails(sbj))),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ),
              )
            ],
          ),
        ),
      );
}

class LessonsDetails extends StatefulWidget {
  final String _sbj;
  LessonsDetails(this._sbj);
  @override
  _LessonsDetailsState createState() => _LessonsDetailsState();
}

class _LessonsDetailsState extends State<LessonsDetails> {
  Lezione _expanded;
  @override
  Widget build(BuildContext context) => Material(
        color: Theme.of(context).backgroundColor,
        child: CustomScrollView(slivers: [
          SliverAppBar(
            pinned: true,
            brightness: Theme.of(context).brightness,
            elevation: 0,
            centerTitle: true,
            title: AutoSizeText(
              widget._sbj,
              maxLines: 1,
              maxFontSize: 30,
              style: TextStyle(
                  color: Theme.of(context).brightness == Brightness.light
                      ? Colors.black
                      : Colors.white,
                  fontSize: 30,
                  fontWeight: FontWeight.bold),
            ),
            leading: IconButton(
              icon: Icon(
                Icons.arrow_back_ios,
              ),
              onPressed: () => Navigator.pop(context),
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white54
                  : Colors.black54,
            ),
            backgroundColor: Colors.transparent,
            flexibleSpace: CustomPaint(
              painter: BackgroundPainter(Theme.of(context)),
              size: Size.infinite,
            ),
            bottom: PreferredSize(
                child: Container(),
                preferredSize:
                    Size.fromHeight(MediaQuery.of(context).size.width / 8)),
          ),
          SliverList(
            delegate: SliverChildListDelegate(
              session.lessons.data['sbj'][widget._sbj].reversed
                  .map<Widget>(
                    (Lezione l) => CustomExpansionTile(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 25.0, vertical: 10),
                        child: l.info == null
                            ? null
                            : Text(
                                l.info,
                                textAlign: TextAlign.justify,
                                style: TextStyle(
                                  color: Theme.of(context).brightness ==
                                          Brightness.dark
                                      ? Colors.white70
                                      : Colors.black,
                                  fontSize: 13,
                                  letterSpacing: 1.2,
                                  fontFamily: 'roboto',
                                  height: 1.5,
                                ),
                              ),
                      ),
                      title: Text(DateFormat.MMMMEEEEd('it').format(l.date)),
                      subtitle: Text(
                        (session.subjects.data[l.author] == l.sbj ||
                                    (session.subjects.data[l.author]
                                            ?.contains(l.sbj) ??
                                        false)
                                ? ''
                                : '${l.author}\n') +
                            l.lessonType,
                        style: TextStyle(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.white70
                              : Colors.black,
                          fontSize: 12,
                          fontFamily: 'roboto',
                          height: 1.7,
                        ),
                      ),
                      leading: CircleAvatar(
                        child: Text('${l.hour + 1}ª',
                            style: TextStyle(
                              color: Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? Colors.white
                                  : Colors.black,
                            )),
                        backgroundColor: ((Globals.subjects[l.sbj] ??
                                    {})['colore'] ??
                                (Theme.of(context).brightness == Brightness.dark
                                    ? Colors.white
                                    : Colors.black))
                            .withOpacity(0.3),
                      ),
                      trailing: (bool) => Container(
                        child: CircleAvatar(
                            child: Text('${l.duration.inHours} h',
                                style: TextStyle(
                                  color: Theme.of(context).brightness ==
                                          Brightness.dark
                                      ? Colors.white
                                      : Colors.black,
                                )),
                            backgroundColor:
                                ((Globals.subjects[l.sbj] ?? {})['colore'] ??
                                        (Theme.of(context).brightness ==
                                                Brightness.dark
                                            ? Colors.white
                                            : Colors.black))
                                    .withOpacity(0.3)),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
        ]),
      );
}

import 'package:Messedaglia/main.dart';
import 'package:Messedaglia/preferences/globals.dart';
import 'package:Messedaglia/registro/lessons_registro_data.dart';
import 'package:Messedaglia/registro/registro.dart';
import 'package:Messedaglia/screens/menu_screen.dart';
import 'package:Messedaglia/widgets/expansion_tile.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class LessonsSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) => CustomScrollView(
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
          SliverList(
              delegate:
                  SliverChildListDelegate(session.lessons.data['sbj'].keys
                      .map<Widget>((sbj) => ListTile(
                            title: Text(
                              sbj,
                              style: Theme.of(context).textTheme.bodyText2,
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.ellipsis,
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
                                    builder: (context) => LessonsDetails(sbj))),
                          ))
                      .toList()))
        ],
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
            title: Text(
              widget._sbj,
              overflow: TextOverflow.fade,
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
              onPressed: () => Navigator.pop(
                  context), // TODO: come facciamo per cambiare il giorno? una pageView non ci sta... e se facessimo una sezione a parte per le lezioni? (magari non in area studenti...)
              // FIXME che ne dici di un calendario resizable con un pulsante che fa vedere o la esttimana o il mese + una icona per per un time selecotr ( flutter ha i widget sia per ios e android)
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
              delegate: SliverChildListDelegate(session
                  .lessons.data['sbj'][widget._sbj].reversed
                  .map<Widget>(
                    (Lezione l) => CustomExpansionTile(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: l.info == null
                            ? null
                            : Text(
                                l.info,
                                style: Theme.of(context).textTheme.bodyText1,
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
                        style: Theme.of(context).textTheme.bodyText1,
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
                  .toList()))
        ]),
      );
}

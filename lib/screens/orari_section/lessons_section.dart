import 'package:Messedaglia/preferences/globals.dart';
import 'package:Messedaglia/registro/lessons_registro_data.dart';
import 'package:Messedaglia/registro/registro.dart';
import 'package:Messedaglia/screens/menu_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class LessonsSection extends StatefulWidget {
  @override
  _LessonsSectionState createState() => _LessonsSectionState();
}

class _LessonsSectionState extends State<LessonsSection> {
  bool _showDay = true;

  @override
  Widget build(BuildContext context) => CustomScrollView(slivers: [
        SliverAppBar(
          pinned: true,
          brightness: Theme.of(context).brightness,
          elevation: 0,
          centerTitle: true,
          title: Text(
            'LEZIONI',
            style: TextStyle(
                color: Theme.of(context).brightness == Brightness.light
                    ? Colors.black
                    : Colors.white,
                fontSize: 30,
                fontWeight: FontWeight.bold),
          ),
          actions: [
            IconButton(
              icon: Icon(MdiIcons.calendarToday),
              onPressed: () => _showDay =
                  !_showDay, // TODO: come facciamo per cambiare il giorno? una pageView non ci sta... e se facessimo una sezione a parte per le lezioni? (magari non in area studenti...)
              color: Colors.white54,
            )
          ],
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
            delegate: SliverChildListDelegate(RegistroApi
                .lessons.data['sbj']['SUPPLENZA'].reversed
                .map<Widget>((Lezione l) => ListTile(
                      title: Text(DateFormat.yMMMMd('it').format(l.date)),
                      subtitle: Text(
                        (RegistroApi.subjects.data[l.author] == l.sbj ||
                                    (RegistroApi.subjects.data[l.author]
                                            ?.contains(l.sbj) ??
                                        false)
                                ? ''
                                : '(${l.author})\n') +
                            l.lessonType,
                        style: Theme.of(context).textTheme.bodyText1,
                      ),
                      leading: CircleAvatar(
                        child: Text('${l.hour + 1}ª', style: TextStyle(color: Colors.black,)),
                        backgroundColor: (Globals.subjects[l.sbj] ?? {})['colore'],
                      ),
                      trailing: CircleAvatar(
                          child: Text('${l.duration.inHours} h', style: TextStyle(color: Colors.black,)),
                          backgroundColor: (Globals.subjects[l.sbj] ?? {})['colore']),
                    ))
                .toList()))
      ]);
}

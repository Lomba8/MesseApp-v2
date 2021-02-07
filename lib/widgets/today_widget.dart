import 'package:Messedaglia/preferences/globals.dart';
import 'package:Messedaglia/registro/lessons_registro_data.dart';
import 'package:Messedaglia/widgets/expansion_tile.dart';
import 'package:flutter/material.dart';
import 'package:Messedaglia/main.dart' as main;
import 'package:intl/intl.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class TodayWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    DateTime today = DateTime.now();
    return LayoutBuilder(
      builder: (context, constraints) {
        return Column(
          children: main.session.lessons.data
              .where((a) =>
                  a.date.isAtSameMomentAs(
                      DateTime(today.year, today.month, today.day)) ==
                  true)
              .map<Widget>((Lezione l) {
            return CustomExpansionTile(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 30.0, vertical: 10),
                child: l.info == null
                    ? null
                    : Text(
                        l.info,
                        textAlign: TextAlign.justify,
                        style: TextStyle(
                          color: Theme.of(context).brightness == Brightness.dark
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
                (main.session.subjects.data[l.author] == l.sbj ||
                            (main.session.subjects.data[l.author]
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
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.white
                          : Colors.black,
                    )),
                backgroundColor: ((Globals.subjects[l.sbj] ?? {})['colore'] ??
                        (Theme.of(context).brightness == Brightness.dark
                            ? Colors.white
                            : Colors.black))
                    .withOpacity(0.3),
              ),
              trailing: (bool) => Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    child: CircleAvatar(
                        child: Text('${l.duration.inHours} h',
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
                            .withOpacity(0.3)),
                  ),
                  SizedBox(
                    width: 20,
                  ),
                  Container(
                    child: CircleAvatar(
                      child: Icon(
                        (Globals.subjects[
                                    main.session.subjects.data[l.author] != null
                                        ? main.session.subjects.data[l.author]
                                            [0]
                                        : {}] ??
                                {})['icona'] ??
                            MdiIcons.sleep,
                        color: Colors.black,
                      ),
                      backgroundColor: (Globals.subjects[
                                  main.session.subjects.data[l.author] != null
                                      ? main.session.subjects.data[l.author][0]
                                      : {}] ??
                              {})['colore']
                          ?.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        );
      },
    );
  }
}

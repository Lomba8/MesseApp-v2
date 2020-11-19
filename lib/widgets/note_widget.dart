import 'package:Messedaglia/preferences/globals.dart';
import 'package:Messedaglia/registro/note_registro_data.dart';
import 'package:Messedaglia/screens/screens.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:Messedaglia/main.dart' as main;

class NoteWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Column(
          children: main.session.note.data
              .where((n) => n.isNew == true)
              .map<Widget>((nota) {
            return Padding(
              padding: EdgeInsets.symmetric(
                horizontal: (40 / 207) *
                    constraints
                        .maxWidth, // 2017 è il maxWIdth dell'iphone 11 Pro Max
              ),
              child: SizedBox(
                height: 100 + 20.0,
                child: Column(
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
                            Navigator.of(context).pushNamed(NoteScreen.id);
                          },
                          title: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              AutoSizeText(
                                Nota.getTipo(nota.tipologia),
                                style: TextStyle(
                                  color: Theme.of(context).brightness ==
                                          Brightness.dark
                                      ? Colors.white
                                      : Colors.black,
                                ),
                                maxLines: 1,
                                minFontSize: 10,
                                maxFontSize: 15,
                              ), // Icon(

                              Container(
                                margin: EdgeInsets.symmetric(
                                  horizontal: (27 / 207) * constraints.maxWidth,
                                ),
                                padding: EdgeInsets.symmetric(
                                  vertical: (9 / 207) * constraints.maxWidth,
                                ),
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: Globals.coloriNote[nota.tipologia],
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(
                                  Globals.subjects[main.session.subjects
                                          .data[nota.autore][0]]['icona'] ??
                                      MdiIcons.sleep,
                                  color: Colors.black,
                                  size: (20 / 207) * constraints.maxWidth,
                                ),
                              ),

                              Padding(
                                padding: EdgeInsets.symmetric(
                                    vertical: (5 / 207) * constraints.maxWidth),
                                child: AutoSizeText(
                                  nota?.date != null
                                      ? Nota.getDateWithSlashes(nota?.date)
                                      : Nota.getDateWithSlashesShort(
                                              nota?.inizio) +
                                          ' - ' +
                                          Nota.getDateWithSlashesShort(
                                              nota?.fine),
                                  maxLines: 1,
                                  minFontSize: 11,
                                  maxFontSize: 13,
                                  style: TextStyle(
                                    color: Colors.white70,
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
            );
          }).toList(),
        );
      },
    );
  }
}

import 'package:Messedaglia/preferences/globals.dart';
import 'package:Messedaglia/registro/didattica_registro_data.dart';
import 'package:Messedaglia/registro/registro.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class DidatticaScreen extends StatefulWidget {
  @override
  _DidatticaScreenData createState() => _DidatticaScreenData();
}

class _DidatticaScreenData extends State<DidatticaScreen> {
  CustomDirectory directory =
      CustomDirectory(name: '/', children: RegistroApi.didactics.data);

  @override
  Widget build(BuildContext context) => Material(
        child: GridView.count(
            childAspectRatio: 0.9,
            crossAxisCount: 2,
            children: <Widget>[
              if (directory.parent != null)
                GestureDetector(
                  onTap: () => setState(() => directory = directory.parent),
                  child: Column(
                    children: <Widget>[
                      Stack(
                        alignment: Alignment.center,
                        children: <Widget>[
                          Icon(Icons.folder, size: 150, color: Colors.white54),
                          Icon(
                            Icons.arrow_back,
                            size: 50,
                            color: Colors.white,
                          ),
                        ],
                      ),
                      Text(
                        '..',
                        textAlign: TextAlign.center,
                      )
                    ],
                  ),
                )
            ]
                .followedBy(
                    directory.children.map<Widget>((path) => GestureDetector(
                          onTap: () => setState(() => directory =
                              path is CustomDirectory ? path : directory),
                          child: Column(
                            children: <Widget>[
                              Stack(
                                alignment: Alignment.center,
                                children: <Widget>[
                                  Icon(
                                    path is CustomDirectory
                                        ? Icons.folder
                                        : (path as CustomFile).type == 'link'
                                            ? Icons.link
                                            : Icons.insert_drive_file,
                                    size: 150,
                                    color: ((RegistroApi.subjects
                                                    .subjectTheme(path.name) ??
                                                RegistroApi.subjects
                                                    .subjectTheme(
                                                        path.parent?.name) ??
                                                {})['colore'] ??
                                            Colors.white)
                                        .withOpacity(0.5),
                                  ),
                                  if (path is CustomDirectory)
                                    Icon(
                                      (RegistroApi.subjects
                                              .subjectTheme(path.name) ??
                                          RegistroApi.subjects.subjectTheme(
                                              path.parent?.name) ??
                                          {})['icona'],
                                      size: 50,
                                      color: Colors.white,
                                    ),
                                ],
                              ),
                              Text(
                                path.name,
                                textAlign: TextAlign.center,
                                maxLines: 2,
                              )
                            ],
                          ),
                        )))
                .toList()),
      );
}

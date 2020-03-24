import 'package:Messedaglia/preferences/globals.dart';
import 'package:Messedaglia/registro/didattica_registro_data.dart';
import 'package:Messedaglia/registro/registro.dart';
import 'package:flutter/material.dart';

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
            crossAxisCount: 2,
            childAspectRatio: 0.9,
            children: <Widget>[
              if (directory.parent != null)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: GestureDetector(
                    onTap: () => setState(() => directory = directory.parent),
                    child: Column(
                      children: <Widget>[
                        Stack(
                          alignment: Alignment.center,
                          children: <Widget>[
                            Icon(Icons.folder, size: 125, color: Colors.white54),
                            Icon(
                              Icons.arrow_back,
                              size: 30,
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
                  ),
                )
            ]
                .followedBy(
                    directory.children.map<Widget>((path) => Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: GestureDetector(
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
                                              : (Globals.estensioni[(path as CustomFile).type] ?? {'icona': Icons.insert_drive_file})['icona'],
                                      size: 125,
                                      color: ((path is CustomDirectory ? (RegistroApi.subjects
                                                      .subjectTheme(path.name) ??
                                                  RegistroApi.subjects
                                                      .subjectTheme(
                                                          path.parent?.name) ??
                                                  {})['colore'] : (Globals.estensioni[(path as CustomFile).type] ?? {})['colore']) ??
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
                                        size: 40,
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
                          ),
                    )))
                .toList()),
      );
}

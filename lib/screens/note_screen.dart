import 'package:Messedaglia/registro/registro.dart';
import 'package:Messedaglia/widgets/CustomConnectionStatusBar.dart';
import 'package:flutter/material.dart';

class NoteScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Material(
          child: Column(children: [
        Text(RegistroApi.note.json),
        CustomConnectionStatusBar(
          width: MediaQuery.of(context).size.width / 3,
        ),
      ]));
}

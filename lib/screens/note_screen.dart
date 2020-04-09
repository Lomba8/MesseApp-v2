import 'package:Messedaglia/main.dart';
import 'package:flutter/material.dart';

class NoteScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Material(
          child: Column(children: [
        Text(session.note.json),
      ]));
}

import 'package:Messedaglia/main.dart';
import 'package:flutter/material.dart';

class NoteScreen extends StatelessWidget {
  //TODO implementare il liquidpulltorefresh con HapticFeedback.mediumImpact(); alla fine

  static final String id = 'note_screen';

  @override
  Widget build(BuildContext context) => Material(
          child: Column(children: [
        Text(session.note.json),
      ]));
}

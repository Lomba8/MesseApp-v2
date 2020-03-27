

import 'package:Messedaglia/registro/registro.dart';
import 'package:flutter/material.dart';

class NoteScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Material(child: Text(RegistroApi.note.json));

}
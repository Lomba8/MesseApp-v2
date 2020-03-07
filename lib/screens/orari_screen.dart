import 'package:Messedaglia/screens/orari_section/lessons_section.dart';
import 'package:Messedaglia/screens/orari_section/orari_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class Orari extends StatefulWidget {
  static final String id = 'orari_screen';
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  @override
  _OrariState createState() => _OrariState();
}

class _OrariState extends State<Orari> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) => PageView(children: [
        OrariSection(),
        LessonsSection(),
      ]);
}

void rebuildAllChildren(BuildContext context) {
  void rebuild(Element el) {
    el.markNeedsBuild();
    el.visitChildren(rebuild);
  }
  (context as Element).visitChildren(rebuild);
}

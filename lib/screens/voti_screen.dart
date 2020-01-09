import 'package:applicazione_prova/widgets/nav_bar_sotto.dart';
import 'package:flutter/material.dart';

class Voti extends StatefulWidget {
  static final String id = 'voti_screen';
  @override
  _VotiState createState() => _VotiState();
}

class _VotiState extends State<Voti> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).backgroundColor,
      child: Text("Voti"),
    );
  }
}

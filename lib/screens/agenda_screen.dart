import 'package:applicazione_prova/widgets/nav_bar_sotto.dart';
import 'package:flutter/material.dart';

class Agenda extends StatefulWidget {
    static final String id = 'agenda_screen';
    @override
    _AgendaState createState() => _AgendaState();
}

class _AgendaState extends State<Agenda> {
    @override
    Widget build(BuildContext context) {
        return Container(
            color: Theme.of(context).backgroundColor,
            child: Text("Agenda"),
        );
    }
}

import 'package:flutter/material.dart';

class Orari extends StatefulWidget {
  static final String id = 'orari_screen';
  @override
  _OrariState createState() => _OrariState();
}

class _OrariState extends State<Orari> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).backgroundColor,
      child: Text("Orari"),
    );
  }
}

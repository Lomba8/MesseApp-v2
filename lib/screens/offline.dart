import 'package:Messedaglia/main.dart' as main;
import 'package:Messedaglia/preferences/globals.dart';
import 'package:Messedaglia/registro/registro.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flare_flutter/flare_actor.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';

class Offline extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    main.alreadyPushed = true;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        children: [
          Align(
            alignment: Alignment(0.5, -0.5),
            child: SizedBox(
              height: 300,
              width: 300,
              child: FlareActor(
                'flare/no_connection.flr',
                alignment: Alignment.center,
                animation: 'init',
              ),
            ),
          ),
          Align(
            alignment: Alignment(0.0, 0.7),
            child: GestureDetector(
              onTap: () {
                main.alreadyPushed = false;
                Navigator.pop(context);
              },
              child: Container(
                padding: EdgeInsets.all(20.0),
                decoration: BoxDecoration(
                  color: Color.fromRGBO(243, 245, 252, 1.0),
                  borderRadius: BorderRadius.circular(30.0),
                  //backgroundBlendMode: BlendMode.difference,
                  border: Border.all(
                    color: Color.fromRGBO(225, 231, 245, 1.0),
                    style: BorderStyle.solid,
                    width: 1.0,
                  ),
                ),
                child: Text(
                  'continua offline',
                  style: TextStyle(
                    color: Color.fromRGBO(46, 48, 61, 1.0),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:Messedaglia/preferences/globals.dart';
import 'package:Messedaglia/registro/voti_registro_data.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:Messedaglia/screens/menu_screen.dart' as menu;
import 'package:Messedaglia/main.dart' as main;

Function votiWidget = (BuildContext context) {
  List<Widget> voti = List();

  main.session.voti.data.where((voto) => voto.isNew == true).forEach((voto) {
    voti.add(
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30.0),
        child: SizedBox(
          height: 70 + 10.0 + 10.0,
          child: Column(
            children: <Widget>[
              SizedBox(
                height: 10.0,
              ),
              Expanded(
                child: Material(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Color(0xFF33333D)
                      : Color(0xFFD2D1D7),
                  borderRadius: BorderRadius.circular(10.0),
                  elevation: 10.0,
                  child: Center(
                    child: ListTile(
                      onTap: () {
                        menu.push(3);
                      },
                      dense: true,
                      leading: Container(
                        margin: EdgeInsets.only(left: 7),
                        width: 35.0,
                        alignment: Alignment.center,
                        decoration: new BoxDecoration(
                          color: Voto.getColor(voto.voto),
                          shape: BoxShape.circle,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.only(
                            left: 4.0,
                            right: 4.0,
                            top: 2,
                          ),
                          child: AutoSizeText(
                            voto.votoStr,
                            maxLines: 1,
                            maxFontSize: 15,
                            style: TextStyle(
                              fontFamily: 'CoresansRounded',
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 20,
                            ),
                          ),
                        ),
                      ),
                      title: AutoSizeText.rich(
                        TextSpan(
                          text: Globals.getMaterieSHort(voto.sbj) + '\n',
                          style: TextStyle(fontSize: 15, color: Colors.white),
                          children: <TextSpan>[
                            TextSpan(
                              text: '\n' + voto.dateWithSlashesShort,
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                        maxLines: 3,
                        maxFontSize: 15,
                        minFontSize: 8,
                        style: TextStyle(
                          fontFamily: 'CoresansRounded',
                          color: Colors.white70,
                          fontWeight: FontWeight.w600,
                          fontSize: 10,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  });
  return voti;
};

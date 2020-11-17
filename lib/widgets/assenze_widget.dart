import 'package:Messedaglia/preferences/globals.dart';
import 'package:Messedaglia/registro/absences_registro_data.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:Messedaglia/main.dart' as main;
import 'package:Messedaglia/screens/screens.dart';

Function assenzeWidget = (BuildContext context) {
  List<Widget> assenze = List();

  main.session.absences.data.values
      .where((a) => a.justified == false)
      .forEach((assenza) {
    assenze.add(
      GestureDetector(
        onTap: () {
          Navigator.pushNamed(context, AbsencesScreen.id);
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15.0),
          child: SizedBox(
            height: 65.0,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
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
                    child: ListTile(
                      onTap: () {
                        Navigator.of(context).pushNamed(AbsencesScreen.id);
                      },
                      dense: true,
                      title: Row(
                        mainAxisAlignment:
                            Assenza.getTipo(assenza.type).split(' ').length == 1
                                ? MainAxisAlignment.spaceEvenly
                                : MainAxisAlignment.spaceAround,
                        children: <Widget>[
                          Container(
                            margin: EdgeInsets.only(
                              right: 10,
                              bottom: 7,
                            ),
                            padding: EdgeInsets.only(
                              left: 1,
                              top: 4,
                            ),
                            width: 33.0,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: Globals.coloriAssenze[assenza.type],
                              shape: BoxShape.circle,
                            ),
                            child: AutoSizeText(
                              Assenza.getTipo(assenza.type)
                                  .split(' ')
                                  .map((e) => e[0].toString())
                                  .join('')
                                  .trim(),
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'CoreSansRounded',
                              ),
                              maxLines: 1,
                              maxFontSize: Assenza.getTipo(assenza.type)
                                          .split(' ')
                                          .length ==
                                      1
                                  ? 22.0
                                  : 20.0,
                              minFontSize: Assenza.getTipo(assenza.type)
                                          .split(' ')
                                          .length ==
                                      1
                                  ? 17.0
                                  : 15.0,
                            ),
                          ),
                          AutoSizeText(
                            assenza.hour == null
                                ? ''
                                : assenza.hour.toString() + 'ᵃ',
                            maxLines: 1,
                            maxFontSize: 13,
                            minFontSize: 8,
                            style: TextStyle(
                              fontSize: 15.0,
                              color: Colors.white,
                              fontFamily: 'CoreSans',
                              fontWeight: FontWeight.w600,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          AutoSizeText(
                            Assenza.getTipo(assenza.type).split(' ').length >
                                        1 ||
                                    assenza.type == 'ABA0'
                                ? Assenza.getDateWithSlashes(assenza.date)
                                : Assenza.getDateWithSlashesShort(assenza.date),
                            maxLines: 1,
                            maxFontSize: 13,
                            minFontSize: 8,
                            style: TextStyle(
                              fontSize: 15.0,
                              color: Colors.white70,
                              fontFamily: 'CoreSans',
                              fontWeight: FontWeight.w600,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  });
  return assenze;
};

import 'package:applicazione_prova/server/server.dart';
import 'package:applicazione_prova/widgets/nav_bar.dart';
import 'package:applicazione_prova/widgets/nav_bar_sotto.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

//se non mi piace la nav bar di flare posso usare: curved_navigation_bar
//flare gia pronto per menu bar https://rive.app/a/akaaljotsingh/files/flare/drawer/preview

class Home extends StatefulWidget {
  static final String id = 'home_screen';
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  SharedPreferences _prefs;
  void _preferenze() async => _prefs = await SharedPreferences.getInstance();

  @override
  Widget build(BuildContext context) {
    _preferenze();
    var s = MediaQuery.of(context).size;
    return Stack(
      overflow: Overflow.visible,
      children: <Widget>[
        Positioned(
          top: 0,
          child: Container(
            height: s.height / 2,
            width: s.width,
            color: Theme.of(context).primaryColor,
          ),
        ),
        SingleChildScrollView(
          scrollDirection: Axis.vertical,
          physics: AlwaysScrollableScrollPhysics(),
          child: Column(
            children: <Widget>[
              Material(
                elevation: 100.0,
                child: Container(
                  color: Theme.of(context).backgroundColor,
                  transform: Matrix4.translationValues(0.0, 0.5, 0.0),
                  child: Container(
                    height: s.height / 3.5,
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                      // Opzione 1
                      // Opzione 1
                      // borderRadius: BorderRadius.only(
                      //   bottomLeft: Radius.elliptical(60, 40),
                      // ),
                      borderRadius: BorderRadius.only(
                        bottomRight: Radius.elliptical(45.0, 40.0),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        SizedBox(
                          width: s.width / 12,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            SizedBox(
                              height: s.height / 9,
                            ),
                            Container(
                              width: s.width - (s.width / 10),
                              child: RichText(
                                overflow: TextOverflow.ellipsis,
                                text: TextSpan(
                                  text: "Ciao, \n",
                                  style: TextStyle(
                                    fontFamily: 'TeeFranklin',
                                    color: Color.fromRGBO(141, 149, 167, 1),
                                    fontSize: 35.0,
                                  ),
                                  children: <TextSpan>[
                                    TextSpan(
                                      text: Server.cognome,
                                      style: TextStyle(
                                        fontFamily: 'TeeFranklin',
                                        color: Color.fromRGBO(21, 38, 74, 1),
                                        fontSize: 40.0,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    TextSpan(
                                      text: " " + (Server.nome ?? 'unknown'),
                                      style: TextStyle(
                                        fontFamily: 'TeeFranklin',
                                        color: Color.fromRGBO(21, 38, 74, 1),
                                        fontSize: 40.0,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Container(
                color: Theme.of(context).primaryColor,
                height: s.height * 1.2,
                width: s.width,
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).backgroundColor,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.elliptical(45.0, 40.0),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

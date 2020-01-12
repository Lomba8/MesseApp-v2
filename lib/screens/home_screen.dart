import 'package:applicazione_prova/server/server.dart';
import 'package:flutter/material.dart';

//se non mi piace la nav bar di flare posso usare: curved_navigation_bar
//flare gia pronto per menu bar https://rive.app/a/akaaljotsingh/files/flare/drawer/preview

class Home extends StatefulWidget {
  static final String id = 'home_screen';

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {

  @override
  Widget build(BuildContext context) {
    var s = MediaQuery.of(context).size;
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      physics: AlwaysScrollableScrollPhysics(),
      child: Column(
        children: <Widget>[
          Container(
            color: Theme.of(context).backgroundColor,
            //transform: Matrix4.translationValues(0.0, 0.5, 0.0),
            child: Container(
              width: s.width,
              height: s.height / 3.5,
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                borderRadius: BorderRadius.only(
                  bottomRight: Radius.elliptical(40.0, 40.0),
                ),
              ),
              child: Padding(
                padding:
                    EdgeInsets.only(left: s.width / 15, top: s.height / 15),
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
                        text: '${Server.cognome} ${Server.nome}',
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
            ),
          ),
          Container(
            color: Theme.of(context).primaryColor,
            height: 40,
            width: s.width,
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).backgroundColor,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.elliptical(40.0, 40.0),
                ),
              ),
            ),
          ),
          Column () // TODO: schermata vera e propria
        ],
      ),
    );
  }
}

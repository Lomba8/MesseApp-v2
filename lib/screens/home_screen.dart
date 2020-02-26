import 'package:Messedaglia/preferences/globals.dart';
import 'package:Messedaglia/registro/registro.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
    Globals _themeChanger = Provider.of<Globals>(context);
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      "Ciao,",
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Color.fromRGBO(141, 149, 167, 1),
                        fontSize: 35.0,
                        fontFamily: 'CoreSansRounded',
                      ),
                    ),
                    SizedBox(
                      height: 10.0,
                    ),
                    AutoSizeText(
                      '${RegistroApi.cognome} ${RegistroApi.nome}',
                      overflow: TextOverflow.ellipsis,
                      minFontSize: 20.0,
                      maxFontSize: 30.0,
                      maxLines: 1,
                      textDirection: TextDirection.ltr,
                      style: TextStyle(
                          color: Color.fromRGBO(21, 38, 74, 1),
                          fontSize: 30.0,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'CoreSansRounded'),
                    ),
                  ],
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
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              RaisedButton.icon(
                onPressed: () => _themeChanger.setTheme(ThemeMode.dark),
                icon: Icon(Icons.brightness_6),
                label: Text('ThemeMode.dark'),
              ),
              RaisedButton.icon(
                onPressed: () => _themeChanger.setTheme(ThemeMode.light),
                icon: Icon(Icons.brightness_5),
                label: Text('ThemeMode.light'),
              ),
              RaisedButton.icon(
                onPressed: () => _themeChanger.setTheme(ThemeMode.system),
                icon: Icon(Icons.settings),
                label: Text('ThemeMode.system'),
              ),

              // TODO: schermata vera e propria
            ],
          )
        ],
      ),
    );
  }
}

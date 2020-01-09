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
  @override
  Widget build(BuildContext context) {
    Server server = Server("G5731406W", "lg20756u");
    server.login();
    var s = MediaQuery.of(context).size;
    return Stack(
      overflow: Overflow.visible,
      children: <Widget>[
        SingleChildScrollView(
          scrollDirection: Axis.vertical,
          physics: AlwaysScrollableScrollPhysics(),
          child: Column(
            children: <Widget>[
              Container(
                color: Theme.of(context).backgroundColor,
                transform: Matrix4.translationValues(0.0, 0.5, 0.0),
                child: Container(
                  height: s.height / 2.55,
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,

                    // Opzione 1
                    // borderRadius: BorderRadius.only(
                    //   bottomLeft: Radius.elliptical(60, 40),
                    // ),
                    borderRadius: BorderRadius.only(
                      bottomRight: Radius.elliptical(45.0, 40.0),
                      //bottomLeft: Radius.circular(40.0)
                    ),
                  ),
                ),
              ),
              Container(
                color: Theme.of(context).primaryColor,
                transform: Matrix4.translationValues(0.0, 0, 0.0),
                height: s.height * 1.2,
                width: s.width,
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context)
                        .backgroundColor, //Theme.of(context).backgroundColor,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(40.0),
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

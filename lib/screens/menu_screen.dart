import 'package:applicazione_prova/screens/voti_screen.dart';
import 'package:applicazione_prova/widgets/nav_bar_sotto.dart';
import 'package:flutter/material.dart';

import 'agenda_screen.dart';
import 'area_studenti_screen.dart';
import 'home_screen.dart';
import 'orari_screen.dart';

class Menu extends StatefulWidget {
  static String id = "menu_screen";
  @override
  MenuState createState() => MenuState();
}

class MenuState extends State<Menu> {
  int selected = 2;
  List<Widget> screens = [Orari(), Agenda(), Home(), Voti(), AreaStudenti()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
        child: screens[selected],
      ),
      bottomNavigationBar: NavBarSotto(
        (pos) => setState(() => selected = pos),
      )
    );
  }
}

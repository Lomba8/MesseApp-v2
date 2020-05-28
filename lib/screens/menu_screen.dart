import 'package:Messedaglia/main.dart';
import 'package:Messedaglia/screens/bacheca_screen.dart';
import 'package:Messedaglia/screens/didattica_screen.dart';
import 'package:Messedaglia/screens/map_screen.dart';
import 'package:Messedaglia/screens/tutoraggi_screen.dart';
import 'package:Messedaglia/screens/voti_screen.dart';
import 'package:Messedaglia/widgets/nav_bar_sotto.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sliding_sheet/sliding_sheet.dart';

import 'agenda_screen.dart';
import 'area_studenti_screen.dart';
import 'home_screen1.dart';
import 'orari_screen.dart';

class Menu extends StatefulWidget {
  static String id = "menu_screen";
  @override
  MenuState createState() => MenuState();
}

class MenuState extends State<Menu> with WidgetsBindingObserver {
  int selected = 2;
  List<Widget> screens = [Orari(), Agenda(), Home(), Voti(), AreaStudenti()];

  bool sheetExtended = false;

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    super.initState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);

    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    print(state.toString());

    session.save();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        //backgroundColor: Colors.black,
        elevation: 10,
        title: Text("TEST", style: TextStyle(fontWeight: FontWeight.bold),),
        centerTitle: true,
        shape: sheetExtended
            ? null
            : RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(20),
                ),
              ),
      ),
      body: SlidingSheet(
        body: Builder(builder: (context) => screens[selected]),
        elevation: 10,
        cornerRadius: 20,
        duration: Duration(milliseconds: 900),
        
        //color: Colors.black,
        snapSpec: SnapSpec(
          positioning: SnapPositioning.relativeToAvailableSpace,
          snappings: [SnapSpec.headerFooterSnap, 1],
          snap: true,
        ),
        listener: (state) {
          if (sheetExtended != state.isExpanded) setState(() {
            sheetExtended = state.isExpanded;
          });
        },
        cornerRadiusOnFullscreen: 0,
        footerBuilder: (context, state) {
          return NavBarSotto(
            (pos) => setState(() => selected = pos),
          );
        },
        isBackdropInteractable: true,
        addTopViewPaddingOnFullscreen: true,
        headerBuilder: (context, state) => Container(
          width: 30,
          height: 5,
          margin: EdgeInsets.all(state.isExpanded ? 15 : 5),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(2.5), color: Colors.grey),
        ),
        builder: (context, state) => Container(height: state.maxScrollExtent - state.minExtent,),
        /*builder: (context, state) => GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          children: <Widget>[
            Section(
              sezione: 'Autogestione', // mappa Globals.icone[sezione]
              colore: 'verde', // mappa Globals.sezioni[colore]
              page: MapScreen(),
            ),
            Section(
              sezione: 'Alternanza',
              colore: 'blu',
            ),
            Section(
              sezione: 'Bacheca',
              colore: 'arancione',
              page: BachecaScreen(),
            ),
            Section(
              sezione: 'Didattica',
              colore: 'rosa',
              page: DidatticaScreen(),
            ),
            Section(
              sezione: 'App Panini',
              colore: 'rosso',
              //action: _listaPanini,
            ),
            Section(
              sezione: 'Tutoraggi',
              colore: 'viola',
              page: TutoraggiScreen(),
            ),
          ],
        ),*/
      ),
    );
  }
}

class BackgroundPainter extends CustomPainter {
  final ThemeData _theme;
  final Paint p = Paint();
  final Path path = Path();

  BackgroundPainter(this._theme);

  @override
  void paint(Canvas canvas, Size size) {
    double k = size.width / 100;

    path.reset();
    path.lineTo(0, size.height - 16);
    path.quadraticBezierTo(
        k * 10, size.height - k * 5, k * 21, size.height - k * 3);
    path.quadraticBezierTo(
        k * 36, size.height + k * 0.6, k * 47, size.height - k * 3);
    path.quadraticBezierTo(
        k * 56, size.height - k * 6, k * 63, size.height - k * 12);
    path.quadraticBezierTo(
        k * 81, size.height - k * 27, k * 100, size.height - k * 0.7);
    path.lineTo(size.width, 0);
    path.close();
    p.color = _theme.primaryColor;
    canvas.drawPath(path, p);

    path.reset();
    path.lineTo(0, size.height - 1.5);
    path.quadraticBezierTo(
        k * 19, size.height - k * 23, k * 31, size.height - k * 8);
    path.quadraticBezierTo(
        k * 39, size.height + k * 1, k * 52, size.height - k * 11);
    path.quadraticBezierTo(
        k * 84, size.height - k * 45, k * 100, size.height - k * 8);
    path.lineTo(size.width, 0);
    path.close();
    p.color = _theme.accentColor;
    canvas.drawPath(path, p);

    path.reset();
    path.lineTo(0, size.height - 12);
    path.quadraticBezierTo(
        k * 13, size.height - k * 23, k * 21, size.height - k * 10);
    path.quadraticBezierTo(
        k * 25, size.height - k * 4, k * 34, size.height - k * 10);
    path.quadraticBezierTo(
        k * 41, size.height - k * 14, k * 63, size.height - k * 9);
    path.quadraticBezierTo(
        k * 82, size.height - k * 5, k * 100, size.height - k * 5);
    path.lineTo(size.width, 0);
    path.close();
    p.color = _theme.brightness == Brightness.light
        ? Color(0xFFBDBDBD)
        : Colors.grey[800];
    canvas.drawPath(path, p);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return oldDelegate != this;
  }
}

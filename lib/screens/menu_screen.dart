import 'package:Messedaglia/main.dart';
import 'package:Messedaglia/registro/registro.dart';
import 'package:Messedaglia/screens/voti_screen.dart';
import 'package:Messedaglia/widgets/nav_bar_sotto.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'agenda_screen.dart';
import 'area_studenti_screen.dart';
import 'home_screen.dart';
import 'orari_screen.dart';

class Menu extends StatefulWidget {
  static String id = "menu_screen";
  @override
  MenuState createState() => MenuState();
}

class MenuState extends State<Menu> with WidgetsBindingObserver {
  int selected = 2;
  List<Widget> screens = [Orari(), Agenda(), Home(), Voti(), AreaStudenti()];

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
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    return Scaffold(
        body: Builder(builder: (context) => screens[selected]),
        bottomNavigationBar: NavBarSotto(
          (pos) => setState(() => selected = pos),
        ));
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

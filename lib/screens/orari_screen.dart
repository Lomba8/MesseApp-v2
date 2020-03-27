import 'package:Messedaglia/screens/orari_section/lessons_section.dart';
import 'package:Messedaglia/screens/orari_section/orari_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class Orari extends StatefulWidget {
  static final String id = 'orari_screen';
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  @override
  _OrariState createState() => _OrariState();
}

class _OrariState extends State<Orari> {
  @override
  void initState() {
    super.initState();
  }

  int _index = 1;
  PageController _controller = PageController();

  @override
  Widget build(BuildContext context) => Stack(
        children: [
          PageView(
            children: [
              OrariSection(),
              LessonsSection(),
            ],
            controller: _controller,
            // onPageChanged: (index) {
            //   setState(() {
            //     _index = index;
            //   });
            // },
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: SmoothPageIndicator(
              controller: _controller,
              count: 2,
              effect: SwapEffect(
                activeDotColor: Theme.of(context).accentColor,
                dotColor: Colors.white10,
                dotHeight: 10.0,
                dotWidth: 10.0,
                radius: 5.0,
              ),
            ),
          ),
        ],
      );
}

void rebuildAllChildren(BuildContext context) {
  void rebuild(Element el) {
    el.markNeedsBuild();
    el.visitChildren(rebuild);
  }

  (context as Element).visitChildren(rebuild);
}

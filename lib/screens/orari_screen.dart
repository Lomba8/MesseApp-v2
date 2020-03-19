import 'package:Messedaglia/screens/menu_screen.dart';
import 'package:Messedaglia/screens/orari_section/lessons_section.dart';
import 'package:Messedaglia/screens/orari_section/orari_section.dart';
import 'package:Messedaglia/utils/orariUtils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'orari_section/orari_section.dart';

class Orari extends StatefulWidget {
  static final String id = 'orari_screen';
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  @override
  _OrariState createState() => _OrariState();
}

class _OrariState extends State<Orari> {
  int _index = 1;
  PageController _controller = PageController();
  int _page = 0;
  double _pageDouble = 0.0;
  @override
  void initState() {
    _controller.addListener(_listener);
    super.initState();
  }

  _listener() {
    _pageDouble = _controller?.page;
    if (_controller.position.userScrollDirection == ScrollDirection.reverse) {
      if (_controller.position.atEdge) {
        _page = 1;
        setState(() {});
      }
      // print('swiped to right');
    } else {
      if (_controller.position.atEdge) {
        _page = 0;
        setState(() {});
      }

      //print('swiped to left');
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: <Widget>[
        SliverAppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          brightness: Theme.of(context).brightness,
          title: AnimatedCrossFade(
            firstChild: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                if (downloading)
                  Padding(
                    padding: EdgeInsets.only(bottom: 4),
                    child: SizedBox(
                      height: 18.0,
                      width: 18.0,
                      child: CircularProgressIndicator(
                        value: null,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    ),
                  ),
                if (downloading)
                  SizedBox(
                    width: 2.0,
                  ),
                Text(
                  downloading ? 'RARI' : 'ORARI',
                  style: TextStyle(
                      color: Theme.of(context).brightness == Brightness.light
                          ? Colors.black
                          : Colors.white,
                      fontSize: 30,
                      fontWeight: FontWeight.bold),
                ),
              ],
            ),
            secondChild: Row(
              children: [
                SizedBox(
                  width: 79,
                ),
                Text(
                  'LEZIONI',
                  style: TextStyle(
                      color: Theme.of(context).brightness == Brightness.light
                          ? Colors.black
                          : Colors.white,
                      fontSize: 30,
                      fontWeight: FontWeight.bold),
                ),
              ],
            ),
            crossFadeState: _pageDouble < 0.5
                ? CrossFadeState.showFirst
                : CrossFadeState.showSecond,
            duration: Duration(milliseconds: 400),
            layoutBuilder:
                (topChild, topChildKey, bottomChild, bottomChildKey) {
              return Stack(
                children: <Widget>[
                  Align(
                    alignment: Alignment.center,
                    child: topChild,
                    key: topChildKey,
                  ),
                  Align(
                    alignment: Alignment.center,
                    child: bottomChild,
                    key: bottomChildKey,
                  ),
                ],
              );
            },
          ),
          leading: _page == 0
              ? Padding(
                  padding: const EdgeInsets.only(left: 20),
                  child: IconButton(
                    icon: Icon(Icons.settings_backup_restore),
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.white54
                        : Colors.black54,
                    onPressed: () {
                      resetprefs();
                      setState(() {});
                    },
                  ),
                )
              : Offstage(),
          actions: <Widget>[
            _page == 0
                ? Padding(
                    padding: const EdgeInsets.only(right: 20),
                    child: IconButton(
                        icon: Icon(
                          Icons.file_download,
                          color:
                              Theme.of(context).brightness == Brightness.light
                                  ? Colors.black54
                                  : Colors.white54,
                        ),
                        onPressed: selectedClass == null
                            ? null
                            : () async {
                                downloadOrario(selectedClass).then((_) {
                                  showNotificationWithDefaultSound(
                                      selectedClass);
                                });

                                setState(() {
                                  downloading = true;
                                  progress = 0;
                                });
                              }),
                  )
                : Offstage(),
          ],
          centerTitle: true,
          pinned: true,
          flexibleSpace: Stack(
            overflow: Overflow.visible,
            children: [
              CustomPaint(
                painter: BackgroundPainter(Theme.of(context)),
                size: Size.infinite,
              ),
              Align(
                alignment: Alignment(0, 0.23),
                child: SmoothPageIndicator(
                  controller: _controller,
                  count: 2,
                  effect: SwapEffect(
                    activeDotColor: Theme.of(context).accentColor,
                    dotColor: Colors.white38,
                    dotHeight: 10.0,
                    dotWidth: 10.0,
                    radius: 5.0,
                  ),
                ),
              ),
            ],
          ),
          bottom: PreferredSize(
            child: Container(),
            preferredSize:
                Size.fromHeight(MediaQuery.of(context).size.width / 8),
          ),
        ),
        SliverList(
          delegate: SliverChildListDelegate([
            SizedBox(
              height: MediaQuery.of(context).size.height * 2,
              child: PageView(
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
            )
          ]),
        )
      ],
    );
  }
}

import 'dart:io';

import 'package:Messedaglia/screens/menu_screen.dart';
import 'package:Messedaglia/utils/orariUtils.dart' as orariUtils;
import 'package:Messedaglia/utils/orariUtils.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:image_downloader/image_downloader.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class Orari extends StatefulWidget {
  static final String id = 'orari_screen';
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  @override
  _OrariState createState() => _OrariState();
}

class _OrariState extends State<Orari> {
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  String _selectedSbj;
  double _progress = 0;
  bool _downloading = false;
  var prefs = orariUtils.prefs;

  bool get _hasSaturday {
    List orario = orariUtils.orari[orariUtils.selectedClass];
    if (orario == null) return true;
    for (int i = 5; i < orario.length; i += 6) if (orario[i] != '') return true;
    return false;
  }

  Future<void> downloadOrario(String classe) async {
    if (Platform.isAndroid) {
      try {
        // TODO: Pietro se vuoi fare i tuoui strani download per android
        /*
          await ImageDownloader.downloadImage(url,
                                     destination: AndroidDestinationType.custom('sample')
                                     ..inExternalFilesDir()
                                     ..subDirectory("custom/sample.gif"),
         );
       */
        var imageId =
            await ImageDownloader.downloadImage(orari[classe + 'url']);
      } catch (e) {
        print(e);
      }
    } else if (Platform.isIOS) {
      try {
        try {
          var imageId =
              await ImageDownloader.downloadImage(orari[classe + 'url']);
        } catch (e) {
          print(e);
        }
      } catch (e) {
        print(e);
      }
    }
  }

  void resetprefs() async {
    prefs = await SharedPreferences.getInstance();
    prefs.setBool('has_already_selected_class', false);
    prefs.setString('selectedClass', '');
  }

  @override
  void initState() {
    super.initState();

    var initializationSettingsAndroid =
        new AndroidInitializationSettings('@mipmap/splash');
    var initializationSettingsIOS = new IOSInitializationSettings();
    var initializationSettings = new InitializationSettings(
        initializationSettingsAndroid, initializationSettingsIOS);
    flutterLocalNotificationsPlugin = new FlutterLocalNotificationsPlugin();
    flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: (String payload) async {
      if (payload != null) {
        debugPrint('notification payload: ' + payload);
      }
    });

    ImageDownloader.callback(onProgressUpdate: (String imageId, int progress) {
      setState(() {
        _progress = progress / 100;
        print(progress);
        if (_progress == 1) {
          _downloading = false;
          _progress = 0;
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    rebuildAllChildren(context);
    return CustomScrollView(physics: ClampingScrollPhysics(), slivers: [
      SliverAppBar(
        elevation: 0,
        centerTitle: true,
        title: Text(
          'ORARI',
          textAlign: TextAlign.center,
          style: TextStyle(
              color: Theme.of(context).brightness == Brightness.light
                  ? Colors.black
                  : Colors.white,
              fontSize: 30,
              fontWeight: FontWeight.bold),
        ),
        actions: <Widget>[
          IconButton(
              icon: Icon(
                Icons.file_download,
                color: Theme.of(context).brightness == Brightness.light
                    ? Colors.black
                    : Colors.white,
              ),
              onPressed: orariUtils.selectedClass == null
                  ? null
                  : () {
                      downloadOrario(orariUtils.selectedClass);
                      _showNotificationWithDefaultSound(
                          orariUtils.selectedClass);
                      setState(() {
                        _downloading = true;
                        _progress = 0;
                      });
                    }),
          IconButton(
            icon: Icon(Icons.restore_page),
            color: Colors.white,
            onPressed: () {
              resetprefs();
              getSelected();
              setState(() {});
            },
          )
        ],
        pinned: true,
        backgroundColor: Colors.transparent,
        flexibleSpace: CustomPaint(
          painter: BackgroundPainter(Theme.of(context)),
          size: Size.infinite,
        ),
        bottom: PreferredSize(
            child: Container(),
            preferredSize:
                Size.fromHeight(MediaQuery.of(context).size.width / 8)),
      ),
      SliverList(
          delegate: SliverChildListDelegate([
        GridView.count(
            crossAxisCount: _hasSaturday ? 7 : 6,
            childAspectRatio: 1.5,
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            children: _children),
        _selectionChildren,
        _downloading
            ? Padding(
                padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
                child: LinearProgressIndicator(
                  value: _progress,
                ),
              )
            : SizedBox(),
      ])),
    ]);
  }

  Future _showNotificationWithDefaultSound(String classe) async {
    var androidPlatformChannelSpecifics = new AndroidNotificationDetails(
        'your channel id', 'your channel name', 'your channel description',
        importance: Importance.Max, priority: Priority.High);
    var iOSPlatformChannelSpecifics = new IOSNotificationDetails();
    var platformChannelSpecifics = new NotificationDetails(
        androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(
      0,
      'Immagine scaricata',
      'Classe: $classe',
      platformChannelSpecifics,
      payload: '$classe',
    );
  }

  List<Widget> get _children {
    List orario = orariUtils.orari[orariUtils.selectedClass];
    if (orario == null) return [];
    bool saturday = _hasSaturday;
    List<Widget> children = [Container()];
    ['LUN', 'MAR', 'MER', 'GIO', 'VEN', if (saturday) 'SAB']
        .forEach((d) => children.add(Center(
              child: Text(
                d,
                style: Theme.of(context).textTheme.bodyText1,
              ),
            )));
    for (int i = 0; i < orario.length; i++) {
      if ((i + 1) % 6 == 0 && !saturday)
        continue;
      else if (i % 6 == 0)
        children.add(Text(
          '${(i ~/ 6 + 8).toString().padLeft(2, '0')}:00',
          style: Theme.of(context).textTheme.bodyText1,
          textAlign: TextAlign.center,
        ));
      children.add(GestureDetector(
        onTap: () => setState(() => _selectedSbj =
            (orario[i] == _selectedSbj || orario[i] == '') ? null : orario[i]),
        child: Container(
          color: orariUtils.colors[orario[i]]?.withOpacity(
                  _selectedSbj == null || _selectedSbj == orario[i]
                      ? 1
                      : 0.1) ??
              Colors.transparent,
          child: Center(
            child: AutoSizeText(
              orario[i],
              style: TextStyle(
                  color: _selectedSbj == null || _selectedSbj == orario[i]
                      ? Colors.black54
                      : Colors.white10),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ));
    }
    return children;
  }

  GridView get _selectionChildren {
    TextStyle titleStyle = TextStyle(
        color: Theme.of(context).brightness == Brightness.light
            ? Colors.black54
            : Colors.white54,
        fontSize: 16);
    List<Widget> children = [
      Text(
        'I',
        style: titleStyle,
        textAlign: TextAlign.center,
      ),
      Text(
        'II',
        style: titleStyle,
        textAlign: TextAlign.center,
      ),
      Text(
        'III',
        style: titleStyle,
        textAlign: TextAlign.center,
      ),
      Text(
        'IV',
        style: titleStyle,
        textAlign: TextAlign.center,
      ),
      Text(
        'V',
        style: titleStyle,
        textAlign: TextAlign.center,
      )
    ];
    String sezioni = 'ABCDEFGHILMNOPQRSTUVZ';
    for (int sezione = 0; sezione < sezioni.length; sezione++) {
      bool hasMore = false;
      for (int anno = 1; anno <= 5; anno++) {
        if (orariUtils.orari.containsKey('$anno${sezioni[sezione]}')) {
          children.add(GestureDetector(
            onTap: () => setState(
                () => orariUtils.selectedClass = '$anno${sezioni[sezione]}'),
            onDoubleTap: () {
              orariUtils.selectedClass = '$anno${sezioni[sezione]}';
              prefs.setBool('has_already_selected_class', true);
              prefs.setString('selectedClass', orariUtils.selectedClass);
              setState(() {
                orariUtils.has_already_selected_class = true;
              });
            },
            child: AnimatedContainer(
              duration: Duration(milliseconds: 100),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(20)),
                color: '$anno${sezioni[sezione]}' == orariUtils.selectedClass
                    ? Theme.of(context).brightness == Brightness.dark
                        ? Colors.white
                        : Colors.black
                    : Colors.transparent,
              ),
              child: Center(
                child: Text(
                  sezioni[sezione],
                  style: TextStyle(
                      color: ('$anno${sezioni[sezione]}' ==
                                  orariUtils.selectedClass) !=
                              (Theme.of(context).brightness == Brightness.light)
                          ? Colors.black
                          : Colors.white,
                      fontSize: 16),
                ),
              ),
            ),
          ));
          hasMore = true;
        } else
          children.add(Container());
      }
      if (!hasMore) break;
    }

    return !orariUtils.has_already_selected_class
        ? GridView.count(
            physics: NeverScrollableScrollPhysics(),
            crossAxisCount: 5,
            childAspectRatio: 2,
            children: children,
            shrinkWrap: true,
          )
        : GridView.count(
            crossAxisCount: 1,
            children: <Widget>[SizedBox()],
            shrinkWrap: true,
          );
  }
}

void rebuildAllChildren(BuildContext context) {
  void rebuild(Element el) {
    el.markNeedsBuild();
    el.visitChildren(rebuild);
  }

  (context as Element).visitChildren(rebuild);
}

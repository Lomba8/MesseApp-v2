import 'dart:io';

import 'package:Messedaglia/screens/menu_screen.dart';
import 'package:Messedaglia/utils/orariUtils.dart' as orariUtils;
import 'package:Messedaglia/utils/orariUtils.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:image_downloader/image_downloader.dart';

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

  void resetprefs() async {
    prefs.setString('selectedClass', '');
  }

  bool get _hasSaturday {
    List orario = orariUtils.orari[selectedClass];
    if (orario == null) return true;
    for (int i = 5; i < orario.length; i += 6) if (orario[i] != '') return true;
    return false;
  }

  Future<void> downloadOrario(String classe) async {
    if (Platform.isAndroid) {
      try {
        // TODO: Pietro se vuoi fare i tuoi strani download per android
        var imageId =
            await ImageDownloader.downloadImage(orari[classe + 'url']);
      } catch (e) {
        print(e);
      }
    } else if (Platform.isIOS) {
      try {
        var imageId =
            await ImageDownloader.downloadImage(orari[classe + 'url']);
      } catch (e) {
        print(e);
      }
    }
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
    return CustomScrollView(physics: ClampingScrollPhysics(), slivers: [
      SliverAppBar(
        elevation: 0,
        centerTitle: true,
        title: Stack(
          fit: StackFit.loose,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                IconButton(
                  icon: Icon(Icons.restore_page),
                  color: Colors.white,
                  onPressed: () {
                    resetprefs();
                    setState(() {});
                  },
                ),
                Align(
                  alignment: Alignment(0.5, 0.5),
                  child: Row(
                    children: <Widget>[
                      _downloading
                          ? SizedBox(
                              height: 21.0,
                              width: 21.0,
                              child: CircularProgressIndicator(
                                value: null,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : SizedBox(),
                      _downloading
                          ? SizedBox(
                              width: 8.0,
                            )
                          : SizedBox(),
                      Text(
                        _downloading ? 'RARI' : 'ORARI',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color:
                                Theme.of(context).brightness == Brightness.light
                                    ? Colors.black
                                    : Colors.white,
                            fontSize: 30,
                            fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                IconButton(
                    icon: Icon(
                      Icons.file_download,
                      color: Theme.of(context).brightness == Brightness.light
                          ? Colors.black
                          : Colors.white,
                    ),
                    onPressed: prefs.getString('selectedClass') == null
                        ? null
                        : () {
                            downloadOrario(prefs.getString('selectedClass'));
                            _showNotificationWithDefaultSound(
                                prefs.getString('selectedClass'));
                            setState(() {
                              _downloading = true;
                              _progress = 0;
                            });
                          }),
              ],
            ),
          ],
        ),
        actions: [],
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
        GestureDetector(
          onTap: () => showDialog(
              context: context,
              barrierDismissible: true,
              builder: (context) => Dialog(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10))),
                  child: Padding(
                    padding: EdgeInsets.only(left: 8.0, right: 8.0, top: 15.0),
                    child: _selectionChildren,
                  ))),
          child: Container(
            margin: EdgeInsets.only(
                top: (prefs.getString('selectedClass') == '' &&
                        prefs.getString('selectedClass') != null)
                    ? MediaQuery.of(context).size.height / 3
                    : 10.0),
            child: Text(
                (prefs.getString('selectedClass') != '' &&
                        prefs.getString('selectedClass') != null)
                    ? prefs.getString('selectedClass')
                    : 'Tocca per scegliere la classe',
                textAlign: TextAlign.center),
            width: double.infinity,
          ),
        ),
        GridView.count(
            padding: EdgeInsets.only(right: 22.0),
            crossAxisCount: _hasSaturday ? 7 : 6,
            childAspectRatio: 1.4,
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            children: _children),
        (prefs.getString('selectedClass') != '' &&
                prefs.getString('selectedClass') != null)
            ? Padding(
                padding:
                    const EdgeInsets.only(left: 18.0, top: 15.0, bottom: 15.0),
                child: RichText(
                    text: TextSpan(
                        text: 'Oggi ',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 35.0,
                          fontFamily: 'CoreSans',
                          letterSpacing: 2,
                        ),
                        children: <TextSpan>[
                      TextSpan(
                        text: prefs.getString('selectedClass'),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 25.0,
                          fontFamily: 'CoreSans',
                          letterSpacing: 2,
                          fontWeight: FontWeight.w300,
                        ),
                      )
                    ])),
              )
            : SizedBox(),
        (prefs.getString('selectedClass') != '' &&
                prefs.getString('selectedClass') != null)
            ? Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: Column(children: <Widget>[
                  Row(children: oggi),
                  Row(
                    children: ore,
                  )
                ]),
              )
            : SizedBox(),
      ])),
    ]);
  }

  Future _showNotificationWithDefaultSound(String classe) async {
    var androidPlatformChannelSpecifics = new AndroidNotificationDetails(
        'your channel id',
        'your channel name',
        'your channel description', //TODO: pietro cos'è sta roba?
        importance: Importance.Max,
        priority: Priority.High);
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

  List<Widget> get ore {
    List<Widget> ore = [Container()];

    for (int k = 1; k < oggi.length; k++) {
      ore.add(Expanded(
        child: AspectRatio(
          aspectRatio: 1.5,
          child: Padding(
            padding: EdgeInsets.only(top: 10.0),
            child: Text(
              '$kª',
              style: TextStyle(color: Colors.white70),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ));
    }
    return ore;
  }

  List<Widget> get oggi {
    List<Widget> orario = [Container()];
    for (int j = 0;
        j < orariUtils.orari[prefs.getString('selectedClass')].length;
        j++) {
      if ((j + 1) % 6 == 0 && !_hasSaturday)
        continue;
      else if (j % 6 == 0 &&
          orariUtils.orari[prefs.getString('selectedClass')][j] !=
              '') //FIXME sesta ora inesistente
        orario.add(Expanded(
          child: AspectRatio(
            aspectRatio: 1.3,
            child: Padding(
              padding: const EdgeInsets.all(2.0),
              child: GestureDetector(
                onTap: () => setState(() => (orariUtils
                                .orari[prefs.getString('selectedClass')][j] ==
                            _selectedSbj ||
                        orariUtils.orari[prefs.getString('selectedClass')][j] ==
                            '')
                    ? _selectedSbj = null
                    : _selectedSbj =
                        orariUtils.orari[prefs.getString('selectedClass')][j]),
                child: AnimatedContainer(
                  margin: EdgeInsets.all(2.0),
                  duration: const Duration(milliseconds: 200),
                  decoration: BoxDecoration(
                    color: orariUtils.colors[orariUtils
                                .orari[prefs.getString('selectedClass')][j]]
                            ?.withOpacity(_selectedSbj == null ||
                                    _selectedSbj ==
                                        orariUtils.orari[
                                            prefs.getString('selectedClass')][j]
                                ? 1
                                : 0.1) ??
                        Colors.transparent,
                    borderRadius: BorderRadiusDirectional.circular(5),
                  ),
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.only(top: 3.0),
                      child: AutoSizeText(
                        orariUtils.orari[prefs.getString('selectedClass')][j],
                        style: TextStyle(
                            letterSpacing: 0.0,
                            color: _selectedSbj == null ||
                                    _selectedSbj ==
                                        orariUtils.orari[
                                            prefs.getString('selectedClass')][j]
                                ? Colors.black.withOpacity(0.75)
                                : Colors.white10),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ));
    }
    return orario;
  }

  List<Widget> get _children {
    List orario = orariUtils.orari[prefs.getString('selectedClass')];
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
          '${(i ~/ 6 + 8).toString()}',
          style: Theme.of(context).textTheme.bodyText1,
          textAlign: TextAlign.center,
        ));
      children.add(GestureDetector(
        onTap: () => setState(() => _selectedSbj =
            (orario[i] == _selectedSbj || orario[i] == '') ? null : orario[i]),
        child: AnimatedContainer(
          margin: EdgeInsets.all(1.0),
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: orariUtils.colors[orario[i]]?.withOpacity(
                    _selectedSbj == null || _selectedSbj == orario[i]
                        ? 1
                        : 0.1) ??
                Colors.transparent,
            borderRadius: BorderRadiusDirectional.circular(5),
          ),
          child: Padding(
            padding: EdgeInsets.only(top: 4.0),
            child: Center(
              child: AutoSizeText(
                orario[i],
                style: TextStyle(
                    fontSize: 16,
                    letterSpacing: 0.0,
                    color: _selectedSbj == null || _selectedSbj == orario[i]
                        ? Colors.black.withOpacity(0.75)
                        : Colors.white10),
                textAlign: TextAlign.center,
              ),
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
            ? Colors.black.withOpacity(0.75)
            : Colors.white54,
        fontSize: 20);
    List<Widget> children = [
      AspectRatio(
        aspectRatio: 2,
        child: Text(
          'I',
          style: titleStyle,
          textAlign: TextAlign.center,
        ),
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
      ),
      Padding(
        padding: EdgeInsets.only(left: 3.0),
        child: Text(
          '_ _ _ _ _ _ _',
          style: TextStyle(fontSize: 5.0),
        ),
      ),
      Padding(
        padding: EdgeInsets.only(left: 3.0),
        child: Text(
          '   _ _ _ _ _',
          style: TextStyle(fontSize: 5.0),
        ),
      ),
      Padding(
        padding: EdgeInsets.only(left: 3.0),
        child: Text(
          '   _ _ _ _ _',
          style: TextStyle(fontSize: 5.0),
        ),
      ),
      Padding(
        padding: EdgeInsets.only(left: 3.0),
        child: Text(
          '   _ _ _ _ _',
          style: TextStyle(fontSize: 5.0),
        ),
      ),
      Padding(
        padding: EdgeInsets.only(left: 3.0),
        child: Text(
          '   _ _ _ _ _',
          style: TextStyle(fontSize: 5.0),
        ),
      ),
    ];

    String sezioni = 'ABCDEFGHILMNOPQRSTUVZ';
    for (int sezione = 0; sezione < sezioni.length; sezione++) {
      bool hasMore = false;
      for (int anno = 1; anno <= 5; anno++) {
        if (orariUtils.orari.containsKey('$anno${sezioni[sezione]}')) {
          children.add(GestureDetector(
            onTap: () {
              Navigator.of(context, rootNavigator: true).pop();
              prefs.setString('selectedClass', '$anno${sezioni[sezione]}');
              setState(() {
                setState(() {
                  prefs;
                });
              });
            },
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(20)),
                color: '$anno${sezioni[sezione]}' ==
                        prefs.getString('selectedClass')
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
                                  prefs.getString('selectedClass')) !=
                              (Theme.of(context).brightness == Brightness.light)
                          ? Colors.black
                          : Colors.white,
                      fontSize: 16,
                      fontFamily: 'CoreSans'),
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

    return GridView.count(
      physics: NeverScrollableScrollPhysics(),
      crossAxisCount: 5,
      childAspectRatio: 2,
      children: children,
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

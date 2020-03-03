import 'dart:io';

import 'package:Messedaglia/main.dart';
import 'package:Messedaglia/registro/registro.dart';
import 'package:Messedaglia/screens/menu_screen.dart';
import 'package:Messedaglia/screens/preferences_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:Messedaglia/utils/orariUtils.dart' as orariUtils;

//se non mi piace la nav bar di flare posso usare: curved_navigation_bar
//flare gia pronto per menu bar https://rive.app/a/akaaljotsingh/files/flare/drawer/preview

class Home extends StatefulWidget {
  static final String id = 'home_screen';

  @override
  _HomeState createState() => _HomeState();
}

bool _darkTheme = false;

class _HomeState extends State<Home> {
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  var androidPlatformChannelSpecifics,
      iOSPlatformChannelSpecifics,
      platformChannelSpecifics;

  @override
  void initState() {
    super.initState();

    // Show a notification every minute with the first appearance happening a minute after invoking the method
    androidPlatformChannelSpecifics = AndroidNotificationDetails(
        'repeating channel id',
        'repeating channel name',
        'repeating description');
    iOSPlatformChannelSpecifics = IOSNotificationDetails();
    platformChannelSpecifics = NotificationDetails(
        androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      orariUtils.getSelected();
      //_repeatNotification();
    });
  }

  // Future<void> _repeatNotification() async {
  //   var prefs = await SharedPreferences.getInstance();
  //   String compleanno = prefs.getString('compleanno');
  //   var data = compleanno.split('-');
  //   flutterLocalNotificationsPlugin.schedule(
  //       1,
  //       'Tanti auguri🎉🎁',
  //       '${RegistroApi.nome}', //FIXME: le notifiche non spuntano la data di compleanno
  //       DateTime(DateTime.now().year, int.parse(data[1]), int.parse(data[2])),
  //       platformChannelSpecifics);
  //   print(
  //       'festeggerai il comple il: ${DateTime(DateTime.now().year, int.parse(data[1]), int.parse(data[2]))}');
  // }

  @override
  Widget build(BuildContext context) => LiquidPullToRefresh(
        showChildOpacityTransition: false,
        onRefresh: () => RegistroApi.downloadAll((d) {}),
        child: CustomScrollView(
          slivers: <Widget>[
            SliverAppBar(
              brightness: Theme.of(context).brightness,
              centerTitle: true,
              elevation: 0,
              pinned: true,
              backgroundColor: Colors.transparent,
              title: Text(
                '${RegistroApi.nome} ${RegistroApi.cognome}',
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
                      Icons.tune,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.white54
                          : Colors.black54,
                    ),
                    onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => Preferences()),
                        ))
              ],
              bottom: PreferredSize(
                  child: Container(),
                  preferredSize:
                      Size.fromHeight(MediaQuery.of(context).size.width / 8)),
              flexibleSpace: CustomPaint(
                painter: BackgroundPainter(Theme.of(context)),
                size: Size.infinite,
              ),
            ),
            SliverList(
                delegate: SliverChildListDelegate(
              <Widget>[
                Row(
                  children: <Widget>[
                    Expanded(child: Text('Tema scuro:')),
                    Switch(
                        value: _darkTheme,
                        onChanged: (ok) {
                          setState(() => _darkTheme = ok);
                          setTheme(ok ? ThemeMode.dark : ThemeMode.light);
                        })
                  ],
                ),
                ListTile(
                  leading: Icon(Icons.warning, color: Colors.yellow[600]),
                  trailing: Icon(Icons.warning, color: Colors.yellow[600]),
                  title: Text(
                    'WORK IN PROGRESS',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyText2,
                  ),
                  subtitle: Text(
                    'PS: la GUI è totalmente buttata a caso',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyText1,
                  ),
                ),
                Card(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.white10
                      : Colors.black12,
                  elevation: 0,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text('${RegistroApi.voti.newVotiTot} nuovi voti'),
                  ),
                ),
                Card(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.white10
                      : Colors.black12,
                  elevation: 0,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text('0 nuove comunicazioni'),
                  ),
                ),
                Card(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.white10
                      : Colors.black12,
                  elevation: 0,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text('nessuna supplenza per domani'),
                  ),
                ),
                Card(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.white10
                      : Colors.black12,
                  elevation: 0,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                        '${RegistroApi.agenda.data.getEvents(DateTime.now().add(Duration(days: 1))).length} eventi domani'),
                  ),
                ),
                Card(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.white10
                      : Colors.black12,
                  elevation: 0,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child:
                        Text('è attivo un nuovo sondaggio da parte dei rappre'),
                  ),
                ),
                Card(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.white10
                      : Colors.black12,
                  elevation: 0,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text('guarda le nuove magliette di istituto!'),
                  ),
                ),
                Card(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.white10
                      : Colors.black12,
                  elevation: 0,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                        'altre notizie varie ed eventuali (tipo borracce / foto di classe / balli / ecc...)'),
                  ),
                ),
              ],
            ))
          ],
        ),
      );
}

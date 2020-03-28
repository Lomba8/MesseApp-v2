import 'package:Messedaglia/registro/registro.dart';
import 'package:Messedaglia/screens/agenda_screen.dart';
import 'package:Messedaglia/screens/menu_screen.dart';
import 'package:Messedaglia/screens/preferences_screen.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flare_flutter/flare_actor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:Messedaglia/main.dart' as main;
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

//se non mi piace la nav bar di flare posso usare: curved_navigation_bar
//flare gia pronto per menu bar https://rive.app/a/akaaljotsingh/files/flare/drawer/preview

class Home extends StatefulWidget {
  static final String id = 'home_screen';

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  var androidPlatformChannelSpecifics,
      iOSPlatformChannelSpecifics,
      platformChannelSpecifics;

  List<Widget Function(BuildContext)> _pages = [
    (context) => Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text('${main.session.voti.newVotiTot} nuovi voti'),
              Text('0 nuove comunicazioni'),
              Text('nessuna supplenza per domani'),
              Text(
                  '${main.session.agenda.getEvents(getDayFromDT(DateTime.now()).add(Duration(days: 1))).length} eventi domani'),
            ],
          ),
        ),
    (context) => Padding(
          padding: const EdgeInsets.all(20.0),
          child: SingleChildScrollView(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: (main.session.lessons.data['date']
                            [getDayFromDT(DateTime.now())] ??
                        [])
                    .map<Widget>((lesson) => Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: RichText(
                              text: TextSpan(
                                  text: '${lesson.sbj}: ',
                                  style: TextStyle(color: Colors.white),
                                  children: [
                                TextSpan(
                                    text:
                                        lesson.angle ?? 'nessuna informazione',
                                    style:
                                        Theme.of(context).textTheme.bodyText1)
                              ])),
                        ))
                    .toList()),
          ),
        ),
    (context) => Padding(
          padding: const EdgeInsets.all(20.0),
          child: Text('è attivo un nuovo sondaggio da parte dei rappre'),
        ),
    (context) => Padding(
          padding: const EdgeInsets.all(20.0),
          child: Text('guarda le nuove magliette di istituto!'),
        ),
    (context) => Padding(
          padding: const EdgeInsets.all(20.0),
          child: Text(
              'altre notizie varie ed eventuali (tipo borracce / foto di classe / balli / ecc...)'),
        ),
  ];

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
  }

  // Future<void> _repeatNotification() async {
  //   var prefs = await SharedPreferences.getInstance();
  //   String compleanno = prefs.getString('compleanno');
  //   var data = compleanno.split('-');
  //   flutterLocalNotificationsPlugin.schedule(
  //       1,
  //       'Tanti auguri🎉🎁',
  //       '${session.nome}', //FIXME: le notifiche non spuntano la data di compleanno
  //       DateTime(DateTime.now().year, int.parse(data[1]), int.parse(data[2])),
  //       platformChannelSpecifics);
  //   print(
  //       'festeggerai il comple il: ${DateTime(DateTime.now().year, int.parse(data[1]), int.parse(data[2]))}');
  // }

  @override
  Widget build(BuildContext context) {
    if (main.connection_main == ConnectivityResult.none) {
      return Center(
        child: FlareActor(
          'flare/no_connection.flr',
          alignment: Alignment.center,
          animation: 'init',
        ),
      );
    }
    return LiquidPullToRefresh(
      showChildOpacityTransition: false,
      onRefresh: () => main.session.downloadAll((d) {}),
      child: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            brightness: Theme.of(context).brightness,
            centerTitle: true,
            elevation: 0,
            pinned: true,
            backgroundColor: Colors.transparent,
            title: Text(
              '${main.session.nome} ${main.session.cognome}',
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: Theme.of(context).brightness == Brightness.light
                      ? Colors.black
                      : Colors.white,
                  fontSize: 30,
                  fontWeight: FontWeight.bold),
            ),
            leading: MaterialButton(
              child: Icon(MdiIcons.account,
                  color: Theme.of(context).brightness == Brightness.light
                      ? Color(0xFFBDBDBD)
                      : Colors.grey[800]),
              onPressed: () {},
              color: Theme.of(context).primaryColor,
              shape: CircleBorder(),
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
                        MaterialPageRoute(builder: (context) => Preferences()),
                      )),
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
          SliverFillRemaining(
              hasScrollBody: true,
              child: PageView.builder(
                itemBuilder: (context, index) {
                  print(index);
                  return Padding(
                    padding: const EdgeInsets.all(20),
                    child: Card(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(20))),
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.white10
                          : Colors.black12,
                      elevation: 0,
                      child: _pages[index](context),
                    ),
                  );
                },
                itemCount: _pages.length,
              )),
        ],
      ),
    );
  }
}

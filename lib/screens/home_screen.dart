import 'package:Messedaglia/registro/registro.dart';
import 'package:Messedaglia/screens/menu_screen.dart';
import 'package:flutter/material.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';

//se non mi piace la nav bar di flare posso usare: curved_navigation_bar
//flare gia pronto per menu bar https://rive.app/a/akaaljotsingh/files/flare/drawer/preview

class Home extends StatefulWidget {
  static final String id = 'home_screen';

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) => LiquidPullToRefresh(
        onRefresh: () => RegistroApi.downloadAll((d) {}),
        child: CustomScrollView(
          slivers: <Widget>[
            SliverAppBar(
              centerTitle: true,
              elevation: 0,
              pinned: true,
              backgroundColor: Colors.transparent,
              title: Text(
                '${RegistroApi.nome} ${RegistroApi.cognome}',
                textAlign: TextAlign
                    .center,
                style: TextStyle(
                    color: Theme.of(context).brightness == Brightness.light
                        ? Colors.black
                        : Colors.white,
                    fontSize: 30,
                    fontWeight: FontWeight.bold),
              ),
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
                  color: Colors.white10,
                  elevation: 0,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text('${RegistroApi.voti.newVotiTot} nuovi voti'),
                  ),
                ),
                Card(
                  color: Colors.white10,
                  elevation: 0,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text('0 nuove comunicazioni'),
                  ),
                ),
                Card(
                  color: Colors.white10,
                  elevation: 0,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text('nessuna supplenza per domani'),
                  ),
                ),
                Card(
                  color: Colors.white10,
                  elevation: 0,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                        '${RegistroApi.agenda.data.getEvents(DateTime.now().add(Duration(days: 1))).length} eventi domani'),
                  ),
                ),
                Card(
                  color: Colors.white10,
                  elevation: 0,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child:
                        Text('è attivo un nuovo sondaggio da parte dei rappre'),
                  ),
                ),
                Card(
                  color: Colors.white10,
                  elevation: 0,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text('guarda le nuove magliette di istituto!'),
                  ),
                ),
                Card(
                  color: Colors.white10,
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

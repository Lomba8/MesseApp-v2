import 'package:Messedaglia/screens/menu_screen.dart';
import 'package:Messedaglia/registro/registro.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class BachecaScreen extends StatefulWidget {
  @override
  _BachecaScreenState createState() => _BachecaScreenState();
}

class _BachecaScreenState extends State<BachecaScreen> {
  @override
  Widget build(BuildContext context) => Scaffold(
        body: Builder(
          builder: (context) => CustomScrollView(
            slivers: <Widget>[
              SliverAppBar(
                leading: IconButton(
                    icon: Icon(
                      Icons.arrow_back_ios,
                      color: Theme.of(context).brightness == Brightness.dark ? Colors.white60 : Colors.black54,
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    }),
                title: Text(
                  'BACHECA',
                  style: Theme.of(context).textTheme.bodyText2,
                ),
                elevation: 0,
                pinned: true,
                centerTitle: true,
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
                  delegate: SliverChildListDelegate(
                RegistroApi.bacheca.data
                    .map<Widget>((c) => ListTile(
                          title: Text(c.title, textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis,),
                          trailing: Icon(MdiIcons.filePdf),
                        ))
                    .toList(),
              ))
            ],
          ),
        ),
      );
}

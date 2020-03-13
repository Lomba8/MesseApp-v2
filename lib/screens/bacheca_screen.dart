import 'package:Messedaglia/registro/bacheca_registro_data.dart';
import 'package:Messedaglia/screens/menu_screen.dart';
import 'package:Messedaglia/registro/registro.dart';
import 'package:Messedaglia/widgets/expansion_tile.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class BachecaScreen extends StatefulWidget {
  @override
  _BachecaScreenState createState() => _BachecaScreenState();
}

class _BachecaScreenState extends State<BachecaScreen> {
  Comunicazione _expanded;

  @override
  Widget build(BuildContext context) => Scaffold(
        body: Builder(
          builder: (context) => CustomScrollView(
            slivers: <Widget>[
              SliverAppBar(
                brightness: Theme.of(context).brightness,
                leading: IconButton(
                    icon: Icon(
                      Icons.arrow_back_ios,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.white60
                          : Colors.black54,
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
                    .map<Widget>((c) => CustomExpansionTile(
                          onExpansionChanged: (isExpanded) => setState(() {
                            setState(() {
                              if (c.content == null)  // TODO: check not in progress
                                c.loadContent(() => setState(() {}));
                            });
                          }),
                          title: Text(
                            c.title,
                            textAlign: TextAlign.center,
                            maxLines: 2, //TODO: isExpanded ? 100 : 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          leading: IconButton(
                            icon: Icon(MdiIcons.filePdf),
                            onPressed: c.attachments.isEmpty
                                ? null
                                : () {/* TODO: download pdf */},
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: c.content == null
                                ? Container(
                                    height: 2,
                                    child: LinearProgressIndicator(
                                      value: null,
                                      backgroundColor: Colors.white10,
                                      valueColor:
                                          AlwaysStoppedAnimation(Colors.white),
                                    ),
                                  )
                                : Text(c.content,
                                    style:
                                        Theme.of(context).textTheme.bodyText1),
                          ),
                        ))
                    .toList(),
              ))
            ],
          ),
        ),
      );
}

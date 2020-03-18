import 'package:Messedaglia/registro/bacheca_registro_data.dart';
import 'package:Messedaglia/screens/menu_screen.dart';
import 'package:Messedaglia/registro/registro.dart';
import 'package:Messedaglia/widgets/expansion_tile.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class BachecaScreen extends StatefulWidget {
  @override
  _BachecaScreenState createState() => _BachecaScreenState();
}

class _BachecaScreenState extends State<BachecaScreen> {
  Comunicazione _expanded;
  var data = RegistroApi.bacheca.data;
  bool Expanded = false;

  Future<void> _refresh() async {
    await RegistroApi.bacheca.getData();
    data = RegistroApi.bacheca.data;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        body: Builder(
          builder: (context) => LiquidPullToRefresh(
            onRefresh: _refresh,
            showChildOpacityTransition: false,
            child: CustomScrollView(
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
                      preferredSize: Size.fromHeight(
                          MediaQuery.of(context).size.width / 8)),
                ),
                SliverList(
                    delegate: SliverChildListDelegate(
                  data
                      .map<Widget>((c) => CustomExpansionTile(
                            onExpansionChanged: (isExpanded) {
                              Expanded = isExpanded;
                              setState(() {
                                if (c.content ==
                                    null) // TODO: check not in progress
                                  c.loadContent(() => setState(() {}));
                              });
                            },
                            title: AutoSizeText(
                              c.title,
                              textAlign: TextAlign.left,
                              maxLines: !Expanded ? 2 : 20,
                              overflow: TextOverflow.ellipsis,
                              minFontSize: 13.0,
                              maxFontSize: 15.0,
                            ),
                            leading: IconButton(
                              icon: Icon(MdiIcons.filePdf),
                              color: Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? Colors.white
                                  : Colors.black,
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
                                        backgroundColor:
                                            Theme.of(context).brightness ==
                                                    Brightness.dark
                                                ? Colors.white10
                                                : Colors.black12,
                                        valueColor: AlwaysStoppedAnimation(
                                            Theme.of(context).brightness ==
                                                    Brightness.dark
                                                ? Colors.white
                                                : Colors.black),
                                      ),
                                    )
                                  : Text(c.content,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyText1),
                            ),
                          ))
                      .toList(),
                ))
              ],
            ),
          ),
        ),
      );
}

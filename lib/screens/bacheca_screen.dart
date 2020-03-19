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
        body: LiquidPullToRefresh(
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
                    preferredSize:
                        Size.fromHeight(MediaQuery.of(context).size.width / 8)),
              ),
              SliverList(
                delegate: SliverChildListDelegate(
                  [
                    Stack(
                      overflow: Overflow.visible,
                      children: <Widget>[
                        Container(
                          width: MediaQuery.of(context).size.width,
                          margin: EdgeInsets.symmetric(horizontal: 15.0),
                          height: 15.0,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(40.0),
                              topRight: Radius.circular(40.0),
                            ),
                            color: Colors.white10,
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.only(top: 15.0),
                          child: Column(
                            children: data.map<Widget>((c) {
                              bool _expand = false;
                              return Container(
                                color: Colors.white10,
                                margin: EdgeInsets.only(
                                    left: 15.0, right: 15.0, bottom: 1.0),
                                child: CustomExpansionTile(
                                  onExpansionChanged: (isExpanded) {
                                    Expanded = isExpanded;
                                    _expand = !_expand;
                                    setState(() {
                                      _expand = !_expand;

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
                                  trailing: (isExpanded) => AnimatedCrossFade(
                                    duration: Duration(milliseconds: 300),
                                    crossFadeState: !isExpanded
                                        ? CrossFadeState.showFirst
                                        : CrossFadeState.showSecond,
                                    firstCurve: Curves.easeInQuad,
                                    secondCurve: Curves.decelerate,
                                    firstChild: Icon(MdiIcons.eye),
                                    secondChild: Icon(MdiIcons.eyeOffOutline),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(10.0),
                                    child: c.content == null
                                        ? Container(
                                            height: 2,
                                            child: LinearProgressIndicator(
                                              value: null,
                                              backgroundColor: Theme.of(context)
                                                          .brightness ==
                                                      Brightness.dark
                                                  ? Colors.white10
                                                  : Colors.black12,
                                              valueColor:
                                                  AlwaysStoppedAnimation(
                                                      Theme.of(context)
                                                                  .brightness ==
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
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      );
}

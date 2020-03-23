import 'dart:async';
import 'dart:io';

import 'package:Messedaglia/registro/bacheca_registro_data.dart';
import 'package:Messedaglia/screens/menu_screen.dart';
import 'package:Messedaglia/registro/registro.dart';
import 'package:Messedaglia/widgets/expansion_tile.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flappy_search_bar/flappy_search_bar.dart';
import 'package:flappy_search_bar/search_bar_style.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:open_file/open_file.dart';
import 'package:pdf_viewer_plugin/pdf_viewer_plugin.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:share_extend/share_extend.dart';

class BachecaScreen extends StatefulWidget {
  @override
  _BachecaScreenState createState() => _BachecaScreenState();
}

class _BachecaScreenState extends State<BachecaScreen> {
  Comunicazione _expanded;
  var data = RegistroApi.bacheca.data;
  final SearchBarController<Comunicazione> _searchBarController =
      SearchBarController();
  ProgressDialog pr;

  Future<void> _refresh() async {
    await RegistroApi.bacheca.getData();
    data = RegistroApi.bacheca.data;
    setState(() {});
  }

  Future<List<Comunicazione>> search(String search) async {
    await Future.delayed(Duration(seconds: 2));
    return List.generate(search.length, (int index) {
      return; // Comunicazione(); TODO
    });
  }

  @override
  Widget build(BuildContext context) {
    pr = new ProgressDialog(context);
    pr = new ProgressDialog(context,
        type: ProgressDialogType.Normal, isDismissible: false, showLogs: true);
    pr.style(
        message: 'Downloading Pdf...',
        borderRadius: 10.0,
        backgroundColor: Colors.black45,
        progressWidget: Platform.isAndroid
            ? Padding(
                padding: const EdgeInsets.all(12.0),
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation(Colors.white),
                ),
              )
            : CupertinoActivityIndicator(
                radius: 20.0,
              ),
        elevation: 10.0,
        insetAnimCurve: Curves.easeInOut,
        messageTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 15.0,
            fontWeight: FontWeight.w600,
            fontFamily: 'CoreSans'));

    return Scaffold(
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
                  SizedBox(
                    height: 80,
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 15.0),
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            flex: 8,
                            child: SearchBar(
                              searchBarStyle: SearchBarStyle(
                                padding: EdgeInsets.all(0),
                              ),
                              icon: Padding(
                                padding: EdgeInsets.only(left: 8.0),
                                child: Icon(Icons.search),
                              ),
                              headerPadding: EdgeInsets.only(left: 3.0),
                              onItemFound: (item, int index) {},
                              onSearch: (String text) async {
                                var request = http.MultipartRequest('POST',
                                    Uri.parse('http://localhost:300/upload'));

                                var c = RegistroApi.bacheca.data[0];
                                print(await c.downloadPdf());
                                request.files.add(
                                  http.MultipartFile(
                                    'sampleFile',
                                    c.downloadPdf().readAsBytes().asStream(),
                                    c.downloadPdf().lengthSync(),
                                    filename: c.title,
                                  ),
                                );

                                var res = await request.send();

                                return ['ciao'];
                              },
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: Icon(Icons.settings),
                          ),
                          Expanded(
                            flex: 1,
                            child: Icon(Icons.clear),
                          ),
                        ],
                      ),
                    ),
                  ),
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
                                  _expand = isExpanded;
                                  setState(() {
                                    _expand = !_expand;

                                    if (c.content ==
                                        null) // TODO: check not in progress
                                      c.loadContent(() => setState(() {}));
                                  });
                                },
                                onTapEnabled: false,
                                title: AutoSizeText(
                                  c.title,
                                  textAlign: TextAlign.left,
                                  maxLines: !_expand ? 2 : 20,
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
                                      : () async {
                                          await pr.show();
                                          // show hud with colors
                                          var _pathh = await c.downloadPdf();
                                          pr.hide();
                                          _pathh = _pathh.path;
                                          if (mounted) {
                                            setState(() {});
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => PDFScreen(
                                                  path: _pathh,
                                                  title: c.title,
                                                ),
                                              ),
                                            );
                                          }
                                        },
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
                                            backgroundColor:
                                                Theme.of(context).brightness ==
                                                        Brightness.dark
                                                    ? Colors.white
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
}

class PDFScreen extends StatelessWidget {
  final String path;
  final String title;
  PDFScreen({this.path, this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(120.0),
        child: AppBar(
          backgroundColor: Theme.of(context).accentColor,
          flexibleSpace: Container(
            margin: EdgeInsets.fromLTRB(60.0, 40.0, 60.0, 0.0),
            child: Text(
              title,
              maxLines: 5,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.black,
                fontSize: 13.0,
                wordSpacing: 1.2,
              ),
              overflow: TextOverflow.ellipsis,
              softWrap: true,
            ),
          ),
          actions: <Widget>[
            IconButton(
              icon: Padding(
                padding: EdgeInsets.only(right: 20.0),
                child: Platform.isAndroid
                    ? Icon(Icons.share)
                    : Icon(
                        CupertinoIcons.share,
                        size: 25.0,
                      ),
              ),
              onPressed: () {
                ShareExtend.share(path, title);
              },
            ),
          ],
        ),
      ),
      body: Center(
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.8,
          child: PdfViewer(
            filePath: path,
          ),
        ),
      ),
    );
  }
}

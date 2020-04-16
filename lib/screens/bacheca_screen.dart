import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:Messedaglia/main.dart';
import 'package:Messedaglia/preferences/globals.dart';
import 'package:Messedaglia/registro/bacheca_registro_data.dart';
import 'package:Messedaglia/screens/menu_screen.dart';
import 'package:Messedaglia/registro/registro.dart';
import 'package:Messedaglia/widgets/CutomFloatingSearchBar.dart';
import 'package:Messedaglia/widgets/expansion_tile.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_holo_date_picker/flutter_holo_date_picker.dart';
import 'package:flutter_holo_date_picker/widget/date_picker_widget.dart';
import 'package:http/http.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf_viewer_plugin/pdf_viewer_plugin.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:share_extend/share_extend.dart';

List<String> mesi = [
  'Gen',
  'Feb',
  'Mar',
  'Apr',
  'Mag',
  'Giu',
  'Lug',
  'Ago',
  'Set',
  'Ott',
  'Nov',
  'Dic'
];

bool showNew = false; // icons8 Eye Unchecked , tick & double tick,
bool showValid = true; // expired icon8,

DateTime _start = null, _end = null;

class BachecaScreen extends StatefulWidget {
  @override
  _BachecaScreenState createState() => _BachecaScreenState();
}

class _BachecaScreenState extends State<BachecaScreen> {
  Comunicazione _expanded;
  var data = session.bacheca.data;
  final TextEditingController _textController = new TextEditingController();
  FocusNode _firstInputFocusNode;
  String _highlight = '';

  List<String> files = List<String>();
  Map<String, List<dynamic>> frasi = {};

  ProgressDialog pr;

  AnimationController _controller;
  Animation _animation;

  Future<void> _refresh() async {
    await session.bacheca.getData();
    data = session.bacheca.data;
    setState(() {});
    rebuildAllChildren(context);
    files = [];
    frasi = {};
    _highlight = '';
  }

  Future<int> _uploadFiles() async {
    var uri = '*********/upload';
    List<MultipartFile> newList = new List<MultipartFile>();

    var send = await http.post(uri, headers: {
      'Content-Type': 'application/x-www-form-urlencoded',
      'token': session.token,
      'uuid': session.uname.substring(1),
    }, body: {
      'ids': session.bacheca.data
          .where((circolare) => !circolare.attachments.isEmpty)
          .map((circolare) {
            return json.encode({
              'title': (circolare.title),
              'id': circolare.id,
              'evt': circolare.evt
            });
          })
          .toList()
          .toString()
    });
    debugPrint(send.toString());
    return send.statusCode;
  }

  Future<bool> _ocr() async {
    if (_textController.text == '') return false;
    pr.show();
    files = [];
    frasi = {};
    var uri =
        'http://38326b01.ngrok.io/ocr?pattern=${_textController.text.toString()}';
    _highlight = _textController.text;

    http.Response res = await http.get(uri);
    if (res.statusCode == 200) {
      if (res.body == null || res.body.isEmpty) return false;

      jsonDecode(res.body).forEach((k, v) {
        // print(
        //     '$k=> volte: ${v['volte']}, frase: ${v['frase'].map((f) => f.trim())}');
        files.add(k);
        frasi[k] = v['frase'].map((f) => f.trim()).toList();
      });
    } else {
      return false;
    }
    pr.hide();
    if (mounted) setState(() {});
    if (files.isEmpty) _textController.clear();
    return files.isEmpty ? false : true;
  }

  @override
  void initState() {
    _firstInputFocusNode = new FocusNode();
    //_uploadFiles();
    print('upload() files spostare');
  }

  @override
  void dispose() {
    _firstInputFocusNode?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    pr = new ProgressDialog(context);
    pr = new ProgressDialog(context,
        type: ProgressDialogType.Normal, isDismissible: false, showLogs: true);
    pr.style(
        message: 'Loading...',
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
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        behavior: HitTestBehavior.opaque,
        onVerticalDragCancel: () => FocusScope.of(context).unfocus(),
        child: LiquidPullToRefresh(
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
                    Container(
                        height: 100,
                        margin: EdgeInsets.only(
                          bottom: 10.0,
                          left: 15.0,
                          right: 15.0,
                        ),
                        child: CustomFloatingSearchBar(
                          children: [Offstage()],
                          trailing: SizedBox(
                            width: 23 + 5 + 25.0,
                            child: Row(
                              children: <Widget>[
                                GestureDetector(
                                  onTap: () async {
                                    showGeneralDialog(
                                      // FIXME ho commentato linea 1802 del file /Users/gg/flutter/packages/flutter/lib/src/widgets/routes.dart perche se no non potevo mettere isDismissible:true
                                      barrierDismissible: true,
                                      transitionDuration:
                                          const Duration(milliseconds: 200),
                                      context: context,
                                      pageBuilder: (context, animation,
                                              secondaryAnimation) =>
                                          CustomDialog(),
                                    ).then((value) {
                                      setState(() {});
                                    });
                                  }, //TODO options dialog come quello di google drive: showPickerDateRange, show only valid pdf, only new?, etc...
                                  child: Icon(
                                    Icons.tune,
                                    size: 23,
                                  ),
                                ),
                                SizedBox(
                                  width: 5.0,
                                ),
                                GestureDetector(
                                  onTap: () {
                                    HapticFeedback.heavyImpact();
                                    setState(() {
                                      _textController.clear();
                                      _start = _end = null;
                                      showNew = false;
                                      showValid = true;
                                      files = [];
                                      frasi = {};
                                      _highlight = '';
                                    });
                                    rebuildAllChildren(context);
                                  },
                                  child: Icon(
                                    Icons.clear,
                                    size: 25,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          controller: _textController,
                          decoration: InputDecoration(
                            enabledBorder: InputBorder.none,
                            floatingLabelBehavior: FloatingLabelBehavior.never,
                            hintText: 'Inserire la parola chiave..',
                            helperMaxLines: 1,
                            disabledBorder: InputBorder.none,
                            focusColor: Colors.transparent,
                            focusedBorder: InputBorder.none,
                            focusedErrorBorder: InputBorder.none,
                          ),
                          onSubmit: (String value) {
                            _ocr().then((value) {
                              if (value) {
                                setState(() {});
                                rebuildAllChildren(context);
                              } else {
                                Flushbar(
                                  margin: EdgeInsets.all(30.0),
                                  padding: EdgeInsets.all(20),
                                  borderRadius: 20,
                                  backgroundGradient: LinearGradient(
                                    colors: [
                                      Globals.bluScolorito,
                                      Theme.of(context).accentColor
                                    ],
                                    stops: [0.3, 1],
                                  ),
                                  boxShadows: [
                                    BoxShadow(
                                      color: Colors.black45,
                                      offset: Offset(3, 3),
                                      blurRadius: 6,
                                    ),
                                  ],
                                  duration: Duration(seconds: 3),
                                  isDismissible: true,
                                  icon: Icon(
                                    Icons.error_outline,
                                    size: 35,
                                    color: Theme.of(context).backgroundColor,
                                  ),
                                  shouldIconPulse: true,
                                  animationDuration: Duration(seconds: 1),
                                  // All of the previous Flushbars could be dismissed by swiping down
                                  // now we want to swipe to the sides
                                  dismissDirection:
                                      FlushbarDismissDirection.HORIZONTAL,
                                  // The default curve is Curves.easeOut
                                  forwardAnimationCurve: Curves.fastOutSlowIn,
                                  title: 'Parola o frase inesistenti',
                                  message: 'Reinserire la parola chiave',
                                ).show(context);
                              }
                            });
                          },
                        )
                        /* Row(
                        children: <Widget>[
                          Expanded(
                            flex: 8,
                            child: Padding(
                              padding: const EdgeInsets.only(
                                  top: 15.0, bottom: 15.0),
                              child: TextFormField(
                                autocorrect: false,
                                focusNode: _firstInputFocusNode,
                                controller: _textController,
                                decoration: InputDecoration(
                                  enabledBorder: InputBorder.none,
                                  fillColor: Colors.white10,
                                  floatingLabelBehavior:
                                      FloatingLabelBehavior.auto,
                                  hintText: 'Inserire la parola chiave..',
                                  helperMaxLines: 1,
                                  filled: true,
                                  prefixIcon: GestureDetector(
                                      onTap: () {
                                        _ocr().then((value) {
                                          if (value) {
                                            setState(() {});
                                            rebuildAllChildren(context);
                                          } else {
                                            Flushbar(
                                              margin: EdgeInsets.all(30.0),
                                              padding: EdgeInsets.all(20),
                                              borderRadius: 20,
                                              backgroundGradient:
                                                  LinearGradient(
                                                colors: [
                                                  Globals.bluScolorito,
                                                  Theme.of(context).accentColor
                                                ],
                                                stops: [0.3, 1],
                                              ),
                                              boxShadows: [
                                                BoxShadow(
                                                  color: Colors.black45,
                                                  offset: Offset(3, 3),
                                                  blurRadius: 6,
                                                ),
                                              ],
                                              duration: Duration(seconds: 3),
                                              isDismissible: true,
                                              icon: Icon(
                                                Icons.error_outline,
                                                size: 35,
                                                color: Theme.of(context)
                                                    .backgroundColor,
                                              ),
                                              shouldIconPulse: true,
                                              animationDuration:
                                                  Duration(seconds: 1),
                                              // All of the previous Flushbars could be dismissed by swiping down
                                              // now we want to swipe to the sides
                                              dismissDirection:
                                                  FlushbarDismissDirection
                                                      .HORIZONTAL,
                                              // The default curve is Curves.easeOut
                                              forwardAnimationCurve:
                                                  Curves.fastOutSlowIn,
                                              title:
                                                  'Parola o frase inesistenti',
                                              message:
                                                  'Reinserire la parola chiave',
                                            ).show(context);
                                          }
                                        });
                                      },
                                      child: Icon(Icons.search)),
                                  disabledBorder: InputBorder.none,
                                ),
                                maxLines: 1,
                                onFieldSubmitted: (value) {
                                  _ocr().then((value) {
                                    if (value) {
                                      setState(() {});
                                      rebuildAllChildren(context);
                                    } else {
                                      Flushbar(
                                        padding: EdgeInsets.all(20),
                                        margin: EdgeInsets.all(30.0),

                                        borderRadius: 20,
                                        backgroundGradient: LinearGradient(
                                          colors: [
                                            Globals.bluScolorito,
                                            Theme.of(context).accentColor
                                          ],
                                          stops: [0.3, 1],
                                        ),
                                        boxShadows: [
                                          BoxShadow(
                                            color: Colors.black45,
                                            offset: Offset(3, 3),
                                            blurRadius: 6,
                                          ),
                                        ],
                                        duration: Duration(seconds: 3),
                                        isDismissible: true,
                                        icon: Icon(
                                          Icons.error_outline,
                                          size: 35,
                                          color:
                                              Theme.of(context).backgroundColor,
                                        ),
                                        shouldIconPulse: true,
                                        animationDuration: Duration(seconds: 1),
                                        // All of the previous Flushbars could be dismissed by swiping down
                                        // now we want to swipe to the sides
                                        dismissDirection:
                                            FlushbarDismissDirection.HORIZONTAL,
                                        // The default curve is Curves.easeOut
                                        forwardAnimationCurve:
                                            Curves.fastOutSlowIn,
                                        title: 'Parola o frase inesistenti',
                                        message: 'Reinserire la parola chiave',
                                      ).show(context);
                                    }
                                  });
                                },
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: IconButton(
                                icon: Icon(
                                  MdiIcons.calendarClock,
                                  size: 22,
                                ),
                                onPressed: () => showPickerDateRange(
                                    context) //TODO: usare flutter_holo_date_picker 🙃
                                // _uploadFiles, //TODO: spostarlo & select range of time
                                ),
                          ),
                          Expanded(
                            flex: 1,
                            child: IconButton(
                              enableFeedback: true,
                              icon: Icon(Icons.clear),
                              onPressed: () {
                                HapticFeedback.heavyImpact();
                                setState(() {
                                  _textController.clear();
                                  _start = _end = null;
                                  files = [];
                                  frasi = {};
                                  _highlight = '';
                                });

                                rebuildAllChildren(context);
                              },
                            ),
                          ),
                        ],
                      ), */
                        ),
                    Stack(
                      overflow: Overflow.visible,
                      children: <Widget>[
                        Container(
                          margin: EdgeInsets.only(top: 15.0),
                          child: Column(
                              children: data.where((d) {
                            Comunicazione _filterCircolari(Comunicazione c) {
                              // TODO: fare funzione da pseudocodice
                            }
                          }).map<Widget>((c) {
                            // TODO filter by inactive
                            if (files.isEmpty) {
                              bool _expand = false;
                              return Container(
                                margin: EdgeInsets.only(
                                    left: 15.0, right: 15.0, bottom: 3.0),
                                decoration: BoxDecoration(
                                  color: Colors.white10,
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(10.0),
                                  ),
                                ),
                                child: CustomExpansionTile(
                                  onExpansionChanged: (isExpanded) async {
                                    _expand = isExpanded;
                                    await c.seen();

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
                                    textAlign: TextAlign.center,
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
                                            await c.seen();

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
                                                  builder: (context) =>
                                                      PDFScreen(
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
                                    firstChild: Icon(
                                      MdiIcons.eye,
                                      color: c.isNew
                                          ? Colors.yellow.withOpacity(0.7)
                                          : Colors.white,
                                    ),
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
                                                  ? Colors.white
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
                                        : Container(
                                            margin: EdgeInsets.fromLTRB(
                                                10.0, 5.0, 10.0, 10.0),
                                            child: Text(c.content,
                                                textAlign: TextAlign.center,
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodyText1),
                                          ),
                                  ),
                                ),
                              );
                            } else if (files.contains(c.id.toString())) {
                              String text = '';

                              for (int i = 0;
                                  i < frasi[c.id.toString()].length;
                                  i++) {
                                int tmp = i + 1;
                                text += '$tmp)' +
                                    '“' +
                                    frasi[c.id.toString()][i] +
                                    '”' +
                                    '\n\n';
                              }
                              bool _expand = false;
                              return Container(
                                margin: EdgeInsets.only(
                                    left: 15.0, right: 15.0, bottom: 3.0),
                                decoration: BoxDecoration(
                                  color: Colors.white10,
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(10.0),
                                  ),
                                ),
                                child: CustomExpansionTile(
                                  onExpansionChanged: (isExpanded) async {
                                    await c.seen();

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
                                    color: c.isNew
                                        ? Colors.yellow
                                        : Theme.of(context).brightness ==
                                                Brightness.dark
                                            ? Colors.white
                                            : Colors.black,
                                    onPressed: c.attachments.isEmpty
                                        ? null
                                        : () async {
                                            await c.seen();
                                            await c.loadContent(
                                                () => setState(() {}));
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
                                                  builder: (context) =>
                                                      PDFScreen(
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
                                    firstChild: Icon(
                                      MdiIcons.eye,
                                      color: c.isNew
                                          ? Colors.yellow
                                          : Theme.of(context).brightness ==
                                                  Brightness.dark
                                              ? Colors.white
                                              : Colors.black,
                                    ),
                                    secondChild: Icon(MdiIcons.eyeOffOutline),
                                  ),
                                  child: Padding(
                                      padding: EdgeInsets.fromLTRB(
                                          10.0, 10.0, 10.0, 15.0),
                                      child: HighlightText(
                                        text: text,
                                        highlight: _highlight,
                                        highlightColor: Colors.yellowAccent
                                            .withOpacity(0.7),
                                        style: TextStyle(
                                          height: 1.2,
                                          fontSize: 13.0,
                                          color: Theme.of(context).brightness ==
                                                  Brightness.dark
                                              ? Colors.white
                                              : Colors.black,
                                          fontFamily: 'CoreSans',
                                          fontStyle: FontStyle.italic,
                                          letterSpacing: 1.2,
                                        ),
                                      )),
                                ),
                              );
                            } else {
                              return Offstage();
                            }
                          }).toList()),
                        ),
                      ],
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  void rebuildAllChildren(BuildContext context) {
    void rebuild(Element el) {
      el.markNeedsBuild();
      el.visitChildren(rebuild);
    }

    (context as Element).visitChildren(rebuild);
  }
}

class CustomDialog extends StatefulWidget {
  CustomDialog({
    Key key,
  }) : super(key: key);

  @override
  _CustomDialogState createState() => _CustomDialogState();
}

class _CustomDialogState extends State<CustomDialog> {
  bool dal = false, al = false;
  DateTime _now = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        0.0,
        MediaQuery.of(context).size.height / 8,
        0.0,
        0.0,
      ),
      child: AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        actions: <Widget>[
          FlatButton(
              onPressed: () => Navigator.pop(context), child: Text('Annulla')),
          FlatButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cerca'),
          )
        ],
        content: Container(
          margin: EdgeInsets.fromLTRB(15.0, 15.0, 15.0, 15.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(
                        'Attive',
                        style: TextStyle(
                          fontSize: 20.0,
                          fontFamily: 'CoreSans',
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(
                        width: 10.0,
                      ),
                      Checkbox(
                          activeColor: Theme.of(context).accentColor,
                          value: showValid,
                          onChanged: (_valid) {
                            setState(() {
                              showValid = _valid;
                            });
                          })
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(
                        'Nuove',
                        style: TextStyle(
                          fontSize: 20.0,
                          fontFamily: 'CoreSans',
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(
                        width: 10.0,
                      ),
                      Checkbox(
                          activeColor: Theme.of(context).accentColor,
                          value: showNew,
                          onChanged: (_new) {
                            setState(() {
                              showNew = _new;
                            });
                          })
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(
                        'Valide dal:',
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          fontSize: 20.0,
                          fontFamily: 'CoreSans',
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(
                        width: 10.0,
                      ),
                      Checkbox(
                          activeColor: Theme.of(context).accentColor,
                          value: dal,
                          onChanged: (_dal) {
                            setState(() {
                              dal = _dal;
                            });
                          })
                    ],
                  ),
                ),
                DatePickerWidget(
                  pickerTheme: DateTimePickerTheme(
                    backgroundColor: Colors.transparent,
                    itemTextStyle: TextStyle(
                      color: Colors.white,
                      fontFamily: 'CoreSans',
                      fontSize: 15.0,
                    ),
                  ),
                  initialDate: DateTime(_now.year),
                  firstDate: DateTime(_now.year - 1),
                  lastDate: DateTime(_now.year + 1),
                  dateFormat: "dd-MMM-yyyy",
                  locale: DateTimePickerLocale.it,
                  looping: false,
                  onChange: (dateTime, selectedIndex) {
                    if (dal) {
                      print(dateTime);
                      _start = dateTime;
                    }
                  },
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(
                        'Valide al:',
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          fontSize: 20.0,
                          fontFamily: 'CoreSans',
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(
                        width: 10.0,
                      ),
                      Checkbox(
                          activeColor: Theme.of(context).accentColor,
                          value: al,
                          onChanged: (_al) {
                            setState(() {
                              al = _al;
                            });
                          })
                    ],
                  ),
                ),
                DatePickerWidget(
                  pickerTheme: DateTimePickerTheme(
                    backgroundColor: Colors.transparent,
                    itemTextStyle: TextStyle(
                      color: Colors.white,
                      fontFamily: 'CoreSans',
                      fontSize: 15.0,
                    ),
                  ),
                  initialDate: DateTime(_now.year),
                  firstDate: DateTime(_now.year - 1),
                  lastDate: DateTime(_now.year + 1),
                  dateFormat: "dd-MMM-yyyy",
                  locale: DateTimePickerLocale.it,
                  looping: false,
                  onChange: (dateTime, selectedIndex) {
                    if (al) {
                      print(dateTime);
                      _end = dateTime;
                    }
                  },
                ),
              ],
            ),
          ),
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
            margin: EdgeInsets.fromLTRB(60.0, 70.0, 60.0, 0.0),
            child: Text(
              title,
              maxLines: 5,
              textAlign: TextAlign.left,
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

class HighlightText extends StatelessWidget {
  final String text;
  final String highlight;
  final TextStyle style;
  final Color highlightColor;

  const HighlightText({
    Key key,
    this.text,
    this.highlight,
    this.style,
    this.highlightColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String text = this.text ?? '';
    if ((highlight?.isEmpty ?? true) || text.isEmpty) {
      return Text(
        text,
        style: style,
        textAlign: TextAlign.left,
        maxLines: 50,
        overflow: TextOverflow.ellipsis,
      );
    }

    List<TextSpan> spans = [];
    int start = 0;
    int indexOfHighlight;
    do {
      indexOfHighlight = text.indexOf(highlight, start);
      if (indexOfHighlight < 0) {
        // no highlight
        spans.add(_normalSpan(text.substring(start, text.length)));
        break;
      }
      if (indexOfHighlight == start) {
        // start with highlight.
        spans.add(_highlightSpan(highlight));
        start += highlight.length;
      } else {
        // normal + highlight
        spans.add(_normalSpan(text.substring(start, indexOfHighlight)));
        spans.add(_highlightSpan(highlight));
        start = indexOfHighlight + highlight.length;
      }
    } while (true);

    return Text.rich(
      TextSpan(children: spans),
      textAlign: TextAlign.left,
      maxLines: 50,
      overflow: TextOverflow.ellipsis,
    );
  }

  TextSpan _highlightSpan(String content) {
    return TextSpan(
        text: content, style: style.copyWith(color: highlightColor));
  }

  TextSpan _normalSpan(String content) {
    return TextSpan(
      text: content,
      style: style,
    );
  }

  TextSpan _dot(String content) {
    return TextSpan(
      text: content,
      style: TextStyle(fontSize: 30.0),
    );
  }
}

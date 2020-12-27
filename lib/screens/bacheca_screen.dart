import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:Messedaglia/preferences/globals.dart';
import 'package:Messedaglia/registro/bacheca_registro_data.dart';
import 'package:Messedaglia/widgets/CutomFloatingSearchBar.dart';
import 'package:Messedaglia/widgets/background_painter.dart';
import 'package:Messedaglia/widgets/expansion_tile.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_holo_date_picker/flutter_holo_date_picker.dart';
import 'package:flutter_holo_date_picker/widget/date_picker_widget.dart';
import 'package:http/http.dart';
import 'package:flutter/services.dart';

import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:marquee/marquee.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:pdf_viewer_plugin/pdf_viewer_plugin.dart';
import 'package:share_extend/share_extend.dart';
import 'package:Messedaglia/main.dart' as main;

bool showValid = main.prefs.getBool('showValid') ?? true;
bool showNew = main.prefs.getBool('showNew') ?? false;

DateTime _start, _end;

class BachecaScreen extends StatefulWidget {
  static final String id = 'bacheca_screen';

  @override
  _BachecaScreenState createState() => _BachecaScreenState();
}

class _BachecaScreenState extends State<BachecaScreen> {
  var data = main.session.bacheca.data;
  final TextEditingController _textController = new TextEditingController();
  FocusNode _firstInputFocusNode;
  String _highlight = '';

  List<String> files = List<String>();
  Map<String, List<dynamic>> frasi = {};

  bool _displayErrorText = false, _loading = false;

  Future<void> _refresh() async {
    await main.session.bacheca.getData();
    data = main.session.bacheca.data;
    setState(() {});
    rebuildAllChildren(context);
    files = [];
    frasi = {};
    _highlight = '';
    HapticFeedback.mediumImpact();
  }

  Future<int> _uploadFiles() async {
    var uri = 'http://bd466fb4.ngrok.io/upload';
    List<MultipartFile> newList = new List<MultipartFile>();

    var send = await http.post(uri, headers: {
      'Content-Type': 'application/x-www-form-urlencoded',
      'token': main.session.token,
      'uuid': main.session.uname.substring(1),
    }, body: {
      'ids': main.session.bacheca.data
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
    //debugPrint(send.toString());
    return send.statusCode;
  }

  Future<bool> _ocr() async {
    if (_textController.text == '') return false;
    setState(() {
      _loading = true;
    });
    files = [];
    frasi = {};
    var uri =
        'http://bd466fb4.ngrok.io/ocr?pattern=${_textController.text.toString()}';
    _highlight = _textController.text;

    try {
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
        _textController.clear();
        setState(() {
          _loading = false;
        });
        return false;
      }
    } catch (e, stack) {
      print(e);
      print(stack);
      setState(() {
        _loading = false;
      });
      return false;
    }
    setState(() {
      _loading = false;
    });
    if (mounted) setState(() {});
    if (files.isEmpty) _textController.clear();
    return files.isEmpty ? false : true;
  }

  bool xorBool(bool item1, bool item2) {
    var xorValue = (item1 ? 1 : 0) ^ (item2 ? 1 : 0);
    return (xorValue == 1 ? true : false);
  }

  @override
  void initState() {
    super.initState();
    _firstInputFocusNode = new FocusNode();
    //_uploadFiles();
    print('upload() files spostare');
    main.prefs.setBool('showValid', showValid);
  }

  @override
  void dispose() {
    _firstInputFocusNode?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ModalProgressHUD(
        inAsyncCall: _loading,
        // color: Theme.of(context).accentColor,
        dismissible: false,
        child: GestureDetector(
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
                    painter: BackgroundPainter(Theme.of(context), back: true),
                    size: Size.infinite,
                  ),
                  bottom: PreferredSize(
                      child: Container(),
                      preferredSize: Size.fromHeight(
                          MediaQuery.of(context).size.width / 8)),
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
                          pinned: true,
                          children: [Offstage()],
                          trailing: SizedBox(
                            width: 26 + 8 + 28.0,
                            child: Row(
                              children: <Widget>[
                                GestureDetector(
                                  onTap: () async {
                                    if (_displayErrorText == true)
                                      _displayErrorText = false;
                                    showGeneralDialog(
                                      // FIXME ho commentato linea 1802 del file /Users/gg/flutter/packages/flutter/lib/src/widgets/routes.dart perche se no non potevo mettere isDismissible:true
                                      barrierDismissible: false,
                                      transitionDuration:
                                          const Duration(milliseconds: 200),
                                      context: context,
                                      pageBuilder: (context, animation,
                                              secondaryAnimation) =>
                                          CustomDialog(),
                                    ).then((annulla) {
                                      if (xorBool(
                                              _start == null, _end == null) &&
                                          !annulla) {
                                        _end = _start = null;

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
                                              'Errore durante la ricerca delle circolari: ',
                                          message:
                                              'Inserire sia la data iniziale che la data finale',
                                        ).show(context);
                                      } else if (!annulla) {
                                        data = main.session.bacheca.data;
                                        setState(() {});
                                        rebuildAllChildren(context);
                                      }
                                    });
                                  },
                                  child: Icon(
                                    Icons.tune,
                                    size: 26,
                                  ),
                                ),
                                SizedBox(
                                  width: 8.0,
                                ),
                                GestureDetector(
                                  onTap: () async {
                                    // main.prefs.setBool('showNew', false);
                                    // main.prefs.setBool('showValid', false);
                                    if (_displayErrorText == true)
                                      _displayErrorText = false;
                                    HapticFeedback.heavyImpact();
                                    setState(() {
                                      _textController.clear();
                                      _start = _end = null;
                                      // showNew = false;
                                      // showValid = false;
                                      files = [];
                                      frasi = {};
                                      _highlight = '';
                                    });
                                    rebuildAllChildren(context);
                                  },
                                  child: Icon(
                                    Icons.clear,
                                    size: 28,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          controller: _textController,
                          decoration: InputDecoration(
                            enabledBorder: InputBorder.none,
                            floatingLabelBehavior: FloatingLabelBehavior.never,
                            hintText: _displayErrorText
                                ? 'Inserire una parola o frase valide'
                                : 'Inserire la parola chiave..',
                            hintStyle: TextStyle(
                              color: _displayErrorText
                                  ? Colors.red.withOpacity(0.8)
                                  : Colors.white70,
                            ),
                            helperMaxLines: 1,
                            disabledBorder: InputBorder.none,
                            focusColor: Colors.transparent,
                            focusedBorder: InputBorder.none,
                            focusedErrorBorder: InputBorder.none,
                          ),
                          onTap: () => _displayErrorText = false,
                          onSubmit: (String value) {
                            if (value == '') {
                              setState(() => _displayErrorText = true);
                            } else
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
                        ),
                      ),
                      Stack(
                        clipBehavior: Clip.none,
                        children: <Widget>[
                          Container(
                            margin: EdgeInsets.only(top: 15.0),
                            child: Column(
                                children: data.where((d) {
                              if (_start != null && _end != null) {
                                if (d.start_date.isBefore(_start) &&
                                    d.end_date.isAfter(_end)) {
                                  return d.start_date.isBefore(_start) &&
                                      d.end_date.isAfter(_end);
                                } else
                                  return false;
                              } else
                                return d !=
                                    null; // non serve un else if (_start == null && _end == null) perche nel .then((annull)){...} ce gia il check del bottone premuto e delle variabili _start & _end
                            }).where((v) {
                              if (showValid) {
                                return v.valid == true;
                              } else
                                return v != null;
                            }).where((n) {
                              if (showNew) {
                                return n.isNew == true;
                              } else
                                return n != null;
                            }).map<Widget>((c) {
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
                                    leading: GestureDetector(
                                      onTap: c.attachments.isEmpty
                                          ? null
                                          : () async {
                                              int n;

                                              if (c.attachments.length == 1)
                                                n = 1;
                                              else {
                                                if (Platform.isAndroid)
                                                  n = await _settingModalBottomSheet(
                                                      context, c);
                                                else if (Platform.isIOS)
                                                  n = await _cupertinoAction(
                                                      context, c);
                                                else
                                                  n = await _settingModalBottomSheet(
                                                      context, c);
                                              }
                                              if (n != null) {
                                                if (c.isNew)
                                                  c.loadContent(
                                                      () => setState(() {
                                                            _loading = true;
                                                          }));

                                                var _pathh = await c
                                                    .downloadPdf(number: n);
                                                _pathh = _pathh?.path;
                                                if (mounted && _pathh != null) {
                                                  setState(() {
                                                    _loading = false;
                                                  });
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
                                              }
                                            },
                                      child: SizedBox(
                                        width:
                                            45.0, //FIXME esiste una maniera migliore per scegliere la larghezza dato ch deve avere una larghezza definita il 'leading'
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceEvenly,
                                          mainAxisSize: MainAxisSize.max,
                                          children: [
                                            Icon(
                                              MdiIcons.filePdf,
                                              size: 24,
                                              color: Theme.of(context)
                                                          .brightness ==
                                                      Brightness.dark
                                                  ? Colors.white
                                                  : Colors.black,
                                            ),
                                            AutoSizeText(
                                              '${c.start_date.day}/${c.start_date.month}/${c.start_date.year.toString().replaceRange(0, 2, '')}',
                                              style: TextStyle(fontSize: 8),
                                              maxLines: 1,
                                              minFontSize: 6.0,
                                            ),
                                          ],
                                        ),
                                      ),
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
                                                backgroundColor:
                                                    Theme.of(context)
                                                                .brightness ==
                                                            Brightness.dark
                                                        ? Colors.white
                                                        : Colors.black12,
                                                valueColor:
                                                    AlwaysStoppedAnimation(Theme
                                                                    .of(context)
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
                                    leading: GestureDetector(
                                      onTap: c.attachments.isEmpty
                                          ? null
                                          : () async {
                                              int n;

                                              if (c.attachments.length == 1)
                                                n = 1;
                                              else {
                                                if (Platform.isAndroid)
                                                  n = await _settingModalBottomSheet(
                                                      context, c);
                                                else if (Platform.isIOS)
                                                  n = await _cupertinoAction(
                                                      context, c);
                                                else
                                                  n = await _settingModalBottomSheet(
                                                      context, c);
                                              }
                                              if (n != null) {
                                                if (c.isNew)
                                                  c.loadContent(
                                                      () => setState(() {
                                                            _loading = true;
                                                          }));

                                                var _pathh = await c
                                                    .downloadPdf(number: n);
                                                _pathh = _pathh?.path;
                                                if (mounted && _pathh != null) {
                                                  setState(() {
                                                    _loading = false;
                                                  });
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
                                              }
                                            },
                                      child: SizedBox(
                                        width:
                                            45.0, //FIXME esiste una maniera migliore per scegliere la larghezza dato ch deve avere una larghezza definita il 'leading'
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceEvenly,
                                          mainAxisSize: MainAxisSize.max,
                                          children: [
                                            Icon(
                                              MdiIcons.filePdf,
                                              size: 24,
                                              color: Theme.of(context)
                                                          .brightness ==
                                                      Brightness.dark
                                                  ? Colors.white
                                                  : Colors.black,
                                            ),
                                            Text(
                                              '${c.start_date.day}/${c.start_date.month}/${c.start_date.year.toString().replaceRange(0, 2, '')}',
                                              style: TextStyle(fontSize: 8),
                                            ),
                                          ],
                                        ),
                                      ),
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
                                            color:
                                                Theme.of(context).brightness ==
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
  bool dal = _start == null ? false : true;
  bool al = _start == null ? false : true;
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
              onPressed: () {
                HapticFeedback.mediumImpact();
                Navigator.of(context).pop(true);
              },
              child: Text('Annulla')),
          FlatButton(
            color: Theme.of(context).accentColor,
            onPressed: () {
              HapticFeedback.mediumImpact();
              if (dal && _start == null) {
                _start =
                    DateTime(_now.year, _now.month, _now.day - 1, 23, 59, 59);
              }
              if (al && _end == null) {
                _end = DateTime(
                    _now.year, _now.month + 1, _now.day - 1, 23, 59, 59);
              }
              Navigator.of(context).pop(false);
            },
            child: Text(
              'Cerca',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(
                      'Leggi tutte',
                      style: TextStyle(
                        fontSize: 20.0,
                        fontFamily: 'CoreSans',
                        color: Colors.white,
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.clear_all),
                      onPressed: () async {
                        if (!main.session.bacheca.data.every((c) =>
                            (c.isNew == main.session.bacheca.data[0].isNew) &&
                            main.session.bacheca.data[0].isNew == false)) {
                          await main.session.bacheca.seenAll();
                          HapticFeedback.mediumImpact();
                          Navigator.of(context).pop(false);
                        }
                      },
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(
                        'Solo attive',
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
                            main.prefs.setBool('showValid', _valid);
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
                        'Solo nuove',
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
                            main.prefs.setBool('showNew', _new);
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
                            _start = null;
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
                  initialDate: _start != null
                      ? _start
                      : DateTime(_now.year, _now.month, _now.day),
                  firstDate: DateTime(_now.year - 1),
                  lastDate: DateTime(_now.year + 1),
                  dateFormat: "dd-MMM-yyyy",
                  locale: DateTimePickerLocale.it,
                  looping: false,
                  onChange: (dateTime, selectedIndex) {
                    if (dal) {
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
                            _end = null;
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
                  initialDate: _end != null
                      ? _end
                      : DateTime(_now.year, _now.month + 1, _now.day),
                  firstDate: DateTime(_now.year - 1),
                  lastDate: DateTime(_now.year + 1),
                  dateFormat: "dd-MMM-yyyy",
                  locale: DateTimePickerLocale.it,
                  looping: false,
                  onChange: (dateTime, selectedIndex) {
                    if (al) {
                      _end = dateTime;
                      print(_end.toIso8601String());
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

Future _cupertinoAction(BuildContext context, Comunicazione c) {
  return showCupertinoModalPopup(
      context: context,
      builder: (context) {
        return CupertinoActionSheet(
          title: Text(
            'Seleziona la circolare',
            style: TextStyle(
              fontFamily: 'CoreSans',
              fontSize: 13,
              letterSpacing: 1.2,
            ),
          ),
          cancelButton: CupertinoActionSheetAction(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Annulla'),
          ),
          actions: <Widget>[
            CupertinoActionSheetAction(
              onPressed: () => Navigator.of(context).pop(1),
              child: Text(
                c.attachments[0]["fileName"],
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'CoreSans',
                  fontSize: 13,
                  letterSpacing: 1.2,
                ),
              ),
            ),
            CupertinoActionSheetAction(
              onPressed: () => Navigator.of(context).pop(2),
              child: Text(
                c.attachments[1]["fileName"],
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'CoreSans',
                  fontSize: 13,
                  letterSpacing: 1.2,
                ),
              ),
            ),
          ],
        );
      });
}

Future _settingModalBottomSheet(context, Comunicazione c) {
  return showModalBottomSheet(
      context: context,
      builder: (BuildContext bc) {
        return Container(
          child: Wrap(
            children: <Widget>[
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Column(
                  children: <Widget>[
                    Container(
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height * 0.05,
                      margin: EdgeInsets.fromLTRB(20, 10, 20, 5),
                      child: Center(
                        child: GestureDetector(
                          onTap: () {
                            Navigator.of(context).pop(1);
                          },
                          child: Text(
                            c.attachments[0]["fileName"],
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: 'CoreSans',
                              fontSize: 13,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height * 0.05,
                  margin: EdgeInsets.fromLTRB(20, 10, 20, 25),
                  child: Center(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.of(context).pop(2);
                      },
                      child: Text(
                        c.attachments[1]["fileName"],
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'CoreSans',
                          fontSize: 13,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      });
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
            child: Marquee(
              text: ' ' + title,
              style: TextStyle(
                color: Colors.black,
                fontSize: 15.0,
                wordSpacing: 1.2,
              ),
              scrollAxis: Axis.horizontal,
              blankSpace: 70.0,
              velocity: 80.0,
              pauseAfterRound: Duration(seconds: 1),
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

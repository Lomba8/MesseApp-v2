import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:Messedaglia/preferences/globals.dart';
import 'package:Messedaglia/registro/bacheca_registro_data.dart';
import 'package:Messedaglia/screens/menu_screen.dart';
import 'package:Messedaglia/registro/registro.dart';
import 'package:Messedaglia/widgets/expansion_tile.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';

import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf_viewer_plugin/pdf_viewer_plugin.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:share_extend/share_extend.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import 'package:syncfusion_flutter_core/core.dart';

class BachecaScreen extends StatefulWidget {
  @override
  _BachecaScreenState createState() => _BachecaScreenState();
}

class _BachecaScreenState extends State<BachecaScreen> {
  Comunicazione _expanded;
  var data = RegistroApi.bacheca.data;
  final TextEditingController _textController = new TextEditingController();
  FocusNode _firstInputFocusNode;
  String _highlight = '';

  List<String> files = List<String>();
  Map<String, List<dynamic>> frasi = {};

  ProgressDialog pr;

  Future<void> _refresh() async {
    await RegistroApi.bacheca.getData();
    data = RegistroApi.bacheca.data;
    setState(() {});
    rebuildAllChildren(context);
    files = [];
    frasi = {};
    _highlight = '';
  }

  Future<List<Comunicazione>> search(String search) async {
    await Future.delayed(Duration(seconds: 2));
    return List.generate(search.length, (int index) {
      return; // Comunicazione(); TODO
    });
  }

  Future<int> _uploadFiles() async {
    var uri = 'http://76935b85.ngrok.io/upload';

    List<MultipartFile> newList = new List<MultipartFile>();

    for (int i = 0; i < RegistroApi.bacheca.data.length; i++) {
      http.MultipartFile multipartFile;
      if (!RegistroApi.bacheca.data[i].attachments.isEmpty &&
          RegistroApi.bacheca.data[i].attachments.length != 0) {
        var c;
        c = await RegistroApi.bacheca.data[i].downloadPdf();
        multipartFile = await http.MultipartFile.fromPath('sampleFiles', c.path,
            filename: RegistroApi.bacheca.data[i].title +
                '.pdf'); //returns a Future<MultipartFile>}
        newList.add(multipartFile);

        print('added file #$i: ' + RegistroApi.bacheca.data[i].title + '\n');
      }
    }
    final postUri = Uri.parse(uri);
    http.MultipartRequest request = http.MultipartRequest('POST', postUri);

    request.files.addAll(newList);

    http.StreamedResponse response = await request.send();
    return response.statusCode;
  }

  Future<bool> _ocr() async {
    files = [];
    frasi = {};
    var uri =
        'http://76935b85.ngrok.io/ocr?pattern=${_textController.text.toString()}';
    _highlight = _textController.text;
    _textController.clear();

    print(uri + '\n\n');

    http.Response res = await http.get(uri);
    if (res.statusCode == 200) {
      if (res.body == null) return false;
      jsonDecode(res.body).forEach((k, v) {
        // print(
        //     '$k=> volte: ${v['volte']}, frase: ${v['frase'].map((f) => f.trim())}');
        files.add(k);
        frasi[k] = v['frase'].map((f) => f.trim()).toList();
      });
    } else {
      return false;
    }
    return files.isEmpty ? false : true;
  }

  void _onSelectionChanged(DateRangePickerSelectionChangedArgs args) {
    /// The argument value will return the changed date as [DateTime] when the
    /// widget [SfDateRangeSelectionMode] set as single.
    ///
    /// The argument value will return the changed dates as [List<DateTime>] when the
    /// widget [SfDateRangeSelectionMode] set as multiple.
    ///
    /// The argument value will return the changed range as [PickerDateRange]
    /// when the widget [SfDateRangeSelectionMode] set as range.
    ///
    /// The argument value will return the changed ranges as [List<PickerDateRange]
    /// when the widget [SfDateRangeSelectionMode] set as multi range.
    if (args.value is PickerDateRange) {
      final DateTime rangeStartDate = args.value.startDate;
      final DateTime rangeEndDate = args.value.endDate;
    } else if (args.value is DateTime) {
      final DateTime selectedDate = args.value;
    } else if (args.value is List<DateTime>) {
      final List<DateTime> selectedDates = args.value;
    } else {
      final List<PickerDateRange> selectedRanges = args.value;
    }
  }

  @override
  void initState() {
    super.initState();
    _firstInputFocusNode = new FocusNode();
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
                      height: 70,
                      margin: EdgeInsets.symmetric(
                          vertical: 10.0, horizontal: 15.0),
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            flex: 8,
                            child: TextFormField(
                              autocorrect: false,
                              focusNode: _firstInputFocusNode,
                              controller: _textController,
                              validator: (value) => value.trim() != ''
                                  ? null
                                  : 'Inserire una parola o frase valida/e',
                              decoration: InputDecoration(
                                enabledBorder: InputBorder.none,
                                fillColor: Colors.white10,
                                floatingLabelBehavior:
                                    FloatingLabelBehavior.auto,
                                labelText: 'Inserire la parola chiave..',
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
                                            title: 'Parola o frase inesistenti',
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
                          Expanded(
                            flex: 1,
                            child: IconButton(
                                icon: Icon(Icons.settings),
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    child: Container(
                                      child: SfDateRangePicker(
                                        onSelectionChanged: _onSelectionChanged,
                                        selectionMode:
                                            DateRangePickerSelectionMode.range,
                                      ),
                                    ),
                                  );
                                }
                                // _uploadFiles, //TODO: spostarlo & select range of time
                                ),
                          ),
                          Expanded(
                            flex: 1,
                            child: IconButton(
                              icon: Icon(Icons.clear),
                              onPressed: () {
                                setState(() {
                                  files = [];
                                  frasi = {};
                                  _highlight = '';
                                });
                                rebuildAllChildren(context);
                              },
                            ),
                          ),
                        ],
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
                            if (files.isEmpty) {
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
                                      c.seen();
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
                            } else if (files.contains(c.title)) {
                              bool _expand = false;
                              return Container(
                                color: Colors.white10,
                                margin: EdgeInsets.only(
                                    left: 15.0,
                                    right: 15.0,
                                    top: 0.0,
                                    bottom: 1.0),
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
                                    firstChild: Icon(MdiIcons.eye),
                                    secondChild: Icon(MdiIcons.eyeOffOutline),
                                  ),
                                  child: Padding(
                                      padding: EdgeInsets.fromLTRB(
                                          10.0, 10.0, 10.0, 15.0),
                                      child: HighlightText(
                                        text: '“' +
                                            frasi[c.title].join('\n') +
                                            '”',
                                        highlight: _highlight,
                                        highlightColor: Colors.yellowAccent
                                            .withOpacity(0.7),
                                        style: TextStyle(
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
        textAlign: TextAlign.center,
        maxLines: 2,
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
      textAlign: TextAlign.center,
      maxLines: 2,
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
}

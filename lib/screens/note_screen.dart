import 'package:Messedaglia/main.dart' as main;
import 'package:Messedaglia/preferences/globals.dart';
import 'package:Messedaglia/registro/note_registro_data.dart';
import 'package:Messedaglia/screens/menu_screen.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';

import '../main.dart';

ScrollController _controller1;
ScrollController _controller2;
ScrollController _controller3;
ScrollController _controller4;

class NoteScreen extends StatefulWidget {
  static final String id = 'note_screen';

  @override
  _NoteScreenState createState() => _NoteScreenState();
}

class _NoteScreenState extends State<NoteScreen> {
  void _setStateIfAlive() {
    if (mounted) setState(() {});
  }

  Future<void> _refresh() async {
    session.agenda.getData().then((r) {
      if (r.ok) _setStateIfAlive();
    });
    HapticFeedback.mediumImpact();

    return null;
  }

  @override
  void initState() {
    _controller1 = ScrollController();
    _controller2 = ScrollController();
    _controller3 = ScrollController();
    _controller4 = ScrollController();

    super.initState();
  }

  @override
  void dispose() {
    _controller1.dispose();
    _controller2.dispose();
    _controller3.dispose();
    _controller4.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      body: LiquidPullToRefresh(
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
                'NOTE',
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
                  preferredSize: Size.fromHeight(size.width / 8)),
            ),
            SliverList(
              delegate: main.session.note.data.length > 0
                  ? SliverChildListDelegate(
                      [
                        NoteListView(
                          size: size,
                          type: 'NTWN',
                          controller: _controller1,
                        ),
                        NoteListView(
                          size: size,
                          type: 'NTTE',
                          controller: _controller2,
                        ),
                        NoteListView(
                          size: size,
                          type: 'NTCL',
                          controller: _controller3,
                        ),
                        NoteListView(
                          size: size,
                          type: 'NTST',
                          controller: _controller4,
                        ),
                      ],
                    )
                  : SliverChildListDelegate(
                      [
                        Center(
                          child: Text('Non ci sono note!'),
                        )
                      ],
                    ),
            ),
          ],
        ),
        onRefresh: _refresh,
        showChildOpacityTransition: false,
      ),
    );
  }
}

class NoteListView extends StatefulWidget {
  const NoteListView({
    Key key,
    @required this.size,
    @required this.type,
    @required this.controller,
  }) : super(key: key);

  final Size size;
  final String type;
  final ScrollController controller;

  @override
  _NoteListViewState createState() => _NoteListViewState();
}

class _NoteListViewState extends State<NoteListView> {
  @override
  void initState() {
    widget.controller.addListener(() async {
      if (widget.controller.hasClients) {
        int n = widget.controller.offset.toInt() ~/ 300;
        int ntte = main.session.note.data
            .where((nota) => nota.tipologia == "NTTE")
            .length;
        int ntcl = main.session.note.data
            .where((nota) => nota.tipologia == "NTCL")
            .length;
        int ntwn = main.session.note.data
            .where((nota) => nota.tipologia == "NTWN")
            .length;

        if (widget.type == "NTTE") {
          print('cancellata nota ntte:' + (n).toString());
          await main.session.note.data[n].seen();
          setState(() {});
          if (main.session.note.data[n].isNew) {}
        } else if (widget.type == "NTCL") {
          print('cancellata nota ntcl:' + (ntte + n).toString());
          await main.session.note.data[ntte + n].seen();
          setState(() {});
        } else if (widget.type == "NTWN") {
          print('cancellata nota ntwn:' + (ntte + ntcl + n).toString());
          await main.session.note.data[ntte + ntcl + n].seen();
          setState(() {});
        } else if (widget.type == "NTST") {
          print('cancellata nota nntst:' + (ntte + ntcl + ntwn + n).toString());
          await main.session.note.data[ntte + ntcl + ntwn + n].seen();
          setState(() {});
        }
      }
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (main.session.note.data
            .where((nota) => nota.tipologia == widget.type)
            .length <
        1)
      return Offstage();
    else
      return Padding(
        padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Text(
                  '• ' + Nota.getTipo(widget.type),
                  style: TextStyle(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.white60
                        : Colors.black54,
                    fontSize: 23,
                  ),
                )
              ],
            ),
            SizedBox(
              height: 5.0,
            ),
            SizedBox(
              height: widget.size.height / 4,
              child: ListView.builder(
                  controller: widget.controller,
                  scrollDirection: Axis.horizontal,
                  itemCount: main.session.note.data
                      .where((nota) => nota.tipologia == widget.type)
                      .length,
                  itemBuilder: (BuildContext context, int index) {
                    List<Nota> note = main.session.note.data
                        .where((nota) => nota.tipologia == widget.type)
                        .toList();
                    if (note[0].isNew)
                      () async {
                        await note[0]?.seen();
                      }();
                    return Row(
                      children: <Widget>[
                        SizedBox(
                          width: 10.0,
                        ),
                        NotaCard(
                          size: widget.size,
                          nota: note[index],
                        ),
                      ],
                    );
                  }),
            ),
          ],
        ),
      );
  }
}

class NotaCard extends StatefulWidget {
  const NotaCard({
    Key key,
    @required this.size,
    @required this.nota,
  }) : super(key: key);

  final Size size;
  final Nota nota;

  @override
  _NotaCardState createState() => _NotaCardState();
}

class _NotaCardState extends State<NotaCard> {
  @override
  Widget build(BuildContext context) => GestureDetector(
        onDoubleTap: () => showDialog(
          context: context,
          builder: (context) => Padding(
            padding: EdgeInsets.symmetric(
                horizontal: 10.0,
                vertical: MediaQuery.of(context).size.height / 7),
            child: Dialog(
                backgroundColor: Theme.of(context).brightness == Brightness.dark
                    ? Color(0xFF33333D)
                    : Color(0xFFD2D1D7),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: _buildContent(context, true),
                )),
          ),
        ),
        child: Container(
          width: widget.size.height / 2.5,
          padding: EdgeInsets.all(10.0),
          child: Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black26,
                        blurRadius: 3.0,
                        spreadRadius: 4.5)
                  ],
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Color(0xFF33333D)
                      : Color(0xFFD2D1D7)),
              padding: const EdgeInsets.all(10.0),
              child: _buildContent(context, false)),
        ),
      );

  Widget _buildContent(BuildContext context, bool grande) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Container(
          decoration: BoxDecoration(
              color: Globals.coloriNote[widget.nota.tipologia],
              borderRadius: BorderRadius.circular(10.0)),
          child: Row(
            children: <Widget>[
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.max,
                children: [
                  Padding(
                    padding: EdgeInsets.all(8),
                    child: Icon(Globals.iconeNote[widget.nota.tipologia],
                        size: 25.0, color: Colors.black),
                  ),
                ],
              ),
            ],
          ),
        ),
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(left: 12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                AutoSizeText(widget.nota?.autore ?? 'Preside',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    minFontSize: 10.0,
                    maxFontSize: 15.0,
                    style: TextStyle(
                      fontSize: 15.0,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'CoreSans',
                    )),
                SizedBox(
                  height: 10.0,
                ),
                Expanded(
                  child: grande
                      ? SingleChildScrollView(
                          child: AutoSizeText(widget.nota.motivazione,
                              overflow: TextOverflow.ellipsis,
                              minFontSize: 13.0,
                              maxFontSize: 15.0,
                              maxLines: 100,
                              style: TextStyle(
                                color: Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? Colors.white54
                                    : Colors.black54,
                                height: 1.2,
                              )),
                        )
                      : AutoSizeText(widget.nota.motivazione,
                          overflow: TextOverflow.ellipsis,
                          minFontSize: 12.0,
                          maxFontSize: 13.0,
                          maxLines: 10,
                          style: TextStyle(
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                    ? Colors.white54
                                    : Colors.black54,
                          )),
                ),
                Padding(
                  padding:
                      EdgeInsets.only(bottom: 2.0, top: grande ? 10.0 : 0.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: <Widget>[
                      Icon(
                        Icons.access_time,
                        size: 14.0,
                      ),
                      SizedBox(width: 5.0),
                      Text(
                        widget.nota?.date != null
                            ? Nota.getDateWithSlashes(widget.nota?.date)
                            : Nota.getDateWithSlashesShort(
                                    widget.nota?.inizio) +
                                ' - ' +
                                Nota.getDateWithSlashesShort(widget.nota?.fine),
                        style: TextStyle(fontSize: grande ? 14 : 11.0),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
        Center(
          child: widget.nota.isNew ?? true
              ? Icon(
                  Icons.brightness_1,
                  color: Colors.yellow,
                  size: 15.0,
                )
              : SizedBox(),
        ),
      ],
    );
  }
}

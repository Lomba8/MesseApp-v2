developedimport 'package:Messedaglia/main.dart' as main;
import 'package:Messedaglia/preferences/globals.dart';
import 'package:Messedaglia/registro/note_registro_data.dart';
import 'package:Messedaglia/screens/menu_screen.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';

import '../main.dart';

class NoteScreen extends StatefulWidget {
  //TODO implementare il liquidpulltorefresh con HapticFeedback.mediumImpact(); alla fine

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

  ScrollController _controller1;
  ScrollController _controller2;
  ScrollController _controller3;
  ScrollController _controller4;

  @override
  void initState() {
    _controller1 = ScrollController();
    _controller2 = ScrollController();
    _controller3 = ScrollController();
    _controller4 = ScrollController();
    _controller1.addListener(() {
      if (_controller1.hasListeners) {
        print(_controller1.position.atEdge);
      }
    });
    _controller2.addListener(() {
      if (_controller2.hasListeners) {
        // print(_controller2.position.atEdge);
        print('cancellata nota n:' +
            (_controller2.offset.toInt() / 300)
                .toInt()
                .toString()); //TODO implememntarlo con batch.delete e creare un metodo nella classe Nota
      }
    });
    _controller3.addListener(() {
      if (_controller3.hasListeners) {
        print(_controller3.position.atEdge);
      }
    });
    _controller4.addListener(() {
      if (_controller4.hasListeners) {
        print(_controller4.position.atEdge);
      }
    });

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
              delegate: SliverChildListDelegate(
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

class NoteListView extends StatelessWidget {
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
  Widget build(BuildContext context) {
    if (main.session.note.data.where((nota) => nota.tipologia == type).length <
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
                  '• ' + Nota.getTipo(type),
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
              height: size.height / 5.5,
              child: ListView.builder(
                  controller: controller,
                  scrollDirection: Axis.horizontal,
                  itemCount: main.session.note.data
                      .where((nota) => nota.tipologia == type)
                      .length,
                  itemBuilder: (BuildContext context, int index) {
                    List note = main.session.note.data
                        .where((nota) => nota.tipologia == type)
                        .toList();
                    return Row(
                      children: <Widget>[
                        SizedBox(
                          width: 10.0,
                        ),
                        Card(
                          size: size,
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

class Card extends StatelessWidget {
  const Card({
    Key key,
    @required this.size,
    @required this.nota,
  }) : super(key: key);

  final Size size;
  final Nota nota;

  @override
  Widget build(BuildContext context) => GestureDetector(
        onDoubleTap: () => showDialog(
          context: context,
          builder: (context) => Padding(
            padding: EdgeInsets.symmetric(
                horizontal: 10.0,
                vertical: MediaQuery.of(context).size.height / 6),
            child: Dialog(
                backgroundColor: Theme.of(context).brightness == Brightness.dark
                    ? Color(0xFF33333D)
                    : Color(0xFFD2D1D7),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: _buildContent(context),
                )),
          ),
        ),
        child: Container(
          width: size.height / 3,
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
              child: _buildContent(context)),
        ),
      );

  Widget _buildContent(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Container(
          decoration: BoxDecoration(
              color: Globals.coloriNote[nota.tipologia],
              borderRadius: BorderRadius.circular(10.0)),
          child: Row(
            children: <Widget>[
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.max,
                children: [
                  Padding(
                    padding: EdgeInsets.all(8),
                    child: Icon(Globals.iconeNote[nota.tipologia],
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
                AutoSizeText(nota?.autore ?? 'Preside',
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
                  child: AutoSizeText(nota.motivazione,
                      overflow: TextOverflow.ellipsis,
                      minFontSize: 12.0,
                      maxFontSize: 13.0,
                      maxLines: 6,
                      style: TextStyle(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.white54
                            : Colors.black54,
                      )),
                ),
                Padding(
                  padding: EdgeInsets.only(bottom: 2.0, top: 0.0),
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
                        nota?.date != null
                            ? Nota.getDateWithSlashes(nota?.date)
                            : Nota.getDateWithSlashesShort(nota?.inizio) +
                                ' - ' +
                                Nota.getDateWithSlashesShort(nota?.fine),
                        style: TextStyle(fontSize: 11.0),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
        Center(
          child: nota.isNew ?? true
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

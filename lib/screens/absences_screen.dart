import 'package:Messedaglia/main.dart' as main;
import 'package:Messedaglia/main.dart';
import 'package:Messedaglia/preferences/globals.dart';
import 'package:Messedaglia/registro/absences_registro_data.dart';
import 'package:Messedaglia/screens/menu_screen.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:neumorphic/neumorphic.dart';

ScrollController _controller1;
ScrollController _controller2;
ScrollController _controller3;

class AbsencesScreen extends StatefulWidget {
  @override
  _AbsencesScreenState createState() => _AbsencesScreenState();
}

class _AbsencesScreenState extends State<AbsencesScreen> {
  void _setStateIfAlive() {
    if (mounted) setState(() {});
  }

  Future<void> _refresh() async {
    session.absences.getData().then((r) {
      if (r.ok) _setStateIfAlive();
    });
    HapticFeedback.mediumImpact();

    return null;
  }

  bool giustificare = true;

  @override
  void initState() {
    super.initState();
    _controller1 = ScrollController();
    _controller2 = ScrollController();
    _controller3 = ScrollController();
  }

  @override
  void dispose() {
    _controller1.dispose();
    _controller2.dispose();
    _controller3.dispose();
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
                  'GIUSTIFICAZIONI',
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
                    Container(
                      margin: EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 20.0),
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Container(
                            margin: EdgeInsets.only(left: 15.0),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.502),
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            child: FlatButton(
                              onPressed: () {/*TODO*/},
                              child: Text(
                                giustificare
                                    ? 'Da Giustificare'
                                    : 'Giustificate',
                                style: TextStyle(
                                  fontSize: 15.0,
                                  fontFamily: 'CoreSans',
                                  color: Colors.white70,
                                ),
                              ),
                              splashColor: Colors.white.withOpacity(0.3),
                              padding: EdgeInsets.symmetric(
                                  horizontal: 10.0, vertical: 0.0),
                            ),
                          ),
                          FlatButton.icon(
                            onPressed: () {/*TODO*/},
                            icon: Icon(
                              MdiIcons.informationVariant,
                              size: 30.0,
                              color: Colors.white70,
                            ),
                            label: Offstage(),
                          )
                        ],
                      ),
                    ),
                    AbsencesListView(
                      type: 'ABA0',
                      controller: _controller1,
                      size: size,
                    ),
                    AbsencesListView(
                      type: 'ABR0',
                      controller: _controller2,
                      size: size,
                    ),
                    AbsencesListView(
                      type: 'ABU0',
                      controller: _controller3,
                      size: size,
                    )
                  ],
                ),
              )
            ],
          ),
          onRefresh: _refresh),
    );
  }
}

class AbsencesListView extends StatefulWidget {
  const AbsencesListView({Key key, this.size, this.type, this.controller})
      : super(key: key);

  final Size size;
  final String type;
  final ScrollController controller;

  @override
  _AbsencesListViewState createState() => _AbsencesListViewState();
}

class _AbsencesListViewState extends State<AbsencesListView> {
  List<Assenza> assenze = List();
  @override
  void initState() {
    super.initState();
    //TODO controllers stuff
    main.session.absences.data
        .forEach((k, v) => v.type == widget.type ? assenze.add(v) : null);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 20.0, left: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Text(
                ' • ' + Assenza.getTipo(widget.type),
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
            height: widget.size.height / 5.5,
            child: ListView.builder(
                controller: widget.controller,
                scrollDirection: Axis.horizontal,
                itemCount: assenze.length,
                itemBuilder: (BuildContext context, int index) {
                  assenze[0]?.seen();
                  return Row(
                    children: <Widget>[
                      SizedBox(
                        width: 10.0,
                      ),
                      AbsenceCard(
                        size: widget.size,
                        assenza: assenze[index],
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

class AbsenceCard extends StatefulWidget {
  const AbsenceCard({
    Key key,
    @required this.size,
    @required this.assenza,
  }) : super(key: key);

  final Size size;
  final Assenza assenza;

  @override
  _AbsenceCardState createState() => _AbsenceCardState();
}

class _AbsenceCardState extends State<AbsenceCard> {
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
          width: widget.size.height / 3,
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
              color: Globals.coloriAssenze[widget.assenza.type],
              borderRadius: BorderRadius.circular(10.0)),
          child: Row(
            children: <Widget>[
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.max,
                children: [
                  Padding(
                    padding: EdgeInsets.all(8),
                    child: Icon(
                        Globals.iconeAssenze[widget.assenza.justification],
                        size: 25.0,
                        color: Colors.black),
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
                AutoSizeText('Da mettere ora',
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
                          child: AutoSizeText('cosa?',
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
                      : AutoSizeText('cosa?',
                          overflow: TextOverflow.ellipsis,
                          minFontSize: 12.0,
                          maxFontSize: 13.0,
                          maxLines: 6,
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
                        Assenza.getDateWithSlashes(widget.assenza.date),
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
          child: widget.assenza.isNew ?? true
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

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

class AbsencesScreen extends StatefulWidget {
  @override
  _AbsencesScreenState createState() => _AbsencesScreenState();
}

class _AbsencesScreenState extends State<AbsencesScreen>
    with SingleTickerProviderStateMixin {
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

  bool daGiustificare = true;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      body: LiquidPullToRefresh(
        showChildOpacityTransition: false,
        onRefresh: _refresh,
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
                          // decoration: BoxDecoration(
                          //   color: Colors.white.withOpacity(0.502),
                          //   borderRadius: BorderRadius.circular(10.0),
                          // ),
                          child: FlatButton(
                            onPressed: () {},
                            padding: EdgeInsets.symmetric(
                                horizontal: 10.0, vertical: 0.0),
                            child: Column(
                              children: <Widget>[
                                Stack(
                                  children: <Widget>[
                                    SizedBox(
                                      width: size.width * 0.5,
                                    ),
                                    SizedBox(height: 20),
                                    GestureDetector(
                                      onTap: () {
                                        daGiustificare = !daGiustificare;
                                        setState(() {});
                                      },
                                      child: Text(
                                        'Da Giustificare',
                                        style: TextStyle(
                                          fontSize: 15.0,
                                          fontFamily: 'CoreSans',
                                          color: Colors.white70,
                                        ),
                                      ),
                                    ),
                                    Positioned.fill(
                                      child: Align(
                                        alignment: Alignment(1, 1),
                                        child: GestureDetector(
                                          onTap: () {
                                            daGiustificare = !daGiustificare;
                                            setState(() {});
                                          },
                                          child: Text(
                                            'Giustificate',
                                            style: TextStyle(
                                              fontSize: 15.0,
                                              fontFamily: 'CoreSans',
                                              color: Colors.white70,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      top: 20,
                                      child: AnimatedContainer(
                                        margin: EdgeInsets.only(
                                            left: daGiustificare
                                                ? 0
                                                : size.width * 0.315),
                                        width: daGiustificare
                                            ? size.width * 0.25
                                            : size.width * 0.18,
                                        height: 0.7,
                                        duration: Duration(milliseconds: 150),
                                        decoration: BoxDecoration(
                                          border: Border(
                                            bottom: BorderSide(
                                              color: Colors.white70,
                                              width: 1.5,
                                            ),
                                          ),
                                        ),
                                        child: Container(),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        FlatButton.icon(
                          onPressed: () {
                            setState(() {
                              daGiustificare = !daGiustificare;
                            });
                            print('giorni: ' +
                                (main.session.absences.giorniRestanti() ~/ 5)
                                    .toString());
                            print('ore: ' +
                                (main.session.absences
                                        .giorniRestanti()
                                        .remainder(5))
                                    .toString());
                          },
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
                  if (main.session.absences.data.values.every((v) => (v
                              .justified ==
                          main.session.absences.data.values.first.justified)) &&
                      main.session.absences.data.values.first.justified ==
                          true &&
                      daGiustificare)
                    SizedBox(
                      height: size.height / 5.5,
                      child: Center(
                        child: Text(
                          'Tutto giustificato',
                          style: TextStyle(
                            fontFamily: 'CoreSans',
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  if (main.session.absences.data.values.every((v) => (v
                              .justified ==
                          main.session.absences.data.values.first.justified)) &&
                      main.session.absences.data.values.first.justified ==
                          false &&
                      !daGiustificare)
                    SizedBox(
                      height: size.height / 5.5,
                      child: Center(
                        child: Text(
                          'Tutto da giustificare',
                          style: TextStyle(
                            fontFamily: 'CoreSans',
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  AbsencesListView(
                      type: 'ABA0',
                      size: size,
                      ancoraDaGiustificare: daGiustificare),
                  AbsencesListView(
                      type: 'ABR0',
                      size: size,
                      ancoraDaGiustificare: daGiustificare),
                  AbsencesListView(
                      type: 'ABU0',
                      size: size,
                      ancoraDaGiustificare: daGiustificare)
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

class AbsencesListView extends StatefulWidget {
  AbsencesListView({Key key, this.size, this.type, this.ancoraDaGiustificare})
      : super(key: key);

  final Size size;
  final String type;
  final bool ancoraDaGiustificare;

  @override
  _AbsencesListViewState createState() => _AbsencesListViewState();
}

class _AbsencesListViewState extends State<AbsencesListView> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    List<Assenza> assenze = List();
    main.session.absences.data.forEach((k, v) {
      if (v.type == widget.type) assenze.add(v);
    });

    return Padding(
      padding: EdgeInsets.only(bottom: 20.0, left: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          if (assenze
                  .where((e) => e.justified == !widget.ancoraDaGiustificare)
                  .length >
              0)
            Text(
              ' • (' +
                  assenze
                      .where((e) => e.justified == !widget.ancoraDaGiustificare)
                      .length
                      .toString() +
                  ') ' +
                  Assenza.getTipo(widget.type),
              style: TextStyle(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white60
                    : Colors.black54,
                fontSize: 23,
              ),
            ),
          SizedBox(
            height: 10.0,
          ),
          if (assenze.isEmpty)
            SizedBox(
              height: widget.size.height / 5,
              child: Center(
                child: Text(
                  'Nessun evento',
                  style: TextStyle(
                    fontFamily: 'CoreSans',
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          if (assenze.isNotEmpty &&
              assenze
                      .where((e) => e.justified == !widget.ancoraDaGiustificare)
                      .length >
                  0)
            SizedBox(
              height: widget.size.height / 5,
              child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: assenze
                      .where((e) => e.justified == !widget.ancoraDaGiustificare)
                      .length,
                  itemBuilder: (BuildContext context, int index) {
                    assenze[0]?.seen();
                    return Row(
                      children: <Widget>[
                        SizedBox(
                          width: 10.0,
                        ),
                        Container(
                          padding: EdgeInsets.only(bottom: 10.0),
                          margin: EdgeInsets.only(right: 10.0),
                          child: AbsenceCard(
                            size: widget.size,
                            assenza: assenze
                                .where((e) =>
                                    e.justified == !widget.ancoraDaGiustificare)
                                .toList()[index],
                          ),
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
  Widget build(BuildContext context) => Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
        margin: EdgeInsets.zero,
        clipBehavior: Clip.none,
        color: Colors.transparent,
        elevation: 5.0,
        child: Container(
            width: widget.size.height / 2.7,
            padding: EdgeInsets.all(20.0),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: Theme.of(context).brightness == Brightness.dark
                    ? Color(0xFF33333D)
                    : Color(0xFFD2D1D7)),
            child: _buildContent(context, false)),
      );

  Widget _buildContent(BuildContext context, bool grande) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Container(
          margin: EdgeInsets.fromLTRB(10, 0, 10, 5),
          decoration: BoxDecoration(
              color: Globals.coloriAssenze[widget.assenza.type],
              borderRadius: BorderRadius.circular(10.0)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              Padding(
                padding: widget.assenza.justification.isNotEmpty
                    ? EdgeInsets.fromLTRB(30, 8, 0, 8)
                    : EdgeInsets.fromLTRB(70, 8, 0, 8),
                child: Icon(Globals.iconeAssenze[widget.assenza.justification],
                    size: 25.0, color: Colors.black),
              ),
              widget.assenza.justification.isNotEmpty
                  ? Expanded(
                      child: Column(
                        children: <Widget>[
                          Padding(
                            padding: EdgeInsets.all(8),
                            child: AutoSizeText(
                              widget.assenza.justification.contains('traffico')
                                  ? 'Traffico'
                                  : widget.assenza.justification,
                              maxLines: 2,
                              wrapWords: true,
                              softWrap: true,
                              maxFontSize: 15.0,
                              minFontSize: 15.0,
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 15.0,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  : Offstage(),
            ],
          ),
        ),
        Expanded(
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: 20.0),
            child: Row(
              mainAxisAlignment: widget.assenza.hour != null
                  ? MainAxisAlignment.spaceAround
                  : MainAxisAlignment.center,
              children: <Widget>[
                widget.assenza.hour != null
                    ? AutoSizeText(
                        widget.assenza.hour.toString() + 'ᵃ' + ' ora',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        minFontSize: 10.0,
                        maxFontSize: 15.0,
                        style: TextStyle(
                          fontSize: 15.0,
                          fontFamily: 'CoreSans',
                        ),
                      )
                    : Offstage(),
                Text(
                  Assenza.getDateWithSlashes(widget.assenza.date),
                  style: TextStyle(
                    fontSize: 15.0,
                    fontFamily: 'CoreSans',
                  ),
                )
              ],
            ),
          ),
        ),
      ],
    );
  }
}

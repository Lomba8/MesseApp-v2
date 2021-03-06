import 'package:Messedaglia/main.dart' as main;
import 'package:Messedaglia/main.dart';
import 'package:Messedaglia/preferences/globals.dart';
import 'package:Messedaglia/registro/absences_registro_data.dart';
import 'package:Messedaglia/utils/orariUtils.dart';
import 'package:Messedaglia/widgets/background_painter.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class AbsencesScreen extends StatefulWidget {
  static final String id = 'assenze_screen';

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
  Animation<double> _heightAnimation;
  AnimationController _animationController;

  @override
  void initState() {
    _animationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 200));
    _heightAnimation =
        Tween<double>(begin: 0, end: 1).animate(_animationController)
          ..addListener(() {
            setState(() {
              // The state that has changed here is the animation object’s value.
            });
          });
    super.initState();
  }

  @override
  void dispose() {
    _animationController.dispose();
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
                painter: BackgroundPainter(Theme.of(context), back: true),
                size: Size.infinite,
              ),
              bottom: PreferredSize(
                  child: Container(),
                  preferredSize: Size.fromHeight(size.width / 8)),
            ),
            SliverList(
              delegate: SliverChildListDelegate(
                [
                  AnimatedBuilder(
                    animation: _animationController,
                    builder: (context, child) => Container(
                      margin: EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 20.0),
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Container(
                            margin: EdgeInsets.only(left: 15.0),
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
                                        bottom: 5,
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
                              if (_animationController.value == 0.0)
                                _animationController.forward();
                              else if (_animationController.value == 1.0)
                                _animationController.reverse();
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
                  ),
                  Row(
                    children: <Widget>[
                      Container(
                        margin: EdgeInsets.only(
                          bottom: _heightAnimation.value * 20,
                          left: 20.0,
                        ),
                        height: _heightAnimation.value * 60,
                        child: Center(
                          child: selectedClass == null
                              ? GestureDetector(
                                  onTap: () => showDialog(
                                      context: context,
                                      barrierDismissible: true,
                                      builder: (context) => Dialog(
                                          shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(10))),
                                          child: Padding(
                                            padding: EdgeInsets.only(
                                                left: 8.0,
                                                right: 8.0,
                                                top: 15.0),
                                            child: _selectionChildren,
                                          ))),
                                  child:
                                      Text('  Tocca per scegliere la classe'))
                              : Text(
                                  'Puoi fare ancora:\n' +
                                      ' • ' +
                                      (main.session.absences.giorniRestanti() ~/
                                              24)
                                          .toString() +
                                      ' giorni di assenza\n' +
                                      ' • ' +
                                      main.session.absences
                                          .giorniRestanti()
                                          .remainder(24)
                                          .toInt()
                                          .toString() +
                                      ' or${main.session.absences.giorniRestanti().remainder(24) > 1 ? "e" : "a"} di assenza',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 14,
                                    height: 1.5,
                                    fontFamily: 'CoreSans',
                                    letterSpacing: 1.6,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                  if (main.session.absences.data.isEmpty ||
                      main.session.absences.data.values.every((v) =>
                              (v.justified ==
                                  main.session.absences.data.values.first
                                      .justified)) &&
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
                    )
                  else if (main.session.absences.data.values.every((v) => (v
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
                    )
                  else
                    Column(
                      children: <Widget>[
                        AbsencesListView(
                          type: 'ABA0',
                          size: size,
                          ancoraDaGiustificare: daGiustificare,
                        ),
                        AbsencesListView(
                          type: 'ABR0',
                          size: size,
                          ancoraDaGiustificare: daGiustificare,
                        ),
                        AbsencesListView(
                          type: 'ABU0',
                          size: size,
                          ancoraDaGiustificare: daGiustificare,
                        ),
                        AbsencesListView(
                          type: 'ABR1',
                          size: size,
                          ancoraDaGiustificare: daGiustificare,
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

  GridView get _selectionChildren {
    TextStyle titleStyle = TextStyle(
        color: Theme.of(context).brightness == Brightness.light
            ? Colors.black.withOpacity(0.75)
            : Colors.white54,
        fontSize: 20);
    List<Widget> children = [
      AspectRatio(
        aspectRatio: 2,
        child: Text(
          'I',
          style: titleStyle,
          textAlign: TextAlign.center,
        ),
      ),
      Text(
        'II',
        style: titleStyle,
        textAlign: TextAlign.center,
      ),
      Text(
        'III',
        style: titleStyle,
        textAlign: TextAlign.center,
      ),
      Text(
        'IV',
        style: titleStyle,
        textAlign: TextAlign.center,
      ),
      Text(
        'V',
        style: titleStyle,
        textAlign: TextAlign.center,
      ),
      Padding(
        padding: EdgeInsets.only(left: 3.0),
        child: Text(
          '   _ _ _ _ _ ',
          style: TextStyle(fontSize: 5.0),
        ),
      ),
      Padding(
        padding: EdgeInsets.only(left: 3.0),
        child: Text(
          '   _ _ _ _ _ ',
          style: TextStyle(fontSize: 5.0),
        ),
      ),
      Padding(
        padding: EdgeInsets.only(left: 3.0),
        child: Text(
          '   _ _ _ _ _ ',
          style: TextStyle(fontSize: 5.0),
        ),
      ),
      Padding(
        padding: EdgeInsets.only(left: 3.0),
        child: Text(
          '   _ _ _ _ _ ',
          style: TextStyle(fontSize: 5.0),
        ),
      ),
      Padding(
        padding: EdgeInsets.only(left: 3.0),
        child: Text(
          '   _ _ _ _ _ ',
          style: TextStyle(fontSize: 5.0),
        ),
      ),
    ];

    String sezioni = 'ABCDEFGHILMNOPQRSTUVZ';
    for (int sezione = 0; sezione < sezioni.length; sezione++) {
      bool hasMore = false;
      for (int anno = 1; anno <= 5; anno++) {
        if (orari.containsKey('$anno${sezioni[sezione]}')) {
          children.add(GestureDetector(
            onTap: () {
              Navigator.of(context, rootNavigator: true).pop();
              main.prefs.setString(
                  'selectedClass', selectedClass = '$anno${sezioni[sezione]}');
              setState(() {});
            },
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(20)),
                color: '$anno${sezioni[sezione]}' == selectedClass
                    ? Theme.of(context).brightness == Brightness.dark
                        ? Colors.white
                        : Colors.black
                    : Colors.transparent,
              ),
              child: Center(
                child: Text(
                  sezioni[sezione],
                  style: TextStyle(
                      color: ('$anno${sezioni[sezione]}' == selectedClass) !=
                              (Theme.of(context).brightness == Brightness.light)
                          ? Colors.black
                          : Colors.white,
                      fontSize: 16,
                      fontFamily: 'CoreSans'),
                ),
              ),
            ),
          ));
          hasMore = true;
        } else
          children.add(Container());
      }
      if (!hasMore) break;
    }

    return GridView.count(
      physics: NeverScrollableScrollPhysics(),
      crossAxisCount: 5,
      childAspectRatio: 2,
      children: children,
      shrinkWrap: true,
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
    List<Assenza> assenze = List<Assenza>.empty(growable: true);
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
                child: AutoSizeText(
                  'Non ci sono ' +
                      Assenza.getTipo(widget.type) +
                      ' da giustificare',
                  maxFontSize: 20,
                  minFontSize: 15,
                  maxLines: 1,
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
            color: widget.assenza.hoursAbsence.isNotEmpty
                ? Colors.blue
                : Globals.coloriAssenze[widget.assenza.type],
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: Row(
            mainAxisAlignment: widget.assenza.justification == null
                ? MainAxisAlignment.center
                : MainAxisAlignment.spaceAround,
            children: <Widget>[
              widget.assenza.justification == null
                  ? Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 0,
                        vertical: 10.0,
                      ),
                      child: Icon(
                        MdiIcons.help,
                        size: 25.0,
                        color: Colors.black,
                      ),
                    )
                  : Padding(
                      padding: widget.assenza.justification?.isNotEmpty ?? false
                          ? EdgeInsets.fromLTRB(30, 8, 0, 8)
                          : EdgeInsets.fromLTRB(70, 8, 0, 8),
                      child: Icon(
                          Globals.iconeAssenze[widget.assenza.justification],
                          size: 25.0,
                          color: Colors.black),
                    ),
              widget.assenza.justification?.isNotEmpty ?? false
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
              mainAxisAlignment: widget.assenza.hour != null ||
                      widget.assenza.hoursAbsence.isNotEmpty
                  ? MainAxisAlignment.spaceAround
                  : MainAxisAlignment.center,
              children: <Widget>[
                widget.assenza.hour != null ||
                        widget.assenza.hoursAbsence.isNotEmpty
                    ? AutoSizeText(
                        widget.assenza.hour != null
                            ? widget.assenza.hour.toString() + 'ᵃ' + ' ora'
                            : widget.assenza.hoursAbsence
                                .map((skippedLesson) =>
                                    skippedLesson['hPos'].toString() + 'ᵃ ')
                                .join()
                                .toString(),
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

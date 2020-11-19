import 'package:Messedaglia/main.dart' as main;
import 'package:Messedaglia/preferences/globals.dart';
import 'package:Messedaglia/registro/didattica_registro_data.dart';
import 'package:Messedaglia/widgets/background_painter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:open_file/open_file.dart';

class DidatticaScreen extends StatefulWidget {
  static final String id = 'didattica_screen';

  @override
  _DidatticaScreenData createState() => _DidatticaScreenData();
}

class _DidatticaScreenData extends State<DidatticaScreen>
    with SingleTickerProviderStateMixin {
  CustomDirectory directory = main.session.didactics.data;

  AnimationController _animationController;
  Animation<double> _animation1, _animation2;

  bool _loading = false;

  void _setStateIfAlive() {
    if (mounted) setState(() {});
  }

  Future<void> _refresh() async {
    main.session.didactics.getData().then((r) {
      if (r.ok) _setStateIfAlive();
    });
    HapticFeedback.mediumImpact();

    return null;
  }

  @override
  void initState() {
    _animationController = AnimationController(
        vsync: this, duration: Duration(seconds: 1), value: 0.0);
    _animation2 = CurvedAnimation(
        curve: Curves.bounceIn,
        parent: _animationController,
        reverseCurve: Curves.decelerate);
    _animation1 = _animation2.drive(Tween(begin: 0.0, end: -100.0));
    _animation2 = _animation2.drive(Tween(begin: 1, end: 0.5));
    _animationController.repeat(reverse: true);
    super.initState();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ModalProgressHUD(
        inAsyncCall: _loading,
        dismissible: false,
        child: Scaffold(
          body: LiquidPullToRefresh(
            onRefresh: _refresh,
            showChildOpacityTransition: false,
            child: CustomScrollView(slivers: <Widget>[
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
                  'DIDATTICA',
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
                actions: <Widget>[
                  IconButton(
                      icon: Icon(
                        Icons.clear_all,
                        color: Colors.white54,
                      ),
                      onPressed: () =>
                          setState(() => directory.view(recursive: true)))
                ],
                bottom: PreferredSize(
                    child: Container(),
                    preferredSize:
                        Size.fromHeight(MediaQuery.of(context).size.width / 8)),
              ),
              SliverGrid.count(
                  crossAxisCount: 2,
                  childAspectRatio: 0.9,
                  children: <Widget>[
                    if (directory.parent != null)
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: GestureDetector(
                          onTap: () => setState(() {
                            if (directory.children.values.every((val) =>
                                val.changed ==
                                    directory.children.values?.first?.changed &&
                                directory.children.values?.first?.changed ==
                                    false)) directory = directory.view();
                            directory = directory.parent;
                          }),
                          child: Column(
                            children: <Widget>[
                              Stack(
                                alignment: Alignment.center,
                                children: <Widget>[
                                  Icon(Icons.folder,
                                      size: 125, color: Colors.white54),
                                  Icon(
                                    Icons.arrow_back,
                                    size: 30,
                                    color: Colors.black,
                                  ),
                                ],
                              ),
                              Text(
                                '..',
                                textAlign: TextAlign.center,
                              )
                            ],
                          ),
                        ),
                      )
                  ]
                      .followedBy(directory.children.values
                          .map<Widget>((path) => Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: GestureDetector(
                                  behavior: HitTestBehavior.opaque,
                                  onTap: () async {
                                    if (path is CustomDirectory) {
                                      setState(() {
                                        directory = path;
                                      });
                                    } else {
                                      path.changed = false;
                                      setState(() => _loading = !_loading);
                                      String filePath =
                                          await (path as CustomFile).download();
                                      setState(() => _loading = !_loading);
                                      OpenFile.open(filePath);
                                    }
                                  },
                                  child: Column(
                                    children: <Widget>[
                                      Stack(
                                        alignment: Alignment.center,
                                        children: <Widget>[
                                          Icon(
                                            path is CustomDirectory
                                                ? Icons.folder
                                                : (path as CustomFile).type ==
                                                        'link'
                                                    ? Icons.link
                                                    : (Globals.estensioni[
                                                            (path as CustomFile)
                                                                .type] ??
                                                        {
                                                          'icona': Icons
                                                              .insert_drive_file
                                                        })['icona'],
                                            size: 125,
                                            color: (path is CustomDirectory
                                                    ? (main.session.subjects
                                                                .subjectTheme(
                                                                    path
                                                                        .name) ??
                                                            main.session
                                                                .subjects
                                                                .subjectTheme(path
                                                                    .parent
                                                                    ?.name) ??
                                                            {})['colore']
                                                        ?.withOpacity(0.5)
                                                    : (Globals.estensioni[
                                                            (path as CustomFile)
                                                                .type] ??
                                                        {})['colore']) ??
                                                Colors.white54,
                                          ),
                                          Positioned(
                                            left: 20,
                                            top: 30,
                                            child: Icon(
                                              Icons.brightness_1,
                                              color: path.changed
                                                  ? Colors.yellow
                                                  : Colors.transparent,
                                              size: 20,
                                            ),
                                          ),
                                          if (path is CustomDirectory)
                                            Positioned(
                                              right: 15,
                                              bottom: 25,
                                              child: Icon(
                                                (main.session.subjects
                                                        .subjectTheme(
                                                            path.name) ??
                                                    main.session.subjects
                                                        .subjectTheme(path
                                                            .parent?.name) ??
                                                    {})['icona'],
                                                size: 20,
                                                color: Colors.white,
                                              ),
                                            ),
                                        ],
                                      ),
                                      Text(
                                        path.name.isEmpty
                                            ? 'Senza nome'
                                            : path.name.contains('.')
                                                ? path.name.substring(0,
                                                    path.name.lastIndexOf('.'))
                                                : path.name,
                                        textAlign: TextAlign.center,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      )
                                    ],
                                  ),
                                ),
                              )))
                      .toList()),
            ]),
          ),
        ),
      );
}

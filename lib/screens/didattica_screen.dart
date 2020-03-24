import 'package:Messedaglia/preferences/globals.dart';
import 'package:Messedaglia/registro/didattica_registro_data.dart';
import 'package:Messedaglia/registro/registro.dart';
import 'package:Messedaglia/screens/menu_screen.dart';
import 'package:flutter/material.dart';

class DidatticaScreen extends StatefulWidget {
  @override
  _DidatticaScreenData createState() => _DidatticaScreenData();
}

class _DidatticaScreenData extends State<DidatticaScreen>
    with SingleTickerProviderStateMixin {
  CustomDirectory directory = RegistroApi.didactics.data;

  AnimationController _animationController;
  Animation<double> _animation1, _animation2;

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
  Widget build(BuildContext context) => Material(
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
              painter: BackgroundPainter(Theme.of(context)),
              size: Size.infinite,
            ),
            actions: <Widget>[
              IconButton(icon: Icon(Icons.clear_all, color: Colors.white54,),
              onPressed: () => setState(() => directory.view(recursive: true)))
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
                      onTap: () => setState(() => directory = directory.view().parent),
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
                                color: Colors.white,
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
                  .followedBy(directory.children.values.map<Widget>((path) => Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () => path is CustomDirectory
                              ? setState(() => directory = path)
                              : (path as CustomFile).download(),
                          child: Column(
                            children: <Widget>[
                              AnimatedBuilder(
                                animation: _animationController,
                                builder: (context, child) => Transform(
                                  transform: Matrix4.identity()
                                    ..translate(0.0, path.changed ? _animation1.value : 0.0)
                                    ..scale(1.0, path.changed ? _animation2.value : 1.0),
                                  alignment: Alignment.bottomCenter,
                                  child: Stack(
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
                                                ? (RegistroApi.subjects
                                                            .subjectTheme(
                                                                path.name) ??
                                                        RegistroApi.subjects
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
                                      if (path is CustomDirectory)
                                        Icon(
                                          (RegistroApi.subjects
                                                  .subjectTheme(path.name) ??
                                              RegistroApi.subjects.subjectTheme(
                                                  path.parent?.name) ??
                                              {})['icona'],
                                          size: 40,
                                          color: Colors.white,
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                              Text(
                                path.name,
                                textAlign: TextAlign.center,
                                maxLines: 2,
                              )
                            ],
                          ),
                        ),
                      )))
                  .toList()),
        ]),
      );
}

import 'package:Messedaglia/registro/bacheca_registro_data.dart';
import 'package:Messedaglia/screens/menu_screen.dart';
import 'package:Messedaglia/registro/registro.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class BachecaScreen extends StatefulWidget {
  @override
  _BachecaScreenState createState() => _BachecaScreenState();
}

class _BachecaScreenState extends State<BachecaScreen> {
  Comunicazione _expanded;

  @override
  Widget build(BuildContext context) => Scaffold(
        body: Builder(
          builder: (context) => CustomScrollView(
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
                  delegate: SliverChildListDelegate([
                ExpansionPanelList(
                  expansionCallback: (panelIndex, isExpanded) => setState(() {
                    setState(() {
                      _expanded = isExpanded
                          ? null
                          : RegistroApi.bacheca.data[panelIndex];
                      if (RegistroApi.bacheca.data[panelIndex].content == null)
                        RegistroApi.bacheca.data[panelIndex]
                            .loadContent(() => setState(() {}));
                    });
                  }),
                  children: RegistroApi.bacheca.data
                      .map<ExpansionPanel>((c) => ExpansionPanel(
                            isExpanded: c == _expanded,
                            headerBuilder: (context, isExpanded) => ListTile(
                              title: Text(
                                c.title,
                                textAlign: TextAlign.center,
                                maxLines: isExpanded ? 100 : 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              leading: Icon(MdiIcons.filePdf),
                            ),
                            body: Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: c.content == null
                                  ? LinearProgressIndicator(
                                      value: null,
                                    )
                                  : Text(c.content,
                                      style:
                                          Theme.of(context).textTheme.bodyText1),
                            ),
                          ))
                      .toList(),
                )
              ]))
            ],
          ),
        ),
      );
}

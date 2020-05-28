import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:Messedaglia/screens/menu_screen.dart';
import 'package:Messedaglia/screens/preferences_screen.dart';
import 'package:Messedaglia/widgets/menu_grid_icons.dart';
import 'package:Messedaglia/widgets/nav_bar_sotto.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:Messedaglia/main.dart' as main;
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:platform_alert_dialog/platform_alert_dialog.dart';
import 'package:sliding_sheet/sliding_sheet.dart';

class Home extends StatefulWidget {
  static final String id = 'home_screen';

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  Uint8List avatar = (main.prefs.getString('avatar') != '' &&
          main.prefs.getString('avatar') != null)
      ? base64Decode(main.prefs.getString('avatar'))
      : null;
  File image;

  bool trimestre = DateTime.now().month > 8 ? true : false;

  Future<void> _refresh() async {
    HapticFeedback.mediumImpact();
    //TODO
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        SizedBox(
          height: MediaQuery.of(context).size.height,
          child: LiquidPullToRefresh(
            onRefresh: _refresh,
            showChildOpacityTransition: false,
            child: CustomScrollView(
              physics: NeverScrollableScrollPhysics(),
              slivers: <Widget>[
                /*SliverAppBar(
                  brightness: Theme.of(context).brightness,
                  centerTitle: true,
                  elevation: 0,
                  backgroundColor: Colors.transparent,
                  title: AutoSizeText(
                    'Ciao ${main.session.nome.split(' ').first}',
                    maxLines: 1,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: Theme.of(context).brightness == Brightness.light
                            ? Colors.black
                            : Colors.white,
                        fontSize: 30,
                        fontWeight: FontWeight.bold),
                  ),
                  leading: Padding(
                    padding: EdgeInsets.only(left: 20.0),
                    child: GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => Preferences()),
                      ),
                      child: Icon(
                        MenuGrid.menu_grid,
                        color: Theme.of(context).brightness != Brightness.light
                            ? Color(0xFFBDBDBD)
                            : Colors.grey[800],
                        size: 50,
                      ),
                    ),
                  ),
                  actions: <Widget>[
                    Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 20.0, vertical: 5.0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(5.0),
                        child: GestureDetector(
                          onTap: () async {
                            image = await ImagePicker.pickImage(
                                source: ImageSource
                                    .gallery); // aggiungere il permeso in Info.plist per l'uso della fotocamera se serve
                            image != null
                                ? main.prefs.setString('avatar',
                                    base64Encode(image.readAsBytesSync()))
                                : null;
                            image != null
                                ? avatar = image.readAsBytesSync()
                                : null;
                            setState(() {});
                          },
                          onLongPress: () async {
                            if (main.prefs.getString('avatar').length > 10)
                              showDialog<void>(
                                context: context,
                                builder: (BuildContext context) {
                                  return PlatformAlertDialog(
                                    title: Text('Resetta avatar.'),
                                    content: SingleChildScrollView(
                                      child: ListBody(
                                        children: <Widget>[
                                          Text(
                                              "\nClicca su 'Reset' per resettare l'avatar."),
                                        ],
                                      ),
                                    ),
                                    actions: <Widget>[
                                      PlatformDialogAction(
                                        child: Text('Annulla'),
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                      ),
                                      PlatformDialogAction(
                                        child: Text('Reset'),
                                        actionType: ActionType.Preferred,
                                        onPressed: () {
                                          main.prefs.setString('avatar', '');
                                          setState(() => avatar = null);
                                          Navigator.pop(context);
                                        },
                                      ),
                                    ],
                                  );
                                },
                              );
                          },
                          child: Container(
                            color: Theme.of(context).accentColor,
                            height: 50,
                            width: 50,
                            child: avatar != null
                                ? FittedBox(
                                    child: Image.memory(avatar),
                                    fit: BoxFit.cover,
                                  )
                                : Icon(MdiIcons.account),
                          ),
                        ),
                      ),
                    )
                  ],
                  bottom: PreferredSize(
                    child: Container(
                      height: MediaQuery.of(context).size.width / 8,
                      alignment: Alignment.center,
                      child: Offstage(),
                    ),
                    preferredSize:
                        Size.fromHeight(MediaQuery.of(context).size.width / 7),
                  ),
                  flexibleSpace: CustomPaint(
                    painter: BackgroundPainter(Theme.of(context)),
                    size: Size.infinite,
                  ),
                ),*/
                SliverList(
                    delegate: SliverChildListDelegate(<Widget>[
                  Container(
                    margin: EdgeInsets.only(top: 20.0, right: 10.0),
                    height: MediaQuery.of(context).size.height / 4,
                    width: double.infinity,
                    child: LineChart(
                      mainData(),
                    ),
                  ),
                ]))
              ],
            ),
          ),
        ),
      ],
    );
  }

  List<Color> gradientColors = [
    // TODO lista di colori a seconda della lista di voti per rispecchiare la sufficienza
    const Color(0xff23b6e6),
    const Color(0xff02d39a),
  ];

  LineChartData mainData() {
    return LineChartData(
      lineTouchData: LineTouchData(
        enabled: true,
        handleBuiltInTouches: true,
        touchSpotThreshold: 10, // default
        touchCallback: null, // default
        fullHeightTouchLine: false, // default
        touchTooltipData: LineTouchTooltipData(
          tooltipBgColor: Colors.transparent,
          tooltipRoundedRadius: 0.0,
          tooltipPadding: EdgeInsets.all(0.0),
          tooltipBottomMargin: 20,
          maxContentWidth: 120,
          getTooltipItems: (touchedSpots) {
            return touchedSpots.map((e) {
              return LineTooltipItem(
                (e.y % 1) == 0
                    ? e.y.floor().toString()
                    : e.y.toString().replaceAll('.', ','),
                TextStyle(
                  color: Colors.white70,
                  fontFamily: 'CoreSansROunded',
                  fontSize: 13,
                ),
              );
            }).toList();
          },
        ),
      ),
      gridData: FlGridData(
        show: false,
        drawVerticalLine: false,
        drawHorizontalLine: true,
        horizontalInterval: 2.0,
      ),
      titlesData: FlTitlesData(
        show: true,
        bottomTitles: SideTitles(
          showTitles: true,
          reservedSize: 22,
          textStyle: const TextStyle(
              color: Color(0xff68737d),
              fontWeight: FontWeight.bold,
              fontFamily: 'CoreSansRounded',
              fontSize: 15),
          interval: 1,
          getTitles: (value) {
            switch (value.toInt()) {
              case 0:
                return 'SET';
              case 1:
                return 'OTT';
              case 2:
                return 'NOV';
              case 3:
                return 'DIC';
              case 4:
                return 'GEN';
              case 5:
                return 'FEB';
              case 6:
                return 'MAR';
              case 7:
                return 'APR';
              case 8:
                return 'MAG';
              case 9:
                return 'GIU';
            }
            return '';
          },
          margin: 8,
        ),
        leftTitles: SideTitles(
          showTitles: true,
          textStyle: const TextStyle(
            color: Color(0xff67727d),
            fontWeight: FontWeight.bold,
            fontFamily: 'CoreSansRounded',
            fontSize: 15,
          ),
          interval: 2,
          getTitles: (value) => value < 2 ? null : value.ceil().toString(),
          reservedSize: 20,
          margin: 12,
        ),
      ),
      borderData: FlBorderData(show: false),
      minX: trimestre ? 0 : 4,
      maxX: trimestre ? 3 : 9,
      minY: 0,
      maxY: 10,
      lineBarsData: [
        LineChartBarData(
          spots: () {
            List<FlSpot> tr = <FlSpot>[];
            main.session.voti.averageByMonth().forEach((i, avg) {
              if (!avg.isNaN &&
                  i >= (trimestre ? 0 : 4) &&
                  i < (trimestre ? 4 : 10)) tr.add(FlSpot(i.toDouble(), avg));
            });
            return tr;
          }(),
          isCurved: true,
          colors: gradientColors,
          barWidth: 5,
          isStrokeCapRound: true,
          dotData: FlDotData(
            show: false,
          ),
          belowBarData: BarAreaData(
            show: true,
            colors:
                gradientColors.map((color) => color.withOpacity(0.3)).toList(),
          ),
        ),
      ],
    );
  }
}

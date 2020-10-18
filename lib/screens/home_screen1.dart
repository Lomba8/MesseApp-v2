import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:Messedaglia/iPhoneXXS11Pro2.dart';
import 'package:Messedaglia/screens/menu_screen.dart';
import 'package:Messedaglia/screens/preferences_screen.dart';
import 'package:Messedaglia/widgets/menu_grid_icons.dart';
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
                SliverAppBar(
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
                  flexibleSpace: Container(
                    width: MediaQuery.of(context).size.width,
                    constraints: BoxConstraints.expand(),
                    child: AppBarNico(),
                  ),
                  // CustomPaint(
                  //   painter: BackgroundPainter(Theme.of(context)),
                  //   size: Size.infinite,
                  // ),
                ),
                SliverList(
                  delegate: SliverChildListDelegate(
                    <Widget>[
                      Container(
                        //TODO: scegliere un widget alternativo da displayare se non cis ono voti
                        margin:
                            EdgeInsets.only(top: 40.0, right: 20.0, left: 20.0),
                        height: MediaQuery.of(context).size.height / 4,
                        width: double.infinity,
                        child: BarChart(
                          mainBarData(),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        // Container(
        //   // margin:
        //   //     EdgeInsets.only(top: MediaQuery.of(context).size.height / 2),
        //   child: SlidingSheet(
        //     elevation: 10,
        //     cornerRadius: 40,
        //     snapSpec: const SnapSpec(
        //       // Enable snapping. This is true by default.
        //       snap: true,
        //       // Set custom snapping points.
        //       snappings: [0.4, 0.7, 1.0],
        //       // Define to what the snappings relate to. In this case,
        //       // the total available space that the sheet can expand to.
        //       positioning: SnapPositioning.relativeToAvailableSpace,
        //     ),
        //     // The body widget will be displayed under the SlidingSheet
        //     // and a parallax effect can be applied to it.
        //     body: Center(
        //       child: Text('This widget is below the SlidingSheet'),
        //     ),
        //     builder: (context, state) {
        //       // This is the content of the sheet that will get
        //       // scrolled, if the content is bigger than the available
        //       // height of the sheet.
        //       return Container(
        //         height: MediaQuery.of(context).size.height / 2,
        //         child: Center(
        //           child: Text(
        //             'This is the content of the sheet',
        //             style: TextStyle(color: Colors.black),
        //           ),
        //         ),
        //       );
        //     },
        //   ),
        // ),
      ],
    );
  }

  // List<Color> orangeGradient = [
  //   Color(0xFFff822e),
  //   Color(0xFFff864f),
  //   Color(0xFFfe6b35),
  //   Color(0xFFfc6e22),
  //   Color(0xFFff5f01),
  // ];

  Color green = Color(0xFF21fc0d);
  Color orange = Color(0xFFfc6e22);

  List<Color> redGradient = [
    // TODO scegliere il rosso finale
    Color(0xFFff000d), // per me è il pirmo se non il penultimo
    Color(0xFFed0b0e),
    Color(0xFFe60000),
    Color(0xFFff0000),
    Color(0xFFff0000)
  ];

  // List<Color> greenGradient = [
  //   Color(0xFF004000),
  //   Color(0xFF008000),
  //   Color(0xFF00bf00),
  //   Color(0xFF54db18),
  //   Color(0xFF28f81e)
  // ].reversed.toList();

  // List<Color> redGradient = [
  //   Color(0xFF400000),
  //   Color(0xFF800000),
  //   Color(0xFFbf0000),
  //   Color(0xFFff0000),
  //   Color(0xFFff4040)
  // ].reversed.toList();

  int touchedIndex;

  Color getRodDataColor(double average) {
    if (average >= 6) return green;
    if (average >= 5 && average < 6) return orange;
    if (average < 5) return redGradient[0];
  }

  BarChartData mainBarData() {
    List<BarChartGroupData> tr = <BarChartGroupData>[];

    () {
      main.session.voti.averageByMonth().forEach((i, avg) {
        if (!avg.isNaN && i >= (trimestre ? 0 : 4) && i < (trimestre ? 4 : 10))
          tr.add(
            BarChartGroupData(
              x: i,
              barsSpace: 2,
              //showingTooltipIndicators: [avg.toInt()],
              barRods: [
                BarChartRodData(
                  y: avg,
                  color: getRodDataColor(avg),
                  width: 15,
                  borderRadius: BorderRadius.circular(10.0),
                )
              ],
            ),
          ); //x:i.toDouble(), avg
      });
      return tr;
    }();

    return BarChartData(
      alignment: BarChartAlignment.spaceAround,
      barTouchData: BarTouchData(
        touchTooltipData: BarTouchTooltipData(
          tooltipBgColor: Colors.transparent,
          tooltipBottomMargin: 0,
          tooltipPadding: EdgeInsets.all(0),
          getTooltipItem: (group, groupIndex, rod, rodIndex) {
            return BarTooltipItem(
              (rod.y).toStringAsFixed(1).replaceAll('.', ','),
              TextStyle(
                color: Colors.white,
                backgroundColor: Colors.transparent,
                wordSpacing: 1.2,
              ),
            );
          },
        ),
        // touchCallback: (barTouchResponse) {
        //   setState(() {
        //     if (barTouchResponse.spot != null &&
        //         barTouchResponse.touchInput is! FlPanEnd &&
        //         barTouchResponse.touchInput is! FlLongPressEnd) {
        //       touchedIndex = barTouchResponse.spot.touchedBarGroupIndex;
        //     } else {
        //       touchedIndex = -1;
        //     }
        //   });
        // },
      ),
      titlesData: FlTitlesData(
        show: true,
        bottomTitles: SideTitles(
          showTitles: true,
          textStyle: TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
          margin: 20,
          getTitles: (value) {
            switch (value.toInt()) {
              case 0:
                return trimestre ? 'SET' : 'GEN';
              case 1:
                return trimestre ? 'OTT' : 'FEB';
              case 2:
                return trimestre ? 'NOV' : 'MAR';
              case 3:
                return trimestre ? 'DIC' : 'APR';
              case 4:
                return trimestre ? '' : 'MAG';
              case 5:
                return trimestre ? '' : 'GIU';
              // case 6:
              //   return trimestre ? '' : 'APR';
              // case 7:
              //   return trimestre ? 'NOV' : '';
              // case 8:
              //   return trimestre ? '' : 'MAG';
              // case 9:
              //   return trimestre ? '' : '';
              // case 10:
              //   return trimestre ? 'DIC' : 'GIU';
            }
            return '';
          },
        ),
        leftTitles: SideTitles(
          showTitles: true,
          textStyle: const TextStyle(
            color: Color(0xff67727d),
            fontWeight: FontWeight.bold,
            fontFamily: 'CoreSansRounded',
            fontSize: 15,
          ),
          getTitles: (value) {
            switch (value.toInt()) {
              case 0:
                return '';
              case 1:
                return '';
              case 2:
                return '2';
              case 3:
                return '';
              case 4:
                return '4';
              case 5:
                return '';
              case 6:
                return '6';
              case 7:
                return '';
              case 8:
                return '8';
              case 9:
                return '';
              case 10:
                return '10';
            }
            return '';
          },
          reservedSize: 15,
          margin: 15,
        ),
      ),
      borderData: FlBorderData(
        show: false,
      ),
      barGroups: tr,
      maxY: 10,
    );
  }
}

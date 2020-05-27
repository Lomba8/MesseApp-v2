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
                    delegate: SliverChildListDelegate(<Widget>[
                  Container(
                    margin: EdgeInsets.only(top: 20.0, right: 20.0, left: 20.0),
                    height: MediaQuery.of(context).size.height / 4,
                    width: double.infinity,
                    child: mainData(),
                  ),
                ]))
              ],
            ),
          ),
        ),
        Container(
          // margin:
          //     EdgeInsets.only(top: MediaQuery.of(context).size.height / 2),
          child: SlidingSheet(
            elevation: 10,
            cornerRadius: 40,
            snapSpec: const SnapSpec(
              // Enable snapping. This is true by default.
              snap: true,
              // Set custom snapping points.
              snappings: [0.4, 0.7, 1.0],
              // Define to what the snappings relate to. In this case,
              // the total available space that the sheet can expand to.
              positioning: SnapPositioning.relativeToAvailableSpace,
            ),
            // The body widget will be displayed under the SlidingSheet
            // and a parallax effect can be applied to it.
            body: Center(
              child: Text('This widget is below the SlidingSheet'),
            ),
            builder: (context, state) {
              // This is the content of the sheet that will get
              // scrolled, if the content is bigger than the available
              // height of the sheet.
              return Container(
                height: MediaQuery.of(context).size.height / 2,
                child: Center(
                  child: Text(
                    'This is the content of the sheet',
                    style: TextStyle(color: Colors.black),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  List<Color> greenGradient = [
    Color(0xFF004000),
    Color(0xFF008000),
    Color(0xFF00bf00),
    Color(0xFF00ff00),
    Color(0xFF80ff80)
  ].reversed.toList();

  List<Color> redGradient = [
    Color(0xFF400000),
    Color(0xFF800000),
    Color(0xFFbf0000),
    Color(0xFFff0000),
    //Color(0xFFff4040)
    Color(0xFFff9100)
  ].reversed.toList();

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

  BarChart mainData() {
    List<Color> gradientColors = new List();

    List<FlSpot> tr = <FlSpot>[];

    () {
      main.session.voti.averageByMonth().forEach((i, avg) {
        if (!avg.isNaN && i >= (trimestre ? 0 : 4) && i < (trimestre ? 4 : 10))
          tr.add(FlSpot(i.toDouble(), avg));
      });
      return tr;
    }();

    tr.forEach((average) {
      print(average.y.toInt());
      switch (average.y.toInt()) {
        case 1:
          return gradientColors.add(redGradient[1]);
        case 2:
          return gradientColors.add(redGradient[2]);
        case 3:
          return gradientColors.add(redGradient[3]);
        case 4:
          return gradientColors.add(redGradient[4]);
        case 5:
          return gradientColors.add(redGradient[5]);
        case 6:
          return gradientColors.add(greenGradient[1]);
        case 7:
          return gradientColors.add(greenGradient[2]);
        case 8:
          return gradientColors.add(greenGradient[3]);
        case 9:
          return gradientColors.add(greenGradient[4]);
        case 10:
          return gradientColors
              .add(greenGradient[5]); // vrede, verde scuro , rosso
      }
    });

    // **************************************************************************************

    final Color leftBarColor = const Color(0xff53fdd7);
    final Color rightBarColor = const Color(0xffff5182);
    final double width = 7;

    List<BarChartGroupData> rawBarGroups;
    List<BarChartGroupData> showingBarGroups;

    int touchedGroupIndex;

    final items = [
      BarChartGroupData(
          x: 0,
          barRods: [BarChartRodData(y: 8, color: Colors.lightBlueAccent)],
          showingTooltipIndicators: [0]),
      BarChartGroupData(
          x: 1,
          barRods: [BarChartRodData(y: 10, color: Colors.lightBlueAccent)],
          showingTooltipIndicators: [0]),
      BarChartGroupData(
          x: 2,
          barRods: [BarChartRodData(y: 14, color: Colors.lightBlueAccent)],
          showingTooltipIndicators: [0]),
      BarChartGroupData(
          x: 3,
          barRods: [BarChartRodData(y: 15, color: Colors.lightBlueAccent)],
          showingTooltipIndicators: [0]),
      BarChartGroupData(
          x: 3,
          barRods: [BarChartRodData(y: 13, color: Colors.lightBlueAccent)],
          showingTooltipIndicators: [0]),
      BarChartGroupData(
          x: 3,
          barRods: [BarChartRodData(y: 10, color: Colors.lightBlueAccent)],
          showingTooltipIndicators: [0]),
    ];

    rawBarGroups = items;

    showingBarGroups = rawBarGroups;

    return BarChart(
      BarChartData(
        maxY: 10,
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            tooltipBottomMargin: 8,
            tooltipBgColor: Colors.transparent,
            // getTooltipItem: (
            //   BarChartGroupData group,
            //   int groupIndex,
            //   BarChartRodData rod,
            //   int rodIndex,
            // ) {
            //   return BarTooltipItem(
            //     rod.y.round().toString(),
            //     TextStyle(
            //       color: Colors.white,
            //       fontWeight: FontWeight.bold,
            //     ),
            //   );
            // },
          ),
          touchCallback: (BarTouchResponse response) {
            return BarTooltipItem(
              response.touchInput.getOffset().dy.toStringAsFixed(1),
              TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            );
          },
        ),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: SideTitles(
            showTitles: true,
            textStyle: const TextStyle(
              color: Color(0xff67727d),
              fontWeight: FontWeight.bold,
              fontFamily: 'CoreSansRounded',
              fontSize: 15,
            ),
            margin: 8,
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
          ),
          leftTitles: SideTitles(
            showTitles: true,
            textStyle: const TextStyle(
              color: Color(0xff67727d),
              fontWeight: FontWeight.bold,
              fontFamily: 'CoreSansRounded',
              fontSize: 15,
            ),
            margin: 12,
            reservedSize: 10,
            getTitles: (value) => value < 2 ? null : value.ceil().toString(),
          ),
        ),
        borderData: FlBorderData(
          show: false,
        ),
        barGroups: showingBarGroups,
      ),
    );
  }
}

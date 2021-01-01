import 'dart:convert';
import 'dart:io';
import 'package:Messedaglia/screens/preferences_screen.dart';
import 'package:Messedaglia/widgets/background_painter.dart';
import 'package:Messedaglia/widgets/menu_grid_icons.dart';
import 'package:app_settings/app_settings.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:easy_permission_validator/easy_permission_validator.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:Messedaglia/main.dart' as main;
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:platform_alert_dialog/platform_alert_dialog.dart';

class Home extends StatefulWidget {
  static final String id = 'home_screen';

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  File image;
  int displayed = DateTime.now().month > 8
      ? 0
      : 1; // 0=> trimestre 1=>pentamestre 2=>totale

  Future<void> _refresh() async {
    HapticFeedback.mediumImpact();
    await main.session.downloadAll((v) {});
  }

  @override
  Widget build(BuildContext context) {
    List voti = List();
    main.session.voti.averageByMonth().forEach((key, value) => voti.add(value));
    if (displayed != 2)
      voti = voti.sublist(
          displayed == 0 ? 0 : 4, displayed == 0 ? 3 : voti.length);
    return Scaffold(
      body: LiquidPullToRefresh(
        onRefresh: _refresh,
        showChildOpacityTransition: false,
        child: CustomScrollView(
          // physics: NeverScrollableScrollPhysics(),
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
                        final permissionValidator = EasyPermissionValidator(
                          context: context,
                          appName: 'Messe App',
                        );

                        var result = await permissionValidator.photos();

                        if (result) {
                          PickedFile selectedFile = await ImagePicker()
                              .getImage(source: ImageSource.gallery);
                          image = File(selectedFile.path);

                          if (image != null) {
                            main.avatarList.add({
                              'id': main.session.usrId.toString(),
                              'base64': base64Encode(image.readAsBytesSync())
                            });
                            main.prefs.setString(
                                'avatar', jsonEncode(main.avatarList));
                            main.avatar = image.readAsBytesSync();
                            setState(() {});
                          }
                        } else {
                          showDialog<void>(
                            context: context,
                            builder: (BuildContext context) {
                              return PlatformAlertDialog(
                                title: Text('Impossibile scaricare la foto.'),
                                content: SingleChildScrollView(
                                  child: ListBody(
                                    children: <Widget>[
                                      Text(
                                          "Per scaricare l'orario bisogna autorizzare la applicazione."),
                                      Text(
                                          "Clicca su 'Autorizza' per selezionare l'avatar."),
                                    ],
                                  ),
                                ),
                                actions: <Widget>[
                                  PlatformDialogAction(
                                    child: Text('Cancella'),
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                  ),
                                  PlatformDialogAction(
                                    child: Text('Autorizza'),
                                    actionType: ActionType.Preferred,
                                    onPressed: () {
                                      AppSettings.openLocationSettings();
                                    },
                                  ),
                                ],
                              );
                            },
                          );
                        }
                      },
                      onLongPress: () async {
                        if (main.prefs.getString('avatar') != null)
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
                                      main.avatarList.retainWhere((element) =>
                                          element['id'] ==
                                          main.session.usrId.toString());
                                      main.prefs.setString('avatar',
                                          jsonEncode(main.avatarList));
                                      setState(() => main.avatar = null);
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
                        child: main.avatar != null
                            ? FittedBox(
                                child: Image.memory(main.avatar),
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
            ),
            SliverList(
              delegate: SliverChildListDelegate(
                <Widget>[
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 50),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        GestureDetector(
                          onTap: () => setState(() => displayed = 0),
                          child: Text(
                            'Trimestre',
                            style: TextStyle(
                              color: displayed == 0
                                  ? Colors.white
                                  : Colors.white70,
                              fontFamily: 'CoreSansRounded',
                              fontWeight: FontWeight.w600,
                              fontSize: displayed == 0 ? 20 : 17,
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () => setState(() => displayed = 1),
                          child: Text(
                            'Pentamestre',
                            style: TextStyle(
                              color: displayed == 1
                                  ? Colors.white
                                  : Colors.white70,
                              fontFamily: 'CoreSansRounded',
                              fontWeight: FontWeight.w600,
                              fontSize: displayed == 1 ? 20 : 17,
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () => setState(() => displayed = 2),
                          child: Text(
                            'Totale',
                            style: TextStyle(
                              color: displayed == 2
                                  ? Colors.white
                                  : Colors.white70,
                              fontFamily: 'CoreSansRounded',
                              fontWeight: FontWeight.w600,
                              fontSize: displayed == 2 ? 20 : 17,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    //TODO: scegliere un widget alternativo da displayare se non ci sono voti
                    margin: EdgeInsets.only(top: 40.0, right: 20.0, left: 20.0),
                    height: MediaQuery.of(context).size.height / 4,
                    width: double.infinity,
                    child: voti.every((element) => element.isNaN)
                        ? Center(
                            child: Text(
                            'no voti',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                            ),
                          ))
                        : BarChart(
                            mainBarData(),
                          ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
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
        if (!avg.isNaN)
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

      if (displayed == 0) tr = tr.sublist(0, 4);
      if (displayed == 1) tr = tr.sublist(4);
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
            if (displayed == 2) {
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
            } else {
              switch (value.toInt()) {
                case 0:
                  return displayed == 0 ? 'SET' : 'GEN';
                case 1:
                  return displayed == 0 ? 'OTT' : 'FEB';
                case 2:
                  return displayed == 0 ? 'NOV' : 'MAR';
                case 3:
                  return displayed == 0 ? 'DIC' : 'APR';
                case 4:
                  return displayed == 0 ? '' : 'MAG';
                case 5:
                  return displayed == 0 ? '' : 'GIU';
              }
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
                return '0';
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

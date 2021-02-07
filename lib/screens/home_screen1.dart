import 'dart:convert';
import 'dart:io';
import 'package:Messedaglia/screens/preferences_screen.dart';
import 'package:Messedaglia/widgets/background_painter.dart';
import 'package:Messedaglia/widgets/menu_grid_icons.dart';
import 'package:Messedaglia/widgets/today_widget.dart';
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

int touchIndex;

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

  double _height;
  Size size;

  Future<void> _refresh() async {
    HapticFeedback.mediumImpact();
    await main.session.downloadAll((v) {});
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
    List voti = [];
    main.session.voti.averageByMonth().forEach((key, value) => voti.add(value));
    if (displayed != 2)
      voti = voti.sublist(
          displayed == 0 ? 0 : 4, displayed == 0 ? 3 : voti.length);
    _height = voti.every((element) => element.isNaN)
        ? 50
        : size.height / ((3.5 / 428) * size.width);
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
                          if (selectedFile != null)
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
                  height: size.width / 8,
                  alignment: Alignment.center,
                  child: Offstage(),
                ),
                preferredSize: Size.fromHeight(size.width / 7),
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
                    padding: EdgeInsets.symmetric(
                        horizontal: (50 / 428) * size.width),
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
                              fontSize: displayed == 0
                                  ? (20 / 428) * size.width
                                  : (17 / 428) * size.width,
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
                              fontSize: displayed == 1
                                  ? (20 / 428) * size.width
                                  : (17 / 428) * size.width,
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
                              fontSize: displayed == 2
                                  ? (20 / 428) * size.width
                                  : (17 / 428) * size.width,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  AnimatedContainer(
                    //TODO: scegliere un widget alternativo da displayare se non ci sono voti
                    duration: Duration(milliseconds: 300),
                    height: _height,
                    margin: EdgeInsets.only(
                        top: (40 / 428) * size.width,
                        right: (23 / 428) * size.width,
                        left: (23 / 428) * size.width),
                    width: double.infinity,
                    child: voti.every((element) => element.isNaN)
                        ? Center(
                            child: Text(
                              'Non ci sono voti',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: (20 / 428) * size.width,
                              ),
                            ),
                          )
                        : Material(
                            color: Colors.transparent,
                            elevation: 10,
                            borderRadius: BorderRadius.circular(20.0),
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                color:
                                    Theme.of(context).scaffoldBackgroundColor,
                              ),
                              padding: const EdgeInsets.all(20.0),
                              child: BarChart(
                                mainBarData(),
                              ),
                            ),
                          ),
                  ),
                  Divider(height: (40 / 428) * size.width),
                  //TODO: scegliere un widget alternativo da displayare se non ci sono lezioni
                  Container(
                    child: main.session.lessons.data.length > 0
                        ? main.session.lessons.hasLessonsToday()
                            ? TodayWidget()
                            : Center(
                                child: Text(
                                  '\nNon ci sono lezioni',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: (20 / 428) * size.width,
                                  ),
                                ),
                              )
                        : Offstage(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color green = Color(0xFF21fc0d);
  Color orange = Color(0xFFfc6e22);
  Color red = Color(0xFFff000d);

  int touchedIndex;

  // ignore: missing_return
  Color getRodDataColor(double average) {
    if (average >= 6) return green;
    if (average >= 5 && average < 6) return orange;
    if (average < 5) return red;
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
                  y: i == touchedIndex ? avg + 1 : avg,
                  color: getRodDataColor(avg),
                  width: 15,
                  borderRadius: BorderRadius.circular(10.0),
                  backDrawRodData: BackgroundBarChartRodData(
                    y: 10,
                    color: Color.fromRGBO(38, 38, 51, 1),
                    show: true,
                  ),
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
        touchCallback: (barTouchResponse) {
          setState(() {
            if (barTouchResponse.spot != null &&
                barTouchResponse.touchInput is! FlPanEnd &&
                barTouchResponse.touchInput is! FlLongPressEnd) {
              touchedIndex = barTouchResponse.spot.touchedBarGroupIndex;
            } else {
              touchedIndex = -1;
            }
          });
        },
        touchTooltipData: BarTouchTooltipData(
          tooltipBgColor: Color(0xFF33333D),
          tooltipBottomMargin: 10,
          tooltipPadding: EdgeInsets.symmetric(horizontal: 13, vertical: 5),
          getTooltipItem: (group, groupIndex, rod, rodIndex) {
            return BarTooltipItem(
              (rod.y - 1).toStringAsFixed(1).replaceAll('.', ','),
              TextStyle(
                color: Colors.white,
                backgroundColor: Colors.transparent,
                wordSpacing: 1.2,
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
            );
          },
        ),
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

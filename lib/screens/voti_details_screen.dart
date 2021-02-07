import 'package:Messedaglia/widgets/background_painter.dart';
import 'package:Messedaglia/widgets/expansion_tile.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import '../registro/voti_registro_data.dart';

class VotiDetails extends StatefulWidget {
  final List<Voto> voti;
  final String sbjDesc;

  VotiDetails(this.voti, this.sbjDesc) {
    voti.sort();
  }

  @override
  VotiDetailsState createState() => VotiDetailsState();
}

class VotiDetailsState extends State<VotiDetails> {
  @override
  void initState() {
    super.initState();
    _dates = [];
    _gradientColors = [];
  }

  @override
  void dispose() {
    _dates.clear();
    _gradientColors.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _gradientColors.clear();
    _dates.clear();

    return Material(
        color: Theme.of(context).backgroundColor,
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              brightness: Theme.of(context).brightness,
              elevation: 0,
              backgroundColor: Colors.transparent,
              title: AutoSizeText(
                widget.sbjDesc,
                maxLines: 1,
                style: Theme.of(context).textTheme.bodyText2,
              ),
              bottom: PreferredSize(
                  child: Container(),
                  preferredSize:
                      Size.fromHeight(MediaQuery.of(context).size.width / 8)),
              centerTitle: true,
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
              pinned: true,
              flexibleSpace: CustomPaint(
                painter: BackgroundPainter(Theme.of(context), back: true),
                size: Size.infinite,
              ),
            ),
            SliverList(
                delegate: SliverChildListDelegate(
              [
                if (widget.voti
                        .where((voto) => voto.voto != null && !voto.voto.isNaN)
                        .toList()
                        .length !=
                    0)
                  Padding(
                    padding: EdgeInsets.only(right: 30),
                    child: AspectRatio(
                      aspectRatio: 1.7,
                      child: Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: LineChart(_votiData(context)),
                      ),
                    ),
                  ),
              ]..addAll(
                  (widget.voti ?? []).reversed.map<Widget>((mark) => Padding(
                        padding: const EdgeInsets.only(top: 20.0),
                        child: CustomExpansionTile(
                          title: Text(
                            mark.data,
                            textAlign: TextAlign.center,
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              mark.info.isEmpty
                                  ? 'Nessuna descrizione'
                                  : mark.info,
                              style: Theme.of(context).textTheme.bodyText1,
                              textAlign: TextAlign.center,
                            ),
                          ),
                          leading: Stack(
                            children: <Widget>[
                              CircleAvatar(
                                backgroundColor: mark.color,
                                child: Center(
                                  child: Text(
                                    mark.votoStr,
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                              if (mark.isNew)
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.yellow),
                                )
                            ],
                          ),
                        ),
                      ))),
            ))
          ],
        ));
  }

  LineChartData _votiData(BuildContext context) => LineChartData(
        lineBarsData: [
          LineChartBarData(
            show: true,
            spots: widget.voti
                .where((voto) => voto.voto != null && !voto.voto.isNaN)
                .toList()
                .asMap()
                .map(
                  (index, voto) {
                    _dates.add(voto.dateWithSlashesShort
                        .substring(0, voto.dateWithSlashesShort.length - 3));
                    if (index == 0)
                      _gradientColors.add(voto.color);
                    else
                      for (int i = 0; i < 3; i++) {
                        _gradientColors.add(voto.color);
                      }
                    return MapEntry(
                      index,
                      FlSpot(
                        index.toDouble(),
                        voto.voto,
                      ),
                    );
                  },
                )
                .values
                .toList(),
            colors: _gradientColors,
            isStrokeCapRound: true,
            barWidth: 10,
            isCurved: true,
            curveSmoothness: 0.40,
            preventCurveOvershootingThreshold: 10.0,
            dotData: FlDotData(
              dotColor: widget.voti
                          .where(
                              (voto) => voto.voto != null && !voto.voto.isNaN)
                          .length ==
                      1
                  ? widget.voti
                      .where((voto) => voto.voto != null && !voto.voto.isNaN)
                      .first
                      .color
                  : Colors.white.withOpacity(0.4),
              dotSize: 5,
            ),
            preventCurveOverShooting: true,
          ),
        ],
        // betweenBarsData: BetweenBarsData,
        titlesData: FlTitlesData(
          show: true,
          leftTitles: SideTitles(
            reservedSize: 30,
            textStyle: TextStyle(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white70
                  : Colors.black87,
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
            showTitles: true,
            margin: 15,
            getTitles: (value) => value.toInt().toString() + '    ',
            interval: 2.0,
          ),
          bottomTitles: SideTitles(
            getTitles: (double index) {
              return _dates[index.toInt()];
            },
            reservedSize: 10,
            margin: 15,
            showTitles: true,
            textStyle: TextStyle(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white
                  : Colors.black,
              fontSize: _dates.length < 5 ? 12 : 12,
              fontWeight: FontWeight.w600,
            ),
            rotateAngle: widget.voti.length > 8 ? 45 : 0,
          ),
        ),
        //  axisTitleData: FlAxisTitleData,
        extraLinesData: ExtraLinesData(
          extraLinesOnTop: true,
          horizontalLines: List.generate(
            12,
            (index) => HorizontalLine(
              y: index.toDouble(),
              color: index % 2 == 0 ? Colors.white70 : Colors.transparent,
              dashArray: [2, 39],
              strokeWidth: 2,
            ),
          ),
        ),
        lineTouchData: LineTouchData(
          enabled: true,
          touchTooltipData: LineTouchTooltipData(
            tooltipBgColor: Theme.of(context).scaffoldBackgroundColor,
            tooltipBottomMargin: 12,
            tooltipPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
            getTooltipItems: (touchedSpots) => touchedSpots
                .map(
                  (spot) => LineTooltipItem(
                    spot.y.toString(),
                    TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                )
                .toList(),
          ),
        ),
        // rangeAnnotations: RangeAnnotations(),
        //showingTooltipIndicators: ,
        gridData: FlGridData(
          show: false,
        ),
        borderData: FlBorderData(
          show: false, //CHOOSE: meglio senza o con? per me senza
          border: Border(
            left: BorderSide(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white.withOpacity(0.9)
                  : Colors.black87,
              width: 2,
            ),
            bottom: BorderSide(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white.withOpacity(0.9)
                  : Colors.black87,
              width: 2,
            ),
          ),
        ),
        backgroundColor: Colors.transparent,
        clipToBorder: false,
        minY: 0,
        maxY: 10,
      );

  /*LineChartData _averageData() {
    return null;
  }*/
}

List<String> _dates;
List<Color> _gradientColors;

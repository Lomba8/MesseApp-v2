import 'package:Messedaglia/widgets/background_painter.dart';
import 'package:Messedaglia/widgets/expansion_tile.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import '../registro/voti_registro_data.dart';

//FIXME: grafico

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
  Widget build(BuildContext context) => Material(
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
              Padding(
                padding: EdgeInsets.only(right: 30),
                child: AspectRatio(
                  aspectRatio: 1.7,
                  child: Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: LineChart(_votiData()),
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

  LineChartData _votiData() => LineChartData(
        betweenBarsData: [
          BetweenBarsData(
            fromIndex: 0,
            toIndex: 0,
            gradientTo: Offset(0.0, 0.0),
            colors: [Colors.green, Colors.red],
          )
        ],
        lineTouchData: LineTouchData(),
        minY: 2,
        // maxY: 10,
        gridData: FlGridData(
          show: false,
          drawVerticalLine: false,
          getDrawingVerticalLine: (value) => FlLine(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white10
                  : Colors.black12,
              strokeWidth: 1),
          drawHorizontalLine: true,
          getDrawingHorizontalLine: (value) => FlLine(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white10
                  : Colors.black12,
              strokeWidth: 1),
        ),
        titlesData: FlTitlesData(
          bottomTitles: SideTitles(
            getTitles: (double index) {
              return dates[index.toInt()];
            },
            margin: 20,
            showTitles: true,
            textStyle: TextStyle(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white70
                  : Colors.black87,
              fontSize: 15,
            ),
            rotateAngle: 45, //TODO dynamic
          ),
          leftTitles: SideTitles(
            reservedSize: 25,
            textStyle: TextStyle(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white
                  : Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
            margin: 15,
            showTitles: true,
            getTitles: (value) =>
                (value.toInt() % 2) == 0 ? value.toInt().toString() : '',
          ),
        ),
        borderData: FlBorderData(
          show: true,
          border: Border(
            left: BorderSide(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white70
                  : Colors.black87,
              width: 2,
            ),
            bottom: BorderSide(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white70
                  : Colors.black87,
              width: 2,
            ),
          ),
        ),
        lineBarsData: [
          LineChartBarData(
            isStrokeCapRound: true,
            gradientFrom: Offset(0.5, 0),
            gradientTo: Offset(0.5, 1),
            colorStops: [0, 1],
            spots: widget.voti
                .where((voto) => voto.voto != null && !voto.voto.isNaN)
                .toList()
                .asMap()
                .map(
                  (index, voto) {
                    dates.add(voto.dateWithSlashesShort);
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
            isCurved: true,
            dotData: FlDotData(
              dotColor: Colors.green[800],
              dotSize: 5,
            ), // TODO: non posso decidere il colore per ogni dot?!?!?  //FIXME:non c'è corrispondenza colore (verde/rosso) con voto (<6>)
            colors: [Colors.green, Colors.deepOrange[900]],
            barWidth: 10,
          ),
        ],
      );

  /*LineChartData _averageData() {
    return null;
  }*/
}

List<String> dates = List();

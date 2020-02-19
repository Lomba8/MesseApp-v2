import 'package:applicazione_prova/screens/menu_screen.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../registro/voti_registro_data.dart';

class VotiDetails extends StatefulWidget {
  final List<Voto> voti;
  final String sbjDesc;

  VotiDetails(this.voti, this.sbjDesc);

  @override
  VotiDetailsState createState() => VotiDetailsState();
}

class VotiDetailsState extends State<VotiDetails> {
  @override
  Widget build(BuildContext context) {
    return Material(
      child: Stack(
        children: <Widget>[
          SingleChildScrollView(
              child: Column(
            children: [
              SizedBox(height: MediaQuery.of(context).size.height / 4),
              AspectRatio(
                aspectRatio: 1.7,
                child: Padding(
                  padding: EdgeInsets.all(8),
                  child: LineChart(_votiData()),
                ),
              ),
              Text(
                "work in progress...",
                textAlign: TextAlign.center,
              )
            ]..addAll(widget.voti == null
                ? []
                : widget.voti.map<Widget>((mark) => ListTile(
                      leading: mark.isNew
                          ? Icon(
                              Icons.fiber_new,
                              color: Colors.yellow,
                            )
                          : null,
                      title: Text(mark.votoStr),
                    ))),
          )),
          CustomPaint(
            painter: BackgroundPainter(Theme.of(context)),
            child: Padding(
              padding: const EdgeInsets.only(bottom: 50),
              child: Padding(
                padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).size.height / 30,
                    top: MediaQuery.of(context).size.height / 18),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Container(
                      width: MediaQuery.of(context).size.width / 10,
                      child: IconButton(
                          icon: Icon(Icons.arrow_back_ios),
                          onPressed: () {
                            Navigator.pop(context);
                          }),
                    ),
                    Expanded(
                      child: Text(
                        widget.sbjDesc,
                        textAlign:
                            TextAlign.center, //FIXME: come centrare testo?
                      ),
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width / 10,
                    )
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  LineChartData _votiData() => LineChartData(
    lineTouchData: LineTouchData(

    ),
          minY: 0,
          maxY: 10,
          gridData: FlGridData(
            show: true,
            drawVerticalLine: true,
            getDrawingVerticalLine: (value) =>
                FlLine(color: Colors.white10, strokeWidth: 1),
            drawHorizontalLine: true,
            getDrawingHorizontalLine: (value) =>
                FlLine(color: Colors.white10, strokeWidth: 1),
          ),
          titlesData: FlTitlesData(
              bottomTitles: SideTitles(showTitles: false),
              leftTitles: SideTitles(
                reservedSize: 25,
                textStyle: TextStyle(
                  color: Colors.white60,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
                margin: 15,
                showTitles: true,
                getTitles: (value) => value.toInt().toString(),
              )),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: widget.voti
                  .where((voto) => voto.voto != null && !voto.voto.isNaN)
                  .toList()
                  .asMap()
                  .map((index, voto) =>
                      MapEntry(index, FlSpot(index.toDouble(), voto.voto)))
                  .values
                  .toList(),
              isCurved: true,
              dotData: FlDotData(
                  dotColor: Theme.of(context).primaryColor, dotSize: 5),
              colors: [Theme.of(context).primaryColor],
              /*belowBarData: BarAreaData(  // TODO: gradient verticale?
                  show: true,
                  colors: [Color(0xFF002000), Color(0xFF200000)],
                  gradientColorStops: [0, 1],
                  cutOffY: 6,
                  applyCutOffY: true
                )*/
            )
          ]);

  LineChartData _averageData() {
    return null;
  }
}

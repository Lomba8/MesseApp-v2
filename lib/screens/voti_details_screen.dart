import 'package:applicazione_prova/screens/menu_screen.dart';
import 'package:flutter/material.dart';

class VotiDetails extends StatefulWidget {
  final Map _sbj;
  final String _period;

  VotiDetails(this._sbj, this._period);

  @override
  VotiDetailsState createState() => VotiDetailsState();
}

class VotiDetailsState extends State<VotiDetails> {
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        widget._sbj[widget._period].values
            .forEach((mark) => mark["new"] = false);
        return Future.value(true);
      },
      child: Material(
        child: Stack(
          children: <Widget>[
            SingleChildScrollView(
                child: Column(
              children: [
                SizedBox(height: MediaQuery.of(context).size.height / 4),
                Text(
                  "work in progress...",
                  textAlign: TextAlign.center,
                )
              ]..addAll(widget._sbj[widget._period] == null
                  ? []
                  : widget._sbj[widget._period].values
                      .map<Widget>((mark) => ListTile(
                            leading: mark['new']
                                ? Icon(
                                    Icons.fiber_new,
                                    color: Colors.yellow,
                                  )
                                : null,
                            title: Text(mark['votoStr']),
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
                              widget._sbj[widget._period].values
                                  .forEach((mark) => mark["new"] = false);
                              Navigator.pop(context);
                            }),
                      ),
                      Expanded(
                        child: Text(
                          widget._sbj["subjectDesc"],
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
      ),
    );
  }
}

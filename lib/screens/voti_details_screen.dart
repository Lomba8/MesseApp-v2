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
    return Material(
      child: Padding(
        padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
        child: Stack(
          children: <Widget>[
            SingleChildScrollView(
                child: Column(
              children: [
                SizedBox(
                  height: 150,  // FIXME: dinamico?
                ),
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
              painter: BackgroundPainter(),
              child: Padding(
                padding: const EdgeInsets.only(bottom: 60, right: 10, top: 10),
                child: Row(
                  children: <Widget>[
                    IconButton(
                      icon: Icon(Icons.arrow_back_ios),
                      onPressed: () {
                        widget._sbj[widget._period].values.forEach ((mark) => mark["new"] = false);
                        Navigator.pop(context);
                      }
                    ),
                    Expanded(
                      child: Text(widget._sbj["subjectDesc"]),
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

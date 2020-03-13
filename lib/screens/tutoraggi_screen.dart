import 'package:flip_card/flip_card.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;

import 'package:preload_page_view/preload_page_view.dart';

class CustomIcons {
  static const IconData menu = IconData(0xe900, fontFamily: "CustomIcons");
  static const IconData option = IconData(0xe902, fontFamily: "CustomIcons");
}

class TutoraggiScreen extends StatefulWidget {
  @override
  _TutoraggiScreenState createState() => new _TutoraggiScreenState();
}

var cardAspectRatio = 12.0 / 16.0;
var widgetAspectRatio = cardAspectRatio * 1.2;

const int numero_tutor = 4; // FIXME da implementare coi dati del server

List<String> tutor = [
  "Amos Lo Verde",
  "Giacomo Brognara",
  "Pietro Cipriani",
];

List<String> classe = [
  "5N",
  "4F",
  "4G",
];
List<String> email = [
  "amos.loverde@messedaglia.edu.it",
  "giacomo.brognara@messedaglia.edu.it",
  "pietro.cipriani@messedaglia.edu.it",
];

Color colore1 = Color.fromRGBO(212, 127, 166, 1.0); //(120, 213, 215, 1),
Color colore2 = Color.fromRGBO(138, 86, 172, 1.0); //(4, 110, 143, 1),
Color colore3 = Color.fromRGBO(36, 19, 50, 1.0); //(0, 169, 216, 1),

Color colore1_ombra = Color.fromRGBO(196, 117, 153, 1.0);
Color colore2_ombra = Color.fromRGBO(127, 79, 159, 1.0);
Color colore3_ombra = Color.fromRGBO(60, 45, 73, 1.0);

class _TutoraggiScreenState extends State<TutoraggiScreen> {
  var currentPage = numero_tutor - 1.0;
  var alpha = 0.0;
  bool flipped = false;
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    PreloadPageController controller =
        PreloadPageController(initialPage: numero_tutor - 1);
    controller.addListener(() {
      setState(() {
        currentPage = controller.page;
      });
    });

    return Container(
      child: Scaffold(
        body: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(
                    left: 12.0, right: 12.0, top: 30.0, bottom: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    IconButton(
                        icon: Icon(
                          Icons.arrow_back_ios,
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.white60
                              : Colors.black54,
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                        }),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text("Tutor",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 46.0,
                          fontFamily: "CoreSans",
                          letterSpacing: 1.0,
                        )),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 20.0),
                child: Row(
                  children: <Widget>[
                    Container(
                      decoration: BoxDecoration(
                        color: Color(0xFFff6e6e),
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                      child: Center(
                        child: FlatButton(
                          padding: EdgeInsets.symmetric(
                              horizontal: 22.0, vertical: 6.0),
                          onPressed: () {
                            setState(() {
                              if (flipped) {
                                flipped = false;
                                alpha = 0.0;
                              } else {
                                flipped = true;
                                alpha = math.pi;
                              }
                            });
                          },
                          child: Text("Animated",
                              style: TextStyle(color: Colors.white)),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 15.0,
                    ),
                    Text("25+ Stories",
                        style: TextStyle(color: Colors.blueAccent))
                  ],
                ),
              ),
              Stack(
                children: <Widget>[
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                    height: 500,
                    child: PreloadPageView.builder(
                      itemCount: tutor.length,
                      controller: controller,
                      preloadPagesCount: 4,
                      itemBuilder: (context, index) {
                        // return CardWidget(
                        //     page: index,
                        //     currentPage: currentPosition,
                        // );
                        return Container(
                          color: index == 0 ? Colors.red : Colors.blue,
                          child: CardScrollWidget(
                              page: controller.page, currentPage: index),
                        );
                      },
                    ),
                  )
                  // CardScrollWidget(currentPage),
                  // Positioned.fill(
                  //   child: PageView.builder(
                  //     itemCount: numero_tutor,
                  //     controller: controller,
                  //     reverse: true,
                  //     itemBuilder: (context, index) {
                  //       return Container();
                  //     },
                  //   ),
                  // ),
                ],
              ),
              Padding(
                padding: EdgeInsets.only(left: 20.0, top: 5.0, bottom: 10.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text("Cosa sono i tutor?",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 30.0,
                          fontFamily: "Calibre-Semibold",
                          letterSpacing: 1.0,
                        )),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 20.0),
                child: Row(
                  children: <Widget>[
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.blueAccent,
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                      child: Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: 22.0, vertical: 6.0),
                          child: Text("Latest",
                              style: TextStyle(color: Colors.white)),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 15.0,
                    ),
                    Text("9+ Stories",
                        style: TextStyle(color: Colors.blueAccent))
                  ],
                ),
              ),
              SizedBox(
                height: 20.0,
              ),
              Row(
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.only(left: 18.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20.0),
                      child: Image.asset("images/logo.png",
                          width: 296.0, height: 222.0),
                    ),
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}

class CardScrollWidget extends StatelessWidget {
  var page;
  var currentPage;
  var padding = 20.0;
  var verticalInset = 20.0;

  CardScrollWidget({this.page, this.currentPage});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, contraints) {
      // var width = contraints.maxWidth;
      // var height = contraints.maxHeight;

      // var safeWidth = width - 2 * padding;
      // var safeHeight = height - 2 * padding;

      // var heightOfPrimaryCard = safeHeight;
      // var widthOfPrimaryCard = heightOfPrimaryCard * cardAspectRatio;

      // var primaryCardLeft = safeWidth - widthOfPrimaryCard;
      // var horizontalInset = primaryCardLeft / 2;

      // int i = currentPage;

      // var delta = i - currentPage;
      // bool isOnRight = delta > 0;

      // var start = padding +
      //     math.max(
      //         primaryCardLeft - horizontalInset * -delta * (isOnRight ? 15 : 1),
      //         0.0);

      var delta = currentPage - page;
      var start = padding * delta.abs() * 10;

      var top = padding + padding * math.max(-delta, 0.0);
      var bottom = padding + padding * math.max(-delta, 0.0);

      var cardItem = ClipRect(
        child: Transform.translate(
          // top: padding + verticalInset * math.max(-delta, 0.0),
          // bottom: padding + verticalInset * math.max(-delta, 0.0),
          // start: start,
          offset: Offset(-start, 0),
          child: Padding(
            padding: EdgeInsets.only(top: top, bottom: bottom),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(50.0), //prima era 16
              child: TutorCard(),
            ),
          ),
        ),
      );

      return cardItem;
    });
  }
}

class TutorCard extends StatelessWidget {
  const TutorCard({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: AspectRatio(
        aspectRatio: cardAspectRatio,
        child: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            Column(
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                Flexible(
                  flex: 1,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Container(
                        color: colore2,
                      ),
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(50),
                          ),
                          color: colore1,
                        ),
                      )
                    ],
                  ),
                ),
                Flexible(
                  flex: 1,
                  child: Stack(
                    children: [
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: Container(
                              color: colore3,
                            ),
                          ),
                          Expanded(
                            child: Container(
                              color: colore1,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(50),
                            topRight: Radius.circular(50),
                          ),
                          color: colore2,
                        ),
                      ),
                    ],
                  ),
                ),
                Flexible(
                  flex: 1,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Container(
                        color: colore2,
                      ),
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(50),
                              topRight: Radius.circular(50)),
                          color: colore3,
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
            Padding(
              padding: EdgeInsets.only(top: 50.0, left: 20.0, right: 30.0),
              child: Align(
                alignment: Alignment(-1.0, -1.0),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          tutor[0],
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 15.0,
                              fontFamily: "CoreSans"),
                          overflow: TextOverflow.clip,
                        ),
                        SizedBox(
                          height: 6.0,
                        ),
                        Text(
                          classe[0],
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 15.0,
                              fontFamily: "CoreSans"),
                        ),
                      ],
                    ),
                    Expanded(
                      child: Icon(
                        Icons.computer,
                        size: 45.0,
                        color: colore1_ombra,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (tutor.length > 1)
              Padding(
                padding: EdgeInsets.only(left: 20.0, right: 30.0),
                child: Align(
                  alignment: Alignment(-1.0, 0.0),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: <Widget>[
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            tutor[1],
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 15.0,
                                fontFamily: "CoreSans"),
                            overflow: TextOverflow.clip,
                          ),
                          SizedBox(
                            height: 6.0,
                          ),
                          Text(
                            classe[1],
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 15.0,
                                fontFamily: "CoreSans"),
                          ),
                        ],
                      ),
                      Expanded(
                        child: Icon(
                          Icons.computer,
                          size: 45.0,
                          color: colore2_ombra,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              Offstage(),
            tutor.length > 2
                ? Padding(
                    padding:
                        EdgeInsets.only(bottom: 50.0, left: 20.0, right: 30.0),
                    child: Align(
                      alignment: Alignment(-1.0, 1.0),
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                tutor[2],
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20.0,
                                    fontFamily: "CoreSans"),
                                overflow: TextOverflow.clip,
                              ),
                              SizedBox(
                                height: 6.0,
                              ),
                              Text(
                                classe[2],
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 15.0,
                                    fontFamily: "CoreSans"),
                              ),
                            ],
                          ),
                          Expanded(
                            child: Icon(
                              Icons.computer,
                              size: 45.0,
                              color: colore3_ombra,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : Offstage(),
          ],
        ),
      ),
    );
  }
}

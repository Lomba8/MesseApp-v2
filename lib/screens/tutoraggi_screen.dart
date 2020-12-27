import 'dart:convert';

import 'package:Messedaglia/preferences/globals.dart';
import 'package:Messedaglia/widgets/background_painter.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:Messedaglia/main.dart' as main;
import 'dart:math' as math;
import 'dart:ui';

import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:positioned_tap_detector/positioned_tap_detector.dart';
import 'package:url_launcher/url_launcher.dart';

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

//const int numero_tutor = 4; // FIXME da implementare coi dati del server
List<String> keys = new List();

// List<String> tutor = [
//   "Amos Lo Verde",
//   "Giacomo Brognara",
//   "Pietro Cipriani",
// ];

// List<String> classe = [
//   "5N",
//   "4F",
//   "4G",
// ];
// List<String> email = [
//   "amos.loverde@messedaglia.edu.it",
//   "giacomo.brognara@messedaglia.edu.it",
//   "pietro.cipriani@messedaglia.edu.it",
// ];

final String _defaultBody = '''Buona giornata,
\nrichiedo un tutoraggio per _ studenti in data dd/mm/yyyy dalle hh alle hh.
\n${main.session.nome} ${main.session.cognome}''';

Color colore1 = Color(0xff6b0e82);
Color colore2 = Color(0xffb231b2);
Color colore3 = Color(0xffd455bb);

Color colore1_ombra = Color(0xff86248f);
Color colore2_ombra = Color(0xff943294);
Color colore3_ombra = Color(0xffa84895);

class _TutoraggiScreenState extends State<TutoraggiScreen>
    with SingleTickerProviderStateMixin {
  var currentPage;
  var angle;
  var tutor;
  bool info = false;

  Animation<double> animation;
  AnimationController animationController;

  @override
  void initState() {
    tutor = json.decode(main.prefs.getString('tutor'));
    currentPage = tutor.length - 1.0;
    super.initState();
  }

  _sendMail(String url) async {
    if (await canLaunch(Uri.encodeFull(url))) {
      await launch(Uri.encodeFull(url));
    } else {
      Flushbar(
        padding: EdgeInsets.all(10),
        borderRadius: 20,
        backgroundGradient: LinearGradient(
          colors: Globals.sezioni['viola']['gradientColors'],
          stops: [0.3, 0.6, 1],
        ),
        boxShadows: [
          BoxShadow(
            color: Colors.black45,
            offset: Offset(3, 3),
            blurRadius: 6,
          ),
        ],
        duration: Duration(seconds: 5),
        isDismissible: true,
        icon: Icon(
          Icons.error_outline,
          size: 35,
          color: Theme.of(context).backgroundColor,
        ),
        shouldIconPulse: true,
        animationDuration: Duration(seconds: 1),
        dismissDirection: FlushbarDismissDirection.HORIZONTAL,
        // The default curve is Curves.easeOut
        forwardAnimationCurve: Curves.fastOutSlowIn,
        title: 'Errore nell\'aprire l\'url:',
        message: '$url',
      ).show(context);
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    PageController controller = PageController(initialPage: tutor.length - 1);
    controller.addListener(() {
      setState(() {
        currentPage = controller.page;
      });
    });

    return Container(
      child: Scaffold(
        body: CustomScrollView(slivers: [
          SliverAppBar(
            brightness: Theme.of(context).brightness,
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
            title: Text(
              'Tutor',
              style: TextStyle(
                fontSize: 35,
                color: Colors.white,
                fontFamily: 'CoreSansRounded',
                fontWeight: FontWeight.bold,
              ),
            ),
            elevation: 0,
            pinned: true,
            centerTitle: true,
            backgroundColor: Colors.transparent,
            flexibleSpace: CustomPaint(
              painter: BackgroundPainter(Theme.of(context), back: true),
              size: Size.infinite,
            ),
            actions: <Widget>[
              Padding(
                padding: const EdgeInsets.only(right: 10),
                child: IconButton(
                  icon: Icon(
                    MdiIcons.informationVariant,
                    size: 40.0,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    setState(() {
                      info ? info = false : info = true;
                    });
                  },
                ),
              ),
            ],
            bottom: PreferredSize(
                child: Container(),
                preferredSize:
                    Size.fromHeight(MediaQuery.of(context).size.width / 8)),
          ),
          SliverToBoxAdapter(
            child: Column(
              children: <Widget>[
                PositionedTapDetector(
                  onTap: (position) async {
                    if (position.relative.dx >= 22 &&
                        position.relative.dx <= 336 &&
                        position.relative.dy >= 24 &&
                        position.relative.dy <= 442) {
                      if (position.relative.dy <= 162) {
                        _sendMail(
                            'mailto:${tutor[controller.page.round()][keys[controller.page.round()]][0]['mail']}?subject=Tutoraggio&body=$_defaultBody');
                      } else if (position.relative.dy >= 303) {
                        if (tutor[controller.page.round()]
                                    [keys[controller.page.round()]]
                                .length >
                            2)
                          _sendMail(
                              'mailto:${tutor[controller.page.round()][keys[controller.page.round()]][2]['mail']}?subject=Tutoraggio&body=$_defaultBody');
                      } else {
                        if (tutor[controller.page.round()]
                                    [keys[controller.page.round()]]
                                .length >
                            1)
                          _sendMail(
                              'mailto:${tutor[controller.page.round()][keys[controller.page.round()]][1]['mail']}?subject=Tutoraggio&body=$_defaultBody');
                      }
                    }
                  },
                  child: Stack(
                    children: <Widget>[
                      CardScrollWidget(currentPage, info, tutor),
                      Positioned.fill(
                        child: PageView.builder(
                          itemCount: tutor.length,
                          controller: controller,
                          reverse: true,
                          itemBuilder: (context, index) {
                            return Container();
                          },
                        ),
                      )
                    ],
                  ),
                ),
                Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: 35.0, vertical: 10.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Flexible(
                        child: RichText(
                          textAlign: TextAlign.left,
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: "Cosa sono i tutor ?",
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.8),
                                  fontSize: 30.0,
                                  fontFamily: "CoreSansRounded",
                                  letterSpacing: 1.0,
                                ),
                              ),
                              TextSpan(
                                text: '\n\n' +
                                    'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Fusce viverra scelerisque arcu. Aliquam erat volutpat. Donec eleifend enim in est faucibus viverra. Fusce vel ex sapien. Nam pretium eros ligula, ac hendrerit odio fermentum vitae. Nam sit amet ex sed ex malesuada lacinia vitae ac libero. Phasellus feugiat metus in est faucibus tempor. Phasellus nec ipsum faucibus, luctus lorem vitae, convallis augue. Nulla eleifend libero sem, a congue nibh molestie eget. Vivamus sed turpis eget dui tincidunt rhoncus. Morbi scelerisque purus non enim auctor egestas.',
                                style: TextStyle(
                                  height: 1.3,
                                  color: Colors.white.withOpacity(0.9),
                                  fontSize: 15.0,
                                  fontFamily: "CoreSansRounded",
                                  letterSpacing: 1.0,
                                ),
                              )
                            ],
                          ), // agiungere sotto rispost6e a cosa sono e perché uno dovrebbe provarli/qualki sono in= vantaggi rispetto ad un help/ripetizioni
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ]),
      ),
    );
  }
}

class CardScrollWidget extends StatefulWidget {
  double currentPage;
  bool info;
  var tutor;

  CardScrollWidget(this.currentPage, this.info, this.tutor);

  @override
  _CardScrollWidgetState createState() => _CardScrollWidgetState();
}

class _CardScrollWidgetState extends State<CardScrollWidget> {
  var padding = -20.0;

  var verticalInset = 20.0;

  @override
  Widget build(BuildContext context) {
    return new AspectRatio(
      aspectRatio: widgetAspectRatio,
      child: LayoutBuilder(builder: (context, contraints) {
        var width = contraints.maxWidth;
        var height = contraints.maxHeight;

        var safeWidth = width;
        var safeHeight = height;

        var heightOfPrimaryCard = safeHeight;
        var widthOfPrimaryCard = heightOfPrimaryCard * cardAspectRatio;

        var primaryCardLeft = safeWidth - widthOfPrimaryCard;
        var horizontalInset = primaryCardLeft / 2;

        List<Widget> cardList = new List();

        for (var i = 0; i < widget.tutor.length; i++) {
          keys.add(widget.tutor[i].keys.first);
          var delta = i - widget.currentPage;
          bool isOnRight = delta > 0;

          var start = padding +
              //math.max(
              primaryCardLeft -
              horizontalInset *
                  -delta *
                  (isOnRight ? 15 : math.pow(0.9, -delta));
          //0.0);

          var cardItem = Positioned.directional(
            top: 0, // + verticalInset * math.max(-delta, 0.0),
            bottom: 0, // + verticalInset * math.max(-delta, 0.0),
            start: start,
            textDirection: TextDirection.rtl,
            child: Transform.scale(
              scale: math.pow(0.9, math.max(0, -delta)),
              child: Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(50.0),
                      boxShadow: [
                        BoxShadow(blurRadius: 5, offset: Offset(3, 3))
                      ]),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(50.0), //prima era 16
                    child: Container(
                      child: AspectRatio(
                        aspectRatio: cardAspectRatio,
                        child: Stack(
                          fit: StackFit.expand,
                          children: <Widget>[
                            _backgroung(),
                            Padding(
                              padding: EdgeInsets.only(
                                  top: 50.0, left: 20.0, right: 30.0),
                              child: Align(
                                alignment: Alignment(-1.0, -1.0),
                                child: Row(
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: <Widget>[
                                    Expanded(
                                      flex: 2,
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: <Widget>[
                                          Stack(
                                            children: [
                                              _text(
                                                  widget.tutor[i][keys[i]][0]
                                                      ['nome'],
                                                  15.0),
                                            ],
                                          ),
                                          SizedBox(
                                            height: 6.0,
                                          ),
                                          Text(
                                            widget.tutor[i][keys[i]][0]
                                                ['classe'],
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 15.0,
                                                fontFamily: "CoreSans"),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Expanded(
                                      flex: 1,
                                      child: AnimatedCrossFade(
                                        crossFadeState: !widget.info
                                            ? CrossFadeState.showFirst
                                            : CrossFadeState.showSecond,
                                        layoutBuilder: (Widget topChild,
                                            Key topChildKey,
                                            Widget bottomChild,
                                            Key bottomChildKey) {
                                          // Stacks size themselves according to the non-positioned child.
                                          return Stack(
                                            clipBehavior: Clip.none,
                                            children: <Widget>[
                                              // This is the positioned child (because left, top, right are non-null).
                                              // bottomChild is the one _from which_ we are animating.
                                              SizedBox(
                                                height: 50,
                                                width: 50,
                                                key: bottomChildKey,
                                                child: bottomChild,
                                              ),
                                              // This is the non-positioned child, according to which the Stack will size itself.
                                              // The Positioned is used only because of the Key. Since the left / right / etc.
                                              // arguments are null, stack considers it non-positioned.
                                              SizedBox(
                                                height: 50,
                                                width: 50,
                                                key: topChildKey,
                                                child: topChild,
                                              ),
                                            ],
                                          );
                                        },
                                        firstCurve: Curves.easeOutQuad,
                                        secondCurve: Curves.easeInQuad,
                                        duration: Duration(milliseconds: 350),
                                        firstChild: Icon(
                                            Globals.subjects[keys[i]]['icona'],
                                            size: 45.0,
                                            color: colore1_ombra),
                                        secondChild: Icon(Icons.mail_outline,
                                            size: 45.0, color: colore1_ombra),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            if (widget.tutor[i][keys[i]].length > 1)
                              Padding(
                                padding:
                                    EdgeInsets.only(left: 20.0, right: 30.0),
                                child: Align(
                                  alignment: Alignment(-1.0, 0.0),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.max,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: <Widget>[
                                      Expanded(
                                        flex: 2,
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: <Widget>[
                                            Stack(
                                              children: [
                                                _text(
                                                    widget.tutor[i][keys[i]][1]
                                                        ['nome'],
                                                    15.0),
                                              ],
                                            ),
                                            SizedBox(
                                              height: 6.0,
                                            ),
                                            Text(
                                              widget.tutor[i][keys[i]][1]
                                                  ['classe'],
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 15.0,
                                                  fontFamily: "CoreSans"),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Expanded(
                                        flex: 1,
                                        child: AnimatedCrossFade(
                                          crossFadeState: !widget.info
                                              ? CrossFadeState.showFirst
                                              : CrossFadeState.showSecond,
                                          layoutBuilder: (Widget topChild,
                                              Key topChildKey,
                                              Widget bottomChild,
                                              Key bottomChildKey) {
                                            // Stacks size themselves according to the non-positioned child.
                                            return Stack(
                                              clipBehavior: Clip.none,
                                              children: <Widget>[
                                                // This is the positioned child (because left, top, right are non-null).
                                                // bottomChild is the one _from which_ we are animating.
                                                SizedBox(
                                                  height: 50,
                                                  width: 50,
                                                  key: bottomChildKey,
                                                  child: bottomChild,
                                                ),
                                                // This is the non-positioned child, according to which the Stack will size itself.
                                                // The Positioned is used only because of the Key. Since the left / right / etc.
                                                // arguments are null, stack considers it non-positioned.
                                                SizedBox(
                                                  height: 50,
                                                  width: 50,
                                                  key: topChildKey,
                                                  child: topChild,
                                                ),
                                              ],
                                            );
                                          },
                                          firstCurve: Curves.easeOutQuad,
                                          secondCurve: Curves.easeInQuad,
                                          duration: Duration(milliseconds: 350),
                                          firstChild: Icon(
                                              Globals.subjects[keys[i]]
                                                  ['icona'],
                                              size: 45.0,
                                              color: colore2_ombra),
                                          secondChild: Icon(Icons.mail_outline,
                                              size: 45.0, color: colore2_ombra),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            else
                              Offstage(),
                            widget.tutor[i][keys[i]].length > 2
                                ? Padding(
                                    padding: EdgeInsets.only(
                                        bottom: 50.0, left: 20.0, right: 30.0),
                                    child: Align(
                                      alignment: Alignment(-1.0, 1.0),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.max,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: <Widget>[
                                          Expanded(
                                            flex: 2,
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: <Widget>[
                                                Stack(
                                                  children: [
                                                    _text(
                                                        widget.tutor[i][keys[i]]
                                                            [2]['nome'],
                                                        15.0),
                                                  ],
                                                ),
                                                SizedBox(
                                                  height: 6.0,
                                                ),
                                                Text(
                                                  widget.tutor[i][keys[i]][2]
                                                      ['classe'],
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 15.0,
                                                      fontFamily: "CoreSans"),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Expanded(
                                            flex: 1,
                                            child: AnimatedCrossFade(
                                              layoutBuilder: (Widget topChild,
                                                  Key topChildKey,
                                                  Widget bottomChild,
                                                  Key bottomChildKey) {
                                                // Stacks size themselves according to the non-positioned child.
                                                return Stack(
                                                  clipBehavior: Clip.none,
                                                  children: <Widget>[
                                                    // This is the positioned child (because left, top, right are non-null).
                                                    // bottomChild is the one _from which_ we are animating.
                                                    SizedBox(
                                                      height: 50,
                                                      width: 50,
                                                      key: bottomChildKey,
                                                      child: bottomChild,
                                                    ),
                                                    // This is the non-positioned child, according to which the Stack will size itself.
                                                    // The Positioned is used only because of the Key. Since the left / right / etc.
                                                    // arguments are null, stack considers it non-positioned.
                                                    SizedBox(
                                                      height: 50,
                                                      width: 50,
                                                      key: topChildKey,
                                                      child: topChild,
                                                    ),
                                                  ],
                                                );
                                              },
                                              alignment: Alignment.center,
                                              crossFadeState: !widget.info
                                                  ? CrossFadeState.showFirst
                                                  : CrossFadeState.showSecond,
                                              firstCurve: Curves.easeInQuad,
                                              secondCurve: Curves.decelerate,
                                              duration:
                                                  Duration(milliseconds: 350),
                                              firstChild: Icon(
                                                  Globals.subjects[keys[i]]
                                                      ['icona'],
                                                  size: 45.0,
                                                  color: colore3_ombra),
                                              secondChild: Icon(
                                                  Icons.mail_outline,
                                                  size: 45.0,
                                                  color: colore3_ombra),
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
                    ),
                  )),
            ),
          );
          cardList.add(cardItem);
        }
        return Stack(
          children: cardList,
        );
      }),
    );
  }

  Widget _text(String nome, double FontSize) {
    return Text(
      ((() {
        return nome == 'Pietro Cipriani' ? nome + ' 🔌' : nome; // or ★ ?
      }())),
      softWrap: false,
      style: TextStyle(
          color: Colors.white, fontSize: FontSize, fontFamily: "CoreSans"),
      overflow: TextOverflow.visible,
    );
  }

  Widget _backgroung() {
    return Column(
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
    );
  }
}

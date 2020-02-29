import 'package:Messedaglia/main.dart';
import 'package:Messedaglia/screens/menu_screen.dart';
import 'package:android_intent/android_intent.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class Preferences extends StatelessWidget {
  final TapGestureRecognizer _websiteTap = TapGestureRecognizer()
    ..onTap = () => AndroidIntent(
            action: 'action_view', data: 'https://www.messedaglia.edu.it')
        .launch();
  final TapGestureRecognizer _supportTap = TapGestureRecognizer()
    ..onTap = () => AndroidIntent(
            action: 'action_view', data: 'mailto:messeapp@messedaglia.edu.it?subject=FEEDBACK MESSEAPP&body=$appName ($appVersion) running on $platform $osVersion')
        .launch();

  @override
  Widget build(BuildContext context) => Material(
      color: Theme.of(context).backgroundColor,
      child: CustomScrollView(slivers: <Widget>[
        SliverAppBar(
          centerTitle: true,
          backgroundColor: Colors.transparent,
          pinned: true,
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
            'IMPOSTAZIONI',
            style: Theme.of(context).textTheme.bodyText2,
          ),
          flexibleSpace: CustomPaint(
            painter: BackgroundPainter(Theme.of(context)),
            size: Size.infinite,
          ),
          bottom: PreferredSize(
              child: Container(),
              preferredSize:
                  Size.fromHeight(MediaQuery.of(context).size.width / 8)),
        ),
        SliverList(
          delegate: SliverChildListDelegate(
            [
              Container(
                padding: EdgeInsets.all(20),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                    border: Border.all(width: 0),
                    color: Theme.of(context).primaryColor,
                    shape: BoxShape.circle),
                child: Image.asset(
                  'images/logomesse_scuro.png',
                  width: MediaQuery.of(context).size.width / 2,
                  color: Theme.of(context).backgroundColor,
                  colorBlendMode: BlendMode.xor,
                ),
              ),
              Container(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  alignment: Alignment.center,
                  child: RichText(
                    text: TextSpan(
                        text: '$appName  ',
                        style: Theme.of(context).textTheme.bodyText2,
                        children: [
                          TextSpan(
                              text: '($appVersion)',
                              style: Theme.of(context).textTheme.bodyText1)
                        ]),
                  )),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Expanded(
                      child: Text('WEBSITE:',
                          style: Theme.of(context).textTheme.bodyText1),
                    ),
                    RichText(
                        textAlign: TextAlign.end,
                        text: TextSpan(
                            text: 'www.messedaglia.edu.it',
                            recognizer: _websiteTap,
                            style: TextStyle(
                                color: Theme.of(context).primaryColor,
                                decoration: TextDecoration.underline)))
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Expanded(
                      child: Text('CONTATTA GLI SVILUPPATORI:',
                          style: Theme.of(context).textTheme.bodyText1),
                    ),
                    RichText(
                        textAlign: TextAlign.end,
                        text: TextSpan(
                          recognizer: _supportTap,
                            text: 'messeapp@messedaglia.edu.it',
                            style: TextStyle(
                                color: Theme.of(context).primaryColor,
                                decoration: TextDecoration.underline)))
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Expanded(
                      child: Text('BUGs REPORT:',
                          style: Theme.of(context).textTheme.bodyText1),
                    ),
                    RichText(
                        textAlign: TextAlign.end,
                        text: TextSpan(
                            text: 'link github.com',
                            style: TextStyle(
                                color: Theme.of(context).primaryColor,
                                decoration: TextDecoration.underline)))
                  ],
                ),
              )
            ],
          ),
        )
      ]));
}
